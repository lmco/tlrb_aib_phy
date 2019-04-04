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
// FIX ME Provisional Delay Line NAND gates
// Added some code for simulation gate delays
//
`timescale 1ns/1ps
module pdl_cell(in_p, bk, co_p, ci_p, out_p);
  input in_p, bk, ci_p;
  output out_p, co_p;
  
  wire a,b;

`ifdef SYNTHESIS

  ND2D0P75BWP16P90 NAND1(.A1(in_p), .A2(bk), .ZN(co_p));
  ND2D0P75BWP16P90  NAND2(.A1(a), .A2(bk), .ZN(b));
  ND2D0P75BWP16P90  NAND3(.A1(in_p), .A2(b), .ZN(a));
  ND2D0P75BWP16P90  NAND4(.A1(a), .A2(ci_p), .ZN(out_p));

`else // vvv RLB - add same gates with simulation delays vvv

  nand #(0.025) NAND1(co_p, in_p, bk);
  nand #(0.025) NAND2(b, a, bk);
  nand #(0.025) NAND3(a, in_p, b);
  nand #(0.025) NAND4(out_p, a, ci_p);

`endif // ^^^^

endmodule

module pdl(in_p, bk, out_p);
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
wire  ci_p16, out15;
wire  ci_p17, out16;
wire  ci_p18, out17;
wire  ci_p19, out18;
wire  ci_p20, out19;
wire  ci_p21, out20;
wire  ci_p22, out21;
wire  ci_p23, out22;
wire  ci_p24, out23;
wire  ci_p25, out24;
wire  ci_p26, out25;
wire  ci_p27, out26;
wire  ci_p28, out27;
wire  ci_p29, out28;
wire  ci_p30, out29;
wire  ci_p31, out30;
wire  ci_p32, out31;
wire  ci_p33, out32;
wire  ci_p34, out33;
wire  ci_p35, out34;
wire  ci_p36, out35;
wire  ci_p37, out36;
wire  ci_p38, out37;
wire  ci_p39, out38;
wire  ci_p40, out39;
wire  ci_p41, out40;
wire  ci_p42, out41;
wire  ci_p43, out42;
wire  ci_p44, out43;
wire  ci_p45, out44;
wire  ci_p46, out45;
wire  ci_p47, out46;
wire  ci_p48, out47;
wire  ci_p49, out48;
wire  ci_p50, out49;
wire  ci_p51, out50;
wire  ci_p52, out51;
wire  ci_p53, out52;
wire  ci_p54, out53;
wire  ci_p55, out54;
wire  ci_p56, out55;
wire  ci_p57, out56;
wire  ci_p58, out57;
wire  ci_p59, out58;
wire  ci_p60, out59;
wire  ci_p61, out60;
wire  ci_p62, out61;
wire  ci_p63, out62;

    pdl_cell pdl_cell0(.in_p(in_p), .ci_p(ci_p1), .bk(bk[0]), .out_p(out_p), .co_p(out0));
    pdl_cell pdl_cell1(.in_p(out0), .ci_p(ci_p2), .bk(bk[1]), .out_p(ci_p1), .co_p(out1));
    pdl_cell pdl_cell2(.in_p(out1), .ci_p(ci_p3), .bk(bk[2]), .out_p(ci_p2), .co_p(out2));
    pdl_cell pdl_cell3(.in_p(out2), .ci_p(ci_p4), .bk(bk[3]), .out_p(ci_p3), .co_p(out3));
    pdl_cell pdl_cell4(.in_p(out3), .ci_p(ci_p5), .bk(bk[4]), .out_p(ci_p4), .co_p(out4));
    pdl_cell pdl_cell5(.in_p(out4), .ci_p(ci_p6), .bk(bk[5]), .out_p(ci_p5), .co_p(out5));
    pdl_cell pdl_cell6(.in_p(out5), .ci_p(ci_p7), .bk(bk[6]), .out_p(ci_p6), .co_p(out6));
    pdl_cell pdl_cell7(.in_p(out6), .ci_p(ci_p8), .bk(bk[7]), .out_p(ci_p7), .co_p(out7));
    pdl_cell pdl_cell8(.in_p(out7), .ci_p(ci_p9), .bk(bk[8]), .out_p(ci_p8), .co_p(out8));
    pdl_cell pdl_cell9(.in_p(out8), .ci_p(ci_p10), .bk(bk[9]), .out_p(ci_p9), .co_p(out9));
    pdl_cell pdl_cell10(.in_p(out9), .ci_p(ci_p11), .bk(bk[10]), .out_p(ci_p10), .co_p(out10));
    pdl_cell pdl_cell11(.in_p(out10), .ci_p(ci_p12), .bk(bk[11]), .out_p(ci_p11), .co_p(out11));
    pdl_cell pdl_cell12(.in_p(out11), .ci_p(ci_p13), .bk(bk[12]), .out_p(ci_p12), .co_p(out12));
    pdl_cell pdl_cell13(.in_p(out12), .ci_p(ci_p14), .bk(bk[13]), .out_p(ci_p13), .co_p(out13));
    pdl_cell pdl_cell14(.in_p(out13), .ci_p(ci_p15), .bk(bk[14]), .out_p(ci_p14), .co_p(out14));
    pdl_cell pdl_cell15(.in_p(out14), .ci_p(ci_p16), .bk(bk[15]), .out_p(ci_p15), .co_p(out15));
    pdl_cell pdl_cell16(.in_p(out15), .ci_p(ci_p17), .bk(bk[16]), .out_p(ci_p16), .co_p(out16));
    pdl_cell pdl_cell17(.in_p(out16), .ci_p(ci_p18), .bk(bk[17]), .out_p(ci_p17), .co_p(out17));
    pdl_cell pdl_cell18(.in_p(out17), .ci_p(ci_p19), .bk(bk[18]), .out_p(ci_p18), .co_p(out18));
    pdl_cell pdl_cell19(.in_p(out18), .ci_p(ci_p20), .bk(bk[19]), .out_p(ci_p19), .co_p(out19));
    pdl_cell pdl_cell20(.in_p(out19), .ci_p(ci_p21), .bk(bk[20]), .out_p(ci_p20), .co_p(out20));
    pdl_cell pdl_cell21(.in_p(out20), .ci_p(ci_p22), .bk(bk[21]), .out_p(ci_p21), .co_p(out21));
    pdl_cell pdl_cell22(.in_p(out21), .ci_p(ci_p23), .bk(bk[22]), .out_p(ci_p22), .co_p(out22));
    pdl_cell pdl_cell23(.in_p(out22), .ci_p(ci_p24), .bk(bk[23]), .out_p(ci_p23), .co_p(out23));
    pdl_cell pdl_cell24(.in_p(out23), .ci_p(ci_p25), .bk(bk[24]), .out_p(ci_p24), .co_p(out24));
    pdl_cell pdl_cell25(.in_p(out24), .ci_p(ci_p26), .bk(bk[25]), .out_p(ci_p25), .co_p(out25));
    pdl_cell pdl_cell26(.in_p(out25), .ci_p(ci_p27), .bk(bk[26]), .out_p(ci_p26), .co_p(out26));
    pdl_cell pdl_cell27(.in_p(out26), .ci_p(ci_p28), .bk(bk[27]), .out_p(ci_p27), .co_p(out27));
    pdl_cell pdl_cell28(.in_p(out27), .ci_p(ci_p29), .bk(bk[28]), .out_p(ci_p28), .co_p(out28));
    pdl_cell pdl_cell29(.in_p(out28), .ci_p(ci_p30), .bk(bk[29]), .out_p(ci_p29), .co_p(out29));
    pdl_cell pdl_cell30(.in_p(out29), .ci_p(ci_p31), .bk(bk[30]), .out_p(ci_p30), .co_p(out30));
    pdl_cell pdl_cell31(.in_p(out30), .ci_p(ci_p32), .bk(bk[31]), .out_p(ci_p31), .co_p(out31));
    pdl_cell pdl_cell32(.in_p(out31), .ci_p(ci_p33), .bk(bk[32]), .out_p(ci_p32), .co_p(out32));
    pdl_cell pdl_cell33(.in_p(out32), .ci_p(ci_p34), .bk(bk[33]), .out_p(ci_p33), .co_p(out33));
    pdl_cell pdl_cell34(.in_p(out33), .ci_p(ci_p35), .bk(bk[34]), .out_p(ci_p34), .co_p(out34));
    pdl_cell pdl_cell35(.in_p(out34), .ci_p(ci_p36), .bk(bk[35]), .out_p(ci_p35), .co_p(out35));
    pdl_cell pdl_cell36(.in_p(out35), .ci_p(ci_p37), .bk(bk[36]), .out_p(ci_p36), .co_p(out36));
    pdl_cell pdl_cell37(.in_p(out36), .ci_p(ci_p38), .bk(bk[37]), .out_p(ci_p37), .co_p(out37));
    pdl_cell pdl_cell38(.in_p(out37), .ci_p(ci_p39), .bk(bk[38]), .out_p(ci_p38), .co_p(out38));
    pdl_cell pdl_cell39(.in_p(out38), .ci_p(ci_p40), .bk(bk[39]), .out_p(ci_p39), .co_p(out39));
    pdl_cell pdl_cell40(.in_p(out39), .ci_p(ci_p41), .bk(bk[40]), .out_p(ci_p40), .co_p(out40));
    pdl_cell pdl_cell41(.in_p(out40), .ci_p(ci_p42), .bk(bk[41]), .out_p(ci_p41), .co_p(out41));
    pdl_cell pdl_cell42(.in_p(out41), .ci_p(ci_p43), .bk(bk[42]), .out_p(ci_p42), .co_p(out42));
    pdl_cell pdl_cell43(.in_p(out42), .ci_p(ci_p44), .bk(bk[43]), .out_p(ci_p43), .co_p(out43));
    pdl_cell pdl_cell44(.in_p(out43), .ci_p(ci_p45), .bk(bk[44]), .out_p(ci_p44), .co_p(out44));
    pdl_cell pdl_cell45(.in_p(out44), .ci_p(ci_p46), .bk(bk[45]), .out_p(ci_p45), .co_p(out45));
    pdl_cell pdl_cell46(.in_p(out45), .ci_p(ci_p47), .bk(bk[46]), .out_p(ci_p46), .co_p(out46));
    pdl_cell pdl_cell47(.in_p(out46), .ci_p(ci_p48), .bk(bk[47]), .out_p(ci_p47), .co_p(out47));
    pdl_cell pdl_cell48(.in_p(out47), .ci_p(ci_p49), .bk(bk[48]), .out_p(ci_p48), .co_p(out48));
    pdl_cell pdl_cell49(.in_p(out48), .ci_p(ci_p50), .bk(bk[49]), .out_p(ci_p49), .co_p(out49));
    pdl_cell pdl_cell50(.in_p(out49), .ci_p(ci_p51), .bk(bk[50]), .out_p(ci_p50), .co_p(out50));
    pdl_cell pdl_cell51(.in_p(out50), .ci_p(ci_p52), .bk(bk[51]), .out_p(ci_p51), .co_p(out51));
    pdl_cell pdl_cell52(.in_p(out51), .ci_p(ci_p53), .bk(bk[52]), .out_p(ci_p52), .co_p(out52));
    pdl_cell pdl_cell53(.in_p(out52), .ci_p(ci_p54), .bk(bk[53]), .out_p(ci_p53), .co_p(out53));
    pdl_cell pdl_cell54(.in_p(out53), .ci_p(ci_p55), .bk(bk[54]), .out_p(ci_p54), .co_p(out54));
    pdl_cell pdl_cell55(.in_p(out54), .ci_p(ci_p56), .bk(bk[55]), .out_p(ci_p55), .co_p(out55));
    pdl_cell pdl_cell56(.in_p(out55), .ci_p(ci_p57), .bk(bk[56]), .out_p(ci_p56), .co_p(out56));
    pdl_cell pdl_cell57(.in_p(out56), .ci_p(ci_p58), .bk(bk[57]), .out_p(ci_p57), .co_p(out57));
    pdl_cell pdl_cell58(.in_p(out57), .ci_p(ci_p59), .bk(bk[58]), .out_p(ci_p58), .co_p(out58));
    pdl_cell pdl_cell59(.in_p(out58), .ci_p(ci_p60), .bk(bk[59]), .out_p(ci_p59), .co_p(out59));
    pdl_cell pdl_cell60(.in_p(out59), .ci_p(ci_p61), .bk(bk[60]), .out_p(ci_p60), .co_p(out60));
    pdl_cell pdl_cell61(.in_p(out60), .ci_p(ci_p62), .bk(bk[61]), .out_p(ci_p61), .co_p(out61));
    pdl_cell pdl_cell62(.in_p(out61), .ci_p(ci_p63), .bk(bk[62]), .out_p(ci_p62), .co_p(out62));
    pdl_cell pdl_cell63(.in_p(out62), .ci_p(1'b1), .bk(bk[63]), .out_p(ci_p63), .co_p());

 endmodule
