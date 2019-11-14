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
// Filename       : itrx_aib_phy_mc.sv
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

  AIB = AIB Advanced Interface Bus (Chiplet to Chiplet bus interface)

  One (1) AIB IO Channel  is instantiated.
  One (1) AIB AUX Channel is instantiated.


*/
//lint_checking IOCOMB off
module itrx_aib_phy_mc(/*AUTOARG*/
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
parameter NCH = 32'd2;          // Number of Channels

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

//lint: The signal is a one pin bus ([NCH-1:0] declarations)
//lint_checking ONPNSG off

inout [NCH-1:0][NBMP-1:0] ubump; // IO chan uBumps
inout [1:0] ubump_aux;// AUX chan uBumps
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
// Source of AIB IO Channel por_vcc_io input only for AIB SLAVE sl2sl
input  por_vcc_io;    // Input Power on reset VCC of IO power domain
                      // (to Analog IO Buffer, =0 for normal operation)

input  por_vcc_dig;   // Input Power on reset VCC of digital logic power domain
                      // (to Analog IO Buffer, =0 for normal ops)

//output device_detect_n; // Output Device detect  (active low)
output device_detect; // Output Device detect
                      // (Monitored by slave. Unused by master and driven to 0)

input  [NCH-1:0] adapt_rstn;    // Input AIB PHY reset (active low); Intel AIB spec ADAPT_RSTN
                      // (resets this local AIB PHY driving the internal Intel AIB spec irstb)
                      // aka adap_irstb

input  [NCH-1:0] rstn_in;       // Input AIB PHY reset (active low)
                      // (ms_rstn or sl_rstn as driven by the reset controller; active low)

output [NCH-1:0] rstn_out;      // Output AIB PHY reset output
                      // (ms_rstn or sl_rstn monitored by the reset controller; active low)

input  [NCH-1:0] adap_rstn_in;  // Input Adapter reset
                      // (ms_adapter_rstn or sl_adapter_rstn as driven by the reset controller; active low)

output [NCH-1:0] adap_rstn_out; // Output Adapter reset output
                      // (ms_adapter_rstn or sl_adapter_rstn monitored by the reset controller; active low)


//------------------------------------------------------------------------------
// IO Cell Configuration (asynchronous/static).
//
input                  ms_nsl;         // Input Master Not Slave signal
                                       //  0=Slave, 1=Master

input [NCH-1:0]        iddr_enable;    // Input DDR mode select

wire  [NCH-1:0]        iddr_enable_clk = {NCH{1'b1}};// Input DDR mode select

input [NCH-1:0][FBMP-1:0]       idat_selb;      // Input Asynchronous TX mode select
                                       // for each AIB IO cell

input [NCH-1:0]  [1:0] ipdrv;          // Input ubump TX drive strength high
                                       // (P-driver) selection.

input [NCH-1:0]  [1:0] indrv;          // Input ubump TX drive strength low
                                       // (N-driver) selection.

input [NCH-1:0]  [1:0] ipdrv_clk;      // Input ubump TX drive strength high
                                       // (P-driver) selection.

input [NCH-1:0]  [1:0] indrv_clk;      // Input ubump TX drive strength low
                                       // (N-driver) selection.

input [NCH-1:0]  [1:0] ipdrv_rst;      // Input ubump TX drive strength high
                                       // (P-driver) selection.

input [NCH-1:0]  [1:0] indrv_rst;      // Input ubump TX drive strength low
                                       // (N-driver) selection.

input [NCH-1:0] [FBMP-1:0] [2:0] rxen;           // Input Receive enable selection for
                                       // each AIB IO cell (encoded)

input [NCH-1:0] [FBMP-1:0]       txen;           // Input Transmit enable for each AIB IO

input [NCH-1:0] [DLYW-1:0] sdr_dly_adjust; // Input Adjustment setting for
                                       // programmable RX inclk delay
                                       // (DLL manual mode) for SDR mode

input [NCH-1:0] [DLYW-1:0] ddr_dly_adjust; // Input Adjustment setting for
                                       // programmable RX inclk delay
                                       // (DLL manual mode) for DDR mode

// Redundancy engage controls for each pair of functional/logical AIB IOs
//
input  [NCH-1:0] [HNBMP-1:0]      redun_engage;


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

input  [$clog2(NCH):0]      dig_test_sel;       // Input DFT: Selects source of debug signals
                                 // driven to the dig_test_bus []
                                 // AUX channel (=0) or the IO channel (=1)

output [7:0] dig_test_bus;       // Output DFT: Debug signals from AIB IO
                                 // and AUX Channels (designer defined)

// Over-ride control signal from ATPG controller
input  [NCH-1:0]        atpg_bsr_ovrd_mode;

// ATPG signals from codec
//
input  [NCH-1:0]        atpg_bsr_scan_in;
input  [NCH-1:0]        atpg_bsr_scan_shift_clk;
input  [NCH-1:0]        atpg_bsr_scan_shift;
// ATPG signal to codec
output [NCH-1:0]        atpg_bsr_scan_out;


//output       dll_lock;

/*AUTOREGINPUT*/


/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    device_detect_n_aux;    // From u_aux_chan of itrx_aib_phy_aux_chan.v
wire [7:0]              dig_test_bus_aux;       // From u_aux_chan of itrx_aib_phy_aux_chan.v
wire                    o_osc_clk;              // From u_aux_chan of itrx_aib_phy_aux_chan.v
wire                    por_aux_vcc_io;         // From u_aux_chan of itrx_aib_phy_aux_chan.v
// End of automatics

wire [NCH-1:0]          dll_lock;               // From u_io_chan of itrx_aib_phy_io_chan.v

wire [NCH-1:0]          atpg_jtag_clkdr;
wire [NCH-1:0]          atpg_jtag_scan_en;
wire [NCH-1:0]          atpg_jtag_scanin;

wire [NCH-1:0] [7:0] dig_test_bus_io;
wire           [7:0] dig_test_bus_io_mux; // bus mux


wire [NCH-1:0] dll_enable   = {NCH{1'b0}};
wire [NCH-1:0] dll_lock_req = {NCH{1'b0}};

generate
  if (NCH == 1) begin : gc1
    assign dig_test_bus_io_mux = dig_test_bus_io[0];
  end else      begin : gc2
    assign dig_test_bus_io_mux = dig_test_bus_io[dig_test_sel[$clog2(NCH)-1:0]];
  end
endgenerate

// MS bit selects IO Channel
assign dig_test_bus =
  dig_test_sel[$clog2(NCH)] ? dig_test_bus_io_mux
                            : dig_test_bus_aux;


//-----------------------------------------------------------------------------
// Connect JTAG chain
//
wire [NCH-1:0] jtag_scanin;
wire [NCH-1:0] jtag_scanout;
//lint_checking ONPNSG on
assign jtag_scan_out = jtag_scanout[NCH-1];
//-----------------------------------------------------------------------------

//lint_checking NODEFD off
`ifdef AIB_ID_REMAP
  `ifndef AIB_ID_REMAP_IOCHAN
    `define AIB_ID_REMAP_PERMUTE // Permute instance connections only if NOT internal chan remap.
  `endif
`endif
//lint_checking NODEFD on

genvar cc;
generate
for (cc=0; cc<NCH; cc=cc+1) begin : gl_ch

if (cc == 0) begin : gc_j0
 assign jtag_scanin[cc] = jtag_scan_in;
end else begin : gc_jn
 assign jtag_scanin[cc] = jtag_scanout[cc-1];
end

//-----------------------------------------------------------------------------
// ATPG over-ride the BSR module instantiation
//

itrx_aib_phy_atpg_bsr
  u_itrx_aib_phy_atpg_bsr(// Outputs
                          .atpg_bsr_scan_out    (atpg_bsr_scan_out[cc]),
                          .atpg_jtag_clkdr      (atpg_jtag_clkdr[cc]),
                          .atpg_jtag_scan_en    (atpg_jtag_scan_en[cc]),
                          .atpg_jtag_scanin     (atpg_jtag_scanin[cc]),
                          // Inputs
                          .atpg_bsr_ovrd_mode   (atpg_bsr_ovrd_mode[cc]),
                          .atpg_bsr_scan_in     (atpg_bsr_scan_in[cc]),
                          .atpg_bsr_scan_shift_clk(atpg_bsr_scan_shift_clk[cc]),
                          .atpg_bsr_scan_shift  (atpg_bsr_scan_shift[cc]),
                          .jtag_clkdr           (jtag_clkdr),
                          .jtag_scan_en         (jtag_scan_en),
                          .jtag_scanin          (jtag_scanin[cc]),
                          .jtag_scanout         (jtag_scanout[cc]));

//-----------------------------------------------------------------------------


itrx_aib_phy_io_chan
  u_io_chan(
// Remap AIB IDs to match Newer V1.0 Intel AIB Spec
//
`ifdef AIB_ID_REMAP_PERMUTE
            .ubump                      ({    ubump[cc][89:70],     ubump[cc][19:0],     ubump[cc][69:20]}),
            .txen                       ({     txen[cc][87:68],      txen[cc][19:0],      txen[cc][67:20]}),
            .rxen                       ({     rxen[cc][87:68],      rxen[cc][19:0],      rxen[cc][67:20]}),
            .idat_selb                  ({idat_selb[cc][87:68], idat_selb[cc][19:0], idat_selb[cc][67:20]}),

`else
            .ubump                      (ubump[cc][NBMP-1:0]),
            .rxen                       (rxen[cc]/*[FBMP-1:0][2:0]*/),
            .txen                       (txen[cc][FBMP-1:0]),
            .idat_selb                  (idat_selb[cc][FBMP-1:0]),
`endif
            // Outputs
            .rstn_out                   (rstn_out[cc]),
            .adap_rstn_out              (adap_rstn_out[cc]),
            .rx_clk                     (rx_clk[cc]),
            .dll_lock                   (dll_lock[cc]),
            .jtag_scanout               (jtag_scanout[cc]),
            .rx_data                    (rx_data[cc]),
            .dig_test_bus_io            (dig_test_bus_io[cc]),
            // Inputs
            .por_vcc_io                 (por_aux_vcc_io),
            .por_vcc_dig                (por_vcc_dig),
            .rstn_in                    (rstn_in[cc]),
            .irstb_in                   (adapt_rstn[cc]),
            .tx_irstb_in                (adapt_rstn[cc]),
            .rx_irstb_in                (adapt_rstn[cc]),
            .adap_rstn_in               (adap_rstn_in[cc]),
            .tx_clk                     (tx_clk[cc]),
            .dll_enable                 (dll_enable[cc]),
            .dll_lock_req               (dll_lock_req[cc]),
            .iredn_engage               (redun_engage[cc]),
            .jtag_clkdr                 (atpg_jtag_clkdr[cc]),
            .jtag_clksel                (jtag_clksel),
            .jtag_intest                (jtag_intest),
            .jtag_mode                  (jtag_mode),
            .jtag_scan_en               (atpg_jtag_scan_en[cc]),
            .jtag_scanin                (atpg_jtag_scanin[cc]),
            .jtag_weakpdn               (jtag_weakpd),
            .jtag_weakpu                (jtag_weakpu),
            .jtag_rstn                  (jtag_rstn),
            .jtag_rstn_en               (jtag_rstn_en),
            .tx_data                    (tx_data[cc]),
            .sdr_dly_adjust             (sdr_dly_adjust[cc]),
            .ddr_dly_adjust             (ddr_dly_adjust[cc]),
            .iddr_enable                (iddr_enable[cc]),
            .iddr_enable_clk            (iddr_enable_clk[cc]),
            .indrv                      (indrv[cc]),
            .ipdrv                      (ipdrv[cc]),
            .indrv_clk                  (indrv_clk[cc]),
            .ipdrv_clk                  (ipdrv_clk[cc]),
            .indrv_rst                  (indrv_rst[cc]),
            .ipdrv_rst                  (ipdrv_rst[cc]));
//lint_checking DIFRST on

end
endgenerate

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
