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
// Filename       : itrx_aib_phy_io_buf_rx_dist.v
// Description    : AIB Digital Logic of the RX side distribution
//                  of an AIB buffer (Fig. 3-13).
//
// ==========================================================================
//
//    $Rev:: 5159                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-07-23 17:18:14 -0400#$: Date of last commit
//
// ==========================================================================

//lint: Combinatorial path is expected for async data.
//lint_checking IOCOMB off
module itrx_aib_phy_io_buf_rx_dist(/*AUTOARG*/
   // Outputs
   odat0, odat1, odat_asyn,
   // Inputs
   rxd0_irstb, rxd1_irstb, inclk_dist, ubump_rx_0ql, ubump_rx_1q,
   ubump_rx_n
   );

//------------------------------------------------------------------------------
// I/O ports
//
input       rxd0_irstb;   // reset (active low, inclk)
input       rxd1_irstb;   // reset (active low, inclk)
input       inclk_dist;   // retime DFF clock
input       ubump_rx_0ql; // RX data SDR/DDR (captured by inclk)
input       ubump_rx_1q;  // RX data DDR  (captured by inclk)
input       ubump_rx_n;   // RX Async data from ubump Analog output (inverted)

output      odat0;        // RX data SDR/DDR
output      odat1;        // RX data DDR
output      odat_asyn;   // RX Asynchronous data
//------------------------------------------------------------------------------

assign odat_asyn = ~ubump_rx_n;

itrx_aib_phy_stdcell_dff
  u_odat0_dff       (// Outputs
                     .qout              (odat0),
                     // Inputs
                     .din               (ubump_rx_0ql),
                     .clk               (inclk_dist),
                     .rstn              (rxd0_irstb));

itrx_aib_phy_stdcell_dff
  u_odat1_dff       (// Outputs
                     .qout              (odat1),
                     // Inputs
                     .din               (ubump_rx_1q),
                     .clk               (inclk_dist),
                     .rstn              (rxd1_irstb));
/*

//lint: Only applies in the top-level context.
//halstruct: Flip-flop 'odat0/1' has clock not derived from primary input.
//lint_checking CLKNPI off
always @(posedge inclk_dist or negedge rxd0_irstb) begin
  if (!rxd0_irstb) begin
    odat0 <= 1'h0;
  end else begin
    odat0 <= ubump_rx_0ql;
  end
end

always @(posedge inclk_dist or negedge rxd1_irstb) begin
  if (!rxd1_irstb) begin
    odat1 <= 1'h0;
  end else begin
    odat1 <= ubump_rx_1q;
  end
end
//lint_checking CLKNPI on
//lint_checking IOCOMB on

*/

endmodule
