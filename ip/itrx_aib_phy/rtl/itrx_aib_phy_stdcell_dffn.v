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
// Filename       : itrx_aib_phy_stdcell_dffn.v
// Description    : Technology std cell DFF for AIB
//
// ==========================================================================
//
//    $Rev:: 5794                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-29 17:34:53 -0400#$: Date of last commit
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

//lint: negative edge use expected here.
//lint_checking NEFLOP NOTECH SEPLIN off

`ifdef SYNTHESIS

`include "itrx_aib_phy_tech_defines.vh"

  `DFFN_CELL_T0

// For example:
//<standard cell name, strength, Vt string code name> u_dff (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));

`else
  reg qout;
  always @(negedge clk or negedge rstn) begin
    if (!rstn) begin
      qout <= 1'b0;
    end else begin
      qout <= din;
//lint_checking NEFLOP NOTECH SEPLIN on
    end
  end
`endif

endmodule
