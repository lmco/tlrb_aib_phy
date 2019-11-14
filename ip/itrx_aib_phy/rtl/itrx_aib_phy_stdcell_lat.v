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
// Filename       : itrx_aib_phy_stdcell_lat.v
// Description    : Technology std cell Latch for AIB
//
// ==========================================================================
//
//    $Rev:: 5794                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-29 17:34:53 -0400#$: Date of last commit
//
// ==========================================================================
// standard cell Latch
// latch enabled high,  async active low clear
//
//lint_checking IOCOMB off
//
module itrx_aib_phy_stdcell_lat (/*AUTOARG*/
   // Outputs
   qout,
   // Inputs
   din, clk, rstn
   );

input  din;
input  clk;
input  rstn;

output qout;

`ifdef SYNTHESIS

// Allow for different flavors (T0-Tn) as in <>defines.vh
//
`include "itrx_aib_phy_tech_defines.vh"

// Instantiate latch technology cell
//

//lint_checking LATINF off
//lint_checking NOTECH SEPLIN off
`LAT_CELL_T0
//lint_checking NOTECH SEPLIN on

`else // alternate synth model

  reg qout;
  always @ (clk or din or rstn) begin // Latch
    if (!rstn) begin
      qout <= 1'h0;
    end else begin
      if (clk) begin
        qout <= din;
//lint_checking LATINF on
      end
    end
  end

`endif

//lint_checking IOCOMB on
endmodule
