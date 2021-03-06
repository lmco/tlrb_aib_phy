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
// Filename       : itrx_aib_phy_stdcell_clk_mux.v
// Description    : AIB PHY standard cell clock MUX
//
// ==========================================================================
//
//    $Rev:: 5794                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-29 17:34:53 -0400#$: Date of last commit
//
// ==========================================================================
// "balanced" delay standard cell 2 to 1 MUX
//
//lint: Combinatorial gate expected.
//lint_checking IOCOMB off
module itrx_aib_phy_stdcell_clk_mux (/*AUTOARG*/
   // Outputs
   dout,
   // Inputs
   din0, din1, msel
   );
//lint_checking IOCOMB on

//-----------------------------------------------------------------------------

// Type/flavor Used for different Vt, Drive strength, etc options of cells
//
parameter CELL_TYPE = 32'd2;

input  din0;
input  din1;
input  msel;

output dout;

generate

begin : gc_tech

`ifdef SYNTHESIS

  `include "itrx_aib_phy_tech_defines.vh"

  // Instantiate a technology cell MUX

  //lint_checking NOTECH off
    if          (CELL_TYPE == 32'd1) begin : gc1
      `CMX_CELL_T1
    end else if (CELL_TYPE == 32'd2) begin : gc2
      `CMX_CELL_T2
    end else if (CELL_TYPE == 32'd3) begin : gc3
      `CMX_CELL_T3
    end else                         begin : gc0
      `CMX_CELL_T0
    end
  //lint_checking NOTECH on

  // Example:
  /*
  <std cell 2 to 1 MUX cell name>
    u_mux (.I0 (din0),
           .I1 (din1),
           .S  (msel),
           .Z  (dout));
  */
`else
  assign dout = msel ? din1 : din0;
  wire unused_ok = &{CELL_TYPE{1'b1}};
`endif
//lint_checking NOTECH off

end

endgenerate

endmodule
