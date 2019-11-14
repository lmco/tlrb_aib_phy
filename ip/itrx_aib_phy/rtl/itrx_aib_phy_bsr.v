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
// Filename       : itrx_aib_phy_bsr.v
// Description    : AIB JTAG BSR (boundary scan register)
//
// ==========================================================================
//
//    $Rev:: 5107                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-06-28 18:54:37 -0400#$: Date of last commit
//
// ==========================================================================

//-----------------------------------------------------------------------------
// JTAG Boundary Cell Registers (BSR) for AIB IO cell.
// See Figure 5-4 module Boundary Scan for a single AIB IO cell.
//
//  + 12 scan DFFs (posedge jtag_clkdr)
//  + 1 output DFF (negedge jtag_clkdr), last stage (to next AIB IO cell).
//  + Clock MUX
//
// Implements AIB Arch Spec:
//   "Figure 5-4: Boundary Scan Chain for Single AIB IO"
//
// SOME IO cell config signals are missing from the IO BSR chain:
//
//  - idat_selb (configure per functional mode for DFT test as in Fig 5-10)
//      (Arch spec depicts as static/tie-off=sync wrt JTAG of TX/RX ubump)
//  - iddr_enable (configure per functional mode for DFT test as in Fig 5-10)
//      (Arch spec depicts as static/tie-off=sync wrt JTAG of RX ubump)
//
//  - weakpdn (has dedicated JTAG instruction to control)
//  - weakpu  (has dedicated JTAG instruction to control)
//-----------------------------------------------------------------------------
//
// "Weak pulldown (iweakpdn) and weak pull-up (iweakpu) control signals to AIB IO can be
// toggled after the deassertion of reset signals to exercise the buffer. They can be
// controlled via configuration bits or via JTAG private instruction"

//lint: Combinatorial flow is expected through the JTAG MUXs.
//lint_checking IOCOMB off

module itrx_aib_phy_bsr (/*AUTOARG*/
   // Outputs
   jtag_scanout, nrml_odat_asyn, nrml_odat1, nrml_odat0, jtag_rxen,
   jtag_txen, jtag_async_data, jtag_idat1, jtag_idat0,
   // Inputs
   jtag_intest, jtag_scan_en, jtag_clkdr, jtag_mode, jtag_scanin,
   rmux_odat_asyn, rmux_oclk, rmux_oclk_b, rmux_odat1, rmux_odat0,
   nrml_rxen, nrml_txen, nrml_async_data, nrml_idat1, nrml_idat0
   );

// input  jtag_rstn; // defaults to 1 upon power up
input  jtag_intest;
input  jtag_scan_en;
// input  jtag_clksel;
input  jtag_clkdr;
input  jtag_mode;
input  jtag_scanin;
// input  jtag_rstn_en;

output reg jtag_scanout;


//------------------------------------------------------------------------------
// In DR order
//
// From IO cell directly (before JTAG)
input                   rmux_odat_asyn;
// From IO cell directly (before JTAG)
input                   rmux_oclk;
input                   rmux_oclk_b;
// From redun mux
input                   rmux_odat1;
input                   rmux_odat0;

// From IO cell (after JTAG)
output                  nrml_odat_asyn;
output                  nrml_odat1;
output                  nrml_odat0;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// To IO cell (before JTAG); before redundancy MUX
input [2:0]             nrml_rxen;
input                   nrml_txen;
input                   nrml_async_data;
input                   nrml_idat1;
input                   nrml_idat0;
//input                   adap_irstb;

// To IO redn muxes (after JTAG)
output [2:0]            jtag_rxen;
output                  jtag_txen;
output                  jtag_async_data;
output                  jtag_idat1;
output                  jtag_idat0;
//output                  irstb;
//------------------------------------------------------------------------------

wire [1:0]               nrml_idat;              // To u1_idat of itrx_aib_phy_out_bc.v, ...
wire [1:0]               si_idat;                // To u1_idat of itrx_aib_phy_out_bc.v, ...
wire [2:0]               si_rxen;                // To u0_rxen of itrx_aib_phy_out_bc.v, ...

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [1:0]              jtag_idat;              // From u1_idat of itrx_aib_phy_out_bc.v, ...
wire                    so_async_data;          // From uy_async_data of itrx_aib_phy_out_bc.v
wire [1:0]              so_idat;                // From u1_idat of itrx_aib_phy_out_bc.v, ...
wire                    so_oclk;                // From u_oclk of itrx_aib_phy_clk_bc.v
wire                    so_oclk_b;              // From u_oclk_b of itrx_aib_phy_clk_bc.v
wire                    so_odat0;               // From u_odat0 of itrx_aib_phy_in_bc.v
wire                    so_odat1;               // From u_odat1 of itrx_aib_phy_in_bc.v
wire                    so_odat_asyn;           // From u_odat_asyn of itrx_aib_phy_in_bc.v
wire [2:0]              so_rxen;                // From u0_rxen of itrx_aib_phy_out_bc.v, ...
wire                    so_txen;                // From ux_txen of itrx_aib_phy_out_bc.v
// End of automatics

/*AUTOREGINPUT*/

//assign irstb = jtag_rstn_en ? jtag_rstn : adap_irstb;

/* itrx_aib_phy_in_bc AUTO_TEMPLATE (
    .s\(.*\)  (s\1_@"(substring vl-cell-name 2)"),
    .d_o      (nrml_@"(substring vl-cell-name 2)"),
    .d_i      (rmux_@"(substring vl-cell-name 2)"),
  ); */

// BIT 0
wire si_odat_asyn = so_oclk;

itrx_aib_phy_in_bc
  u_odat_asyn(/*AUTOINST*/
              // Outputs
              .d_o                      (nrml_odat_asyn),        // Templated
              .so                       (so_odat_asyn),          // Templated
              // Inputs
              .jtag_clkdr               (jtag_clkdr),
              .jtag_scan_en             (jtag_scan_en),
              .jtag_intest              (jtag_intest),
              .d_i                      (rmux_odat_asyn),        // Templated
              .si                       (si_odat_asyn));                 // Templated

/* itrx_aib_phy_clk_bc AUTO_TEMPLATE (
    .s\(.*\)  (s\1_@"(substring vl-cell-name 2)"),
    .d_i      (rmux_@"(substring vl-cell-name 2)"),
  ); */

// BIT 1
wire si_oclk = so_oclk_b;

itrx_aib_phy_clk_bc
  u_oclk(/*AUTOINST*/
         // Outputs
         .so                            (so_oclk),               // Templated
         // Inputs
         .jtag_clkdr                    (jtag_clkdr),
         .jtag_scan_en                  (jtag_scan_en),
         .d_i                           (rmux_oclk),             // Templated
         .si                            (si_oclk));              // Templated

// BIT 2
wire si_oclk_b = so_odat1;

itrx_aib_phy_clk_bc
 u_oclk_b(/*AUTOINST*/
          // Outputs
          .so                           (so_oclk_b),             // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .d_i                          (rmux_oclk_b),           // Templated
          .si                           (si_oclk_b));            // Templated

// BIT 3
wire si_odat1 = so_odat0;

itrx_aib_phy_in_bc
  u_odat1(/*AUTOINST*/
          // Outputs
          .d_o                          (nrml_odat1),            // Templated
          .so                           (so_odat1),              // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_intest                  (jtag_intest),
          .d_i                          (rmux_odat1),            // Templated
          .si                           (si_odat1));             // Templated

// BIT 4
wire si_odat0 = so_rxen[0];

itrx_aib_phy_in_bc
  u_odat0(/*AUTOINST*/
          // Outputs
          .d_o                          (nrml_odat0),            // Templated
          .so                           (so_odat0),              // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_intest                  (jtag_intest),
          .d_i                          (rmux_odat0),            // Templated
          .si                           (si_odat0));             // Templated

/* itrx_aib_phy_out_bc AUTO_TEMPLATE (
    .s\(.*\)  (s\1_@"(substring vl-cell-name 3)"[@]),
    .d_i      (nrml_@"(substring vl-cell-name 3)"[@]),
    .d_o      (jtag_@"(substring vl-cell-name 3)"[@]),
  ); */

// BIT 5
assign si_rxen[0] = so_rxen[1];

itrx_aib_phy_out_bc
  u0_rxen(/*AUTOINST*/
          // Outputs
          .d_o                          (jtag_rxen[0]),          // Templated
          .so                           (so_rxen[0]),            // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_intest                  (jtag_intest),
          .jtag_mode                    (jtag_mode),
          .d_i                          (nrml_rxen[0]),          // Templated
          .si                           (si_rxen[0]));           // Templated

// BIT 6
assign si_rxen[1] = so_rxen[2];

itrx_aib_phy_out_bc
  u1_rxen(/*AUTOINST*/
          // Outputs
          .d_o                          (jtag_rxen[1]),          // Templated
          .so                           (so_rxen[1]),            // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_intest                  (jtag_intest),
          .jtag_mode                    (jtag_mode),
          .d_i                          (nrml_rxen[1]),          // Templated
          .si                           (si_rxen[1]));           // Templated

// BIT 7
assign si_rxen[2] = so_txen;

itrx_aib_phy_out_bc
  u2_rxen(/*AUTOINST*/
          // Outputs
          .d_o                          (jtag_rxen[2]),          // Templated
          .so                           (so_rxen[2]),            // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_intest                  (jtag_intest),
          .jtag_mode                    (jtag_mode),
          .d_i                          (nrml_rxen[2]),          // Templated
          .si                           (si_rxen[2]));           // Templated

// BIT 8
wire si_txen = so_async_data;

itrx_aib_phy_out_bc
  ux_txen(/*AUTOINST*/
          // Outputs
          .d_o                          (jtag_txen),             // Templated
          .so                           (so_txen),               // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_intest                  (jtag_intest),
          .jtag_mode                    (jtag_mode),
          .d_i                          (nrml_txen),             // Templated
          .si                           (si_txen));              // Templated

// BIT 9
wire si_async_data = so_idat[1];

itrx_aib_phy_out_bc
  uy_async_data(/*AUTOINST*/
                // Outputs
                .d_o                    (jtag_async_data),       // Templated
                .so                     (so_async_data),         // Templated
                // Inputs
                .jtag_clkdr             (jtag_clkdr),
                .jtag_scan_en           (jtag_scan_en),
                .jtag_intest            (jtag_intest),
                .jtag_mode              (jtag_mode),
                .d_i                    (nrml_async_data),       // Templated
                .si                     (si_async_data));        // Templated

// BIT 10
assign  si_idat[1] = so_idat[0];

assign nrml_idat[1] = nrml_idat1;
assign jtag_idat1 = jtag_idat[1];

itrx_aib_phy_out_bc
  u1_idat(/*AUTOINST*/
          // Outputs
          .d_o                          (jtag_idat[1]),          // Templated
          .so                           (so_idat[1]),            // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_intest                  (jtag_intest),
          .jtag_mode                    (jtag_mode),
          .d_i                          (nrml_idat[1]),          // Templated
          .si                           (si_idat[1]));           // Templated
// BIT 11
assign si_idat[0] = jtag_scanin; // First boundary cell of the chain (IDAT0).

assign nrml_idat[0] = nrml_idat0;
assign jtag_idat0 = jtag_idat[0];

itrx_aib_phy_out_bc
  u0_idat(/*AUTOINST*/
          // Outputs
          .d_o                          (jtag_idat[0]),          // Templated
          .so                           (so_idat[0]),            // Templated
          // Inputs
          .jtag_clkdr                   (jtag_clkdr),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_intest                  (jtag_intest),
          .jtag_mode                    (jtag_mode),
          .d_i                          (nrml_idat[0]),          // Templated
          .si                           (si_idat[0]));           // Templated

//lint: Flip-flop 'jtag_scanout' does not have any set or reset.
//lint: Flip-flop 'jtag_scanout' is triggered at the negative edge of clock 'jtag_clkdr'.
//lint_checking NEFLOP FFWNSR off
always @(negedge jtag_clkdr) begin
  jtag_scanout <= so_odat_asyn;
end
//lint_checking NEFLOP FFWNSR on

endmodule
