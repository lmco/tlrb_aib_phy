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
input                    rx_irstb;

input                    por_vcc_dig;
input                    por_vcc_io;

inout   [NBMP-1:0]       ubump;

input   [NBMP-1:0]       redn_engage;
input   [NBMP-1:0]       prev_redn_engage;

//------------------------------------------------------------------------------
// JTAG I/O
//
input  [NBMP-1:0]        jtag_clkdr;
output [NBMP-1:0]        jtag_clkdr_n;
input                    jtag_clksel;
input                    jtag_intest;
input                    jtag_mode;
input                    jtag_scan_en;
input  [NBMP-1:0]        jtag_scanin;
input                    jtag_weakpdn;
input                    jtag_weakpu;
output [NBMP-1:0]        jtag_scanout;
input                    jtag_rstn;
input                    jtag_rstn_en;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// IO Cell CFG functional Inputs
//
input  [NBMP-1:0]        idat_selb;
input  [NBMP-1:0] [2:0]  rxen;
input  [NBMP-1:0]        txen;

input  [NBMP-1:0]        iddr_enable;
input  [NBMP-1:0] [1:0]  indrv;
input  [NBMP-1:0] [1:0]  ipdrv;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// IO Cell Output ports
//lint_checking NUMSUF off

output [NBMP-1:0]        nrml_odat0;
output [NBMP-1:0]        nrml_odat1;
output [NBMP-1:0]        nrml_odat_asyn;

output [NBMP-1:0]        rmux_oclk;
output [NBMP-1:0]        rmux_oclk_b;

output [NBMP-1:0]        oclk;
output [NBMP-1:0]        oclk_b;

output [NBMP-1:0]        odat0;
output [NBMP-1:0]        odat1;
output [NBMP-1:0]        odat_asyn;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// IO Cell Input  ports


input [NBMP-1:0]          iclkn;
input [NBMP-1:0]          inclk;
input [NBMP-1:0]          inclk_dist;

input [NBMP-1:0]          nrml_async_data;
input [NBMP-1:0]          nrml_idat0;
input [NBMP-1:0]          nrml_idat1;
input [NBMP-1:0]          nrml_idat_selb;
input [NBMP-1:0]          nrml_iddr_enable;
input [NBMP-1:0]          nrml_ilaunch_clk;
input [NBMP-1:0] [1:0]    nrml_indrv;
input [NBMP-1:0] [1:0]    nrml_ipdrv;
input [NBMP-1:0] [2:0]    nrml_rxen;
input [NBMP-1:0]          nrml_txen;

input [NBMP-1:0]          redn_async_data;
input [NBMP-1:0]          redn_idat0;
input [NBMP-1:0]          redn_idat1;
input [NBMP-1:0]          redn_idat_selb;
input [NBMP-1:0]          redn_iddr_enable;
input [NBMP-1:0]          redn_ilaunch_clk;
input [NBMP-1:0] [1:0]    redn_indrv;
input [NBMP-1:0] [1:0]    redn_ipdrv;
input [NBMP-1:0] [2:0]    redn_rxen;
input [NBMP-1:0]          redn_txen;

input [NBMP-1:0]          redn_odat0;
input [NBMP-1:0]          redn_odat1;
input [NBMP-1:0]          redn_odat_asyn;

input [NBMP-1:0]          redn_oclk;
input [NBMP-1:0]          redn_oclk_b;


// Outputs from AIB IO Cells
//
output [NBMP-1:0]         jtag_async_data;
output [NBMP-1:0]         jtag_idat0;
output [NBMP-1:0]         jtag_idat1;

// Internal wires to be assigned:
wire   [NBMP -1:0]       spare_mode = SPARE_GRP;

genvar ii;
generate
for (ii=0; ii<NBMP; ii=ii+1) begin : gl_bmp
  itrx_aib_phy_io_cell #(.AIB_IS_LEGACY(AIB_IS_LEGACY))
    u_cell(// Outputs
          .jtag_scanout                 (jtag_scanout[ii]),

          .rmux_oclk                    (rmux_oclk[ii]),
          .rmux_oclk_b                  (rmux_oclk_b[ii]),

          .oclk                         (oclk[ii]),
          .oclk_b                       (oclk_b[ii]),

          .nrml_odat0                   (nrml_odat0[ii]),
          .nrml_odat1                   (nrml_odat1[ii]),
          .nrml_odat_asyn               (nrml_odat_asyn[ii]),

          .jtag_idat0                   (jtag_idat0[ii]),
          .jtag_idat1                   (jtag_idat1[ii]),
          .jtag_async_data              (jtag_async_data[ii]),

          .odat0                        (odat0[ii]),
          .odat1                        (odat1[ii]),
          .odat_asyn                    (odat_asyn[ii]),
          // Inouts
          .ubump                        (ubump[ii]),
          // Inputs
          .por_vcc_io                   (por_vcc_io),
          .por_vcc_dig                  (por_vcc_dig),

          .iclkn                        (iclkn[ii]),
          .inclk                        (inclk[ii]),
          .inclk_dist                   (inclk_dist[ii]),

          .redn_engage                  (redn_engage[ii]),
          .prev_redn_engage             (prev_redn_engage[ii]),
          .spare_mode                   (spare_mode[ii]),

          .irstb                        (irstb),
          .tx_irstb                     (tx_irstb),
          .rx_irstb                     (rx_irstb),

          .jtag_clkdr                   (jtag_clkdr[ii]),
          .jtag_clkdr_n                 (jtag_clkdr_n[ii]),
          .jtag_clksel                  (jtag_clksel),
          .jtag_intest                  (jtag_intest),
          .jtag_mode                    (jtag_mode),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_scanin                  (jtag_scanin[ii]),
          .jtag_weakpdn                 (jtag_weakpdn),
          .jtag_weakpu                  (jtag_weakpu),

          .nrml_ilaunch_clk             (nrml_ilaunch_clk[ii]),
          .nrml_async_data              (nrml_async_data[ii]),
          .nrml_idat0                   (nrml_idat0[ii]),
          .nrml_idat1                   (nrml_idat1[ii]),
          .nrml_idat_selb               (nrml_idat_selb[ii]),
          .nrml_iddr_enable             (nrml_iddr_enable[ii]),
          .nrml_indrv                   (nrml_indrv[ii][1:0]),
          .nrml_ipdrv                   (nrml_ipdrv[ii][1:0]),
          .nrml_rxen                    (nrml_rxen[ii][2:0]),
          .nrml_txen                    (nrml_txen[ii]),

          .redn_ilaunch_clk             (redn_ilaunch_clk[ii]),
          .redn_async_data              (redn_async_data[ii]),
          .redn_idat0                   (redn_idat0[ii]),
          .redn_idat1                   (redn_idat1[ii]),
          .redn_idat_selb               (redn_idat_selb[ii]),
          .redn_iddr_enable             (redn_iddr_enable[ii]),
          .redn_indrv                   (redn_indrv[ii][1:0]),
          .redn_ipdrv                   (redn_ipdrv[ii][1:0]),
          .redn_rxen                    (redn_rxen[ii][2:0]),
          .redn_txen                    (redn_txen[ii]),

          .redn_oclk                    (redn_oclk[ii]),
          .redn_oclk_b                  (redn_oclk_b[ii]),

          .redn_odat0                   (redn_odat0[ii]),
          .redn_odat1                   (redn_odat1[ii]),
          .redn_odat_asyn               (redn_odat_asyn[ii]));
end
endgenerate

endmodule
