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
// Filename       : itrx_aib_phy_ext_dig.sv
// Description    : Digital logic for AIB Extended Controller functions
//                  (APB Registers, JTAG, TAP, POR) intended for Synthesis & Scan
//                  Insertion
//
// ==========================================================================
//
//    $Rev:: 5697                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-03-21 12:06:54 -0400#$: Date of last commit
//
// ==========================================================================

// FIX ME - Add reset synchronizers in AIB IO Channel.

module itrx_aib_phy_ext_dig(/*AUTOARG*/
   // Outputs
   prdata, pready, config_done, tdo, adap_rstn_in, rstn_in,
   adapt_irstb, idat_selb, iddr_enable, indrv, indrv_clk, indrv_rst,
   ipdrv, ipdrv_clk, ipdrv_rst, jtag_clkdr, jtag_clksel, jtag_intest,
   jtag_mode, jtag_rstn, jtag_rstn_en, jtag_scan_en, jtag_weakpd,
   jtag_weakpu, sdr_dly_adjust, ddr_dly_adjust, redun_engage, rxen,
   txen, por_in_vcc_dig, por_sl2sl, por_vcc_dig,
   // Inputs
   pclk, presetn, paddr, pwrite, psel, penable, pwdata, conf_done,
   tdi, tck, tms, trstn_or_por_rstn, jtag_scan_out, adap_rstn_out,
   rstn_out, por_out_vcc_dig, device_detect_vcc_dig
   );

localparam NBMP  = 32'd90;
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

// From AIB IO Channel Macro
//
input                     jtag_scan_out;
input                     adap_rstn_out;
input                     rstn_out;


// Outputs to AIB IO Channel Macro
//
output                    adap_rstn_in;
output                    rstn_in;
output                    adapt_irstb;
output [FBMP-1:0]         idat_selb;
output                    iddr_enable;
output [1:0]              indrv;
output [1:0]              indrv_clk;
output [1:0]              indrv_rst;
output [1:0]              ipdrv;
output [1:0]              ipdrv_clk;
output [1:0]              ipdrv_rst;
output                    jtag_clkdr;
output                    jtag_clksel;
output                    jtag_intest;
output                    jtag_mode;
output                    jtag_rstn;
output                    jtag_rstn_en;
output                    jtag_scan_en;
output                    jtag_weakpd;
output                    jtag_weakpu;
output [DLYW-1:0]         sdr_dly_adjust;
output [DLYW-1:0]         ddr_dly_adjust;
output [HNBMP-1:0]        redun_engage;
output [FBMP-1:0] [2:0]   rxen;
output [FBMP-1:0]         txen;

// Outputs to AIB IO AUX Channel Macro Level-Shifters
//
output                    por_in_vcc_dig;
output                    por_sl2sl;

// VCC_DIG
input                     por_out_vcc_dig;
input                     device_detect_vcc_dig;
output                    por_vcc_dig;

/*AUTOREGINPUT*/

/*AUTOWIRE*/

/*
itrx_aib_phy_apbs AUTO_TEMPLATE (
                                    .device_detect      (device_detect_vcc_dig),
                                    .por_out            (por_out_vcc_dig),
                                    .por_in             (por_in_vcc_dig),
  ); */

itrx_aib_phy_apbs u_itrx_aib_phy_apbs(/*AUTOINST*/
                                      // Outputs
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
                                      .por_in           (por_in_vcc_dig), // Templated
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
                                      .device_detect    (device_detect_vcc_dig), // Templated
                                      .por_out          (por_out_vcc_dig), // Templated
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

assign por_vcc_dig =  por_out_vcc_dig | por_sl2sl; // VCC DIG domain

endmodule
