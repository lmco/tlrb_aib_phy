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
// Filename       : itrx_aib_phy_out_bc.v
// Description    : AIB JTAG Output Boundary Cell
//
// ==========================================================================
//
//    $Rev:: 5038                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-05-04 12:42:03 -0400#$: Date of last commit
//
// ==========================================================================

/*
Detailed description:
   AIB JTAG Output Boundary Cell
   Reference Arch Spec Figure: "Boundary Scan Cells for Clocks, Inputs, and Output"
*/

module itrx_aib_phy_out_bc(/*AUTOARG*/
   // Outputs
   d_o, so,
   // Inputs
   jtag_clkdr, jtag_scan_en, jtag_intest, jtag_mode, d_i, si
   );

input jtag_clkdr;
input jtag_scan_en;
input jtag_intest;
input jtag_mode;

input  d_i;
input  si;

output d_o;
output so;

reg tx_reg;

assign d_o = jtag_mode ? tx_reg : d_i;

always @(posedge jtag_clkdr) begin
//lint: no resets for BC cells
//lint_checking FFWNSR off
  tx_reg <= jtag_scan_en ? si : (jtag_intest ? d_i : tx_reg);
//lint_checking FFWNSR on
end

assign so = tx_reg;

endmodule
