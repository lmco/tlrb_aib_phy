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
// Original Author: Intrinsix Corp./ Jason Karka
// Filename       : pdl.v
// Description    : PDL (Delay Cell) for AIB RXCLK
//
// ==========================================================================
//
//    $Rev:: 5794                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-29 17:34:53 -0400#$: Date of last commit
//
// ==========================================================================

// From Jason
/*

pd/pdl/pnr/rundir_template/inputs/pdl.v
pd/pdl_4x_delay_cell/pnr/rundir_template/inputs/pdl_4x_delay_cell.v

*/
module pdl (in_p, bk, out_p);
  input in_p;
  input [63:0] bk;
  output out_p;

wire ci_p1, out0;
wire  ci_p2, out1;
wire  ci_p3, out2;
wire  ci_p4, out3;
wire  ci_p5, out4;
wire  ci_p6, out5;
wire  ci_p7, out6;
wire  ci_p8, out7;
wire  ci_p9, out8;
wire  ci_p10, out9;
wire  ci_p11, out10;
wire  ci_p12, out11;
wire  ci_p13, out12;
wire  ci_p14, out13;
wire  ci_p15, out14;
wire  feedback;

// perl -p -ne 'BEGIN{$i=0; $j=3;}; s/bk\[[0-9]+\]/bk[$j:$i]/; $i++; $j++; $i++; $j++; $i++; $j++; $i++; $j++;'
    pdl_4x_delay_cell pdl_cell0(.in_p(in_p), .ci_p(ci_p1), .bk(bk[3:0]), .out_p(out_p), .co_p(out0));
    pdl_4x_delay_cell pdl_cell1(.in_p(out0), .ci_p(ci_p2), .bk(bk[7:4]), .out_p(ci_p1), .co_p(out1));
    pdl_4x_delay_cell pdl_cell2(.in_p(out1), .ci_p(ci_p3), .bk(bk[11:8]), .out_p(ci_p2), .co_p(out2));
    pdl_4x_delay_cell pdl_cell3(.in_p(out2), .ci_p(ci_p4), .bk(bk[15:12]), .out_p(ci_p3), .co_p(out3));
    pdl_4x_delay_cell pdl_cell4(.in_p(out3), .ci_p(ci_p5), .bk(bk[19:16]), .out_p(ci_p4), .co_p(out4));
    pdl_4x_delay_cell pdl_cell5(.in_p(out4), .ci_p(ci_p6), .bk(bk[23:20]), .out_p(ci_p5), .co_p(out5));
    pdl_4x_delay_cell pdl_cell6(.in_p(out5), .ci_p(ci_p7), .bk(bk[27:24]), .out_p(ci_p6), .co_p(out6));
    pdl_4x_delay_cell pdl_cell7(.in_p(out6), .ci_p(ci_p8), .bk(bk[31:28]), .out_p(ci_p7), .co_p(out7));
    pdl_4x_delay_cell pdl_cell8(.in_p(out7), .ci_p(ci_p9), .bk(bk[35:32]), .out_p(ci_p8), .co_p(out8));
    pdl_4x_delay_cell pdl_cell9(.in_p(out8), .ci_p(ci_p10), .bk(bk[39:36]), .out_p(ci_p9), .co_p(out9));
    pdl_4x_delay_cell pdl_cell10(.in_p(out9), .ci_p(ci_p11), .bk(bk[43:40]), .out_p(ci_p10), .co_p(out10));
    pdl_4x_delay_cell pdl_cell11(.in_p(out10), .ci_p(ci_p12), .bk(bk[47:44]), .out_p(ci_p11), .co_p(out11));
    pdl_4x_delay_cell pdl_cell12(.in_p(out11), .ci_p(ci_p13), .bk(bk[51:48]), .out_p(ci_p12), .co_p(out12));
    pdl_4x_delay_cell pdl_cell13(.in_p(out12), .ci_p(ci_p14), .bk(bk[55:52]), .out_p(ci_p13), .co_p(out13));
    pdl_4x_delay_cell pdl_cell14(.in_p(out13), .ci_p(ci_p15), .bk(bk[59:56]), .out_p(ci_p14), .co_p(out14));
    pdl_4x_delay_cell pdl_cell15(.in_p(out14), .ci_p(feedback), .bk(bk[63:60]), .out_p(ci_p15), .co_p(feedback));

 endmodule
