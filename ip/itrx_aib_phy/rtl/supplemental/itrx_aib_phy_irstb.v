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
wire rx_irstb;

// Synchronize irstb to tx_clk (mux-ed w jtag_clkdr).
//

wire tx_clk_jtag;

// DFT:
// Mux to allow jtag_clkdr to drive the TX ilaunch_clk
//
itrx_aib_phy_stdcell_clk_mux
  u_tx_jtag_clk (.din0(tx_clk),
                 .din1(jtag_clkdr),
                 .msel(jtag_clksel),
                 .dout(tx_clk_jtag));

// FIX ME - may already be sync-ed to tx_clk wasteful
//lint_checking DIFCLK DIFRST off
itrx_aib_phy_sync_rstn
  u_tx_sync_rstn (// Outputs
                  .dout                 (tx_irstb),
                  // Inputs
                  .scan_mode            (jtag_rstn_en),
                  .rst_n                (irstb),
                  .clk                  (tx_clk_jtag));

// Synchronize irstb to inclk (rx_clk delayed)
//
itrx_aib_phy_sync_rstn
  u_rx_sync_rstn (// Outputs
                  .dout                 (rx_irstb),
                  // Inputs
                  .scan_mode            (jtag_rstn_en),
                  .rst_n                (irstb),
                  .clk                  (rx_clk));
//lint_checking DIFCLK DIFRST on
//-----------------------------------------------------------------------------

endmodule
