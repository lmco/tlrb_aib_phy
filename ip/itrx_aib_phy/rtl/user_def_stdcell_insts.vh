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
// Filename       : user_def_tech_insts.vh
// Description    : Macros for User Defined Technology Standard Cell Instantiations
//
// ==========================================================================
//
//    $Rev:: 5793                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-23 13:27:54 -0400#$: Date of last commit
//
// ==========================================================================

// USER DEFINED technology Specific Information
// For Standard Cell Instantiations
//
// Replace descriptions of cell names in "< cell_names >" with actual cell names below.
// Also change port names as necessary (e.g. "CP" might be "CK", etc.).

  `define LAT_CELL_T0  <Latch enabled high>  u_lat  (.D(din),.E  (clk),.CDN(rstn),.Q(qout));
  `define LATN_CELL_T0 <Latch enabled low>   u_latn (.D(din),.EN (clk),.CDN(rstn),.Q(qout));

  `define DFF_CELL_T0  <DFF rise clock>  u_dff  (.D(din),.CP (clk),.CDN(rstn),.Q(qout));
  `define DFF_CELL_T1  <DFF rise clock>  u_dff  (.D(din),.CP (clk),.CDN(rstn),.Q(qout));
  `define DFF_CELL_T2  <DFF rise clock>  u_dff  (.D(din),.CP (clk),.CDN(rstn),.Q(qout));
  `define DFF_CELL_T3  <DFF rise clock>  u_dff  (.D(din),.CP (clk),.CDN(rstn),.Q(qout));

  `define DFFN_CELL_T0 <DFF fall clock> u_dffn (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));
  `define DFFN_CELL_T1 <DFF fall clock> u_dffn (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));
  `define DFFN_CELL_T2 <DFF fall clock> u_dffn (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));
  `define DFFN_CELL_T3 <DFF fall clock> u_dffn (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));

  `define CMX_CELL_T0  <MUX 2 to 1>     u_mx2  (.I0(din0),.I1(din1),.S(msel),.Z(dout));
  `define CMX_CELL_T1  <MUX 2 to 1>     u_mx2  (.I0(din0),.I1(din1),.S(msel),.Z(dout));
  `define CMX_CELL_T2  <MUX 2 to 1>     u_mx2  (.I0(din0),.I1(din1),.S(msel),.Z(dout));
  `define CMX_CELL_T3  <MUX 2 to 1>     u_mx2  (.I0(din0),.I1(din1),.S(msel),.Z(dout));

  `define ICG_CELL_PORTS (.Q(clk_o),.TE(scan_mode),.CPN(clk),.E(ena));
  `define ICG_CELL_T0  <clock gate (high when disabled)>  u_icg  `ICG_CELL_PORTS
  `define ICG_CELL_T1  <clock gate (high when disabled)>  u_icg  `ICG_CELL_PORTS
  `define ICG_CELL_T2  <clock gate (high when disabled)>  u_icg  `ICG_CELL_PORTS
  `define ICG_CELL_T3  <clock gate (high when disabled)>  u_icg  `ICG_CELL_PORTS

  // NAND delay cell standard cell NAND gates
  //
  `define PDL_CELL <NAND 2 input>   nand0 (.A1(in_p), .A2(bk),   .ZN(co_p)); \
                   <NAND 2 input>   nand1 (.A1(a),    .A2(bk),   .ZN(b)); \
                   <NAND 2 input>   nand2 (.A1(in_p), .A2(b),    .ZN(a)); \
                   <NAND 2 input>   nand3 (.A1(a),    .A2(ci_p), .ZN(out_p));
