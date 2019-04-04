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
// Filename       : itrx_aib_phy_stdcell_dffn.v
// Description    : Technology std cell DFF for AIB
//
// ==========================================================================
//
//    $Rev:: 5038                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-05-04 12:42:03 -0400#$: Date of last commit
//
// ==========================================================================
//
// standard cell DFF
// 1 output NEGedge clock, async active low clear
//
module itrx_aib_phy_stdcell_dffn (/*AUTOARG*/
   // Outputs
   qout,
   // Inputs
   din, clk, rstn
   );

input  din;
input  clk;
input  rstn;

output qout;

//lint_checking NOTECH off
//
// EDIT ME for the selected technology:
//
// vvvvvvvvvvvvvvvvvvvvvvvvvv
`ifdef TECH_IS_TSMC_16FFC

DFNCNQD0BWP16P90 
  u_dffn(.D   (din), 
         .CPN (clk), 
         .CDN (rstn), 
         .Q   (qout));
// ^^^^^^^^^^^^^^^^^^^^^^^^^^
//lint_checking NOTECH off
`else
  reg qout;
  always @(negedge clk or negedge rstn) begin
    if (!rstn) begin
      qout <= 1'b0;
    end else begin
//lint: negative edge use expected here.
//lint_checking NEFLOP off
      qout <= din;
//lint_checking NEFLOP on
    end
  end
`endif

endmodule
