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
// Filename       : itrx_aib_phy_tech_defines.vh
// Description    : Macros for Technology Cell Instantiations
//
// ==========================================================================
//
//    $Rev:: 5810                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-06-24 16:29:21 -0400#$: Date of last commit
//
// ==========================================================================
//lint_checking SEPLIN off
//lint_checking NOTECH off


// Create a table of standard cell IP dig gate instantiations for each technology.
//
`ifdef TECH_IS_TSMC_16FFC

/*
  A few basic standard cells are directly instantiated in the AIB PHY RTL design.
  The table of `defines below needs to be filled out by the implementer considering the chosen technology,
  and corresponding standard cell names.

  The list of standard cells required to be added to this table include:

   1) LATCH (LAT,  enabled high)
   2) LATCH (LATN, enabled low)
   3) DFF   (DFF,  rising  edge clocked)
   4) DFF   (DFFN, falling edge clocked)
   5) MUX   (CMX, clock MUX, 2 to 1)
   6) ICG   (ICG, Integrated Clock Gate, enabled high)

  The "<standard cell..>" fields below are names of the standard cells to be instantiated, and need to be
  filled-in together with the corresponding port names connected.

  The use of different sub-Types (e.g. "_T0") is optional and intended to provide flexibility in the design
  to control options like drive strength and Vt type per instance. ALL of the types
  (T0-T3) can be set to the SAME `define, for example.

  `define LAT_CELL_T0  <standard cell Latch enabled high>  u_lat  (.D(din),.E  (clk),.CDN(rstn),.Q(qout));
  `define LATN_CELL_T0 <standard cell Latch enabled low>   u_latn (.D(din),.EN (clk),.CDN(rstn),.Q(qout));

  `define DFF_CELL_T0  <standard cell DFF posedge> u_dff  (.D(din),.CP (clk),.CDN(rstn),.Q(qout));
  `define DFF_CELL_T1  <standard cell DFF posedge> u_dff  (.D(din),.CP (clk),.CDN(rstn),.Q(qout));
  `define DFF_CELL_T2  <standard cell DFF posedge> u_dff  (.D(din),.CP (clk),.CDN(rstn),.Q(qout));
  `define DFF_CELL_T3  <standard cell DFF posedge> u_dff  (.D(din),.CP (clk),.CDN(rstn),.Q(qout));

  `define DFFN_CELL_T0 <standard cell DFF negedge> u_dffn (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));
  `define DFFN_CELL_T1 <standard cell DFF negedge> u_dffn (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));
  `define DFFN_CELL_T2 <standard cell DFF negedge> u_dffn (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));
  `define DFFN_CELL_T3 <standard cell DFF negedge> u_dffn (.D(din),.CPN(clk),.CDN(rstn),.Q(qout));

  `define CMX_CELL_T0 <standard cell clock MUX 2to1> u_mx2 (.I0(din0),.I1(din1),.S(msel),.Z(dout));
  `define CMX_CELL_T1 <standard cell clock MUX 2to1> u_mx2 (.I0(din0),.I1(din1),.S(msel),.Z(dout));
  `define CMX_CELL_T2 <standard cell clock MUX 2to1> u_mx2 (.I0(din0),.I1(din1),.S(msel),.Z(dout));
  `define CMX_CELL_T3 <standard cell clock MUX 2to1> u_mx2 (.I0(din0),.I1(din1),.S(msel),.Z(dout));

  `define ICG_CELL_PORTS (.Q(clk_o),.TE(scan_mode),.CPN(clk),.E(ena));
  `define ICG_CELL_T0  <standard cell clock gate output high when disabled> u_icg  `ICG_CELL_PORTS
  `define ICG_CELL_T1  <standard cell clock gate output high when disabled> u_icg  `ICG_CELL_PORTS
  `define ICG_CELL_T2  <standard cell clock gate output high when disabled> u_icg  `ICG_CELL_PORTS
  `define ICG_CELL_T3  <standard cell clock gate output high when disabled> u_icg  `ICG_CELL_PORTS
*/

  `include "itrx_tsmc_16ffc_stdcell_insts.vh" // REQUIRES TSMC Library Cells for simulation

`elsif TECH_IS_USER_DEF // This `define selects "user" example table of standard cell lib instantiations.

  `include "user_def_stdcell_insts.vh" // This is an example table to be filled in by "user".

`else
// Default case where technology is not yet specified.
// Gate instantations revert back to Synthesizable code.

//lint: REGs only used if DFF or LATCH or ICG
//lint_checking URAREG off
  reg qout;
  reg q;
//lint_checking URAREG on

`define LAT_BEH  \
  always @ (clk or din or rstn) begin \
    if (!rstn) begin \
      qout <= 1'h0; \
    end else begin \
      if (clk) begin \
        qout <= din; \
      end \
    end \
  end

`define LATN_BEH  \
  always @ (clk or din or rstn) begin \
    if (!rstn) begin \
      qout <= 1'h0; \
    end else begin \
      if (!clk) begin \
        qout <= din; \
      end \
    end \
  end

  `define LAT_CELL_T0  `LAT_BEH
  `define LATN_CELL_T0 `LATN_BEH

  `define DFF_BEH always @(posedge clk or negedge rstn) begin \
                     if (!rstn) begin \
                       qout <= 1'b0; \
                     end else begin \
                       qout <= din; \
                     end \
                   end

  `define DFFN_BEH always @(negedge clk or negedge rstn) begin \
                     if (!rstn) begin \
                       qout <= 1'b0; \
                     end else begin \
                       qout <= din; \
                     end \
                   end

  `define DFF_CELL_T0 `DFF_BEH
  `define DFF_CELL_T1 `DFF_BEH
  `define DFF_CELL_T2 `DFF_BEH
  `define DFF_CELL_T3 `DFF_BEH

  `define DFFN_CELL_T0 `DFFN_BEH
  `define DFFN_CELL_T1 `DFFN_BEH
  `define DFFN_CELL_T2 `DFFN_BEH
  `define DFFN_CELL_T3 `DFFN_BEH

  `define CMX_CELL_T0 assign dout = msel ? din1 : din0;
  `define CMX_CELL_T1 assign dout = msel ? din1 : din0;
  `define CMX_CELL_T2 assign dout = msel ? din1 : din0;
  `define CMX_CELL_T3 assign dout = msel ? din1 : din0;

  `define ICG_BEH always @(*) begin \
                    if (clk) begin \
                      q <= ena | scan_mode; \
                    end \
                  end \
                  assign clk_o = clk | (~q);

  `define ICG_CELL_T0 `ICG_BEH
  `define ICG_CELL_T1 `ICG_BEH
  `define ICG_CELL_T2 `ICG_BEH
  `define ICG_CELL_T3 `ICG_BEH

//`define PDL_CELL assign  co_p = ~(in_p & bk); \
//                 assign     b = ~(a    & bk); \
//                 assign     a = ~(in_p &  b); \
//                 assign out_p = ~(a    & ci_p);

  `define PDL_CELL PDL_NAND nand0 (.A1(in_p), .A2(bk), .ZN(co_p)); \
                   PDL_NAND nand1 (.A1(a), .A2(bk), .ZN(b)); \
                   PDL_NAND nand2 (.A1(in_p), .A2(b), .ZN(a)); \
                   PDL_NAND nand3 (.A1(a), .A2(ci_p), .ZN(out_p));


`endif
//lint_checking NOTECH on
