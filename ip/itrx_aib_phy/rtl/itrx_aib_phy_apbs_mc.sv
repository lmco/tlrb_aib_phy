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
// Filename       : itrx_aib_phy_apbs_mc.sv
// Description    : APB Slave controller for AIB IO Channel(s) & AUX Channel.
//                  Multi-Channel
// ==========================================================================
//
//    $Rev:: 5797                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-06-12 13:24:32 -0400#$: Date of last commit
//
// ==========================================================================

module itrx_aib_phy_apbs_mc (/*AUTOARG*/
   // Outputs
   r_apb_fs_adap_rstn, r_apb_fs_rstn, prdata, pready, rstn_in,
   adap_rstn_in, adapt_irstb, ddr_dly_adjust, sdr_dly_adjust,
   idat_selb, iddr_enable, indrv, indrv_clk, indrv_rst, ipdrv,
   ipdrv_clk, ipdrv_rst, rxen, txen, por_sl2sl, por_in, redun_engage,
   config_done,
   // Inputs
   pclk, presetn, paddr, pwrite, psel, penable, pwdata, rstn_out,
   adap_rstn_out, device_detect, por_out, conf_done
   );

parameter NCH = 32'd2;           // Number of AIB IO Channels.

localparam DLYW  = 32'd10;
localparam FBMP  = 32'd88;
localparam HNBMP = 32'd45;

localparam AIB_DEF_DRV = 2'b01; // AIB default drive strength
localparam RXEN_DISABLED = 3'b010;

//
`ifdef AIB_ID_REMAP
parameter [FBMP-1:0] GROUP0 = { // Data Group 0
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b1}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b1}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b1}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b1}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] TX_CLK = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b1}},  // TX CLK
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] TX_RST = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b1}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] TX_DAT = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b1}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b1}},  // TX D
 {10{1'b1}},  // TX D
 {10{1'b1}}}; // TX D

parameter [FBMP-1:0] RX_CLK = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 { 2{1'b1}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] RX_RST = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b1}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] RX_DAT = {
 {10{1'b1}},  // RX D
 {10{1'b1}},  // RX D
 {10{1'b1}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b1}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}}}; // TX D

`else   // Orignal MAP

parameter [FBMP-1:0] GROUP0 = { // Data Group 0
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b1}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b1}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b1}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b1}}}; // TX D

parameter [FBMP-1:0] TX_CLK = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b1}},  // TX CLK
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] TX_RST = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b1}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] TX_DAT = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b1}},  // TX D
 {10{1'b1}},  // TX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b1}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b1}}}; // TX D

parameter [FBMP-1:0] RX_CLK = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // RX D
 { 2{1'b1}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] RX_RST = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b1}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}}}; // TX D

parameter [FBMP-1:0] RX_DAT = {
 {10{1'b1}},  // RX D
 {10{1'b1}},  // RX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b1}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b1}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}}}; // TX D
`endif

output [NCH-1:0] r_apb_fs_adap_rstn; // from far-side AIB PHY
output [NCH-1:0] r_apb_fs_rstn;      // from far-side AIB PHY

// APB Slave Interface
//
input                          pclk;    // Clock.
input                          presetn; // Reset.
input     [11:0]               paddr;   // Address.
input                          pwrite;  // Direction.
input                          psel;    // Select.
input                          penable; // Enable.
input      [31:0]              pwdata;  // Write Data.
output reg [31:0]              prdata;  // Read Data.
output reg                     pready;  // Ready.

// Control Outputs (from Registers)
// & Status Inputs (to Registers)
//
output reg [NCH-1:0]                     rstn_in;
output reg [NCH-1:0]                     adap_rstn_in;
output reg [NCH-1:0]                     adapt_irstb;

output reg [NCH-1:0] [DLYW-1:0]          ddr_dly_adjust;
output reg [NCH-1:0] [DLYW-1:0]          sdr_dly_adjust;

output     [NCH-1:0] [FBMP-1:0]          idat_selb;
output reg [NCH-1:0]                     iddr_enable;

output reg [NCH-1:0] [1:0]               indrv;
output reg [NCH-1:0] [1:0]               indrv_clk;
output reg [NCH-1:0] [1:0]               indrv_rst;

output reg [NCH-1:0] [1:0]               ipdrv;
output reg [NCH-1:0] [1:0]               ipdrv_clk;
output reg [NCH-1:0] [1:0]               ipdrv_rst;

output     [NCH-1:0] [FBMP-1:0] [2:0]    rxen;
output     [NCH-1:0] [FBMP-1:0]          txen;

output reg                     por_sl2sl;
output reg                     por_in;        // por_sl2ms
output    [NCH-1:0]  [HNBMP-1:0]         redun_engage;

input     [NCH-1:0]                      rstn_out;
input     [NCH-1:0]                      adap_rstn_out;

input                          device_detect;
input                          por_out;

input                          conf_done;
output reg                     config_done;

wire [NCH-1:0]          adap_rstn_out_sync;
wire [NCH-1:0]          rstn_out_sync;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    conf_done_sync;         // From u_conf_done of itrx_aib_phy_bit_sync.v
wire                    device_detect_sync;     // From u_device_detect of itrx_aib_phy_bit_sync.v
wire                    por_out_sync;           // From u_por_out of itrx_aib_phy_bit_sync.v
// End of automatics

//-----------------------------------------------------------------------------
// Synchronizers for input status bits
//
localparam NUM_SYNC_DFFS = 32'd2;

/*
itrx_aib_phy_bit_sync AUTO_TEMPLATE (
              .NUM_FLOPS                (NUM_SYNC_DFFS),
              .rst_n                    (presetn),
              .clk                      (pclk),
              .din                      (@"(substring vl-cell-name 2)"),
              .dout                     (@"(substring vl-cell-name 2)"_sync),

 ); */

//lint: Clock and reset names change names to generic port names.
//lint_checking DIFCLK DIFRST off
genvar cc;
generate
for (cc=0; cc<NCH; cc=cc+1) begin : gl_sync

 itrx_aib_phy_bit_sync #(/*AUTOINSTPARAM*/
                         // Parameters
                         .NUM_FLOPS             (NUM_SYNC_DFFS)) // Templated
  u_rstn_out (.dout                     (rstn_out_sync[cc]),
              .din                      (rstn_out[cc]),
              /*AUTOINST*/
              // Inputs
              .rst_n                    (presetn),               // Templated
              .clk                      (pclk));                         // Templated

 itrx_aib_phy_bit_sync #(/*AUTOINSTPARAM*/
                         // Parameters
                         .NUM_FLOPS             (NUM_SYNC_DFFS)) // Templated
  u_adap_rstn_out (.dout                (adap_rstn_out_sync[cc]),
                   .din                 (adap_rstn_out[cc]),
                   /*AUTOINST*/
                   // Inputs
                   .rst_n               (presetn),               // Templated
                   .clk                 (pclk));                         // Templated
end // gl_sync
endgenerate

itrx_aib_phy_bit_sync #(/*AUTOINSTPARAM*/
                        // Parameters
                        .NUM_FLOPS      (NUM_SYNC_DFFS))         // Templated
  u_device_detect   (/*AUTOINST*/
                     // Outputs
                     .dout              (device_detect_sync),    // Templated
                     // Inputs
                     .rst_n             (presetn),               // Templated
                     .clk               (pclk),                  // Templated
                     .din               (device_detect));        // Templated

itrx_aib_phy_bit_sync #(/*AUTOINSTPARAM*/
                        // Parameters
                        .NUM_FLOPS      (NUM_SYNC_DFFS))         // Templated
  u_por_out (/*AUTOINST*/
             // Outputs
             .dout                      (por_out_sync),          // Templated
             // Inputs
             .rst_n                     (presetn),               // Templated
             .clk                       (pclk),                  // Templated
             .din                       (por_out));              // Templated

itrx_aib_phy_bit_sync #(/*AUTOINSTPARAM*/
                        // Parameters
                        .NUM_FLOPS      (NUM_SYNC_DFFS))         // Templated
  u_conf_done (/*AUTOINST*/
               // Outputs
               .dout                    (conf_done_sync),        // Templated
               // Inputs
               .rst_n                   (presetn),               // Templated
               .clk                     (pclk),                  // Templated
               .din                     (conf_done));            // Templated

//lint_checking DIFCLK DIFRST on
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Revision  Constants
//
localparam T_5HEX = 5'h14;
localparam A_5HEX = 5'h01;
localparam I_5HEX = 5'h09;
localparam B_5HEX = 5'h02;

// "TAIB" ASCII string encoding
localparam [23:0] DEV_ID = {4'h0,T_5HEX,
                                 A_5HEX,
                                 I_5HEX,
                                 B_5HEX};
localparam [3:0] MINOR = 4'd0;
localparam [3:0] MAJOR = 4'd0;
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// APB Interface Constants
//

localparam IDLE_SETUP = 1'b0;  // APB IDLE/SETUP state
localparam PACCESS    = 1'b1;  // APB ACCESS state

reg pstate; // APB state register
//-----------------------------------------------------------------------------


//------------------------------------------------------------------------------
// CSR APB Address Map LOCations
//
localparam TX_DRV_LOC = 12'h000;
localparam TX_CFG_LOC = 12'h004;
localparam RX_ENA_LOC = 12'h008;
localparam RX_DLY_LOC = 12'h00C;
localparam REPAIR_LOC = 12'h010;
localparam RESETS_LOC = 12'h014;

localparam CFG_DN_LOC = 12'h800; // CONFIG_DONE
localparam DD_POR_LOC = 12'h804;

localparam REVISN_LOC = 12'hFFC;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// CSR registers control bits
//
reg [NCH-1:0]       idat_selb_dat;
reg [NCH-1:0]       idat_selb_rst;
reg [NCH-1:0]       idat_selb_clk;

reg [NCH-1:0] [1:0] txen_dat;
reg [NCH-1:0]       txen_rst;
reg [NCH-1:0]       txen_clk;

reg [NCH-1:0] [1:0] [2:0] rxen_dat;
reg [NCH-1:0] [2:0] rxen_rst;
reg [NCH-1:0] [2:0] rxen_clk;

reg [NCH-1:0] [5:0] ddr_dly_adj_csr;
reg [NCH-1:0] [5:0] sdr_dly_adj_csr;

reg [NCH-1:0]       repair_info_vld;
reg [NCH-1:0]       repair_info_dir;
reg [NCH-1:0] [9:0] repair_info_loc;
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Connect APB mem-mapped control regs to AIB IO Chan config inputs:
//  txen, rxen, idat_selb
//
localparam [31:0] ADJ_PAD = DLYW - 32'd6;

genvar ii;
generate
for (cc=0; cc<NCH;  cc=cc+1) begin : gl_nch
for (ii=0; ii<FBMP; ii=ii+1) begin : gl_bmp

//lint_checking DALIAS TIELOG off
  if          (TX_CLK[ii]) begin : gc_txclk
    assign txen[cc][ii] = txen_clk[cc];
  end else if (TX_RST[ii]) begin : gc_txrst
    assign txen[cc][ii] = txen_rst[cc];
  end else if (TX_DAT[ii]) begin : gc_txdat

   if (GROUP0[ii])  begin : gc_txdat0
    assign txen[cc][ii] = txen_dat[cc][0];
   end else         begin : gc_txdat1
    assign txen[cc][ii] = txen_dat[cc][1];
   end

  end else                 begin : gc_txdef
    assign txen[cc][ii] = 1'b0;
  end

  if          (RX_CLK[ii]) begin : gc_rxclk
    assign rxen[cc][ii] = rxen_clk[cc];
  end else if (RX_RST[ii]) begin : gc_rxrst
    assign rxen[cc][ii] = rxen_rst[cc];
  end else if (RX_DAT[ii]) begin : gc_rxdat

   if (GROUP0[ii])  begin : gc_rxdat0
    assign rxen[cc][ii] = rxen_dat[cc][0];
   end else         begin : gc_rxdat1
    assign rxen[cc][ii] = rxen_dat[cc][1];
   end

  end else                 begin : gc_rxdef
    assign rxen[cc][ii] = RXEN_DISABLED;
  end

  if          (TX_CLK[ii]) begin : gc_sbclk
    assign idat_selb[cc][ii] = idat_selb_clk[cc];
  end else if (TX_RST[ii]) begin : gc_sbrst
    assign idat_selb[cc][ii] = idat_selb_rst[cc];
  end else if (TX_DAT[ii]) begin : gc_sbdat
    assign idat_selb[cc][ii] = idat_selb_dat[cc];
  end else                 begin : gc_sbdef
    assign idat_selb[cc][ii] = 1'b0;
  end
//lint_checking DALIAS on

end // gl_bmp

//-----------------------------------------------------------------------------

assign ddr_dly_adjust[cc] = { {ADJ_PAD{1'b0}}, ddr_dly_adj_csr[cc] };
assign sdr_dly_adjust[cc] = { {ADJ_PAD{1'b0}}, sdr_dly_adj_csr[cc] };
//lint_checking TIELOG on
end // gl_nch
endgenerate

//-----------------------------------------------------------------------------
// APB Interface
//

wire psetup = psel & (~penable);

always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
    pstate  <= IDLE_SETUP;
    pready <= 1'b0;
  end else begin

   pready <= psetup;

   pstate <= psetup |
             pstate & (~pready);
  end
end
//-----------------------------------------------------------------------------

reg [NCH-1:0] [31:0] prdata_ch;
generate
for (cc=0; cc<NCH; cc=cc+1) begin : gl_rep

//-----------------------------------------------------------------------------
// Encode redun_engage output port.
//

 itrx_aib_phy_repair_enc
  u_itrx_aib_phy_repair_enc (
                             // Outputs
                             .redun_engage      (redun_engage[cc][44:0]),
                             // Inputs
                             .repair_info_nvm   ({repair_info_dir[cc], repair_info_loc[cc]}),
                             .repair_info_vld   (repair_info_vld[cc]));
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// APB Read Data
//
always_comb begin
  case (paddr - {cc[6:0], 5'b0_0000})
    TX_DRV_LOC: prdata_ch[cc] = {20'd0, ipdrv[cc],     indrv[cc],
                                 ipdrv_rst[cc], indrv_rst[cc],
                                 ipdrv_clk[cc], indrv_clk[cc]};

    TX_CFG_LOC: prdata_ch[cc] = {24'd0, txen_dat[cc][1], iddr_enable[cc],
                                 idat_selb_dat[cc], idat_selb_rst[cc], idat_selb_clk[cc],
                                 txen_dat[cc][0], txen_rst[cc], txen_clk[cc]};

    RX_ENA_LOC: prdata_ch[cc] = {20'd0, rxen_dat[cc][1],
                                 rxen_dat[cc][0], rxen_rst[cc], rxen_clk[cc]};

    RX_DLY_LOC: prdata_ch[cc] = {18'd0, ddr_dly_adj_csr[cc], 2'b00, sdr_dly_adj_csr[cc]};
    REPAIR_LOC: prdata_ch[cc] = {20'd0, repair_info_vld[cc], repair_info_dir[cc], repair_info_loc[cc]};

    RESETS_LOC: prdata_ch[cc] = {27'd0, adap_rstn_out_sync[cc], rstn_out_sync[cc],  // From IO
                                 adap_rstn_in[cc],  rstn_in[cc], adapt_irstb[cc]};
    default   : prdata_ch[cc] = 32'd0;
  endcase
end
end // gl_rep
endgenerate

//------------------------------------------------------------------------------
// OR each prdata bit together across all of the Channels.
wire [31:0] prdata_ch_or;

genvar bb;
generate
for (bb=0; bb<32; bb=bb+1) begin : gl_bit
  wire [NCH-1:0] tmp_prdata;
  for (cc=0; cc<NCH; cc=cc+1) begin : gl_prdata
    assign tmp_prdata[cc] = prdata_ch[cc][bb];
  end
 assign prdata_ch_or[bb] = |tmp_prdata;
end
endgenerate
//------------------------------------------------------------------------------


always_comb begin
  case (paddr)
    CFG_DN_LOC: prdata = {30'd0, conf_done_sync, config_done};
    DD_POR_LOC: prdata = {28'd0, por_sl2sl, por_in,
                          por_out_sync, device_detect_sync}; // From AUX
    REVISN_LOC: prdata = {DEV_ID, MAJOR, MINOR};
    default   : prdata = prdata_ch_or;
  endcase
end
//-----------------------------------------------------------------------------

always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
    por_in <= 1'b1;
    por_sl2sl <= 1'b1;
    config_done <= 1'h0;
  end else begin
    if ((pstate == PACCESS) && pwrite && pready) begin
      case (paddr)
        CFG_DN_LOC: config_done <= pwdata[0];
        DD_POR_LOC: {por_sl2sl, por_in} <= pwdata[3:2];
        default:    {por_sl2sl, por_in, config_done} <=
                    {por_sl2sl, por_in, config_done};
      endcase
    end
  end
end

generate
for (cc=0; cc<NCH; cc=cc+1) begin : gl_wdat
always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
    ipdrv[cc]     <= AIB_DEF_DRV;
    indrv[cc]     <= AIB_DEF_DRV;
    ipdrv_rst[cc] <= AIB_DEF_DRV;
    indrv_rst[cc] <= AIB_DEF_DRV;
    ipdrv_clk[cc] <= AIB_DEF_DRV;
    indrv_clk[cc] <= AIB_DEF_DRV;

    iddr_enable[cc]     <= 1'b1;
    idat_selb_dat[cc]   <= 1'b0;
    idat_selb_rst[cc]   <= 1'b1;
    idat_selb_clk[cc]   <= 1'b0;
    txen_dat[cc][1]     <= 1'b1;
    txen_dat[cc][0]     <= 1'b1;
    txen_rst[cc]        <= 1'b1;
    txen_clk[cc]        <= 1'b1;

    rxen_dat[cc][1] <= RXEN_DISABLED;
    rxen_dat[cc][0] <= RXEN_DISABLED;
    rxen_rst[cc]    <= RXEN_DISABLED;
    rxen_clk[cc]    <= RXEN_DISABLED;

    ddr_dly_adj_csr[cc] <= 6'd0;
    sdr_dly_adj_csr[cc] <= 6'd0;
    repair_info_loc[cc] <= 10'd0;

    rstn_in[cc] <= 1'b0;
    adap_rstn_in[cc] <= 1'b0;
    repair_info_dir[cc] <= 1'h0;
    repair_info_vld[cc] <= 1'h0;
    adapt_irstb[cc] <= 1'b0;

  end else begin
    if ((pstate == PACCESS) && pwrite && pready) begin
      case (paddr - {cc[6:0], 5'b0_0000})
        TX_DRV_LOC: {ipdrv[cc], indrv[cc],
                     ipdrv_rst[cc], indrv_rst[cc],
                     ipdrv_clk[cc], indrv_clk[cc]} <= pwdata[11:0];

        TX_CFG_LOC: {txen_dat[cc][1], iddr_enable[cc],
                     idat_selb_dat[cc], idat_selb_rst[cc], idat_selb_clk[cc],
                     txen_dat[cc][0], txen_rst[cc], txen_clk[cc]} <= pwdata[7:0];

        RX_ENA_LOC: {rxen_dat[cc][1],
                     rxen_dat[cc][0], rxen_rst[cc], rxen_clk[cc]} <= pwdata[11:0];

        RX_DLY_LOC: {ddr_dly_adj_csr[cc], sdr_dly_adj_csr[cc]} <= {pwdata[13:8],
                                                                   pwdata[ 5:0]};

        REPAIR_LOC: {repair_info_vld[cc], repair_info_dir[cc], repair_info_loc[cc]}
                      <= pwdata[11:0];

        RESETS_LOC: {adap_rstn_in[cc], rstn_in[cc], adapt_irstb[cc]} <= pwdata[2:0];

        default: begin // HOLD VALUES
          ipdrv[cc]     <= ipdrv[cc];
          indrv[cc]     <= indrv[cc];
          ipdrv_rst[cc] <= ipdrv_rst[cc];
          indrv_rst[cc] <= indrv_rst[cc];
          ipdrv_clk[cc] <= ipdrv_clk[cc];
          indrv_clk[cc] <= indrv_clk[cc];

          iddr_enable[cc]   <= iddr_enable[cc];
          idat_selb_dat[cc] <= idat_selb_dat[cc];
          idat_selb_rst[cc] <= idat_selb_rst[cc];
          idat_selb_clk[cc] <= idat_selb_clk[cc];
          txen_dat[cc]      <= txen_dat[cc];
          txen_rst[cc]      <= txen_rst[cc];
          txen_clk[cc]      <= txen_clk[cc];

          rxen_dat[cc] <= rxen_dat[cc];
          rxen_rst[cc] <= rxen_rst[cc];
          rxen_clk[cc] <= rxen_clk[cc];

          ddr_dly_adj_csr[cc] <= ddr_dly_adj_csr[cc];
          sdr_dly_adj_csr[cc] <= sdr_dly_adj_csr[cc];
          repair_info_loc[cc] <= repair_info_loc[cc];

          adap_rstn_in[cc] <= adap_rstn_in[cc];
          adapt_irstb[cc] <= adapt_irstb[cc];
          repair_info_dir[cc] <= repair_info_dir[cc];
          repair_info_vld[cc] <= repair_info_vld[cc];
          rstn_in[cc] <= rstn_in[cc];
        end
      endcase
    end
  end
end

assign r_apb_fs_adap_rstn[cc] = adap_rstn_out_sync[cc];
assign r_apb_fs_rstn[cc] = rstn_out_sync[cc];
end // gl_wdat
endgenerate

wire unused_ok = &{1'b1, pwdata[31:12]};

endmodule

// Local Variables:
// verilog-auto-inst-param-value:t
// End:
