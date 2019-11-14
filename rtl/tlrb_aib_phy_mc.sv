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
// Filename       : tlrb_aib_phy_mc.sv
// Description    : Top-Level wrapper for the TLRB AIB PHY
//                  Multi-Channel
//
// ==========================================================================
//
//    $Rev:: 97                        $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-04-26 14:06:10 -0400#$: Date of last commit
//
// ==========================================================================

/*
Detailed Description:

  This module is a top-level wrapper for TLRB AIB PHY implementation.

  AIB = AIB Advanced Interface Bus (Chiplet to Chiplet bus interface)

  TLRB = TSMC 16FFC Long Reach AIB Base configuration

  This module instantiates (wraps) an itrx_aib_phy_mc IP module.

*/
`timescale 1ps/1ps
module tlrb_aib_phy_mc(/*AUTOARG*/
   // Outputs
   rx_data, rx_clk, por_out, device_detect, rstn_out, adap_rstn_out,
   jtag_scan_out, dig_test_bus, atpg_bsr_scan_out,
   // Inouts
   ubump, ubump_aux,
   // Inputs
   tx_data, tx_clk, por_in, por_vcc_io, por_vcc_dig, adap_irstb,
   rstn_in, adap_rstn_in, ms_nsl, iddr_enable, idat_selb, ipdrv,
   ipdrv_clk, ipdrv_rst, indrv, indrv_clk, indrv_rst, rxen, txen,
   sdr_dly_adjust, ddr_dly_adjust, redun_engage, jtag_scan_en,
   jtag_clkdr, jtag_rstn, jtag_rstn_en, jtag_clksel, jtag_intest,
   jtag_mode, jtag_weakpd, jtag_weakpu, jtag_scan_in,
   device_detect_ovrd, por_ovrd, dig_test_sel, atpg_bsr_ovrd_mode,
   atpg_bsr_scan_in, atpg_bsr_scan_shift, atpg_bsr_scan_shift_clk
   );

parameter NCH = 32'd2; // Number of AIB IO Channels

localparam NDAT = 32'd80;         // Number of Sync Data uBumps in chan
localparam NBMP = NDAT + 32'd10;  // Number of uBumps in chan
localparam HNBMP = NBMP/32'd2;    // Half the # of uBumps in chan
localparam FBMP  = NBMP - 32'd2;  // # of functional/logical uBumps (wo spares)
localparam DLYW = 32'd10;         // Manual mode DLL adjust bit width

//------------------------------------------------------------------------------
// MicroBumps
//

//lint: ubump is inout, ubump is multi-driven
//lint_checking IOPNTA MULWIR off
inout [NCH-1:0][NBMP-1:0] ubump; // IO chan uBumps
inout          [1:0] ubump_aux;// AUX chan uBumps
//lint_checking IOPNTA MULWIR on


//------------------------------------------------------------------------------
// Synchronous Data (ND = # of synchronous Data uBumps; i.e. 80)
//
input  [NCH-1:0][NDAT-1:0] tx_data; // Input Synchronous (tx_clk) data output to uBump
output [NCH-1:0][NDAT-1:0] rx_data; // Output Synchronous (rx_clk) data input from uBump
input  [NCH-1:0]           tx_clk;  // Input Transmit clock for synchronous tx_data
output [NCH-1:0]           rx_clk;  // Output Receive clock for synchronous rx_data

//------------------------------------------------------------------------------
// Resets and Reset Control (asynchronous)
//
input  por_in;        // Input Slave: Input Power on reset (POR)
                      // (Driven by the slave from an external POR controller.)
                      // Master: unused (tie low)

output por_out;       // Output Slave: unused (=0)
                      //        Master: POR
                      // (Monitored by master in an external POR controller.)

input  por_vcc_io;    // Input Power on reset VCC of IO power domain
                      // (to Analog IO Buffer, =0 for normal operation)

input  por_vcc_dig;   // Input Power on reset VCC of digital logic power domain
                      // (to Analog IO Buffer, =0 for normal ops)

output device_detect; // Output Device detect
                      // (Monitored by slave. Unused by master and driven to 0)

input  [NCH-1:0] adap_irstb;    // Input AIB PHY reset (IRSTB) (active low)

input  [NCH-1:0] rstn_in;       // Input AIB PHY reset (active low)

output [NCH-1:0] rstn_out;      // Output AIB PHY reset output
                      // (monitored by the reset controller; active low)

input  [NCH-1:0] adap_rstn_in;  // Input Adapter reset
                      // (resets the other, remote AIB PHY; active low)

output [NCH-1:0] adap_rstn_out; // Output Adapter reset output
                      // (monitored by the reset controller; active low)


//------------------------------------------------------------------------------
// IO Cell Configuration (asynchronous/static).
//
input                  ms_nsl;         // Input Master Not Slave signal
                                       //  0=Slave, 1=Master

input [NCH-1:0]                 iddr_enable;    // Input DDR mode select

input [NCH-1:0][FBMP-1:0]       idat_selb;      // Input Asynchronous TX mode select
                                       // for each AIB IO cell

input [NCH-1:0]           [1:0] ipdrv;          // Input ubump TX drive strength high
input [NCH-1:0]           [1:0] ipdrv_clk;      // Input ubump TX drive strength high
input [NCH-1:0]           [1:0] ipdrv_rst;      // Input ubump TX drive strength high
                                       // (P-driver) selection.

input [NCH-1:0]           [1:0] indrv;          // Input ubump TX drive strength low
input [NCH-1:0]           [1:0] indrv_clk;      // Input ubump TX drive strength low
input [NCH-1:0]           [1:0] indrv_rst;      // Input ubump TX drive strength low
                                       // (N-driver) selection.

input [NCH-1:0][FBMP-1:0] [2:0] rxen;           // Input Receive enable selection for
                                       // each AIB IO cell (encoded)

input [NCH-1:0][FBMP-1:0]       txen;           // Input Transmit enable for each AIB IO

/*
For DEBUG
final
for (int i=FBMP-1; i>=0; i=i-1) begin
      $display("rxen[%2d] %b", i, rxen[i]);
end

final $display("txen: %h", txen);
*/

input [NCH-1:0][DLYW-1:0]       sdr_dly_adjust; // Input Adjustment setting for
                                       // programmable RX inclk delay
                                       // (DLL manual mode) for SDR mode

input [NCH-1:0][DLYW-1:0]       ddr_dly_adjust; // Input Adjustment setting for
                                       // programmable RX inclk delay
                                       // (DLL manual mode) for DDR mode

input [NCH-1:0][HNBMP-1:0]      redun_engage;   // Input Redundancy engage enable
                                       // for each pair of AIB IO Channel IOs

//------------------------------------------------------------------------------
// JTAG/DFT
//
input  jtag_scan_en;  // Input  JTAG scan enable
input  jtag_clkdr;    // Input  JTAG data register clock
input  jtag_rstn;     // Input  JTAG reset (active low)
input  jtag_rstn_en;  // Input  JTAG reset enable
input  jtag_clksel;   // Input  JTAG clock select
input  jtag_intest;   // Input  JTAG INTEST (internal test, e.g. probing)
input  jtag_mode;     // Input  JTAG mode
input  jtag_weakpd;   // Input  JTAG weak pull down
input  jtag_weakpu;   // Input  JTAG weak pull up
input  jtag_scan_in;  // Input  JTAG chain scan input data
output jtag_scan_out; // Output JTAG chain scan output data

input        device_detect_ovrd; // Input DFT: Device Detect override
input        por_ovrd;           // Input DFT: POR override

input [$clog2(NCH):0] dig_test_sel; // Input DFT: Selects source of debug signals
                                 // driven to the dig_test_bus []
                                 // AUX channel (=0) or the IO channel (=1)

output [7:0] dig_test_bus;       // Output DFT: Debug signals from AIB IO
                                 // and AUX Channels (designer defined)

// Interface for ATPG override of BSR JTAG chain
//
output [NCH-1:0]                 atpg_bsr_scan_out;
input  [NCH-1:0]                 atpg_bsr_ovrd_mode;
input  [NCH-1:0]                 atpg_bsr_scan_in;
input  [NCH-1:0]                 atpg_bsr_scan_shift;
input  [NCH-1:0]                 atpg_bsr_scan_shift_clk;

/*AUTOWIRE*/

/*AUTOREGINPUT*/

//------------------------------------------------------------------------------
// Instantiate Intrinisx AIB PHY module
//

/*
wire vcc_dig = 1'b1;
wire vcc_io  = 1'b1;
wire vss_ana = 1'b0;
*/

/*
itrx_aib_phy_mc AUTO_TEMPLATE (
                   .adapt_rstn          (adap_irstb[]),
 );*/

itrx_aib_phy_mc #(.NCH(NCH))
   u_itrx_aib_phy (/*AUTOINST*/
                   // Outputs
                   .rx_data             (rx_data/*[NCH-1:0][NDAT-1:0]*/),
                   .rx_clk              (rx_clk[NCH-1:0]),
                   .por_out             (por_out),
                   .device_detect       (device_detect),
                   .rstn_out            (rstn_out[NCH-1:0]),
                   .adap_rstn_out       (adap_rstn_out[NCH-1:0]),
                   .jtag_scan_out       (jtag_scan_out),
                   .dig_test_bus        (dig_test_bus[7:0]),
                   .atpg_bsr_scan_out   (atpg_bsr_scan_out[NCH-1:0]),
                   // Inouts
                   .ubump               (ubump/*[NCH-1:0][NBMP-1:0]*/),
                   .ubump_aux           (ubump_aux[1:0]),
                   // Inputs
                   .tx_data             (tx_data/*[NCH-1:0][NDAT-1:0]*/),
                   .tx_clk              (tx_clk[NCH-1:0]),
                   .por_in              (por_in),
                   .por_vcc_io          (por_vcc_io),
                   .por_vcc_dig         (por_vcc_dig),
                   .adapt_rstn          (adap_irstb[NCH-1:0]),   // Templated
                   .rstn_in             (rstn_in[NCH-1:0]),
                   .adap_rstn_in        (adap_rstn_in[NCH-1:0]),
                   .ms_nsl              (ms_nsl),
                   .iddr_enable         (iddr_enable[NCH-1:0]),
                   .idat_selb           (idat_selb/*[NCH-1:0][FBMP-1:0]*/),
                   .ipdrv               (ipdrv/*[NCH-1:0][1:0]*/),
                   .indrv               (indrv/*[NCH-1:0][1:0]*/),
                   .ipdrv_clk           (ipdrv_clk/*[NCH-1:0][1:0]*/),
                   .indrv_clk           (indrv_clk/*[NCH-1:0][1:0]*/),
                   .ipdrv_rst           (ipdrv_rst/*[NCH-1:0][1:0]*/),
                   .indrv_rst           (indrv_rst/*[NCH-1:0][1:0]*/),
                   .rxen                (rxen/*[NCH-1:0][FBMP-1:0][2:0]*/),
                   .txen                (txen/*[NCH-1:0][FBMP-1:0]*/),
                   .sdr_dly_adjust      (sdr_dly_adjust/*[NCH-1:0][DLYW-1:0]*/),
                   .ddr_dly_adjust      (ddr_dly_adjust/*[NCH-1:0][DLYW-1:0]*/),
                   .redun_engage        (redun_engage/*[NCH-1:0][HNBMP-1:0]*/),
                   .jtag_scan_en        (jtag_scan_en),
                   .jtag_clkdr          (jtag_clkdr),
                   .jtag_rstn           (jtag_rstn),
                   .jtag_rstn_en        (jtag_rstn_en),
                   .jtag_clksel         (jtag_clksel),
                   .jtag_intest         (jtag_intest),
                   .jtag_mode           (jtag_mode),
                   .jtag_weakpd         (jtag_weakpd),
                   .jtag_weakpu         (jtag_weakpu),
                   .jtag_scan_in        (jtag_scan_in),
                   .device_detect_ovrd  (device_detect_ovrd),
                   .por_ovrd            (por_ovrd),
                   .dig_test_sel        (dig_test_sel[$clog2(NCH):0]),
                   .atpg_bsr_ovrd_mode  (atpg_bsr_ovrd_mode[NCH-1:0]),
                   .atpg_bsr_scan_in    (atpg_bsr_scan_in[NCH-1:0]),
                   .atpg_bsr_scan_shift_clk(atpg_bsr_scan_shift_clk[NCH-1:0]),
                   .atpg_bsr_scan_shift (atpg_bsr_scan_shift[NCH-1:0]));

endmodule

// Local Variables:
// verilog-library-files:("../ip/itrx_aib_phy/rtl/itrx_aib_phy_mc.sv")
// End:
