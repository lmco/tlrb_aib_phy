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
// Original Author: Intrinsix Corp.
// Filename       : itrx_aib_phy_ms2sl_dp_sl_sm.v
// Description    : AIB PHY Master-to-Slave, Master Data Path State Machine
//
// ==========================================================================
//
//    $Rev:: 5809                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-06-24 16:02:37 -0400#$: Date of last commit
//
// ==========================================================================

// AIB Master Data Path Calibration State Machine (MS-to-SL datapath)
// Also called the Reset Sequence.

/*
AIB AS Spec (Intel):

  phy_ms_tx_dll_dcd_lock_req Master PHY request to start DLL/DCC calibration on MS-to-SL datapath
  phy_sl_rx_dll_dcd_lock_req Slave  PHY request to start DLL/DCC calibration on MS-to-SL datapath

  phy_sl_tx_dll_dcd_lock_req Slave  PHY request to start DLL/DCC calibration on SL-to-MS datapath
  phy_ms_rx_dll_dcd_lock_req Master PHY request to start DLL/DCC calibration on SL-to-MS datapath

*/

// Abbreviations
//
//   XFER = TRANSFER
//   RMT  = REMOTE
//
//   cal   = calibration
//   cmplt = complete

// This State machine is Resident on the SLAVE Chiplet.

//lint: FSM for state register 'cur_st' does not adhere STYLE guidelines
//lint: One-hot encoding not used for assigning states
//lint: Extraneous logic present in FSM
//
//lint_checking BADFSM ONHOEN EXTFSM off

module itrx_aib_phy_ms2sl_dp_sl_sm (
  input  osc_clk,
  input  rstn,                    // Where is reset from?

  input  ns_adapter_rstn,
  input  fs_adapter_rstn,
  input  conf_done,
  input  sl_osc_transfer_alive,   // From OSC clock Cal SM

  input  int_dll_lock_cmplt,      // INTERNAL DLL Lock Complete

//output int_dcc_cal_req,

  output sl_rx_dll_lock,          // From Slave Chiplet DP SM
  output sl_rx_transfer_en,       // From Slave Chiplet DP SM

  input  ms_tx_dcc_cal_done,      // To   Slave Chiplet DP SM
  input  ms_tx_transfer_en);      // To   Slave Chiplet DP SM

// States from "Figure 41. Master-to-Slave Datapath Calibration State Machine"
//
localparam ST_WAIT_RX_XFER_REQ     = 3'd0;
localparam ST_SEND_RX_DLL_LOCK_REQ = 3'd1;
localparam ST_RX_DLL_LOCK          = 3'd2;
localparam ST_RX_XFER_EN           = 3'd3;
localparam ST_RX_XFER_ALIVE        = 3'd4;

reg [2:0] cur_st; // Current state register (DFF)
reg [2:0] nxt_st; // Next state (combinatorial)

// Stay in the reset state unless all of the
// prerequisites are met.
//
wire prereqs = ns_adapter_rstn &
               fs_adapter_rstn &
               conf_done &
               ms_osc_transfer_alive;

assign ms_tx_transfer_en  = (cur_st == ST_TX_XFER_EN);

always @(posedge osc_clk or negedge rstn) begin
  if (!rstn) begin
    cur_st <= ST_WAIT_RX_XFER_REQ;
  end else begin
    cur_st <= nxt_st;
  end
end


always @(*) begin
  case (cur_st)

    ST_WAIT_RX_XFER_REQ:      nxt_st = (prereqs & ms_tx_dcc_cal_done) ? ST_SEND_RX_DLL_LOCK_REQ
                                                                      : ST_WAIT_RX_XFER_REQ;

    ST_SEND_RX_DLL_LOCK_REQ:  nxt_st = (!both_reqs) ? ST_WAIT_TX_XFER_REQ
                                                   : (int_dcc_cal_cmplt) ? ST_WAIT_RMT_RX_DLL_LOCK
                                                                         : ST_SEND_RX_DLL_LOCK_REQ;

    ST_WAIT_RMT_RX_DLL_LOCK: nxt_st = (!both_reqs) ? ST_WAIT_TX_XFER_REQ
                                                   : (sl_rx_dll_lock) ? ST_WAIT_RMT_RX_XFER_EN
                                                                      : ST_WAIT_RMT_RX_DLL_LOCK;

    ST_WAIT_RMT_RX_XFER_EN:  nxt_st = (!both_reqs) ? ST_WAIT_TX_XFER_REQ
                                                   : (sl_rx_transfer_en) ? ST_TX_XFER_EN
                                                                         : ST_WAIT_RMT_RX_DLL_LOCK;

    ST_TX_XFER_EN:           nxt_st = (!both_reqs) ? ST_WAIT_TX_XFER_REQ
                                                   : ST_TX_XFER_EN;

    default:                 nxt_st = ST_WAIT_TX_XFER_REQ;

  endcase
end

//lint_checking BADFSM ONHOEN EXTFSM on

endmodule
