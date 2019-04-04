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
// Filename       : tlrb_aib_phy_ext.sv
// Description    : Top-Level wrapper for the TLRB AIB PHY
//
// ==========================================================================
//
//    $Rev:: 75                        $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-12-04 17:37:02 -0500#$: Date of last commit
//
// ==========================================================================

/*
Detailed Description:

  This module is a top-level wrapper for TLRB AIB PHY 
  EXTended implementation.

  AIB = AIB Intel Avalon Interface Bus (Chiplet to Chiplet bus interface)

  TLRB = TSMC 16FFC Long Reach AIB Base configuration

  This module instantiates (wraps) an itrx_aib_phy_ext IP module.

*/
`timescale 1ps/1ps
module tlrb_aib_phy_ext(/*AUTOARG*/
   // Outputs
   rx_data, rx_clk, config_done, dig_test_bus, prdata, pready, tdo,
   r_apb_iddr_enable, r_apb_ns_adap_rstn, r_apb_ns_rstn,
   r_apb_fs_adap_rstn, r_apb_fs_rstn,
   // Inouts
   ubump, ubump_aux,
   // Inputs
   tx_data, tx_clk, ms_nsl, conf_done, device_detect_ovrd,
   dig_test_sel, paddr, pclk, penable, por_ovrd, presetn, psel,
   pwdata, pwrite, tck, tdi, tms, trstn_or_por_rstn
   );

localparam NDAT = 32'd80;         // Number of Sync Data uBumps in chan
localparam NBMP = NDAT + 32'd10;  // Number of uBumps in chan

//------------------------------------------------------------------------------
// MicroBumps
//

//lint: ubump is inout, ubump is multi-driven
//lint_checking IOPNTA MULWIR off
inout [NBMP-1:0] ubump; // IO chan uBumps
inout [1:0] ubump_aux;// AUX chan uBumps
//lint_checking IOPNTA MULWIR on

//------------------------------------------------------------------------------
// Synchronous Data (ND = # of synchronous Data uBumps; i.e. 80)
//
input  [NDAT-1:0] tx_data; // Input Synchronous (tx_clk) data output to uBump
output [NDAT-1:0] rx_data; // Output Synchronous (rx_clk) data input from uBump
input             tx_clk;  // Input Transmit clock for synchronous tx_data
output            rx_clk;  // Output Receive clock for synchronous rx_data

// AIB Master (=1) / AIB Slave (=0)
input                     ms_nsl;

// AIB CONF_DONE
input                     conf_done;
output                    config_done;

// DFT
input                     device_detect_ovrd;
input                     dig_test_sel;
output  [7:0]             dig_test_bus;

// APB Slave
input  [11:0]             paddr;
input                     pclk;
input                     penable;
input                     por_ovrd;
input                     presetn;
input                     psel;
input  [31:0]             pwdata;
input                     pwrite;
output [31:0]             prdata; 
output                    pready;

// JTAG
input                     tck;
input                     tdi;
input                     tms;
output                    tdo;
input                     trstn_or_por_rstn;

output                    r_apb_iddr_enable;
output                    r_apb_ns_adap_rstn;
output                    r_apb_ns_rstn;
output                    r_apb_fs_adap_rstn;
output                    r_apb_fs_rstn; 

/*AUTOREGINPUT*/

//------------------------------------------------------------------------------
// Instantiate Intrinisx AIB PHY module
//

/*
wire vcc_dig = 1'b1;
wire vcc_io  = 1'b1;
wire vss_ana = 1'b0;
*/

itrx_aib_phy_ext 
   u_itrx_aib_ext (/*AUTOINST*/
                   // Outputs
                   .prdata              (prdata[31:0]),
                   .pready              (pready),
                   .r_apb_iddr_enable   (r_apb_iddr_enable),
                   .r_apb_ns_adap_rstn  (r_apb_ns_adap_rstn),
                   .r_apb_ns_rstn       (r_apb_ns_rstn),
                   .r_apb_fs_adap_rstn  (r_apb_fs_adap_rstn),
                   .r_apb_fs_rstn       (r_apb_fs_rstn),
                   .config_done         (config_done),
                   .tdo                 (tdo),
                   .dig_test_bus        (dig_test_bus[7:0]),
                   .rx_clk              (rx_clk),
                   .rx_data             (rx_data[NDAT-1:0]),
                   // Inouts
                   .ubump               (ubump[NBMP-1:0]),
                   .ubump_aux           (ubump_aux[1:0]),
                   // Inputs
                   .pclk                (pclk),
                   .presetn             (presetn),
                   .paddr               (paddr[11:0]),
                   .pwrite              (pwrite),
                   .psel                (psel),
                   .penable             (penable),
                   .pwdata              (pwdata[31:0]),
                   .conf_done           (conf_done),
                   .tdi                 (tdi),
                   .tck                 (tck),
                   .tms                 (tms),
                   .trstn_or_por_rstn   (trstn_or_por_rstn),
                   .ms_nsl              (ms_nsl),
                   .device_detect_ovrd  (device_detect_ovrd),
                   .por_ovrd            (por_ovrd),
                   .dig_test_sel        (dig_test_sel),
                   .tx_clk              (tx_clk),
                   .tx_data             (tx_data[NDAT-1:0]));

// Local Variables:
// verilog-library-files:("../ip/itrx_aib_phy/rtl/itrx_aib_phy_ext.sv")
// End:

endmodule
