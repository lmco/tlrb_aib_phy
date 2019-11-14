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
// Filename       : itrx_aib_phy_io_cell.v
// Description    : AIB IO Cell (Instantiates BSR, Redundancy, IO Buffer)
//
// ==========================================================================
//
//    $Rev:: 5810                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-06-24 16:29:21 -0400#$: Date of last commit
//
// ==========================================================================
// Instantiate BSR, Redundancy MUXs, and AIB IO Buffer modules
//
//lint: paths to odat outputs are expected combinatorial (redn muxes)
//lint_checking IOCOMB off
module itrx_aib_phy_io_cell(/*AUTOARG*/
   // Outputs
   jtag_scanout, jtag_clkdr_n, jtag_async_data, jtag_idat0,
   jtag_idat1, oclk, oclk_b, rmux_oclk, rmux_oclk_b, nrml_odat0,
   odat0, nrml_odat1, odat1, nrml_odat_asyn, odat_asyn,
   // Inouts
   ubump,
   // Inputs
   por_vcc_io, por_vcc_dig, iclkn, inclk, inclk_dist, redn_engage,
   prev_redn_engage, spare_mode, redn_any, irstb, tx_irstb, rx_irstb,
   jtag_clkdr, jtag_clksel, jtag_intest, jtag_mode, jtag_scan_en,
   jtag_scanin, jtag_weakpdn, jtag_weakpu, nrml_ilaunch_clk,
   nrml_async_data, nrml_idat0, nrml_idat1, nrml_idat_selb,
   nrml_iddr_enable, nrml_indrv, nrml_ipdrv, nrml_rxen, nrml_txen,
   redn_ilaunch_clk, redn_async_data, redn_idat0, redn_idat1,
   redn_rxen, redn_txen, redn_idat_selb, redn_iddr_enable, redn_indrv,
   redn_ipdrv, redn_oclk, redn_oclk_b, redn_odat0, redn_odat1,
   redn_odat_asyn
   );

input                    por_vcc_io;
input                    por_vcc_dig;

// IO to/from MicroBump, adjacent MicroBump
//
//lint: ubump is inout, ubump is multi-driven
//lint_checking IOPNTA MULWIR off
/*
inout                   vcc_dig;
inout                   vcc_io;
inout                   vss_ana;
*/


inout                   ubump;
//lint_checking IOPNTA MULWIR off

input                   iclkn;

// RX clock Inputs
//
input                   inclk;
input                   inclk_dist;

input                   redn_engage;
input                   prev_redn_engage;
input                   spare_mode;
input                   redn_any;         // Any Redundancy engaged

// Reset Inputs
//
input                   irstb;
input                   tx_irstb;
input                   rx_irstb;

// JTAG I/O
//
input                   jtag_clkdr;
input                   jtag_clksel;
input                   jtag_intest;
input                   jtag_mode;
input                   jtag_scan_en;
input                   jtag_scanin;
input                   jtag_weakpdn;
input                   jtag_weakpu;
output                  jtag_scanout;
output                  jtag_clkdr_n;

assign jtag_clkdr_n = ~jtag_clkdr; // UNUSED

// Normal    TX clock, data and Config Inputs
//
input                   nrml_ilaunch_clk;
input                   nrml_async_data;
input                   nrml_idat0;
input                   nrml_idat1;

input                   nrml_idat_selb;
input                   nrml_iddr_enable;
input [1:0]             nrml_indrv;
input [1:0]             nrml_ipdrv;
input [2:0]             nrml_rxen;
input                   nrml_txen;

// Redundant TX clock, data and Config Inputs
//
input                   redn_ilaunch_clk;

input                   redn_async_data;
input                   redn_idat0;
input                   redn_idat1;
input  [2:0]            redn_rxen;
input                   redn_txen;

// To other AIB IO cell redundant input (sourced by JTAG BSR module)
//
output                  jtag_async_data;
output                  jtag_idat0;
output                  jtag_idat1;

input                   redn_idat_selb;
input                   redn_iddr_enable;
input [1:0]             redn_indrv;
input [1:0]             redn_ipdrv;

// RX clock Outputs
//
output                  oclk;             // Direct from AIB IO Buffer
output                  oclk_b;

input                    redn_oclk;       // Redun input from other Cell
input                    redn_oclk_b;

output                   rmux_oclk;       // After Redun MUX
output                   rmux_oclk_b;


// RX data Outputs (and redundant Inputs)
//
output                  nrml_odat0;
output                       odat0;
input                   redn_odat0;

output                  nrml_odat1;
output                       odat1;
input                   redn_odat1;

output                  nrml_odat_asyn;
output                       odat_asyn;
input                   redn_odat_asyn;

parameter AIB_IS_LEGACY = 1'b0; // =0 for AIB Architecture Spec implementations
                                // =1 for AIB Legacy implementations

// Assert iredrstb (low) if Broken AIB OR input irstb is asserted low.
//
// Broken/Bad AIB = redn_engage AND (NOT previous redn_engage)
//            = 1st AIB IO cell engaged in the redundancy chain
//
wire bad_ubump_link = redn_engage & (~prev_redn_engage);

wire iredrstb = ~( bad_ubump_link | ((~redn_any) & spare_mode) |
                   (~irstb) );

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    async_data;             // From u_redn of itrx_aib_phy_redn.v
wire                    idat0;                  // From u_redn of itrx_aib_phy_redn.v
wire                    idat1;                  // From u_redn of itrx_aib_phy_redn.v
wire                    idat_selb;              // From u_redn of itrx_aib_phy_redn.v
wire                    iddr_enable;            // From u_redn of itrx_aib_phy_redn.v
wire [1:0]              indrv;                  // From u_redn of itrx_aib_phy_redn.v
wire [1:0]              ipdrv;                  // From u_redn of itrx_aib_phy_redn.v
wire [2:0]              jtag_rxen;              // From u_bsr of itrx_aib_phy_bsr.v
wire                    jtag_txen;              // From u_bsr of itrx_aib_phy_bsr.v
wire                    rmux_odat0;             // From u_redn of itrx_aib_phy_redn.v
wire                    rmux_odat1;             // From u_redn of itrx_aib_phy_redn.v
wire                    rmux_odat_asyn;         // From u_redn of itrx_aib_phy_redn.v
wire [2:0]              rxen;                   // From u_redn of itrx_aib_phy_redn.v
wire                    txen;                   // From u_redn of itrx_aib_phy_redn.v
// End of automatics

/*AUTOREGINPUT*/

itrx_aib_phy_bsr
  u_bsr (/*AUTOINST*/
         // Outputs
         .jtag_scanout                  (jtag_scanout),
         .nrml_odat_asyn                (nrml_odat_asyn),
         .nrml_odat1                    (nrml_odat1),
         .nrml_odat0                    (nrml_odat0),
         .jtag_rxen                     (jtag_rxen[2:0]),
         .jtag_txen                     (jtag_txen),
         .jtag_async_data               (jtag_async_data),
         .jtag_idat1                    (jtag_idat1),
         .jtag_idat0                    (jtag_idat0),
         // Inputs
         .jtag_intest                   (jtag_intest),
         .jtag_scan_en                  (jtag_scan_en),
         .jtag_clkdr                    (jtag_clkdr),
         .jtag_mode                     (jtag_mode),
         .jtag_scanin                   (jtag_scanin),
         .rmux_odat_asyn                (rmux_odat_asyn),
         .rmux_oclk                     (rmux_oclk),
         .rmux_oclk_b                   (rmux_oclk_b),
         .rmux_odat1                    (rmux_odat1),
         .rmux_odat0                    (rmux_odat0),
         .nrml_rxen                     (nrml_rxen[2:0]),
         .nrml_txen                     (nrml_txen),
         .nrml_async_data               (nrml_async_data),
         .nrml_idat1                    (nrml_idat1),
         .nrml_idat0                    (nrml_idat0));

itrx_aib_phy_redn
  u_redn (/*AUTOINST*/
          // Outputs
          .rmux_oclk                    (rmux_oclk),
          .rmux_oclk_b                  (rmux_oclk_b),
          .idat0                        (idat0),
          .idat1                        (idat1),
          .async_data                   (async_data),
          .rxen                         (rxen[2:0]),
          .txen                         (txen),
          .iddr_enable                  (iddr_enable),
          .idat_selb                    (idat_selb),
          .ipdrv                        (ipdrv[1:0]),
          .indrv                        (indrv[1:0]),
          .rmux_odat0                   (rmux_odat0),
          .rmux_odat1                   (rmux_odat1),
          .rmux_odat_asyn               (rmux_odat_asyn),
          // Inputs
          .oclk                         (oclk),
          .oclk_b                       (oclk_b),
          .redn_oclk                    (redn_oclk),
          .redn_oclk_b                  (redn_oclk_b),
          .redn_engage                  (redn_engage),
          .spare_mode                   (spare_mode),
          .jtag_mode                    (jtag_mode),
          .nrml_idat0                   (nrml_idat0),
          .nrml_idat1                   (nrml_idat1),
          .nrml_async_data              (nrml_async_data),
          .nrml_rxen                    (nrml_rxen[2:0]),
          .nrml_txen                    (nrml_txen),
          .redn_idat0                   (redn_idat0),
          .redn_idat1                   (redn_idat1),
          .redn_async_data              (redn_async_data),
          .redn_rxen                    (redn_rxen[2:0]),
          .redn_txen                    (redn_txen),
          .jtag_idat0                   (jtag_idat0),
          .jtag_idat1                   (jtag_idat1),
          .jtag_async_data              (jtag_async_data),
          .jtag_rxen                    (jtag_rxen[2:0]),
          .jtag_txen                    (jtag_txen),
          .nrml_iddr_enable             (nrml_iddr_enable),
          .redn_iddr_enable             (redn_iddr_enable),
          .nrml_idat_selb               (nrml_idat_selb),
          .redn_idat_selb               (redn_idat_selb),
          .nrml_ipdrv                   (nrml_ipdrv[1:0]),
          .redn_ipdrv                   (redn_ipdrv[1:0]),
          .nrml_indrv                   (nrml_indrv[1:0]),
          .redn_indrv                   (redn_indrv[1:0]),
          .redn_odat0                   (redn_odat0),
          .odat0                        (odat0),
          .redn_odat1                   (redn_odat1),
          .odat1                        (odat1),
          .redn_odat_asyn               (redn_odat_asyn),
          .odat_asyn                    (odat_asyn));

/*
itrx_aib_phy_io_buf AUTO_TEMPLATE (
  .iweak\(.*\) (jtag_weak\1),
); */

itrx_aib_phy_io_buf #(.AIB_IS_LEGACY(AIB_IS_LEGACY))
  u_io_buf (/*AUTOINST*/
            // Outputs
            .oclk                       (oclk),
            .oclk_b                     (oclk_b),
            .odat0                      (odat0),
            .odat1                      (odat1),
            .odat_asyn                  (odat_asyn),
            // Inouts
            .ubump                      (ubump),
            // Inputs
            .por_vcc_io                 (por_vcc_io),
            .por_vcc_dig                (por_vcc_dig),
            .jtag_clksel                (jtag_clksel),
            .jtag_clkdr                 (jtag_clkdr),
            .nrml_ilaunch_clk           (nrml_ilaunch_clk),
            .redn_ilaunch_clk           (redn_ilaunch_clk),
            .redn_engage                (redn_engage),
            .async_data                 (async_data),
            .iclkn                      (iclkn),
            .idat0                      (idat0),
            .idat1                      (idat1),
            .idat_selb                  (idat_selb),
            .iddr_enable                (iddr_enable),
            .inclk                      (inclk),
            .inclk_dist                 (inclk_dist),
            .indrv                      (indrv[1:0]),
            .ipdrv                      (ipdrv[1:0]),
            .iweakpdn                   (jtag_weakpdn),          // Templated
            .iweakpu                    (jtag_weakpu),           // Templated
            .iredrstb                   (iredrstb),
            .tx_irstb                   (tx_irstb),
            .rx_irstb                   (rx_irstb),
            .rxen                       (rxen[2:0]),
            .txen                       (txen));

//lint_checking IOCOMB on
endmodule
