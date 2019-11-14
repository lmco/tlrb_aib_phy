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
// Filename       : itrx_aib_phy_redn.v
// Description    : Redundancy 3 to 1 MUX for each AIB IO cell
//                  (to support JTAG for spare IOs)
//
// ==========================================================================
//
//    $Rev:: 5041                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-05-07 09:46:41 -0400#$: Date of last commit
//
// ==========================================================================

//lint: combinatorial path to output OK (MUX)
//lint_checking IOCOMB off
module itrx_aib_phy_redn_3to1_mux (/*AUTOARG*/
   // Outputs
   mux_do,
   // Inputs
   spare_mode, jtag_mode, redn_engage, jtag_di, nrml_di, redn_di
   );
//lint_checking IOCOMB on

parameter integer DWID = 1;

input             spare_mode;
input             jtag_mode;
input             redn_engage;

//lint: 1 pin bus is OK/expected
//lint_checking ONPNSG off
input  [DWID-1:0] jtag_di;      // from BSR
input  [DWID-1:0] nrml_di;      // from Adapter
input  [DWID-1:0] redn_di;      // from other AIB IO

output [DWID-1:0] mux_do;       // to AIB IO
//lint_checking ONPNSG on

assign mux_do =
  spare_mode ? (jtag_mode ? jtag_di
                          : (redn_engage ? redn_di : nrml_di))
             : (redn_engage ? redn_di : jtag_di);
endmodule
