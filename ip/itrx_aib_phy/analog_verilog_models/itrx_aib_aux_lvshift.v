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
// Filename       : itrx_aib_aux_lvshift.v
// Description    : Intrinsix logically equivalent structural version of
//                  aibcr3aux_lvshift (Intel AIB GitHub)
// ==========================================================================
//
//    $Rev:: 5823                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-06-27 09:46:15 -0400#$: Date of last commit
//
// ==========================================================================

module aibcr3aux_lvshift (
  input  in,             // INPUT SIGNAL
  output out             // OUTPUT SIGNAL
// Note: itrx_aib_phy_io_buf_ana uses `POWER_PINS
`ifdef NO_POWER_PINS
  );
  wire   vccl_aibcr3aux = 1'b1;
  wire   vcc_aibcr3aux  = 1'b1;
  wire   vssl_aibcr3aux = 1'b0;
`else
  ,
  input  vccl_aibcr3aux, // INPUT POWER
  input  vcc_aibcr3aux,  // OUTPUT POWER
  input  vssl_aibcr3aux);// GND (common)
`endif

//pmos  M0 (in_b, vccl_aibcr3aux, in); // Invert "in" (in --|>o-- in_b)
//nmos  M1 (in_b, vssl_aibcr3aux, in);
//rtran R0 (in_b, vssl_aibcr3aux); // Pull DOWN "in_b"

wire in_b = in  ? 1'b0 : vccl_aibcr3aux;

//nmos  M3 (h0, vssl_aibcr3aux, in_b);
//rtran R1 (h0, vcc_aibcr3aux); // Pull UP "h0"

wire  h0 = in_b ? 1'b0 : vcc_aibcr3aux;

//pmos M4 (h0_b, vcc_aibcr3aux,  h0);  // (h0 --|>o-- h0_b)
//nmos M5 (h0_b, vssl_aibcr3aux, h0);

wire h0_b = ~h0;

//pmos M6 (out, vcc_aibcr3aux,  h0_b); // (h0_b --|>o-- out)
//nmos M7 (out, vssl_aibcr3aux, h0_b);

wire out = ~h0_b;

endmodule
