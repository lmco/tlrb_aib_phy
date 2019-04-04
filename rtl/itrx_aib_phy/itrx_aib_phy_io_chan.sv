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
// Filename       : itrx_aib_phy_io_chan.v
// Description    : AIB IO Channel (Connected Array of AIB IO Cells)
//
// ==========================================================================
//
//    $Rev:: 5429                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-12-11 16:46:02 -0500#$: Date of last commit
//
// ==========================================================================

//lint halstruct: Comb detected between top-level input 'ubump[x]' and ubump[x]'
//lint_checking IOCOMB off
module itrx_aib_phy_io_chan (/*AUTOARG*/
   // Outputs
   rstn_out, adap_rstn_out, rx_clk, dll_lock, jtag_scanout, rx_data,
   dig_test_bus_io,
   // Inouts
   ubump,
   // Inputs
   por_vcc_io, por_vcc_dig, rstn_in, irstb_in, tx_irstb_in,
   rx_irstb_in, adap_rstn_in, tx_clk, dll_enable, dll_lock_req,
   iredn_engage, jtag_clkdr, jtag_clksel, jtag_intest, jtag_mode,
   jtag_scan_en, jtag_scanin, jtag_weakpdn, jtag_weakpu, jtag_rstn,
   jtag_rstn_en, tx_data, sdr_dly_adjust, ddr_dly_adjust, idat_selb,
   rxen, txen, iddr_enable, iddr_enable_clk, indrv, ipdrv, indrv_clk,
   ipdrv_clk, indrv_rst, ipdrv_rst
   );
//lint_checking IOCOMB on


//------------------------------------------------------------------------------
// Parameters
//
parameter  NBMP  = 32'd90;              // Number of uBumps in chan
parameter  DLYW  = 32'd10;              // Bit width of manual DLL delay adjust
localparam NSPR  = 32'd2;               // Number of Spares per chan (AIB const)
localparam NDAT  = NBMP - NSPR - 32'd8; // Number of Sync Data uBumps in chan

//`ifndef DDR_MAP99
//localparam HNDAT = NDAT/32'd2;          // Half NDAT
//`endif

localparam HNBMP = NBMP/32'd2;          // Half the # of uBumps in chan
localparam FBMP  = NBMP - 32'd2;        // # of functional uBumps (wo spares)

// FIX ME: Add std cell buffer for clock tree placeholder
// FIX ME: May need to write a program to generate the parameter set?
// There really needs to be a separate IP spec for describing builds of 
// AIB configurations.
// Assume ever bump has a bump ID (0 - (NBMP-1))
// CFG inputs (ports) are 2 less than NBMP to account for spares.
// Map CFG input ID directly to bump ID (starting at 0 which is the "bottom" end towards
// AUX) until the spare position is encountered, 
// then subtract 2 from the bump ID to get the corresponding CFG input ID.
// CFG Inputs (6) include: iddr_enable, idat_selb, txen, rxen, ipdrv, indrv.
// The CFG cell inputs to the spares are NOT from from CFG port inputs.  
// Rather, the CFG inputs to spare cells come from the CFG inputs of other
// functional cells which the spares are redundantly protecting.
// Put the logic that drives multiple CFG inputs with a common signal above this level.

//------------------------------------------------------------------------------
// Parameters defined in included file:
//
// parameter            [31:0] NULLB
// parameter            [31:0] SPARE_POS
// parameter            [31:0] RX_DAT_CLK_POS
// parameter            [31:0] TX_DAT_CLK_POS
// parameter            [31:0] RX_RST_POS
// parameter            [31:0] TX_RST_POS
// parameter            [31:0] RX_ARST_POS
// parameter            [31:0] TX_ARST_POS
// parameter [NBMP-1:0] [31:0] REDN_ORDERI
// parameter [NBMP-1:0] [31:0] REDN_ORDERO
// parameter [NBMP-1:0] [31:0] JTAG_ORDER
// parameter            [31:0] JTAG_FIRST
// parameter            [31:0] JTAG_LAST
// parameter [NBMP-1:0] [31:0] RED_ENGAGE_MAP
// parameter            [31:0] RX_DAT_CLK_RED_ENGAGE
// parameter            [31:0] TX_CLK_GROUP
// parameter            [31:0] RX_CLK_GROUP
// parameter [NBMP-1:0] [31:0] TX_DAT_GROUP
// parameter [NBMP-1:0] [31:0] RX_DAT_GROUP
//

//`ifdef AIB_MAP99
`include "itrx_aib_phy_io_chan_param2.vh"
//`else
//`include "itrx_aib_phy_io_chan_params.vh"
//`endif
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------

input                    por_vcc_io;
input                    por_vcc_dig;

input                    rstn_in;
input                    irstb_in;
input                    tx_irstb_in;
input                    rx_irstb_in;
input                    adap_rstn_in;

output                   rstn_out;
output                   adap_rstn_out;

//------------------------------------------------------------------------------
// IO to/from MicroBump
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

inout [NBMP-1:0]         ubump;
//lint_checking IOPNTA MULWIR on


// Clock I/O ports
//
input                    tx_clk;
output                   rx_clk;

// DLL I/O ports
output                   dll_lock;
input                    dll_enable;
input                    dll_lock_req;

// Redundancy engage controls for each pair of functional/logical AIB IOs
//
input  [HNBMP-1:0]       iredn_engage;

//------------------------------------------------------------------------------
// JTAG I/O
//
input                    jtag_clkdr;
input                    jtag_clksel;
input                    jtag_intest;
input                    jtag_mode;
input                    jtag_scan_en;
input                    jtag_scanin;
input                    jtag_weakpdn;
input                    jtag_weakpu;
output                   jtag_scanout;
input                    jtag_rstn;
input                    jtag_rstn_en;
//------------------------------------------------------------------------------


input  [NDAT-1:0]        tx_data;
output [NDAT-1:0]        rx_data;

input  [DLYW-1:0]        sdr_dly_adjust;
input  [DLYW-1:0]        ddr_dly_adjust;

output [7:0]             dig_test_bus_io;

//------------------------------------------------------------------------------
// IO Cell CFG functional Inputs
//
input  [FBMP-1:0]        idat_selb;
input  [FBMP-1:0] [2:0]  rxen;
input  [FBMP-1:0]        txen;

input                    iddr_enable;
input                    iddr_enable_clk;

input             [1:0]  indrv;
input             [1:0]  ipdrv;

input             [1:0]  indrv_clk;
input             [1:0]  ipdrv_clk;
input             [1:0]  indrv_rst;
input             [1:0]  ipdrv_rst;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Internal wires to be assigned to (or connected to sub-mods)
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// IO Cell Output ports
//lint_checking NUMSUF off

wire [NBMP-1:0]          nrml_odat0;
wire [NBMP-1:0]          nrml_odat1;
wire [NBMP-1:0]          nrml_odat_asyn;

wire [NBMP-1:0]          oclk;
wire [NBMP-1:0]          oclk_b;

wire [NBMP-1:0]          rmux_oclk;
wire [NBMP-1:0]          rmux_oclk_b;

wire [NBMP-1:0]          odat0;
wire [NBMP-1:0]          odat1;
wire [NBMP-1:0]          odat_asyn;

wire [NBMP-1:0]          jtag_scanout_cell;
wire [NBMP-1:0]          jtag_clkdr_n;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// IO Cell Input  ports
wire [NBMP-1:0]          jtag_scanin_cell;

wire [NBMP-1:0]          prev_redn_engage;
wire [NBMP-1:0]          redn_engage;

wire [NBMP-1:0]          iclkn;
wire [NBMP-1:0]          inclk;
wire [NBMP-1:0]          inclk_dist;

wire [NBMP-1:0]          nrml_async_data;
wire [NBMP-1:0]          nrml_idat0;
wire [NBMP-1:0]          nrml_idat1;
wire [NBMP-1:0]          nrml_idat_selb;
wire [NBMP-1:0]          nrml_iddr_enable;
wire [NBMP-1:0]          nrml_ilaunch_clk;
wire [NBMP-1:0] [1:0]    nrml_indrv;
wire [NBMP-1:0] [1:0]    nrml_ipdrv;
wire [NBMP-1:0] [2:0]    nrml_rxen;
wire [NBMP-1:0]          nrml_txen;

wire [NBMP-1:0]          redn_async_data;
wire [NBMP-1:0]          redn_idat0;
wire [NBMP-1:0]          redn_idat1;
wire [NBMP-1:0]          redn_idat_selb;
wire [NBMP-1:0]          redn_iddr_enable;
wire [NBMP-1:0]          redn_ilaunch_clk;
wire [NBMP-1:0] [1:0]    redn_indrv;
wire [NBMP-1:0] [1:0]    redn_ipdrv;
wire [NBMP-1:0] [2:0]    redn_rxen;
wire [NBMP-1:0]          redn_txen;
wire [NBMP-1:0]          redn_oclk;
wire [NBMP-1:0]          redn_oclk_b;

wire [NBMP-1:0]          redn_odat0;
wire [NBMP-1:0]          redn_odat1;
wire [NBMP-1:0]          redn_odat_asyn;

// Outputs from AIB IO Cells
//
wire [NBMP-1:0]          jtag_async_data;
wire [NBMP-1:0]          jtag_idat0;
wire [NBMP-1:0]          jtag_idat1;
//lint_checking NUMSUF on
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// DLL (manual mode) instance
//
wire            rx_clk_dly;

wire [DLYW-1:0] dll_adjust = iddr_enable ? ddr_dly_adjust : sdr_dly_adjust;

wire dll_fbclk = 1'b0;

// FIX ME add dll_refclk_b port
itrx_aib_phy_dll #(.MANUAL_MODE(1'b1), .DLYW(DLYW))
  u_itrx_aib_phy_dll(// Outputs
                     .dll_lock          (dll_lock),
                     .dll_outclk        (rx_clk_dly),
                     // Inputs
                     .dll_enable        (dll_enable),
                     .dll_fbclk         (dll_fbclk),
                     .dll_refclk        (rx_clk),
                     .dll_lock_req      (dll_lock_req),
                     .dll_adjust        (dll_adjust[DLYW-1:0]));
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Reset logic
//
// FIX ME Ask Intel about role of adap_rstn_out
//wire irstb = rstn_in & adap_rstn_out;
// DFT:
//wire sync_tx_irstb;
//wire sync_rx_irstb;
wire irstb    = jtag_rstn_en ? jtag_rstn : irstb_in;
wire tx_irstb = jtag_rstn_en ? jtag_rstn : tx_irstb_in;
wire rx_irstb = jtag_rstn_en ? jtag_rstn : rx_irstb_in;
//wire tie_low = 1'b0;

// Synchronize irstb to tx_clk (mux-ed w jtag_clkdr).
//

//wire tx_clk_jtag;

// DFT:
// Mux to allow jtag_clkdr to drive the TX ilaunch_clk
//
//itrx_aib_phy_stdcell_clk_mux
//  u_tx_jtag_clk (.din0(tx_clk),
//                 .din1(jtag_clkdr),
//                 .msel(jtag_clksel),
//                 .dout(tx_clk_jtag));

// FIX ME - may already be sync-ed to tx_clk wasteful
//lint_checking DIFCLK DIFRST off

// Removed synchronizer within channel.
/*
itrx_aib_phy_sync_rstn
  u_tx_sync_rstn (// Outputs
                  .dout                 (sync_tx_irstb),
                  // Inputs
                  .scan_mode            (tie_low),
                  .rst_n                (irstb_in),
                  .clk                  (tx_clk));

// Synchronize irstb to inclk (rx_clk delayed)
//
itrx_aib_phy_sync_rstn
  u_rx_sync_rstn (// Outputs
                  .dout                 (sync_rx_irstb),
                  // Inputs
                  .scan_mode            (tie_low),
                  .rst_n                (irstb_in),
                  .clk                  (rx_clk_dly));
*/
//lint_checking DIFCLK DIFRST on
//-----------------------------------------------------------------------------

wire [NBMP-1:0] nrml_odat0_unused_ok;
wire [NBMP-1:0] nrml_odat1_unused_ok;

//------------------------------------------------------------------------------
// RX Clock Redundancy MUX
//

itrx_aib_phy_stdcell_clk_mux
  u_oclk  (.din0(oclk[RX_DAT_CLK_POS]), // OK
           .din1(oclk[RX_DAT_CLK_POS-2]), // OK
           .msel(iredn_engage[RX_DAT_CLK_RED_ENGAGE]),
           .dout(rx_clk));

wire rx_clk_b;

itrx_aib_phy_stdcell_clk_mux
  u_oclk_b(.din0(oclk_b[RX_DAT_CLK_POS]), // OK
           .din1(oclk_b[RX_DAT_CLK_POS-2]), // OK
           .msel(iredn_engage[RX_DAT_CLK_RED_ENGAGE]),
           .dout(rx_clk_b));
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
assign adap_rstn_out = nrml_odat_asyn[RX_ARST_POS];
assign rstn_out      = nrml_odat_asyn[RX_RST_POS];
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Drive the "previous" redundancy engage to each AIB IO cell
// for the purposes of identifying and reseting the analog PAD signals 
// to force weak pull-down for the broken AIB link uBumps 
// (AIB Arch Spec requirement).
//
// The previous engage is the engage input port signal of the immediately 
// adjacent AIB IO cell further from the spares in the redundancy chain.
// The chain starts at the bad AIB IO pair and ends at the spares.
//

//assign prev_redn_engage = {1'b0, 
//                           iredn_engage[44:24], // 21 
//                           iredn_engage[21: 0], // 22 
//                           1'b0};

//---------------------
// bit 0  = 0
// bit 1  = i-1
// ...
// bit 22 = i-1
// bit 23 = i+1
// ...
// bit 43 = i+1
// bit 44 = 0
//---------------------
// bit 0:1  = 0
// bit 2:3  = i-1
// ...
// bit 44:45 = i-1
// bit 46:47 = i+1
// ...
// bit 86:87 = i+1
// bit 88:89 = 0
//------------------------------------------------------------------------------

wire redn_any = |iredn_engage; // Any redundancy engaged

genvar ii;
generate

for (ii=0; ii<NBMP; ii=ii+1) begin : gl_bmp

  localparam [31:0] REDO_II = REDN_ORDERO[ii];
  localparam [31:0] REDI_II = REDN_ORDERI[ii];

  if (REDO_II != NULLB) begin : gc_redno
//lint_checking DALIAS off
    assign redn_odat0[ii]     = odat0[REDO_II]; 
    assign redn_odat1[ii]     = odat1[REDO_II]; 
    assign redn_odat_asyn[ii] = odat_asyn[REDO_II]; 
//lint_checking DALIAS on
  end else             begin : gcn_redno
    assign redn_odat0[ii]     = 1'b0;
    assign redn_odat1[ii]     = 1'b0;
    assign redn_odat_asyn[ii] = 1'b0;
  end

  // CFG input [ii] controls uBump ID ii+2 for IDs greater than SPARE IDs.
  //
  localparam integer CFG_II = (ii < SPARE_POS) ? ii : ii-2; // OK for v0.99

  if (ii == RX_DAT_CLK_POS) begin : gc_redn_oclk 
     assign redn_oclk  [ii] = rx_clk;
     assign redn_oclk_b[ii] = rx_clk_b;
  end else begin : gcn_redn_oclk
     assign redn_oclk  [ii] = 1'b0;
     assign redn_oclk_b[ii] = 1'b0;
  end

  wire spare_mode;  
  if ( (ii == SPARE_POS) || 
       (ii == (SPARE_POS+1)) ) begin : gc_spare
    assign spare_mode = 1'b1;
  end else begin : gcn_spare
    assign spare_mode = 1'b0;
  end

// if bit  0 of iredn_engage is set, then set redn_engage[50:51]  
// if bit 10 of iredn_engage is set, then set redn_engage[ 0: 1]  

// redn_engage[ 0: 1] = iredn_engage[10]
// redn_engage[ 2: 3] = iredn_engage[11]
// redn_engage[ 4: 5] = iredn_engage[12]
// redn_engage[ 6: 7] = iredn_engage[13]
// redn_engage[ 8: 9] = iredn_engage[14]
// redn_engage[10:11] = iredn_engage[15]

  //---------------------------------------------------------------------------
  // Map redundancy engage input controls to AIB IO cell inputs.
  //
//lint_checking DALIAS off
    assign redn_engage[ii] = iredn_engage[RED_ENGAGE_MAP[ii]];
//lint_checking DALIAS on

//`ifdef AIB_MAP99

  if (PREV_RED_ENGAGE_MAP[ii] == NULLB) begin : gc_prev0m
    assign prev_redn_engage[ii] = 1'b0;
  end else begin : gc_prevm
//lint_checking DALIAS off
    assign prev_redn_engage[ii] = iredn_engage[PREV_RED_ENGAGE_MAP[ii]];
//lint_checking DALIAS on
  end

/*
`else
  localparam RX_BMP_II = (ii > HNBMP);

  if ( (ii ==  JTAG_FIRST    ) || 
       (ii == (JTAG_FIRST +1)) || 
       (ii == (JTAG_LAST  -1)) || 
       (ii ==  JTAG_LAST     )   ) begin : gc_prev0
    assign prev_redn_engage[ii] = 1'b0;
  end else if (RX_BMP_II)          begin : gc_prev_rx
//lint_checking DALIAS off
    assign prev_redn_engage[ii] = iredn_engage[RED_ENGAGE_MAP[ii+2]];
  end else                         begin : gc_prev_tx
    assign prev_redn_engage[ii] = iredn_engage[RED_ENGAGE_MAP[ii-2]];
//lint_checking DALIAS on
  end
`endif
*/
  //---------------------------------------------------------------------------

//lint_checking DIFRST off
  itrx_aib_phy_io_cell 
    u_cell(// Outputs
          .jtag_scanout                 (jtag_scanout_cell[ii]),
          .jtag_clkdr_n                 (jtag_clkdr_n[ii]),

          .oclk                         (oclk[ii]),
          .oclk_b                       (oclk_b[ii]),

          .rmux_oclk                    (rmux_oclk[ii]),
          .rmux_oclk_b                  (rmux_oclk_b[ii]),

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
/*
          .vcc_dig                      (vcc_dig),
          .vcc_io                       (vcc_io),
          .vss_ana                      (vss_ana),
*/
          // Inputs
          .por_vcc_io                   (por_vcc_io),
          .por_vcc_dig                  (por_vcc_dig),
          .iclkn                        (iclkn[ii]),
          .inclk                        (inclk[ii]),
          .inclk_dist                   (inclk_dist[ii]),

          .redn_engage                  (redn_engage[ii]),
          .prev_redn_engage             (prev_redn_engage[ii]),
          .spare_mode                   (spare_mode),
          .redn_any                     (redn_any),

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
          .nrml_indrv                   (nrml_indrv[ii]),
          .nrml_ipdrv                   (nrml_ipdrv[ii]),
          .nrml_rxen                    (nrml_rxen[ii]),
          .nrml_txen                    (nrml_txen[ii]),

          .redn_oclk                    (redn_oclk[ii]),
          .redn_oclk_b                  (redn_oclk_b[ii]),

          .redn_ilaunch_clk             (redn_ilaunch_clk[ii]),
          .redn_async_data              (redn_async_data[ii]),
          .redn_idat0                   (redn_idat0[ii]),
          .redn_idat1                   (redn_idat1[ii]),
          .redn_idat_selb               (redn_idat_selb[ii]),
          .redn_iddr_enable             (redn_iddr_enable[ii]),
          .redn_indrv                   (redn_indrv[ii]),
          .redn_ipdrv                   (redn_ipdrv[ii]),
          .redn_rxen                    (redn_rxen[ii]),
          .redn_txen                    (redn_txen[ii]),
          .redn_odat0                   (redn_odat0[ii]),
          .redn_odat1                   (redn_odat1[ii]),
          .redn_odat_asyn               (redn_odat_asyn[ii]));
//lint_checking DIFRST on

  //---------------------------------------------------------------------------
  // Connect ICLKN input
  //
  if ((ii == RX_DAT_CLK_POS) || 
      (ii == (RX_DAT_CLK_POS-2))) begin : gc_iclkn
   assign iclkn [ii] = ubump[ii-1];
  end else begin : gc_no_iclkn
   assign iclkn [ii] = 1'b0;
  end
  //---------------------------------------------------------------------------


  //---------------------------------------------------------------------------
  // Connect JTAG 
  //
  if (ii == JTAG_FIRST) begin : gc_bmp1st
    assign jtag_scanin_cell[ii] = jtag_scanin;
  end else if (ii == JTAG_LAST) begin : gc_bmplast
    assign jtag_scanout = jtag_scanout_cell[ii];
    assign jtag_scanin_cell[ii] = jtag_scanout_cell[JTAG_ORDER[ii]];
  end else begin : gc_bmpmid
    assign jtag_scanin_cell[ii] = jtag_scanout_cell[JTAG_ORDER[ii]];
  end
  //---------------------------------------------------------------------------


  //---------------------------------------------------------------------------
  // Connect (or tie-off) TX clocks
  //
  if (TX_CLK_GROUP[ii]) begin : gc_txc
//lint: halstruct: DIFCLK Clock '' is being renamed to ''.
//lint_checking DALIAS DIFCLK off
    assign nrml_ilaunch_clk[ii] = tx_clk;
//lint_checking DALIAS DIFCLK on
  end else begin : gc_txcn
    assign nrml_ilaunch_clk[ii] = 1'b0;
  end
  //---------------------------------------------------------------------------


  //---------------------------------------------------------------------------
  // Connect (or tie-off) RX clocks
  //
  if (RX_CLK_GROUP[ii]) begin : gc_rxc
//lint: halstruct: DIFCLK Clock '' is being renamed to ''.
//lint_checking DALIAS DIFCLK off
    assign inclk     [ii] = rx_clk_dly;
    assign inclk_dist[ii] = rx_clk;
//lint_checking DALIAS DIFCLK on
  end else begin : gc_rxcn
    assign inclk     [ii] = 1'b0;
    assign inclk_dist[ii] = 1'b0;
  end
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // Connect RX Sync Data bits
  //
  if (RX_DAT_GROUP[ii] != NULLB) begin : gc_rx0d
//`ifndef DDR_MAP99
//    assign rx_data[RX_DAT_GROUP[ii]/2        ] = nrml_odat0[ii];
//    assign rx_data[RX_DAT_GROUP[ii]/2 + HNDAT] = nrml_odat1[ii];
//`else
    assign rx_data[RX_DAT_GROUP[ii]        ] = nrml_odat0[ii];
    assign rx_data[RX_DAT_GROUP[ii] +     1] = nrml_odat1[ii]; // v0.99 DDR MAP
//`endif
    assign nrml_odat0_unused_ok[ii] = 1'b0;
    assign nrml_odat1_unused_ok[ii] = 1'b0;
  end else begin : gc_rx0d_unused
    assign nrml_odat0_unused_ok[ii] = nrml_odat0[ii];
    assign nrml_odat1_unused_ok[ii] = nrml_odat1[ii];
  end
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // Connect tx_data and constants to Cell idat0/1 
  // TX clk iddr_enable only to data bumps.
  //

  if (TX_DAT_GROUP[ii] != NULLB) begin : gc_tx1d // TX Data bumps before TX clock

//`ifndef DDR_MAP99
//  assign nrml_idat0[ii] = tx_data[TX_DAT_GROUP[ii]/2];
//  assign nrml_idat1[ii] = tx_data[TX_DAT_GROUP[ii]/2 + HNDAT];
//`else
    assign nrml_idat0[ii] = tx_data[TX_DAT_GROUP[ii]];
    assign nrml_idat1[ii] = tx_data[TX_DAT_GROUP[ii] + 1]; // v0.99 DDR MAP
//`endif

//lint_checking DALIAS off
    assign nrml_iddr_enable[ii] = iddr_enable;
//lint_checking DALIAS on

  end else if (ii == TX_DAT_CLK_POS) begin : gc_txd0c // TX Data clock

    assign nrml_idat0[ii] = 1'b0;
    assign nrml_idat1[ii] = 1'b1;
    assign nrml_iddr_enable[ii] = iddr_enable_clk;

  end else if (ii == (TX_DAT_CLK_POS+1)) begin : gc_txd1c // TX Data clock (clkb)

    assign nrml_idat0[ii] = 1'b1;
    assign nrml_idat1[ii] = 1'b0;
//lint_checking DALIAS off
    assign nrml_iddr_enable[ii] = iddr_enable_clk;
//lint_checking DALIAS on

  end else if ( (ii == SPARE_POS) || 
                (ii == (SPARE_POS+1)) ) begin : gc_txsd // TX Data Spares

    assign nrml_idat0[ii] = jtag_idat0[ii+2];
    assign nrml_idat1[ii] = jtag_idat1[ii+2];
    assign nrml_iddr_enable[ii] = 1'b1;

  end else begin : gc_tx3d // Other bumps unused for TX Data

    assign nrml_idat0[ii] = 1'b0;
    assign nrml_idat1[ii] = 1'b0;

    // Set to 1 to allow JTAG Loopback DDR testing of RX synchronous (clocked) IOs
    //
    assign nrml_iddr_enable[ii] = 1'b1;

  end
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // Connect module port inputs to TX async data IO cell input ports
  //
  if (ii == TX_ARST_POS) begin : gc_tx0asy
    assign nrml_async_data [ii] = adap_rstn_in;
  end else if (ii == TX_RST_POS) begin : gc_tx1asy
    assign nrml_async_data [ii] = rstn_in;
  end else if ((ii == SPARE_POS) || 
               (ii == (SPARE_POS+1))) begin : gc_txasy_sp
    assign nrml_async_data [ii] = jtag_async_data[ii+2];
  end else begin : gc_tx2asy
    assign nrml_async_data [ii] = 1'b0;
  end
  //----------------------------------------------------------------------------


  //----------------------------------------------------------------------------
  // Connect module port inputs to CFG IO cell input ports
  //
   if  ((ii !=  SPARE_POS) && 
        (ii != (SPARE_POS+1))) begin : gc_cfg
     assign nrml_idat_selb  [ii] = idat_selb [CFG_II];
     assign nrml_rxen       [ii] = rxen      [CFG_II];
     assign nrml_txen       [ii] = txen      [CFG_II];

//lint_checking DALIAS off
     if ((ii == TX_ARST_POS) ||
         (ii == RX_ARST_POS) ||
         (ii == TX_RST_POS)  ||
         (ii == RX_RST_POS)    ) begin : gc_drvrst
       assign nrml_indrv   [ii] = indrv_rst;
       assign nrml_ipdrv   [ii] = ipdrv_rst;
     end else if ((ii ==  TX_DAT_CLK_POS   ) ||
                  (ii == (TX_DAT_CLK_POS+1)) ||
                  (ii ==  RX_DAT_CLK_POS   ) ||
                  (ii == (RX_DAT_CLK_POS-1))   ) begin : gc_drvclk
       assign nrml_indrv   [ii] = indrv_clk;
       assign nrml_ipdrv   [ii] = ipdrv_clk;
     end else begin : gc_rstdef
       assign nrml_indrv   [ii] = indrv;
       assign nrml_ipdrv   [ii] = ipdrv;
     end
//lint_checking DALIAS on

  end else begin : gc_cfg_spare
    assign nrml_idat_selb  [ii] = nrml_idat_selb [ii+2];
    assign nrml_rxen       [ii] = nrml_rxen      [ii+2];
    assign nrml_txen       [ii] = nrml_txen      [ii+2];

    assign nrml_indrv      [ii] = nrml_indrv     [ii+2];
    assign nrml_ipdrv      [ii] = nrml_ipdrv     [ii+2];
  end
  //---------------------------------------------------------------------------


  //---------------------------------------------------------------------------
  // Drive Redundancy TX & CFG Inputs to protecting cell.
  //
   if (REDI_II == NULLB) begin : gc_rednull
    assign redn_async_data [ii] = 1'b0;
    assign redn_idat0      [ii] = 1'b0;
    assign redn_idat1      [ii] = 1'b0;
    assign redn_idat_selb  [ii] = 1'b0;
    assign redn_iddr_enable[ii] = 1'b0;
    assign redn_ilaunch_clk[ii] = 1'b0;
    assign redn_indrv      [ii] = 2'b00;
    assign redn_ipdrv      [ii] = 2'b00;
    assign redn_rxen       [ii] = 3'b000;
    assign redn_txen       [ii] = 1'b0;
   end else begin : gc_red
    assign redn_async_data [ii] = jtag_async_data [REDI_II];
    assign redn_idat0      [ii] = jtag_idat0      [REDI_II];
    assign redn_idat1      [ii] = jtag_idat1      [REDI_II];
    assign redn_idat_selb  [ii] = nrml_idat_selb  [REDI_II];
    assign redn_iddr_enable[ii] = nrml_iddr_enable[REDI_II];
    assign redn_ilaunch_clk[ii] = nrml_ilaunch_clk[REDI_II];
    assign redn_indrv      [ii] = nrml_indrv      [REDI_II];
    assign redn_ipdrv      [ii] = nrml_ipdrv      [REDI_II];
    assign redn_rxen       [ii] = nrml_rxen       [REDI_II];
    assign redn_txen       [ii] = nrml_txen       [REDI_II];
   end
  //---------------------------------------------------------------------------

end
endgenerate

// FIX ME Define some signals for debug
//lint_checking TIELOG off
assign dig_test_bus_io = 8'd0;
//lint_checking TIELOG on


//lint_checking REDOPR off
wire unused_ok = &{

                   // The JTAG outputs are not used for spares.
                   // They connect from the BSR to the 3to1 MUX only.
                   jtag_idat0[SPARE_POS +: 2],
                   jtag_idat1[SPARE_POS +: 2],
                   jtag_async_data[SPARE_POS +: 2],

                   // Only RX reset odat_async outputs are used
                   //
                   nrml_odat_asyn[NBMP-1:RX_RST_POS+1],
                   nrml_odat_asyn[RX_ARST_POS-1:0],

                   // Only RX Sync Data odat0/1 outputs are used (skip RX rsts)
                   // Also, exclude the RX clock pair
                   nrml_odat0_unused_ok,
                   nrml_odat1_unused_ok,

                   // Only two oclk/oclk_b pairs are connected:
                   //  [RX_DAT_CLK_POS] and [RX_DAT_CLK_POS-2] (redun), Exclude the rest.
                   oclk  [NBMP-1:RX_DAT_CLK_POS+1],
                   oclk  [RX_DAT_CLK_POS-1],
                   oclk  [RX_DAT_CLK_POS-3:0],

                   oclk_b[NBMP-1:RX_DAT_CLK_POS+1],
                   oclk_b[RX_DAT_CLK_POS-1],
                   oclk_b[RX_DAT_CLK_POS-3:0],

                   // Unused since RX clock red mux is outside of the IO Array.
                   rmux_oclk,   
                   rmux_oclk_b,

                   // Unused
//                 jtag_clkdr_n,

                   // End AIB IOs pairs don't repair other AIB IOs
                   //
                   odat0[JTAG_FIRST +:2],
                   odat1[JTAG_FIRST +:2],
                   odat_asyn[JTAG_FIRST +:2],

                   odat0[(NBMP-1) -:2],
                   odat1[(NBMP-1) -:2],
                   odat_asyn[(NBMP-1) -:2],
                   
                   1'b1};
wire unused_ok_2 = &{jtag_clkdr_n};
//lint_checking REDOPR on

endmodule
