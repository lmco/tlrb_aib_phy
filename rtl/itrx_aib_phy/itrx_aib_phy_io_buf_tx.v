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
// Filename       : itrx_aib_phy_io_buf_tx.v
// Description    : AIB IO Buffer TX data logic
//
// ==========================================================================
//
//    $Rev:: 5159                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-07-23 17:18:14 -0400#$: Date of last commit
//
// ==========================================================================
//------------------------------------------------------------------------------
// Digital Logic (non analog portion) of the TX side of an AIB Buffer.
// Port names match Fig. 3-13 AIB Spec
//
module itrx_aib_phy_io_buf_tx (/*AUTOARG*/
   // Outputs
   idat0q, idat1ql,
   // Inputs
   tx_irstb, idat0, idat1, ilaunch_clk, iddr_enable
   );

//------------------------------------------------------------------------------
// I/O ports
//
input  tx_irstb;    // reset (active low)
input  idat0;       // SDR/DDR TX data
input  idat1;       // DDR TX data
input  ilaunch_clk; // TX clock

input  iddr_enable; // =1 selects DDR mode (otherwise SDR)

output idat0q;      // to TX clock MUXs
output idat1ql;     // to TX clock MUXs
//------------------------------------------------------------------------------

wire idat0q;  // idat0 DFF
wire idat1q;  // idat1 DFF
wire idat1ql; // idat  Latch

wire iddr_mux;

itrx_aib_phy_stdcell_clk_mux 
  u_iddr_mux  (// Inputs
               .din0             (idat0q),
               .din1             (idat1q),
               .msel             (iddr_enable),
               // Outputs
               .dout             (iddr_mux));

itrx_aib_phy_stdcell_dff
  u_idat0q_dff (// Outputs
                .qout              (idat0q),
                // Inputs
                .din               (idat0),
                .clk               (ilaunch_clk),
                .rstn              (tx_irstb));

itrx_aib_phy_stdcell_dff
  u_idat1q_dff (// Outputs
                .qout              (idat1q),
                // Inputs
                .din               (idat1),
                .clk               (ilaunch_clk),
                .rstn              (tx_irstb));

itrx_aib_phy_stdcell_latn
  u_idat1ql_latn (// Outputs
                  .qout            (idat1ql),
                  // Inputs
                  .din             (iddr_mux),
                  .clk             (ilaunch_clk),
                  .rstn            (tx_irstb));

//lint: Exceptions only apply in top-level context
//halstruct: Enable of latch 'idat1ql' is not controllable from primary inputs.
//halstruct: Flip-flop 'idat0q' has clock 'ilaunch_clk' which is not derived from primary input.
//lint_checking LENCPI CLKNPI off

/*
always @(posedge ilaunch_clk or negedge tx_irstb) begin
  if (!tx_irstb) begin
    idat0q <= 1'h0;
    idat1q <= 1'h0;
    // End of automatics
  end else begin
    idat0q <= idat0;
    idat1q <= idat1;
  end
end
*/

/*
always @(ilaunch_clk or iddr_mux or tx_irstb) begin // Latch
  if (!tx_irstb) begin
    idat1ql <= 1'h0;
    // End of automatics
  end else begin
    if (!ilaunch_clk) begin // Latch enable active low

//lint: A latch is expected here.
//lint_checking LATINF off
    idat1ql <= iddr_mux;
//lint_checking LATINF on
    end
  end
end
//lint_checking LENCPI CLKNPI on
*/

endmodule
