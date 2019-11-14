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
// Filename       : itrx_aib_phy_stdcell_dff.v
// Description    : Technology std cell DFF for AIB
//
// ==========================================================================
//
//    $Rev:: 5794                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-29 17:34:53 -0400#$: Date of last commit
//
// ==========================================================================
// standard cell DFF
// 1 output posedge clock, async active low clear
//
module itrx_aib_phy_stdcell_dff (/*AUTOARG*/
   // Outputs
   qout,
   // Inputs
   din, clk, rstn
   );

// Type/flavor Used for different Vt, Drive strength, etc options of cells
//
parameter CELL_TYPE = 32'd0;

input  din;
input  clk;
input  rstn;

output qout;

//lint_checking NOTECH SEPLIN off

`ifdef SYNTHESIS

// Allow for 4 different flavors of DFF as in <>defines.vh
//
`include "itrx_aib_phy_tech_defines.vh"

generate
  if          (CELL_TYPE == 32'd1) begin : gc1
    `DFF_CELL_T1
  end else if (CELL_TYPE == 32'd2) begin : gc2
    `DFF_CELL_T2
  end else if (CELL_TYPE == 32'd3) begin : gc3
    `DFF_CELL_T3
  end else                         begin : gc0
    `DFF_CELL_T0
  end
endgenerate

// For example:
//<standard cell name, strength, Vt string code name> u_dff (.D(din),.CP (clk),.CDN(rstn),.Q(qout));

`else

    reg qout;
    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
          qout <= 1'b0;
        end else begin
          qout <= din;
        end
      end

    wire unused_ok = &{CELL_TYPE};

`endif

//lint_checking NOTECH SEPLIN on

endmodule
