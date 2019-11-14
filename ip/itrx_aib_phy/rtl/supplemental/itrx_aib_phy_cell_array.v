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
input  [NBMP-1:0]        idat_selb;
input  [NBMP-1:0] [2:0]  rxen;
input  [NBMP-1:0]        txen;

input  [NBMP-1:0]        iddr_enable;
input  [NBMP-1:0] [1:0]  indrv;
input  [NBMP-1:0] [1:0]  ipdrv;
//------------------------------------------------------------------------------


// Internal wires to be assigned:

wire   [NBMP -1:0]       spare_mode = SPARE_GRP;


//------------------------------------------------------------------------------
// IO Cell Output ports
//lint_checking NUMSUF off

wire [NBMP-1:0]          nrml_odat0;
wire [NBMP-1:0]          nrml_odat1;
wire [NBMP-1:0]          nrml_odat_asyn;

wire [NBMP-1:0]          oclk;
wire [NBMP-1:0]          oclk_b;

wire [NBMP-1:0]          odat0;
wire [NBMP-1:0]          odat1;
wire [NBMP-1:0]          odat_asyn;

wire [NBMP-1:0]          jtag_scanout_cell;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// IO Cell Input  ports
wire [NBMP-1:0]          jtag_scanin_cell;


wire [NBMP-1:0]          iclkn;
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

wire  [NBMP-1:0]          redn_async_data;
wire  [NBMP-1:0]          redn_idat0;
wire  [NBMP-1:0]          redn_idat1;
wire  [NBMP-1:0]          redn_idat_selb;
wire  [NBMP-1:0]          redn_iddr_enable;
wire  [NBMP-1:0]          redn_ilaunch_clk;
wire  [NBMP-1:0] [1:0]    redn_indrv;
wire  [NBMP-1:0] [1:0]    redn_ipdrv;
wire  [NBMP-1:0] [2:0]    redn_rxen;
wire  [NBMP-1:0]          redn_txen;

// Outputs from AIB IO Cells
//
wire [NBMP-1:0]          jtag_async_data;
wire [NBMP-1:0]          jtag_idat0;
wire [NBMP-1:0]          jtag_idat1;
wire [NBMP-1:0] [2:0]    jtag_rxen;
wire [NBMP-1:0]          jtag_txen;


genvar ii;
generate
for (ii=0; ii<NBMP; ii=ii+1) begin : gl_bmp
  itrx_aib_phy_io_cell
    u_cell(// Outputs
          .jtag_scanout                 (jtag_scanout_cell[ii]),
          .oclk                         (oclk[ii]),
          .oclk_b                       (oclk_b[ii]),

          .nrml_odat0                   (nrml_odat0[ii]),
          .nrml_odat1                   (nrml_odat1[ii]),
          .nrml_odat_asyn               (nrml_odat_asyn[ii]),

          .jtag_idat0                   (jtag_idat0[ii]),
          .jtag_idat1                   (jtag_idat1[ii]),
          .jtag_async_data              (jtag_async_data[ii]),
          .jtag_rxen                    (jtag_rxen[ii]),
          .jtag_txen                    (jtag_txen[ii]),

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

          .redn_engage                  (iredn_engage[ii]),
          .prev_redn_engage             (prev_redn_engage[ii]),
          .spare_mode                   (spare_mode[ii]),

          .irstb                        (irstb),
          .tx_irstb                     (tx_irstb),
          .rx_irstb                     (rx_irstb),

          .jtag_clkdr                   (jtag_clkdr),
          .jtag_clksel                  (jtag_clksel),
          .jtag_intest                  (jtag_intest),
          .jtag_mode                    (jtag_mode),
          .jtag_scan_en                 (jtag_scan_en),
          .jtag_scanin                  (jtag_scanin_cell[ii]),
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
          .redn_odat0                   (odat0[RED_II]),
          .redn_odat1                   (odat1[RED_II]),
          .redn_odat_asyn               (odat_asyn[RED_II]));
endgenerate

endmodule
