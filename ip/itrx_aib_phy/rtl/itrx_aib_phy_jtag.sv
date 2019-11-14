// Copyright 2019 © Lockheed Martin Corporation
// Copyright 2019 © Intrinsix Corp.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ==========================================================================
// Original Author: Intrinsix Corp.
// Filename       : itrx_aib_phy_jtag.sv
// Description    : JTAG TAP controller for AIB IO Channel(s)
//
// Instantiates   : dbg_test_jtagsm         u_jtagsm (TAP SM RTL from Intel)
//                  itrx_aib_phy_bscan      u_itrx_aib_phy_bscan
//                  itrx_aib_phy_jtag_clkdr u_itrx_aib_phy_jtag_clkdr
// ==========================================================================
//
//    $Rev:: 5810                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-06-24 16:29:21 -0400#$: Date of last commit
//
// ==========================================================================

//lint: jtag_scan_out from AIB IO channel combinatorially (MUX) drive tdo.
//lint_checking IOCOMB off
module itrx_aib_phy_jtag (/*AUTOARG*/
   // Outputs
   tdo, jtag_clkdr, jtag_clksel, jtag_intest, jtag_mode, jtag_rstn,
   jtag_rstn_en, jtag_scan_en, jtag_weakpd, jtag_weakpu,
   // Inputs
   tck, tms, tdi, trstn_or_por_rstn, jtag_scan_out
   );
//lint_checking IOCOMB on


// Standard, required JTAG pins
//
input  tck;
input  tms;
input  tdi;
output tdo;

// The IEEE 1149.1 standard has a "reset at power-up" requirement.
// Inclusion of the optional TRST* (TRSTN) pin meets this requirement.
// Also, a POR signal from the system may be used to meet this requirement.
// The input signal "trstn_or_por_rstn" can either be
// driven by TRST*, or a POR reset signal (on-chip) from the system.
// The Intel AIB standard does not explicitly include or require the TRST* pin.
//
input  trstn_or_por_rstn;

// Signals (jtag_*) to the AIB IO channel(s)
//
output                    jtag_clkdr;
output                    jtag_clksel;
output                    jtag_intest;
output                    jtag_mode;
output                    jtag_rstn;
output                    jtag_rstn_en;
output                    jtag_scan_en;
output                    jtag_weakpd;
output                    jtag_weakpu;

// AIB IO channel(s) JTAG test data register data
//
input                     jtag_scan_out; // data from AIB IO channel

// Test data input (TDI) also goes directly to AIB IO JTAG (jtag_scan_in) input.
//

// From:
//   /projects/lmat101/vendor_lib/aib_full_05_30/c3dfx/rtl/tap/tb_adapt_wrap_unit.sv
//

/*
IEEE 1149.1 Std:

The instruction shifted into the instruction register is latched onto the parallel
output from the shift-register path on the falling edge of TCK in this controller state.
Once the new instruction has been latched, it becomes the current instruction.
*/

// Parameters for Intel JTAGSM module:
//
localparam LATCHED_IR_WID = 32'd7; // Width of Latched IR (latched_ir)
localparam TOTAL_IR_SIZE = 32'd7;

/*AUTOREGINPUT*/

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    capture_dr;             // From u_jtagsm of `AIB_JTAGSM.v
wire [LATCHED_IR_WID-1:0] ir_latched;           // From u_jtagsm of `AIB_JTAGSM.v
wire                    shift_dr;               // From u_jtagsm of `AIB_JTAGSM.v
wire                    shift_ir;               // From u_jtagsm of `AIB_JTAGSM.v
wire                    state_shift_dr_p;       // From u_jtagsm of `AIB_JTAGSM.v
wire                    tdo_ir;                 // From u_jtagsm of `AIB_JTAGSM.v
wire                    test_logic_reset;       // From u_jtagsm of `AIB_JTAGSM.v
wire                    update_dr;              // From u_jtagsm of `AIB_JTAGSM.v
wire                    update_ir;              // From u_jtagsm of `AIB_JTAGSM.v
// End of automatics

/*

The jtagsm module implements a STANDARD JTAG State Machine.

resetn is a negative edge async reset input.

next_state wire and current_state reg are updated.
next_state depends only on the current_state and tms.

current state is reset only by resetn.
current state is updated with next_state on the POSitive edge of tck.

current_state reg is combinatorially decode-ed to generate one of the following output ports:

  o shift_ir
  o shift_dr
  o capture_dr
  o update_ir
  o update_dr
  o test_logic_reset

However, not all of these standard decoded outputs are used at the level above.

IF the current_state decodes to shift_ir (SHIFT_IR), then
a 7-bit (parameter-ized width) INTERNAL instruction register ("ir") is loaded and shifted right on the
POSitive edge of tck.  TDI is loaded into the MS bit, and TDO is the LS bit [0].
The internal ir reset is also reset by the resetn input.

IF the current_state decodes to update_ir (UPDATE-IR), then
a 7-bit (parameter-ized width) instruction register ("instruction") output is loaded
with the LS bits of the ir internal register on the NEGATIVE/falling edge of tck.
This is the "latched" instruction register.

A combinatorial output (state_shift_dr_p) is generated when the
NEXT state (next_state) decodes to SHIFT-DR.
Again, the NEXT state is a combinatorial function of TMS and the CURRENT state.
This combinatorial output is used to enable the clkdr to the BSR.
It is a clock gate enable signal.

In summary, the 7-bit "instruction" output port is a FALLING edge of tck output representing
the LS bits of the internal 7-bit instruction register that was updated in the UPDATE-IR
state.

*/

//lint_checking DIFRST off

// Macro define `ITRX_AIB_JTAGSM selects
// use of Intrinsix version of the JTAG state machine
// versus the Intel AIB CR3 Legacy version.
// The TLRB AIB PHY was implemented with
// the Intel version to save time porting and
// checking the state machine code.
// Future implementations may want to use ITRX version.

//lint: Compiler directive `define should not be used.
//      `define statement is not undefined using `undef
//lint_checking NODEFD NOUNDF off
`ifdef ITRX_AIB_JTAGSM
  `define AIB_JTAGSM itrx_aib_phy_jtagsm
`else
  `define AIB_JTAGSM dbg_test_jtagsm
`endif
//lint_checking NODEFD NOUNDF on

/*
`AIB_JTAGSM AUTO_TEMPLATE  (
              .tdo                  (tdo_ir),
              .reset_n              (trstn_or_por_rstn),
              .instruction          (ir_latched[]),
  ); */


 `AIB_JTAGSM
   #(.TOTAL_IR_SIZE(TOTAL_IR_SIZE), .EFF_IR_SIZE(LATCHED_IR_WID))
    u_jtagsm (/*AUTOINST*/
              // Outputs
              .tdo                      (tdo_ir),                // Templated
              .update_ir                (update_ir),
              .update_dr                (update_dr),
              .capture_dr               (capture_dr),
              .shift_ir                 (shift_ir),
              .shift_dr                 (shift_dr),
              .test_logic_reset         (test_logic_reset),
              .instruction              (ir_latched[LATCHED_IR_WID-1:0]), // Templated
              .state_shift_dr_p         (state_shift_dr_p),
              // Inputs
              .tck                      (tck),
              .tms                      (tms),
              .reset_n                  (trstn_or_por_rstn),     // Templated
              .tdi                      (tdi));

//lint_checking DIFRST on

/*

In the bscan module, the input ir "instruction" port (negedge of tck) is decoded
to a set of pre_<INST>_en or pre_<INST>_dis internal wires.

Each of the pre_<INST>_en or pre_<INST>_dis internal wires then either sets (_en)
clears (_dis) one of the following corresponding output registers on the
POSITIVE edge of tck:

  o jtag_clksel        default=0
  o jtag_tx_scan_en    default=0
  o jtag_mode          default=0
  o jtag_weakpu_en     default=0
  o jtag_weakpdn_en    default=0
  o jtag_rstb_en       default=0
  o jtag_rstb          default=1
  o jtag_intest        default=0

*/

/*
itrx_aib_phy_bscan AUTO_TEMPLATE  (
             .reset_n        (trstn_or_por_rstn),
             .jtag_weakpdn   (jtag_weakpd),
 ); */

//lint_checking DIFRST off
itrx_aib_phy_bscan
  u_itrx_aib_phy_bscan (/*AUTOINST*/
                        // Outputs
                        .jtag_scan_en   (jtag_scan_en),
                        .jtag_rstn_en   (jtag_rstn_en),
                        .jtag_rstn      (jtag_rstn),
                        .jtag_mode      (jtag_mode),
                        .jtag_clksel    (jtag_clksel),
                        .jtag_weakpu    (jtag_weakpu),
                        .jtag_weakpdn   (jtag_weakpd),           // Templated
                        .jtag_intest    (jtag_intest),
                        // Inputs
                        .tck            (tck),
                        .reset_n        (trstn_or_por_rstn),     // Templated
                        .ir_latched     (ir_latched[LATCHED_IR_WID-1:0]));

/*
itrx_aib_phy_jtag_clkdr AUTO_TEMPLATE  (
             .reset_n        (trstn_or_por_rstn),
 ); */

itrx_aib_phy_jtag_clkdr
  u_itrx_aib_phy_jtag_clkdr (/*AUTOINST*/
                             // Outputs
                             .jtag_clkdr        (jtag_clkdr),
                             // Inputs
                             .tck               (tck),
                             .reset_n           (trstn_or_por_rstn), // Templated
                             .state_shift_dr_p  (state_shift_dr_p),
                             .ir_latched        (ir_latched[LATCHED_IR_WID-1:0]));
//lint_checking DIFRST on


/*

IEEE BOUNDARY-SCAN ARCHITECTURE Std 1149.1-2001

Rule 4.4.1 b) is included so that open-circuit faults in the board-level serial test data path cause a defined
logic value to be shifted into the test logic. Note that when this constant value is shifted into the instruction
register, the bypass register will be selected (as will be discussed further in 8.4). For TTL-compatible
designs, this rule may be met by inclusion of a pull-up resistor in the component's TDI input circuitry

b) The design of the circuitry fed from TDI shall be such that an undriven input produces a logical
response identical to the application of a logic 1.

*/

localparam BYPASS = {LATCHED_IR_WID{1'b1}}; // 7'b111_1111;

reg tdo_bypass_rg;

//lint: Both edges of clock signal 'tck' used.
//lint_checking EDGMIX off

always @ (posedge tck or negedge trstn_or_por_rstn) begin
  if (!trstn_or_por_rstn) begin
    tdo_bypass_rg <= 1'b0;
  end else begin
    if (test_logic_reset) begin
      tdo_bypass_rg <= 1'b0;
    end else if ((ir_latched == BYPASS) && capture_dr) begin
      tdo_bypass_rg <= 1'b0;
    end else if ((ir_latched == BYPASS) && shift_dr) begin
      tdo_bypass_rg <= tdi;
    end
  end
end

// "Changes in the state of the signal driven through TDO shall occur only on the falling edge of TCK"
//
localparam AIB_SHIFT_EN = 7'b000_1100;

reg tdo_fall_rg;

//lint: Flip-flop is triggered at the negative edge of clock.
//lint_checking NEFLOP off
always @(negedge tck or negedge trstn_or_por_rstn) begin
  if (!trstn_or_por_rstn) begin
    tdo_fall_rg <= 1'b0;
  end else begin
    tdo_fall_rg <= shift_ir ? tdo_ir : tdo_bypass_rg;
  end
end
//lint_checking NEFLOP on
//lint_checking EDGMIX on

assign tdo = (ir_latched == AIB_SHIFT_EN) ? jtag_scan_out : tdo_fall_rg;

wire unused_ok = &{
                   update_ir,
                   update_dr,
                   1'b1};

endmodule

// Local Variables:
// verilog-library-files:("/projects/lmat101/vendor_lib/aib_full_05_30/c3dfx/rtl/tap/dbg_test_jtagsm.v" "itrx_aib_phy_jtagsm.v")
// verilog-auto-inst-param-value:t
// eval:(verilog-read-defines)
// End:
