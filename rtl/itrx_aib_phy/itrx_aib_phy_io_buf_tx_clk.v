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
// Filename       : itrx_aib_phy_io_buf_tx_clk.v
// Description    : AIB IO Buffer TX clocks
//
// ==========================================================================
//
//    $Rev:: 5038                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-05-04 12:42:03 -0400#$: Date of last commit
//
// ==========================================================================
/*

  This module encapsulates all of the digital logic in the AIB TX clock path
  (as the logic is specified in the AIB Architecture Spec).

  The purpose is to allow this module to be used (independently of the rest 
  of the digital logic) in analog design, simulation,
  and analysis such that the all of the timing info for the critical
  paths to the TX AIB ubumps is represented.
 
  The TX clock path starts from the AIB PHY input TX clock port.
  This port can be represented by "refClk" from the AIB Arch Spec Eye Diagram
  Test Setup.  The TX clock is distributed to an array of TX AIB IO buffer
  cells and connected to the ilanuch_clk inputs of each. Each AIB IO cell has 
  2 ilanuch clock inputs (normal and redundant) which may be connected. 

  The digital logic in this module is composed solely of instantiated gates from 
  the technology vendor standard cell digital logic IP library.

*/
//------------------------------------------------------------------------------
module itrx_aib_phy_io_buf_tx_clk(/*AUTOARG*/
   // Outputs
   txdat_mux, ilaunch_clk,
   // Inputs
   jtag_clksel, redn_engage, idat_selb, idat0q, idat1ql, async_data,
   nrml_ilaunch_clk, redn_ilaunch_clk, jtag_clkdr
   );

//------------------------------------------------------------------------------
// I/O ports
//
input  jtag_clksel;        // Mux select to select JTAG to drive CLKDR to TX clk
input  redn_engage;        // Mux select to select redundant ilaunch clock
input  idat_selb;          // Mux select to select async data to the output 
                           // (=1 selects async data)

input  idat0q;             // Registered data bit from idat0
input  idat1ql;            // Registered-Latched data bit from idat1
input  async_data;         // TX Asynchronous data input to AIB IO buffer

input  nrml_ilaunch_clk;   // distributed TX (ilaunch) clock normal (non-redund)
input  redn_ilaunch_clk;   // distributed TX (ilaunch) clock (redundant)
input  jtag_clkdr;         // JTAG clock from TAP controller

output txdat_mux;          // Clock/Data To Analog AIB IO Driver 
output ilaunch_clk;        // buffered copy of TX clock to digital logic 
//                            (DFFs/latch in THIS AIB IO Buffer only) 
//------------------------------------------------------------------------------

wire tie_low = 1'b0; // Tie off for unused logic gate inputs

// internal MUX gate outputs
//
wire ilaunch_clk_rmx;  // TX launch clock after redundany mux selection
wire ilaunch_clk_ana;  // TX launch clock after JTAG mux selection
wire txdat_ddr;        // SDR/DDR data/clocka selected by TX launch clock

// Instantiate digital logic gates (MUXs)
//
//lint: Connecting clocks to non-clock input names is expected.
//lint_checking DIFCLK off
itrx_aib_phy_stdcell_clk_mux 
  u_rmx (.din0(nrml_ilaunch_clk),  // Redundancy clock MUX
         .din1(redn_ilaunch_clk), 
         .msel(redn_engage),
         .dout(ilaunch_clk_rmx));

itrx_aib_phy_stdcell_clk_mux 
  u_ana (.din0(ilaunch_clk_rmx),  // JTAG clock MUX (to DDR MUX)
         .din1(jtag_clkdr),      
         .msel(jtag_clksel),     
         .dout(ilaunch_clk_ana));

itrx_aib_phy_stdcell_clk_mux 
  u_ddr (.din0(idat0q),           // DDR MUX (to Async Data MUX)          
         .din1(idat1ql),         
         .msel(ilaunch_clk_ana), 
         .dout(txdat_ddr));

itrx_aib_phy_stdcell_clk_mux 
  u_txm (.din0(txdat_ddr),        // Sync/Async Data MUX (to ANA)
         .din1(async_data),       
         .msel(idat_selb),       
         .dout(txdat_mux));

itrx_aib_phy_stdcell_clk_mux 
  u_buf (.din0(ilaunch_clk_ana),  // ilaunch_clk buffer (to DFFs)
         .din1(tie_low),         
         .msel(tie_low),         
         .dout(ilaunch_clk));
//lint_checking DIFCLK on

endmodule
