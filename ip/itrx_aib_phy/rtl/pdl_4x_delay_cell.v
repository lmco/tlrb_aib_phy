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
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.
//
// ==========================================================================
// Original Author: Intrinsix Corp./ Jason Karka
// Filename       : pdl_4x_delay_cell.v
// Description    : PDL (Delay Cell) for AIB RXCLK
//
// ==========================================================================
//
//    $Rev:: 5794                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-29 17:34:53 -0400#$: Date of last commit
//
// ==========================================================================
//


//lint: DIFFMN Module name differs from file name
//lint: MULTMF More than one design-unit definition in file
//lint_checking DIFFMN MULTMF off

//`ifdef SYNTHESIS
//`else
// Behavioral (tech independent) version of NAND gate with 25ps delay for Simulation only.
// The LEC "CUT" points for combinatorial loops in the PDL confuse LEC equivalence checking
// unless the behavioral is structured as below where NAND gate ports mimic the tech gate.
//
module PDL_NAND (A1, A2, ZN);
    input A1, A2;
    output ZN;
    nand #(0.025) (ZN, A1, A2);
endmodule
//`endif

module pdl_cell (in_p, bk, co_p, ci_p, out_p);
  input in_p, bk, ci_p;
  output out_p, co_p;

  wire #(0.010) a,b; // # delay just for sim wo back annotate Lib NAND cell

`ifdef SYNTHESIS

  /*
  <Tech std cell NAND name> nand0 (.A1(in_p), .A2(bk), .ZN(co_p));
  <Tech std cell NAND name> nand1 (.A1(a), .A2(bk), .ZN(b));
  <Tech std cell NAND name> nand2 (.A1(in_p), .A2(b), .ZN(a));
  <Tech std cell NAND name> nand3 (.A1(a), .A2(ci_p), .ZN(out_p));
  */
  // Instantiate the gates as in example above for a particular technology
  //  (and standard cell flavors):

  `include "itrx_aib_phy_tech_defines.vh"

  //lint_checking NOTECH SEPLIN off
  `PDL_CELL
  //lint_checking NOTECH SEPLIN on

`else // vvv RLB - add "SAME" gates with simulation delays vvv

  PDL_NAND         nand0 (.A1(in_p), .A2(bk), .ZN(co_p));
  PDL_NAND         nand1 (.A1(a), .A2(bk), .ZN(b));
  PDL_NAND         nand2 (.A1(in_p), .A2(b), .ZN(a));
  PDL_NAND         nand3 (.A1(a), .A2(ci_p), .ZN(out_p));

`endif

endmodule


module pdl_4x_delay_cell (co_p, out_p, bk, ci_p, in_p);
  output  co_p, out_p;
  input  ci_p, in_p;
  input [3:0] bk;

  wire a0, b0;
  wire a1, b1;
  wire a2, b2;

  pdl_cell dlycell0 (.in_p( in_p ), .ci_p( b0 ), .co_p( a0 ), .bk( bk[0] ), .out_p( out_p ));
  pdl_cell dlycell1 (.in_p( a0 ), .ci_p( b1 ), .co_p( a1 ), .bk( bk[1] ), .out_p( b0 ));
  pdl_cell dlycell2 (.in_p( a1 ), .ci_p( b2 ), .co_p( a2 ), .bk( bk[2] ), .out_p( b1 ));
  pdl_cell dlycell3 (.in_p( a2 ), .ci_p( ci_p ), .co_p( co_p ), .bk( bk[3] ), .out_p( b2 ));

endmodule

//lint_checking DIFFMN MULTMF on
