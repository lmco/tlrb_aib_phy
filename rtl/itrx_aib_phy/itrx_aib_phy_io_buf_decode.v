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
// Filename       : itrx_aib_phy_io_buf_decode.v
// Description    : AIB IO Buffer Decode logic
//
// ==========================================================================
//
//    $Rev:: 5100                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-06-26 19:22:56 -0400#$: Date of last commit
//
// ==========================================================================

//lint: This module is expected to have combinatorial decode paths.
//lint_checking IOCOMB off

module itrx_aib_phy_io_buf_decode(/*AUTOARG*/
   // Outputs
   tx_en_buf, weakp0, weakp1, rx_dat_en, rx_clk_en, rxd0_irstb,
   rxd1_irstb,
   // Inputs
   txen, rxen, iredrstb, rx_irstb, iweakpdn, iweakpu
   );

`include  "itrx_aib_phy_consts.vh"

input        txen; // From AIB configuration
input  [2:0] rxen;

input        iredrstb; // Asserted low if irstb, OR 
                       // cell is broken (redundancy engaged & 1st in chain)
input        rx_irstb;

input        iweakpdn; // From JTAG
input        iweakpu;

//output       tx_tristate; // To TX Analog 


output       tx_en_buf; // To TX Analog 
output       weakp0;
output       weakp1;

//output       rx_dat_pwr_dn; // To RX Analog 
//output       rx_clk_pwr_dn;

output       rx_dat_en; // To RX Analog 
output       rx_clk_en;

output       rxd0_irstb; // To RX digital (data path reset)
output       rxd1_irstb; 

//------------------------------------------------------------------------------
// TX Driver Enable
//
wire   tx_en_buf = txen & iredrstb; // Enable driver if configed txen & reset negated.

// TX Driver Tristate
//
//assign tx_tristate = ~tx_en; // Opposite polarity of TX Driver Enable (tx_en)

// Pulldown Enable
//
assign weakp0 = iweakpdn | // DFT pulldown enable OR-term
                (~iredrstb) | // Pulldown if iredrstb is asserted OR-term

                // Tristated TX and Disabled RX (rxen=010)
                ((~tx_en_buf) & (rxen[2:0] == RXEN_NRX));

// Pullup Enable. 
// Enable pullup if configured iweakpu and iredrstb is negated (DFT only).
//
assign weakp1 = iweakpu & iredrstb;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// RX Data Receiver Enable
//
wire   rx_dat_en = iredrstb & 
                    ((rxen[2:0] == RXEN_ASI) |  // 000 = Async data input
                     (rxen[2:0] == RXEN_SDR) |  // 100 = Sync SDR input
                     (rxen[2:0] == RXEN_DDR) ); // 001 = Sync DDR input

// RX Data Receiver Power Down (disable)
//
//assign rx_dat_pwr_dn = ~rx_dat_en; // Opposite polarity RX Data Receiver Enable

// RX Clock Receiver Enable
//
wire   rx_clk_en = iredrstb & (rxen[2:0] == RXEN_CKI); // 011 = In Clk buff enabled.

// RX Clock Receiver Power Down (disable)
//
//assign rx_clk_pwr_dn = ~rx_clk_en; // Opposite polarity RX Clock Receiver Enable


// FIX ME Put this is separate module for lint?
//lint: Combin logic in the path of asyn reset. OK, comb static when rstb 0-> 1
//lint_checking GLTASR off

// Resets to Bit 0 DFFs and Latch can only be negated high (released) if irstb 
// is released AND the rxen configuration input decodes to either SDR or DDR.
//
wire [2:0] irxen = iredrstb ? rxen : RXEN_NRX;

assign rxd0_irstb = rx_irstb & ((irxen[2:0] == RXEN_SDR) |  // 100 = Sync SDR in
                                (irxen[2:0] == RXEN_DDR) ); // 001 = Sync DDR in

// Resets to Bit 1 DFFs can only be negated high (released) if irstb is released
// AND the rxen configuration input decodes to DDR.
//
assign rxd1_irstb = rx_irstb & (irxen[2:0] == RXEN_DDR); // 001 = Sync DDR input.

//lint_checking GLTASR on

endmodule
