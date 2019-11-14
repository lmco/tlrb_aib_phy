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
// Filename       : itrx_aib_phy_ext.sv
// Description    : Top-level of AIB PHY EXTended with APB slave and
//                  and JTAG controllers
//
// ==========================================================================
//
//    $Rev:: 5810                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-06-24 16:29:21 -0400#$: Date of last commit
//
// ==========================================================================

module itrx_aib_phy_ext(/*AUTOARG*/
   // Outputs
   prdata, pready, r_apb_iddr_enable, r_apb_ns_adap_rstn,
   r_apb_ns_rstn, r_apb_fs_adap_rstn, r_apb_fs_rstn, config_done, tdo,
   dig_test_bus, rx_clk, rx_data, atpg_bsr_scan_out,
   // Inouts
   ubump, ubump_aux,
   // Inputs
   pclk, presetn, paddr, pwrite, psel, penable, pwdata, conf_done,
   tdi, tck, tms, trstn_or_por_rstn, ms_nsl, device_detect_ovrd,
   por_ovrd, dig_test_sel, tx_clk, tx_data, atpg_bsr_ovrd_mode,
   atpg_bsr_scan_in, atpg_bsr_scan_shift, atpg_bsr_scan_shift_clk
   );

localparam NBMP  = 32'd90;
localparam NDAT  = 32'd80;
localparam FBMP  = 32'd88;
localparam HNBMP = NBMP/32'd2;
localparam DLYW  = 32'd10;

// APB Slave Interface
//
input                     pclk;    // Clock.
input                     presetn; // Reset.
input  [11:0]             paddr;   // Address.
input                     pwrite;  // Direction.
input                     psel;    // Select.
input                     penable; // Enable.
input  [31:0]             pwdata;  // Write Data.
output [31:0]             prdata;  // Read Data.
output                    pready;  // Ready.

//------------------------------------------------------------------------------
// APB control register (csr) bits
// For system use.
// Synchronous to APB pclk.
//
output                    r_apb_iddr_enable;

output                    r_apb_ns_adap_rstn; // to near-side, local AIB PHY
output                    r_apb_ns_rstn;      // to near-side, local AIB PHY
output                    r_apb_fs_adap_rstn; // from far-side, remote AIB PHY
output                    r_apb_fs_rstn;      // from far-side, remote AIB PHY
//------------------------------------------------------------------------------

// AIB CONF_DONE
//
input                     conf_done;
output                    config_done; // To open drain driver


// JTAG Interface
//
input                     tdi;     // test data in     (JTAG)
input                     tck;     // test clock       (JTAG)
input                     tms;     // test mode select (JTAG)
output                    tdo;     // test data out    (JTAG)

input                     trstn_or_por_rstn;

// AIB Master (=1), Slave (=0)
//
input                     ms_nsl;

// AIB DFT (C4s)
//
input                     device_detect_ovrd;
input                     por_ovrd;

input                     dig_test_sel;
output [7:0]              dig_test_bus;

// AIB Adapter Synchronous Data Interface
//
input                     tx_clk;
input  [NDAT-1:0]         tx_data;

output                    rx_clk;
output [NDAT-1:0]         rx_data;


//lint: ubump is inout, ubump is multi-driven
//lint_checking IOPNTA MULWIR MLTDRV off

// AIB IO Micro-bumps
//
inout  [NBMP-1:0]         ubump;
inout  [1:0]              ubump_aux;

input                   atpg_bsr_ovrd_mode;     // To u_itrx_aib_phy of itrx_aib_phy.v
input                   atpg_bsr_scan_in;       // To u_itrx_aib_phy of itrx_aib_phy.v
input                   atpg_bsr_scan_shift;    // To u_itrx_aib_phy of itrx_aib_phy.v
input                   atpg_bsr_scan_shift_clk;// To u_itrx_aib_phy of itrx_aib_phy.v
output                  atpg_bsr_scan_out;      // From u_itrx_aib_phy of itrx_aib_phy.v

// Power and ground for Analog blocks (and level-shifters)
//
/*
inout                     vcc_dig;
inout                     vcc_io;
inout                     vss_ana;
*/

//lint_checking IOPNTA MULWIR MLTDRV on

/*AUTOREGINPUT*/

//wire por_in;
wire por_vcc_dig;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    adap_rstn_in;           // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire                    adap_rstn_out;          // From u_itrx_aib_phy of itrx_aib_phy.v
wire                    adapt_irstb;            // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [DLYW-1:0]         ddr_dly_adjust;         // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire                    device_detect;          // From u_itrx_aib_phy of itrx_aib_phy.v
wire [FBMP-1:0]         idat_selb;              // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire                    iddr_enable;            // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [1:0]              indrv;                  // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [1:0]              indrv_clk;              // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [1:0]              indrv_rst;              // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [1:0]              ipdrv;                  // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [1:0]              ipdrv_clk;              // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [1:0]              ipdrv_rst;              // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire                    jtag_clkdr;             // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    jtag_clksel;            // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    jtag_intest;            // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    jtag_mode;              // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    jtag_rstn;              // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    jtag_rstn_en;           // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    jtag_scan_en;           // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    jtag_scan_out;          // From u_itrx_aib_phy of itrx_aib_phy.v
wire                    jtag_weakpd;            // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    jtag_weakpu;            // From u_itrx_aib_phy_jtag of itrx_aib_phy_jtag.v
wire                    por_in;                 // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire                    por_out;                // From u_itrx_aib_phy of itrx_aib_phy.v
wire                    por_sl2sl;              // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [HNBMP-1:0]        redun_engage;           // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire                    rstn_in;                // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire                    rstn_out;               // From u_itrx_aib_phy of itrx_aib_phy.v
wire [FBMP-1:0] [2:0]   rxen;                   // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [DLYW-1:0]         sdr_dly_adjust;         // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
wire [FBMP-1:0]         txen;                   // From u_itrx_aib_phy_apbs of itrx_aib_phy_apbs.v
// End of automatics

// VCC_DIG
//wire por_out_vcc_dig;
//wire device_detect_vcc_dig;

// VCC_IO
//wire por_sl2sl_vcc_io;

assign r_apb_iddr_enable  = iddr_enable;
assign r_apb_ns_adap_rstn = adap_rstn_in;
assign r_apb_ns_rstn      = rstn_in;

/*
itrx_aib_phy AUTO_TEMPLATE(
                            .adapt_rstn         (adapt_irstb),
                            .por_vcc_io         (por_sl2sl),
                            .jtag_scan_in       (tdi),
 ); */

itrx_aib_phy u_itrx_aib_phy(/*AUTOINST*/
                            // Outputs
                            .rx_data            (rx_data[NDAT-1:0]),
                            .rx_clk             (rx_clk),
                            .por_out            (por_out),
                            .device_detect      (device_detect),
                            .rstn_out           (rstn_out),
                            .adap_rstn_out      (adap_rstn_out),
                            .jtag_scan_out      (jtag_scan_out),
                            .dig_test_bus       (dig_test_bus[7:0]),
                            .atpg_bsr_scan_out  (atpg_bsr_scan_out),
                            // Inouts
                            .ubump              (ubump[NBMP-1:0]),
                            .ubump_aux          (ubump_aux[1:0]),
                            // Inputs
                            .tx_data            (tx_data[NDAT-1:0]),
                            .tx_clk             (tx_clk),
                            .por_in             (por_in),
                            .por_vcc_io         (por_sl2sl),     // Templated
                            .por_vcc_dig        (por_vcc_dig),
                            .adapt_rstn         (adapt_irstb),   // Templated
                            .rstn_in            (rstn_in),
                            .adap_rstn_in       (adap_rstn_in),
                            .ms_nsl             (ms_nsl),
                            .iddr_enable        (iddr_enable),
                            .idat_selb          (idat_selb[FBMP-1:0]),
                            .ipdrv              (ipdrv[1:0]),
                            .indrv              (indrv[1:0]),
                            .ipdrv_clk          (ipdrv_clk[1:0]),
                            .indrv_clk          (indrv_clk[1:0]),
                            .ipdrv_rst          (ipdrv_rst[1:0]),
                            .indrv_rst          (indrv_rst[1:0]),
                            .rxen               (rxen/*[FBMP-1:0][2:0]*/),
                            .txen               (txen[FBMP-1:0]),
                            .sdr_dly_adjust     (sdr_dly_adjust[DLYW-1:0]),
                            .ddr_dly_adjust     (ddr_dly_adjust[DLYW-1:0]),
                            .redun_engage       (redun_engage[HNBMP-1:0]),
                            .jtag_scan_en       (jtag_scan_en),
                            .jtag_clkdr         (jtag_clkdr),
                            .jtag_rstn          (jtag_rstn),
                            .jtag_rstn_en       (jtag_rstn_en),
                            .jtag_clksel        (jtag_clksel),
                            .jtag_intest        (jtag_intest),
                            .jtag_mode          (jtag_mode),
                            .jtag_weakpd        (jtag_weakpd),
                            .jtag_weakpu        (jtag_weakpu),
                            .jtag_scan_in       (tdi),           // Templated
                            .device_detect_ovrd (device_detect_ovrd),
                            .por_ovrd           (por_ovrd),
                            .dig_test_sel       (dig_test_sel),
                            .atpg_bsr_ovrd_mode (atpg_bsr_ovrd_mode),
                            .atpg_bsr_scan_in   (atpg_bsr_scan_in),
                            .atpg_bsr_scan_shift_clk(atpg_bsr_scan_shift_clk),
                            .atpg_bsr_scan_shift(atpg_bsr_scan_shift));

/*
itrx_aib_phy_apbs AUTO_TEMPLATE (
  ); */

itrx_aib_phy_apbs u_itrx_aib_phy_apbs(/*AUTOINST*/
                                      // Outputs
                                      .r_apb_fs_adap_rstn(r_apb_fs_adap_rstn),
                                      .r_apb_fs_rstn    (r_apb_fs_rstn),
                                      .prdata           (prdata[31:0]),
                                      .pready           (pready),
                                      .rstn_in          (rstn_in),
                                      .adap_rstn_in     (adap_rstn_in),
                                      .adapt_irstb      (adapt_irstb),
                                      .ddr_dly_adjust   (ddr_dly_adjust[DLYW-1:0]),
                                      .sdr_dly_adjust   (sdr_dly_adjust[DLYW-1:0]),
                                      .idat_selb        (idat_selb[FBMP-1:0]),
                                      .iddr_enable      (iddr_enable),
                                      .indrv            (indrv[1:0]),
                                      .indrv_clk        (indrv_clk[1:0]),
                                      .indrv_rst        (indrv_rst[1:0]),
                                      .ipdrv            (ipdrv[1:0]),
                                      .ipdrv_clk        (ipdrv_clk[1:0]),
                                      .ipdrv_rst        (ipdrv_rst[1:0]),
                                      .rxen             (rxen/*[FBMP-1:0][2:0]*/),
                                      .txen             (txen[FBMP-1:0]),
                                      .por_sl2sl        (por_sl2sl),
                                      .por_in           (por_in),
                                      .redun_engage     (redun_engage[HNBMP-1:0]),
                                      .config_done      (config_done),
                                      // Inputs
                                      .pclk             (pclk),
                                      .presetn          (presetn),
                                      .paddr            (paddr[11:0]),
                                      .pwrite           (pwrite),
                                      .psel             (psel),
                                      .penable          (penable),
                                      .pwdata           (pwdata[31:0]),
                                      .rstn_out         (rstn_out),
                                      .adap_rstn_out    (adap_rstn_out),
                                      .device_detect    (device_detect),
                                      .por_out          (por_out),
                                      .conf_done        (conf_done));

itrx_aib_phy_jtag u_itrx_aib_phy_jtag (/*AUTOINST*/
                                       // Outputs
                                       .tdo             (tdo),
                                       .jtag_clkdr      (jtag_clkdr),
                                       .jtag_clksel     (jtag_clksel),
                                       .jtag_intest     (jtag_intest),
                                       .jtag_mode       (jtag_mode),
                                       .jtag_rstn       (jtag_rstn),
                                       .jtag_rstn_en    (jtag_rstn_en),
                                       .jtag_scan_en    (jtag_scan_en),
                                       .jtag_weakpd     (jtag_weakpd),
                                       .jtag_weakpu     (jtag_weakpu),
                                       // Inputs
                                       .tck             (tck),
                                       .tms             (tms),
                                       .tdi             (tdi),
                                       .trstn_or_por_rstn(trstn_or_por_rstn),
                                       .jtag_scan_out   (jtag_scan_out));

// COMMENT OUT RELOCATED TO AUX MACRO
//------------------------------------------------------------------------------
// Level Shifters for AUX signals.
// Shift to Digital Levels
//

//lint: IPRTEX - A constant is used in a port expression.
//lint_checking IPRTEX off

//aibcr3aux_lvshift  u_lvshift_2dig_por (.in             (por_out),
                                    // .vccl_aibcr3aux (1'b1), // in  vcc_io
                                    // .vcc_aibcr3aux  (1'b1), // out vcc_dig
//                                     .out            (por_out_vcc_dig)
                                    // .vssl_aibcr3aux (1'b0)
//                                    );

//aibcr3aux_lvshift  u_lvshift_2dig_dd  (.in             (device_detect),
                                    // .vccl_aibcr3aux (1'b1), // in  vcc_io
                                    // .vcc_aibcr3aux  (1'b1), // out vcc_dig
//                                       .out            (device_detect_vcc_dig)
                                    // .vssl_aibcr3aux (1'b0)
//                                      );
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Level Shifters for AUX signals.
// Shift to IO Levels
//
//aibcr3aux_lvshift  u_lvshift_2io_por2m(.in             (por_in_vcc_dig),
                                    // .vccl_aibcr3aux (1'b1), // in  vcc_dig
                                    // .vcc_aibcr3aux  (1'b1), // out vcc_io
//                                     .out            (por_in)
                                    // .vssl_aibcr3aux (1'b0)
//                                    );

//aibcr3aux_lvshift  u_lvshift_2io_por2s(.in             (por_sl2sl),
                                    // .vccl_aibcr3aux (1'b1), // in  vcc_dig
                                    // .vcc_aibcr3aux  (1'b1), // out vcc_io
//                                     .out            (por_sl2sl_vcc_io)
                                    // .vssl_aibcr3aux (1'b0)
//                                    );
//lint_checking IPRTEX on
//------------------------------------------------------------------------------

//  Master: configures por_sl2sl to be 0 in APB register set.
//  Slave : AIB IO AUX Channel drives por_out/por_out_vcc_dig to be 0
//
assign por_vcc_dig =  por_out | por_sl2sl; // VCC DIG domain

endmodule
