// DISTRIBUTION STATEMENT A. Approved for public release.
//
// The views, opinions and/or findings expressed are those of the author and
// should not be interpreted as representing the official views or policies of
// the Department of Defense or the U.S. Government.
//
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
// Original Author: Intrinsix Corporation
// Filename       : itrx_aib_phy_jtag_clkdr.v
// Description    : Generate Intel AIB gated jtag_clkdr
//
// ==========================================================================
//
//    $Rev:: 5263                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-10-24 15:12:17 -0400#$: Date of last commit
//
// ==========================================================================

/*
Intel AIB Spec v1.0:

5.8 Jtag_clkdr Gated Clocking
JTAG_CLKDR is a gated clock that only toggles 

[1]  during Transmit Mode (where jtag_clksel is enabled) and 
[2]  during Shift Mode. 
[3]  Apart from that, user will need to
     cycle the JTAG controller into SHIFT_DR state in order 
     to have JTAG_CLKDR toggling.
*/

//lint: comb path tck to jtag_clkdr
//lint_checking IOCOMB CLKUCL off
module itrx_aib_phy_jtag_clkdr (/*AUTOARG*/
   // Outputs
   jtag_clkdr,
   // Inputs
   tck, reset_n, state_shift_dr_p, ir_latched
   );
//lint_checking IOCOMB on

parameter LATCHED_IR_WID = 32'd7;

input        tck;              // JTAG TCK
input        reset_n;          // JTAG reset

input        state_shift_dr_p; // From JTAG state machine
input  [LATCHED_IR_WID-1:0] ir_latched;  // Instruction reg from JTAG SM

output       jtag_clkdr;       // Clock to AIB BSR

localparam AIB_TRANSMIT_EN = 7'b000_1110;
localparam AIB_SHIFT_EN    = 7'b000_1100;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    tap_clk_dr;             // From u_tap_clk_dr of itrx_aib_phy_stdcell_icg.v
// End of automatics

reg jtag_clkdr_en; // [1] or [2]
reg tap_clk_dr_en; // [3]

always @(posedge tck or negedge reset_n) begin
  if (!reset_n) begin
   /*AUTORESET*/
   // Beginning of autoreset for uninitialized flops
   jtag_clkdr_en <= 1'h0;
   tap_clk_dr_en <= 1'h0;
   // End of automatics
    end
  else begin
    tap_clk_dr_en <= state_shift_dr_p;

    jtag_clkdr_en <= (ir_latched == AIB_TRANSMIT_EN) | 
                     (ir_latched == AIB_SHIFT_EN); 
  end
end

//------------------------------------------------------------------------------
// Falling edge setup/hold (ena wrt clk) ICG standard cell clock gate instances
// Intel AIB Spec: jtag_clkdr defaults to 1.
// The outputs of clock gates below are high unless enabled (active JTAG).
//

wire icg_scan_mode = 1'b0;

/*
itrx_aib_phy_stdcell_icg AUTO_TEMPLATE (
  .clk_o     (@"(substring vl-cell-name 2)"),
  .ena       (@"(substring vl-cell-name 2)"_en),
  .scan_mode (icg_scan_mode),
  ); */

//lint_checking DIFCLK off
itrx_aib_phy_stdcell_icg 
  u_tap_clk_dr (.clk                    (tck), // Input clock
                /*AUTOINST*/
                // Outputs
                .clk_o                  (tap_clk_dr),            // Templated
                // Inputs
                .scan_mode              (icg_scan_mode),         // Templated
                .ena                    (tap_clk_dr_en));        // Templated

itrx_aib_phy_stdcell_icg 
  u_jtag_clkdr (.clk                    (tap_clk_dr), // Input clock
                /*AUTOINST*/
                // Outputs
                .clk_o                  (jtag_clkdr),            // Templated
                // Inputs
                .scan_mode              (icg_scan_mode),         // Templated
                .ena                    (jtag_clkdr_en));        // Templated
//lint_checking DIFCLK on
//------------------------------------------------------------------------------

endmodule
