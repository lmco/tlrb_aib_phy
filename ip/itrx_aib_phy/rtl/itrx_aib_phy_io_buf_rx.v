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
// Filename       : itrx_aib_phy_io_buf_rx.v
// Description    : AIB Digital Logic (non analog portion) of the RX side
//                  of an AIB buffer (Fig. 3-13).
//
// ==========================================================================
//
//    $Rev:: 5038                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-05-04 12:42:03 -0400#$: Date of last commit
//
// ==========================================================================

module itrx_aib_phy_io_buf_rx(/*AUTOARG*/
   // Outputs
   ubump_rx_0ql, ubump_rx_1q,
   // Inputs
   rxd0_irstb, rxd1_irstb, inclk, ubump_rx
   );

//------------------------------------------------------------------------------
// I/O ports
//
input       rxd0_irstb;   // reset (active low, inclk)
input       rxd1_irstb;   // reset (active low, inclk)
input       inclk;        // strobe DFF clock
input       ubump_rx;     // ubump level shifted to digital (from Analog output)

output      ubump_rx_0ql; // RX data SDR/DDR (registered-latched RX ubump)
output      ubump_rx_1q;  // RX data DDR (registered RX ubump)
//------------------------------------------------------------------------------

wire ubump_rx_dly; // Delayed by a MUX gate
wire ubump_rx_0q;   // Captured but not yet latched

wire tie_low = 1'b0;

//-----------------------------------------------------------------------------
// Matches RX clock delay (corresponding to the clock redundancy MUX)
//
itrx_aib_phy_stdcell_clk_mux
  u_dly_mux (.din0(ubump_rx),
             .din1(tie_low),
             .msel(tie_low),
             .dout(ubump_rx_dly));
//-----------------------------------------------------------------------------


// lint_checking DIFCLK DIFRST off

//-----------------------------------------------------------------------------
// Capture (strobe DFFs)
//
itrx_aib_phy_stdcell_dffn
  u_strobe_dff_fall (// Outputs
                     .qout              (ubump_rx_0q),
                     // Inputs
                     .din               (ubump_rx_dly),
                     .clk               (inclk),
                     .rstn              (rxd0_irstb));

itrx_aib_phy_stdcell_dff
  u_strobe_dff_rise (// Outputs
                     .qout              (ubump_rx_1q),
                     // Inputs
                     .din               (ubump_rx_dly),
                     .clk               (inclk),
                     .rstn              (rxd1_irstb));
//-----------------------------------------------------------------------------


//-----------------------------------------------------------------------------
// Latch for idat0 path
//
itrx_aib_phy_stdcell_lat
  u_strobe_lat_rise (// Outputs
                     .qout              (ubump_rx_0ql),
                     // Inputs
                     .din               (ubump_rx_0q),
                     .clk               (inclk),
                     .rstn              (rxd0_irstb));
//-----------------------------------------------------------------------------

// lint_checking DIFCLK DIFRST on

endmodule
