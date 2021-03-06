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
// Filename       : itrx_aib_phy.sv
// Description    : Top-Level wrapper for the Intrinsix AIB PHY
//
// ==========================================================================
//
//    $Rev:: 5810                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-06-24 16:29:21 -0400#$: Date of last commit
//
// ==========================================================================

/*
Detailed Description:

  This module is the top-level of Intrinsix AIB PHY configurable IP.

  AIB = AIB Avalon Interface Bus (Chiplet to Chiplet bus interface)

  One (1) AIB IO Channel  is instantiated.
  One (1) AIB AUX Channel is instantiated.


*/
//lint_checking IOCOMB off
module itrx_aib_phy(/*AUTOARG*/
   // Outputs
   rx_data, rx_clk, por_out, device_detect, rstn_out, adap_rstn_out,
   jtag_scan_out, dig_test_bus, atpg_bsr_scan_out,
   // Inouts
   ubump, ubump_aux,
   // Inputs
   tx_data, tx_clk, por_in, por_vcc_io, por_vcc_dig, adapt_rstn,
   rstn_in, adap_rstn_in, ms_nsl, iddr_enable, idat_selb, ipdrv,
   indrv, ipdrv_clk, indrv_clk, ipdrv_rst, indrv_rst, rxen, txen,
   sdr_dly_adjust, ddr_dly_adjust, redun_engage, jtag_scan_en,
   jtag_clkdr, jtag_rstn, jtag_rstn_en, jtag_clksel, jtag_intest,
   jtag_mode, jtag_weakpd, jtag_weakpu, jtag_scan_in,
   device_detect_ovrd, por_ovrd, dig_test_sel, atpg_bsr_ovrd_mode,
   atpg_bsr_scan_in, atpg_bsr_scan_shift_clk, atpg_bsr_scan_shift
   );
//lint_checking IOCOMB on

parameter NDAT = 32'd80;         // Number of Sync Data uBumps in chan
parameter NBMP = NDAT + 32'd10;  // Number of uBumps in chan

localparam HNBMP = NBMP/32'd2;    // Half the # of uBumps in chan
localparam FBMP  = NBMP - 32'd2;  // # of functional/logical uBumps (wo spares)
//localparam XBMP  = FBMP/32'd2;    // # of RX or TX uBumps
//localparam RBMP  = HNBMP - 32'd2; // # of Redundancy Controls (wo end pairs)

localparam DLYW = 32'd10;        // Delay adjust bit width


//------------------------------------------------------------------------------
// MicroBumps
//

//lint: ubump is inout, ubump is multi-driven
//lint_checking IOPNTA MULWIR off

//lint_checking MLTDRV off
/*
inout                   vcc_dig;
inout                   vcc_io;
inout                   vss_ana;
*/
//lint_checking MLTDRV on

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

//------------------------------------------------------------------------------
// Resets and Reset Control (asynchronous)
//
input  por_in;        // Input Slave: Input Power on reset (POR)
                      // (Driven by the slave from an external POR controller.)
                      // Master: unused (tie low)

output por_out;       // Output Slave: unused (=0)
                      //        Master: POR
                      // (Monitored by master in an external POR controller.)
// Source of AIB IO Channel por_vcc_io input only for AIB SLAVE sl2sl
input  por_vcc_io;    // Input Power on reset VCC of IO power domain
                      // (to Analog IO Buffer, =0 for normal operation)

input  por_vcc_dig;   // Input Power on reset VCC of digital logic power domain
                      // (to Analog IO Buffer, =0 for normal ops)

output device_detect; // Output Device detect
                      // (Monitored by slave. Unused by master and driven to 0)

input  adapt_rstn;    // Input AIB PHY reset (active low); Intel AIB spec ADAPT_RSTN
                      // (resets this local AIB PHY driving the internal Intel AIB spec irstb)

input  rstn_in;       // Input AIB PHY reset (active low)
                      // (ms_rstn or sl_rstn as driven by the reset controller; active low)

output rstn_out;      // Output AIB PHY reset output
                      // (ms_rstn or sl_rstn monitored by the reset controller; active low)

input  adap_rstn_in;  // Input Adapter reset
                      // (ms_adapter_rstn or sl_adapter_rstn as driven by the reset controller; active low)

output adap_rstn_out; // Output Adapter reset output
                      // (ms_adapter_rstn or sl_adapter_rstn monitored by the reset controller; active low)


//------------------------------------------------------------------------------
// IO Cell Configuration (asynchronous/static).
//
input                  ms_nsl;         // Input Master Not Slave signal
                                       //  0=Slave, 1=Master

input                  iddr_enable;    // Input DDR mode select

wire                   iddr_enable_clk = 1'b1;// Input DDR mode select

input [FBMP-1:0]       idat_selb;      // Input Asynchronous TX mode select
                                       // for each AIB IO cell

input            [1:0] ipdrv;          // Input ubump TX drive strength high
                                       // (P-driver) selection.

input            [1:0] indrv;          // Input ubump TX drive strength low
                                       // (N-driver) selection.

input            [1:0] ipdrv_clk;      // Input ubump TX drive strength high
                                       // (P-driver) selection.

input            [1:0] indrv_clk;      // Input ubump TX drive strength low
                                       // (N-driver) selection.

input            [1:0] ipdrv_rst;      // Input ubump TX drive strength high
                                       // (P-driver) selection.

input            [1:0] indrv_rst;      // Input ubump TX drive strength low
                                       // (N-driver) selection.

input [FBMP-1:0] [2:0] rxen;           // Input Receive enable selection for
                                       // each AIB IO cell (encoded)

input [FBMP-1:0]       txen;           // Input Transmit enable for each AIB IO

input       [DLYW-1:0] sdr_dly_adjust; // Input Adjustment setting for
                                       // programmable RX inclk delay
                                       // (DLL manual mode) for SDR mode

input       [DLYW-1:0] ddr_dly_adjust; // Input Adjustment setting for
                                       // programmable RX inclk delay
                                       // (DLL manual mode) for DDR mode

// Redundancy engage controls for each pair of functional/logical AIB IOs
//
input  [HNBMP-1:0]      redun_engage;


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

input        dig_test_sel;       // Input DFT: Selects source of debug signals
                                 // driven to the dig_test_bus []
                                 // AUX channel (=0) or the IO channel (=1)

output [7:0] dig_test_bus;       // Output DFT: Debug signals from AIB IO
                                 // and AUX Channels (designer defined)

// Over-ride control signal from ATPG controller
input                    atpg_bsr_ovrd_mode;

// ATPG signals from codec
//
input                    atpg_bsr_scan_in;
input                    atpg_bsr_scan_shift_clk;
input                    atpg_bsr_scan_shift;
// ATPG signal to codec
output                   atpg_bsr_scan_out;


//output       dll_lock;

/*AUTOREGINPUT*/


/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    atpg_jtag_clkdr;        // From u_itrx_aib_phy_atpg_bsr of itrx_aib_phy_atpg_bsr.v
wire                    atpg_jtag_scan_en;      // From u_itrx_aib_phy_atpg_bsr of itrx_aib_phy_atpg_bsr.v
wire                    atpg_jtag_scanin;       // From u_itrx_aib_phy_atpg_bsr of itrx_aib_phy_atpg_bsr.v
wire                    device_detect_n_aux;    // From u_aux_chan of itrx_aib_phy_aux_chan.v
wire [7:0]              dig_test_bus_aux;       // From u_aux_chan of itrx_aib_phy_aux_chan.v
wire [7:0]              dig_test_bus_io;        // From u_io_chan of itrx_aib_phy_io_chan.v
wire                    dll_lock;               // From u_io_chan of itrx_aib_phy_io_chan.v
wire                    jtag_scanout;           // From u_io_chan of itrx_aib_phy_io_chan.v
wire                    o_osc_clk;              // From u_aux_chan of itrx_aib_phy_aux_chan.v
wire                    por_aux_vcc_io;         // From u_aux_chan of itrx_aib_phy_aux_chan.v
// End of automatics


wire dll_enable = 1'b0;
wire dll_lock_req = 1'b0;

assign dig_test_bus = dig_test_sel ? dig_test_bus_io : dig_test_bus_aux;

//-----------------------------------------------------------------------------
// Connect JTAG chain
//
wire jtag_scanin     = jtag_scan_in;
assign jtag_scan_out = jtag_scanout;
//-----------------------------------------------------------------------------

// Block Comment-out irstb synchronizers since after reset is released
// AIB data path registers are flushed in the bring-up sequence.
/*
wire tx_adapt_rstn;
wire rx_adapt_rstn;
wire tie_low = 1'b0;

//lint_checking DIFCLK DIFRST off
itrx_aib_phy_sync_rstn
  u_tx_sync_rstn (// Outputs
                  .dout                 (tx_adapt_rstn),
                  // Inputs
                  .scan_mode            (tie_low),
                  .rst_n                (adapt_rstn),
                  .clk                  (tx_clk));

itrx_aib_phy_sync_rstn
  u_rx_sync_rstn (// Outputs
                  .dout                 (rx_adapt_rstn),
                  // Inputs
                  .scan_mode            (tie_low),
                  .rst_n                (adapt_rstn),
                  .clk                  (rx_clk));
//lint_checking DIFCLK on
*/

//-----------------------------------------------------------------------------
// ATPG over-ride the BSR module instantiation
//

itrx_aib_phy_atpg_bsr
  u_itrx_aib_phy_atpg_bsr(/*AUTOINST*/
                          // Outputs
                          .atpg_bsr_scan_out    (atpg_bsr_scan_out),
                          .atpg_jtag_clkdr      (atpg_jtag_clkdr),
                          .atpg_jtag_scan_en    (atpg_jtag_scan_en),
                          .atpg_jtag_scanin     (atpg_jtag_scanin),
                          // Inputs
                          .atpg_bsr_ovrd_mode   (atpg_bsr_ovrd_mode),
                          .atpg_bsr_scan_in     (atpg_bsr_scan_in),
                          .atpg_bsr_scan_shift_clk(atpg_bsr_scan_shift_clk),
                          .atpg_bsr_scan_shift  (atpg_bsr_scan_shift),
                          .jtag_clkdr           (jtag_clkdr),
                          .jtag_scan_en         (jtag_scan_en),
                          .jtag_scanin          (jtag_scanin),
                          .jtag_scanout         (jtag_scanout));

//-----------------------------------------------------------------------------


/*
itrx_aib_phy_io_chan AUTO_TEMPLATE (
  .jtag_weakpdn      (jtag_weakpd),
  .iredn_engage      (redun_engage[]),
  .iredn_engage_outs (redun_engage_outs[]),
  .irstb_in          (adapt_rstn),
  .tx_irstb_in       (adapt_rstn),
  .rx_irstb_in       (adapt_rstn),
  .por_vcc_io        (por_aux_vcc_io),
  .jtag_clkdr        (atpg_jtag_clkdr),
  .jtag_scan_en      (atpg_jtag_scan_en),
  .jtag_scanin       (atpg_jtag_scanin),
 ); */

itrx_aib_phy_io_chan
  u_io_chan(

// Remap AIB IDs to match Newer V1.0 Intel AIB Spec
//

/*
                                  | Permuted
`AIB_ID_REMAP|`AIB_ID_REMAP_IOCHAN|`AIB_ID_REMAP_PERMUTE
-------------+--------------------+--------------------
  0            0                   0         - DV Tested (orig)
  1            0                   1         - DV Tested (new)
  0            1                   0         - Don't use for _ext
  1            1                   0         - New IO Chan Macro impl

*/

//lint_checking NODEFD off
`ifdef AIB_ID_REMAP
  `ifndef AIB_ID_REMAP_IOCHAN
    `define AIB_ID_REMAP_PERMUTE // Permute instance connections only if NOT internal chan remap.
  `endif
`endif
//lint_checking NODEFD on

`ifdef AIB_ID_REMAP_PERMUTE
            .ubump                      ({    ubump[89:70],     ubump[19:0],     ubump[69:20]}),
            .txen                       ({     txen[87:68],      txen[19:0],      txen[67:20]}),
            .rxen                       ({     rxen[87:68],      rxen[19:0],      rxen[67:20]}),
            .idat_selb                  ({idat_selb[87:68], idat_selb[19:0], idat_selb[67:20]}),
`else
            .ubump                      (ubump[NBMP-1:0]),
            .rxen                       (rxen/*[FBMP-1:0][2:0]*/),
            .txen                       (txen[FBMP-1:0]),
            .idat_selb                  (idat_selb[FBMP-1:0]),
`endif
            /*AUTOINST*/
            // Outputs
            .rstn_out                   (rstn_out),
            .adap_rstn_out              (adap_rstn_out),
            .rx_clk                     (rx_clk),
            .dll_lock                   (dll_lock),
            .jtag_scanout               (jtag_scanout),
            .rx_data                    (rx_data[NDAT-1:0]),
            .dig_test_bus_io            (dig_test_bus_io[7:0]),
            // Inouts
            // Inputs
            .por_vcc_io                 (por_aux_vcc_io),        // Templated
            .por_vcc_dig                (por_vcc_dig),
            .rstn_in                    (rstn_in),
            .irstb_in                   (adapt_rstn),            // Templated
            .tx_irstb_in                (adapt_rstn),            // Templated
            .rx_irstb_in                (adapt_rstn),            // Templated
            .adap_rstn_in               (adap_rstn_in),
            .tx_clk                     (tx_clk),
            .dll_enable                 (dll_enable),
            .dll_lock_req               (dll_lock_req),
            .iredn_engage               (redun_engage[HNBMP-1:0]), // Templated
            .jtag_clkdr                 (atpg_jtag_clkdr),       // Templated
            .jtag_clksel                (jtag_clksel),
            .jtag_intest                (jtag_intest),
            .jtag_mode                  (jtag_mode),
            .jtag_scan_en               (atpg_jtag_scan_en),     // Templated
            .jtag_scanin                (atpg_jtag_scanin),      // Templated
            .jtag_weakpdn               (jtag_weakpd),           // Templated
            .jtag_weakpu                (jtag_weakpu),
            .jtag_rstn                  (jtag_rstn),
            .jtag_rstn_en               (jtag_rstn_en),
            .tx_data                    (tx_data[NDAT-1:0]),
            .sdr_dly_adjust             (sdr_dly_adjust[DLYW-1:0]),
            .ddr_dly_adjust             (ddr_dly_adjust[DLYW-1:0]),
            .iddr_enable                (iddr_enable),
            .iddr_enable_clk            (iddr_enable_clk),
            .indrv                      (indrv[1:0]),
            .ipdrv                      (ipdrv[1:0]),
            .indrv_clk                  (indrv_clk[1:0]),
            .ipdrv_clk                  (ipdrv_clk[1:0]),
            .indrv_rst                  (indrv_rst[1:0]),
            .ipdrv_rst                  (ipdrv_rst[1:0]));
//lint_checking DIFRST on

/*
itrx_aib_phy_aux_chan AUTO_TEMPLATE (
             .device_detect             (device_detect_n_aux),
 ); */

itrx_aib_phy_aux_chan
  u_aux_chan(/*AUTOINST*/
             // Outputs
             .dig_test_bus_aux          (dig_test_bus_aux[7:0]),
             .por_out                   (por_out),
             .device_detect             (device_detect_n_aux),   // Templated
             .o_osc_clk                 (o_osc_clk),
             .por_aux_vcc_io            (por_aux_vcc_io),
             // Inouts
             .ubump_aux                 (ubump_aux[1:0]),
             // Inputs
             .ms_nsl                    (ms_nsl),
             .por_in                    (por_in),
             .por_ovrd                  (por_ovrd),
             .device_detect_ovrd        (device_detect_ovrd),
             .por_vcc_io                (por_vcc_io));

// device_detect is inverted internal to aux_chan so invert here again.
// It is inverted so that if VCC_IO is not on device_detect = 0.
assign device_detect = ~device_detect_n_aux;

wire unused_ok = &{1'b1, dll_lock, o_osc_clk};

endmodule
