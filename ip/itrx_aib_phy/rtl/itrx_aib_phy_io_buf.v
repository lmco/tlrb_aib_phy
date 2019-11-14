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
// Filename       : itrx_aib_phy_io_buf.v
// Description    : AIB IO Buffer
//
// ==========================================================================
//
//    $Rev:: 5720                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-03-29 16:34:06 -0400#$: Date of last commit
//
// ==========================================================================

module itrx_aib_phy_io_buf(/*AUTOARG*/
   // Outputs
   oclk, oclk_b, odat0, odat1, odat_asyn,
   // Inouts
   ubump,
   // Inputs
   por_vcc_io, por_vcc_dig, jtag_clksel, jtag_clkdr, nrml_ilaunch_clk,
   redn_ilaunch_clk, redn_engage, async_data, iclkn, idat0, idat1,
   idat_selb, iddr_enable, inclk, inclk_dist, indrv, ipdrv, iweakpdn,
   iweakpu, iredrstb, tx_irstb, rx_irstb, rxen, txen
   );

parameter AIB_IS_LEGACY = 1'b0; // =0 for AIB Architecture Spec implementations
                                // =1 for AIB Legacy implementations


input                    por_vcc_io;
input                    por_vcc_dig;

//lint_checking IOPNTA MULWIR off
/*
inout                   vcc_dig;
inout                   vcc_io;
inout                   vss_ana;
*/

inout                   ubump;
//lint_checking IOPNTA MULWIR on

input                   jtag_clksel;
input                   jtag_clkdr;

input                   nrml_ilaunch_clk;
input                   redn_ilaunch_clk;
input                   redn_engage;

input                   async_data;
input                   iclkn;
input                   idat0;
input                   idat1;
input                   idat_selb;
input                   iddr_enable;
input                   inclk;
input                   inclk_dist;
input [1:0]             indrv;
input [1:0]             ipdrv;
input                   iweakpdn;
input                   iweakpu;
input                   iredrstb;
input                   tx_irstb;
input                   rx_irstb;

input [2:0]             rxen;
input                   txen;

output                  oclk;
output                  oclk_b;
output                  odat0;
output                  odat1;
output                  odat_asyn;

wire                    ubump_rx;                       // To u_rx of itrx_aib_phy_io_buf_rx.v
wire                    ubump_odig_async;               // From "buf_ana"
wire                    ubump_rx_n = ~ubump_odig_async; // To u_rx_dist of itrx_aib_phy_io_buf_rx_dist.v

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    idat0q;                 // From u_tx of itrx_aib_phy_io_buf_tx.v
wire                    idat1ql;                // From u_tx of itrx_aib_phy_io_buf_tx.v
wire                    ilaunch_clk;            // From u_tx_clk of itrx_aib_phy_io_buf_tx_clk.v
wire                    rx_clk_en;              // From u_decode of itrx_aib_phy_io_buf_decode.v
wire                    rx_dat_en;              // From u_decode of itrx_aib_phy_io_buf_decode.v
wire                    rxd0_irstb;             // From u_decode of itrx_aib_phy_io_buf_decode.v
wire                    rxd1_irstb;             // From u_decode of itrx_aib_phy_io_buf_decode.v
wire                    tx_en_buf;              // From u_decode of itrx_aib_phy_io_buf_decode.v
wire                    txdat_mux;              // From u_tx_clk of itrx_aib_phy_io_buf_tx_clk.v
wire                    ubump_rx_0ql;           // From u_rx of itrx_aib_phy_io_buf_rx.v
wire                    ubump_rx_1q;            // From u_rx of itrx_aib_phy_io_buf_rx.v
wire                    weakp0;                 // From u_decode of itrx_aib_phy_io_buf_decode.v
wire                    weakp1;                 // From u_decode of itrx_aib_phy_io_buf_decode.v
// End of automatics

/*AUTOREGINPUT*/

//------------------------------------------------------------------------------
// idat_selb is inverted in AIB Legacy
//
wire idat_selb_w_legacy;

generate
  if (AIB_IS_LEGACY) begin : gc_selb_lgcy
    assign idat_selb_w_legacy = ~idat_selb; // Legacy implemenation
  end else begin : gc_selb_aib
    assign idat_selb_w_legacy =  idat_selb; // Same as AIB Spec.
  end
endgenerate
//------------------------------------------------------------------------------


itrx_aib_phy_io_buf_decode
  u_decode (/*AUTOINST*/
            // Outputs
            .tx_en_buf                  (tx_en_buf),
            .weakp0                     (weakp0),
            .weakp1                     (weakp1),
            .rx_dat_en                  (rx_dat_en),
            .rx_clk_en                  (rx_clk_en),
            .rxd0_irstb                 (rxd0_irstb),
            .rxd1_irstb                 (rxd1_irstb),
            // Inputs
            .txen                       (txen),
            .rxen                       (rxen[2:0]),
            .iredrstb                   (iredrstb),
            .rx_irstb                   (rx_irstb),
            .iweakpdn                   (iweakpdn),
            .iweakpu                    (iweakpu));
/*
itrx_aib_phy_io_buf_tx_clk AUTO_TEMPLATE (
 .idat_selb (idat_selb_w_legacy),
 ); */

itrx_aib_phy_io_buf_tx_clk
  u_tx_clk (/*AUTOINST*/
            // Outputs
            .txdat_mux                  (txdat_mux),
            .ilaunch_clk                (ilaunch_clk),
            // Inputs
            .jtag_clksel                (jtag_clksel),
            .redn_engage                (redn_engage),
            .idat_selb                  (idat_selb_w_legacy),    // Templated
            .idat0q                     (idat0q),
            .idat1ql                    (idat1ql),
            .async_data                 (async_data),
            .nrml_ilaunch_clk           (nrml_ilaunch_clk),
            .redn_ilaunch_clk           (redn_ilaunch_clk),
            .jtag_clkdr                 (jtag_clkdr));

itrx_aib_phy_io_buf_tx
  u_tx (/*AUTOINST*/
        // Outputs
        .idat0q                         (idat0q),
        .idat1ql                        (idat1ql),
        // Inputs
        .tx_irstb                       (tx_irstb),
        .idat0                          (idat0),
        .idat1                          (idat1),
        .ilaunch_clk                    (ilaunch_clk),
        .iddr_enable                    (iddr_enable));

itrx_aib_phy_io_buf_rx
  u_rx (/*AUTOINST*/
        // Outputs
        .ubump_rx_0ql                   (ubump_rx_0ql),
        .ubump_rx_1q                    (ubump_rx_1q),
        // Inputs
        .rxd0_irstb                     (rxd0_irstb),
        .rxd1_irstb                     (rxd1_irstb),
        .inclk                          (inclk),
        .ubump_rx                       (ubump_rx));

itrx_aib_phy_io_buf_rx_dist
  u_rx_dist (/*AUTOINST*/
             // Outputs
             .odat0                     (odat0),
             .odat1                     (odat1),
             .odat_asyn                 (odat_asyn),
             // Inputs
             .rxd0_irstb                (rxd0_irstb),
             .rxd1_irstb                (rxd1_irstb),
             .inclk_dist                (inclk_dist),
             .ubump_rx_0ql              (ubump_rx_0ql),
             .ubump_rx_1q               (ubump_rx_1q),
             .ubump_rx_n                (ubump_rx_n));

//lint_checking NODEFD NOUNDF off
`ifndef POWER_PINS
//`define POWER_PINS
`endif
//lint_checking NODEFD NOUNDF on


//lint_checking NOTECH off
itrx_aib_phy_io_buf_ana
  u_ana (// Outputs
         .oclk_b                        (oclk_b),
         .ubump_odig                    (ubump_rx),
         .ubump_odig_async              (ubump_odig_async),
         .oclk                          (oclk),
         // Inouts
`ifdef POWER_PINS
         .vcc_dig                       (vcc_dig),
         .vcc_io                        (vcc_io),
         .vss                           (vss_ana),
`endif
         .ubump                         (ubump),

         // Inputs
         .txdat_mux                     (txdat_mux),
         .por_vcc_io                    (por_vcc_io),
         .ipdrv                         (ipdrv[1:0]),
         .indrv                         (indrv[1:0]),
         .por_vcc_dig                   (por_vcc_dig),
         .rx_clk_en                     (rx_clk_en),
         .weakp1                        (weakp1),
         .weakp0                        (weakp0),
         .tx_en_buf                     (tx_en_buf),
         .rx_dat_en                     (rx_dat_en),
         .iclkn                         (iclkn));
//lint_checking NOTECH on

endmodule
