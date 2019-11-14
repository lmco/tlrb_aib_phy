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
// Filename       : itrx_aib_phy_stdcell_icg.v
// Description    : Technology std cell ICG for AIB
//
// ==========================================================================
//
//    $Rev:: 5794                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-29 17:34:53 -0400#$: Date of last commit
//
// ==========================================================================
// Integrated Clock Gate
//
//   clk_o is held HIGH when not enabled (ena=0).
//   The ena input setup/hold is wrt the falling edge of clk input.
//
//scan_mode\          ------------------------------
//          OR:gate-->| D LATCH                  QN|---\
//  ena>---/          | CLK (transparent high)     |    OR:gate-->clk_o
//                    --^---------------------------   /
//                      |                             /
//                      |                            /
//  clk>----------------+---------------------------/
//

//lint: A comb path from clk to clk_o, and thru comb logic is expected.
//lint_checking IOCOMB CLKUCL off
module itrx_aib_phy_stdcell_icg (/*AUTOARG*/
   // Outputs
   clk_o,
   // Inputs
   scan_mode, ena, clk
   );
//lint_checking IOCOMB on
//lint_checking SEPLIN off

// Type/flavor Used for different Vt, Drive strength, etc options of cells
//
parameter CELL_TYPE = 32'd0;

input  scan_mode;
input  ena;
input  clk;

output clk_o;

//lint: Expected latch: Process/always block models a latch.
//lint_checking LATINF off

`ifdef SYNTHESIS
//lint_checking NOTECH off

// Allow for 4 different flavors of ICG as in <>defines.vh
//
`include "itrx_aib_phy_tech_defines.vh"

generate
  if          (CELL_TYPE == 32'd1) begin : gc1
    `ICG_CELL_T1
  end else if (CELL_TYPE == 32'd2) begin : gc2
    `ICG_CELL_T2
  end else if (CELL_TYPE == 32'd3) begin : gc3
    `ICG_CELL_T3
  end else                         begin : gc0
    `ICG_CELL_T0
  end
//lint_checking NOTECH on
endgenerate

`else

  reg q;
  always @(*) begin
    if (clk) begin

      q <= ena | scan_mode;
//lint_checking LATINF on

    end
  end

  assign clk_o = clk | (~q);

  wire unused_ok = &{CELL_TYPE};

`endif
//lint_checking CLKUCL on

endmodule
