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
// Filename       : itrx_aib_phy_apbs.sv
// Description    : APB Slave controller for AIB IO Channel(s) & AUX Channel.
//
// ==========================================================================
//
//    $Rev:: 5392                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-12-04 17:36:46 -0500#$: Date of last commit
//
// ==========================================================================

module itrx_aib_phy_apbs (/*AUTOARG*/
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

localparam DLYW  = 32'd10;
localparam FBMP  = 32'd88;
localparam HNBMP = 32'd45;

localparam AIB_DEF_DRV = 2'b01; // AIB default drive strength
localparam RXEN_DISABLED = 3'b010;

// For reduced pin count the 2nd data group (group increments of 40) begins
// in the MSBs of the AIB buffer control signals.
//
localparam GROUP1 = FBMP - 32'd40;

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

output r_apb_fs_adap_rstn; // from far-side AIB PHY
output r_apb_fs_rstn;      // from far-side AIB PHY

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
output reg                     rstn_in;
output reg                     adap_rstn_in;
output reg                     adapt_irstb;

output reg [DLYW-1:0]          ddr_dly_adjust;
output reg [DLYW-1:0]          sdr_dly_adjust;

output     [FBMP-1:0]          idat_selb;
output reg                     iddr_enable;

output reg [1:0]               indrv;
output reg [1:0]               indrv_clk;
output reg [1:0]               indrv_rst;

output reg [1:0]               ipdrv;
output reg [1:0]               ipdrv_clk;
output reg [1:0]               ipdrv_rst;

output     [FBMP-1:0] [2:0]    rxen;
output     [FBMP-1:0]          txen;

output reg                     por_sl2sl;
output reg                     por_in;        // por_sl2ms
output     [HNBMP-1:0]         redun_engage;

input                          rstn_out;
input                          adap_rstn_out;
//input                          device_detect_n;
input                          device_detect;
input                          por_out;

input                          conf_done;
output reg                     config_done;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire                    adap_rstn_out_sync;     // From u_adap_rstn_out of itrx_aib_phy_bit_sync.v
wire                    conf_done_sync;         // From u_conf_done of itrx_aib_phy_bit_sync.v
wire                    device_detect_sync;     // From u_device_detect of itrx_aib_phy_bit_sync.v
wire                    por_out_sync;           // From u_por_out of itrx_aib_phy_bit_sync.v
wire                    rstn_out_sync;          // From u_rstn_out of itrx_aib_phy_bit_sync.v
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

itrx_aib_phy_bit_sync #(/*AUTOINSTPARAM*/
                        // Parameters
                        .NUM_FLOPS      (NUM_SYNC_DFFS))         // Templated
  u_rstn_out (/*AUTOINST*/
              // Outputs
              .dout                     (rstn_out_sync),         // Templated
              // Inputs
              .rst_n                    (presetn),               // Templated
              .clk                      (pclk),                  // Templated
              .din                      (rstn_out));             // Templated

itrx_aib_phy_bit_sync #(/*AUTOINSTPARAM*/
                        // Parameters
                        .NUM_FLOPS      (NUM_SYNC_DFFS))         // Templated
  u_adap_rstn_out (/*AUTOINST*/
                   // Outputs
                   .dout                (adap_rstn_out_sync),    // Templated
                   // Inputs
                   .rst_n               (presetn),               // Templated
                   .clk                 (pclk),                  // Templated
                   .din                 (adap_rstn_out));        // Templated

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
reg       idat_selb_dat;
reg       idat_selb_rst;
reg       idat_selb_clk;

reg [1:0] txen_dat;
reg       txen_rst;
reg       txen_clk;

reg [1:0] [2:0] rxen_dat;
reg [2:0] rxen_rst;
reg [2:0] rxen_clk;

reg [5:0] ddr_dly_adj_csr;
reg [5:0] sdr_dly_adj_csr;

reg       repair_info_dir;
reg [9:0] repair_info_loc;

//lint: One pin bus for upgrade to multi-chan
//lint_checking ONPNSG off
reg  [0:0] repair_info_vld;
wire [0:0][10:0] repair_info_nvm = {repair_info_dir, repair_info_loc};
//lint_checking ONPNSG on
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Connect APB mem-mapped control regs to AIB IO Chan config inputs:
//  txen, rxen, idat_selb
//
genvar ii;
generate
for (ii=0; ii<FBMP; ii=ii+1) begin : gl_bmp

//lint_checking DALIAS TIELOG off
  if          (TX_CLK[ii]) begin : gc_txclk
    assign txen[ii] = txen_clk;  
  end else if (TX_RST[ii]) begin : gc_txrst 
    assign txen[ii] = txen_rst;  
  end else if (TX_DAT[ii]) begin : gc_txdat 

   if (ii < GROUP1) begin : gc_txdat0 
    assign txen[ii] = txen_dat[0];  
   end else         begin : gc_txdat1
    assign txen[ii] = txen_dat[1];  
   end

  end else                 begin : gc_txdef
    assign txen[ii] = 1'b0;
  end

  if          (RX_CLK[ii]) begin : gc_rxclk
    assign rxen[ii] = rxen_clk;
  end else if (RX_RST[ii]) begin : gc_rxrst
    assign rxen[ii] = rxen_rst;
  end else if (RX_DAT[ii]) begin : gc_rxdat

   if (ii < GROUP1) begin : gc_rxdat0
    assign rxen[ii] = rxen_dat[0];
   end else         begin : gc_rxdat1
    assign rxen[ii] = rxen_dat[1];
   end

  end else                 begin : gc_rxdef
    assign rxen[ii] = RXEN_DISABLED;
  end

  if          (TX_CLK[ii]) begin : gc_sbclk
    assign idat_selb[ii] = idat_selb_clk;
  end else if (TX_RST[ii]) begin : gc_sbrst
    assign idat_selb[ii] = idat_selb_rst;
  end else if (TX_DAT[ii]) begin : gc_sbdat
    assign idat_selb[ii] = idat_selb_dat;
  end else                 begin : gc_sbdef
    assign idat_selb[ii] = 1'b0;
  end
//lint_checking DALIAS on

end
endgenerate
//-----------------------------------------------------------------------------

localparam [31:0] ADJ_PAD = DLYW - 32'd6;

assign ddr_dly_adjust = { {ADJ_PAD{1'b0}}, ddr_dly_adj_csr };
assign sdr_dly_adjust = { {ADJ_PAD{1'b0}}, sdr_dly_adj_csr };
//lint_checking TIELOG on

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


//-----------------------------------------------------------------------------
// Encode redun_engage output port.
//


itrx_aib_phy_repair_enc #(.MAXCH(32'd1))
  u_itrx_aib_phy_repair_enc (/*AUTOINST*/
                             // Outputs
                             .redun_engage      (redun_engage[44:0]),
                             // Inputs
                             .repair_info_nvm   (repair_info_nvm/*[(32'd1)-1:0][10:0]*/),
                             .repair_info_vld   (repair_info_vld[(32'd1)-1:0]));
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// APB Read Data
//
always_comb begin
  case (paddr)
    TX_DRV_LOC: prdata = {20'd0, ipdrv,     indrv, 
                                 ipdrv_rst, indrv_rst, 
                                 ipdrv_clk, indrv_clk};

    TX_CFG_LOC: prdata = {24'd0, txen_dat[1], iddr_enable,
                                 idat_selb_dat, idat_selb_rst, idat_selb_clk,
                                 txen_dat[0], txen_rst, txen_clk};

    RX_ENA_LOC: prdata = {20'd0, rxen_dat[1], 
                                 rxen_dat[0], rxen_rst, rxen_clk};

    RX_DLY_LOC: prdata = {18'd0, ddr_dly_adj_csr, 2'b00, sdr_dly_adj_csr};
    REPAIR_LOC: prdata = {20'd0, repair_info_vld, repair_info_nvm};

    RESETS_LOC: prdata = {27'd0, adap_rstn_out_sync, rstn_out_sync,  // From IO
                                 adap_rstn_in,  rstn_in, adapt_irstb};

    CFG_DN_LOC: prdata = {30'd0, conf_done_sync, config_done};
    DD_POR_LOC: prdata = {28'd0, por_sl2sl, por_in, 
                          por_out_sync, device_detect_sync}; // From AUX
    REVISN_LOC: prdata = {DEV_ID, MAJOR, MINOR};
    default   : prdata = 32'd0;
  endcase
end
//-----------------------------------------------------------------------------


always @(posedge pclk or negedge presetn) begin
  if (!presetn) begin
    ipdrv     <= AIB_DEF_DRV;
    indrv     <= AIB_DEF_DRV;
    ipdrv_rst <= AIB_DEF_DRV;
    indrv_rst <= AIB_DEF_DRV;
    ipdrv_clk <= AIB_DEF_DRV;
    indrv_clk <= AIB_DEF_DRV;

    iddr_enable     <= 1'b1;
    idat_selb_dat   <= 1'b0;
    idat_selb_rst   <= 1'b1;
    idat_selb_clk   <= 1'b0;
    txen_dat[1]     <= 1'b1;
    txen_dat[0]     <= 1'b1;
    txen_rst        <= 1'b1;
    txen_clk        <= 1'b1;

    rxen_dat[1] <= RXEN_DISABLED;
    rxen_dat[0] <= RXEN_DISABLED;
    rxen_rst    <= RXEN_DISABLED;
    rxen_clk    <= RXEN_DISABLED;

    ddr_dly_adj_csr <= 6'd0;
    sdr_dly_adj_csr <= 6'd0;
    repair_info_loc <= 10'd0;

    por_in <= 1'b1;
    por_sl2sl <= 1'b1;

    /*AUTORESET*/
    // Beginning of autoreset for uninitialized flops
    adap_rstn_in <= 1'h0;
    adapt_irstb <= 1'h0;
    config_done <= 1'h0;
    repair_info_dir <= 1'h0;
    repair_info_vld <= 1'h0;
    rstn_in <= 1'h0;
    // End of automatics

  end else begin
    if ((pstate == PACCESS) && pwrite && pready) begin
      case (paddr)
        TX_DRV_LOC: {ipdrv, indrv,
                     ipdrv_rst, indrv_rst,
                     ipdrv_clk, indrv_clk} <= pwdata[11:0];

        TX_CFG_LOC: {txen_dat[1], iddr_enable,
                     idat_selb_dat, idat_selb_rst, idat_selb_clk,
                     txen_dat[0], txen_rst, txen_clk} <= pwdata[7:0];

        RX_ENA_LOC: {rxen_dat[1],
                     rxen_dat[0], rxen_rst, rxen_clk} <= pwdata[11:0];

        RX_DLY_LOC: {ddr_dly_adj_csr, sdr_dly_adj_csr} <= {pwdata[13:8],
                                                           pwdata[ 5:0]};

        REPAIR_LOC: {repair_info_vld, repair_info_dir, repair_info_loc}
                      <= pwdata[11:0];

        RESETS_LOC: {adap_rstn_in, rstn_in, adapt_irstb} <= pwdata[2:0];

        CFG_DN_LOC: config_done <= pwdata[0];

        DD_POR_LOC: {por_sl2sl, por_in} <= pwdata[3:2];

        default: begin // HOLD VALUES 
          ipdrv     <= ipdrv;
          indrv     <= indrv;
          ipdrv_rst <= ipdrv_rst;
          indrv_rst <= indrv_rst;
          ipdrv_clk <= ipdrv_clk;
          indrv_clk <= indrv_clk;

          iddr_enable     <= iddr_enable;
          idat_selb_dat   <= idat_selb_dat;
          idat_selb_rst   <= idat_selb_rst;
          idat_selb_clk   <= idat_selb_clk;
          txen_dat        <= txen_dat;
          txen_rst        <= txen_rst;
          txen_clk        <= txen_clk;

          rxen_dat <= rxen_dat;
          rxen_rst <= rxen_rst;
          rxen_clk <= rxen_clk;

          ddr_dly_adj_csr <= ddr_dly_adj_csr;
          sdr_dly_adj_csr <= sdr_dly_adj_csr;
          repair_info_loc <= repair_info_loc;

          por_in    <= por_in;
          por_sl2sl <= por_sl2sl;

          adap_rstn_in <= adap_rstn_in;
          adapt_irstb <= adapt_irstb;
          config_done <= config_done;
          repair_info_dir <= repair_info_dir;
          repair_info_vld <= repair_info_vld;
          rstn_in <= rstn_in;
        end
      endcase
    end
  end
end

assign r_apb_fs_adap_rstn = adap_rstn_out_sync;
assign r_apb_fs_rstn = rstn_out_sync;

wire unused_ok = &{1'b1, pwdata[31:12]};

endmodule

// Local Variables:                                                                 
// verilog-auto-inst-param-value:t                                                  
// End:                         

