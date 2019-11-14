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
// Filename       : itrx_aib_phy_atpg_bsr.v
// Description    : ATPG over-ride muxing for AIB IO Channel BSR chain
//
// ==========================================================================
//
//    $Rev:: 5621                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-02-24 20:01:40 -0500#$: Date of last commit
//
// ==========================================================================

/*

Instantiate one of these modules per AIB IO channel
for the purpose of over-riding the BSR/JTAG chain
with an ATPG chain.

The ATPG chain over-rides the BSR when the
atpg_ovrd_mode input signal is 1.
Otherwise (when atpg_ovrd_mode=0),
the JTAG chain is controlled by the JTAG TAP controller.

See:
  "Figure 8-12: AIB Boundary Scan Chain Used In ATPG Test"

From:
  "Common Heterogeneous Integration and
   Intellectual Property (IP) Reuse Strategies (CHIPS)
   AIB Architecture Overview V1.0"

The ATPG scan chain piggy-backs onto the boundary scan register (BSR) chain
within the AIB IO Channel.

The ATPG vs. JTAG mode use of the BSR chain is mutually exclusive.

Since the ATPG scan chains leverage the boundary scan infrastructure,
the flops along the chain are not reset-able.
A known pattern has to be shifted in to initialize the flops.

*/
//lint: This module contains combinatorial input to output paths.
//lint_checking IOCOMB off
module itrx_aib_phy_atpg_bsr(/*AUTOARG*/
   // Outputs
   atpg_bsr_scan_out, atpg_jtag_clkdr, atpg_jtag_scan_en,
   atpg_jtag_scanin,
   // Inputs
   atpg_bsr_ovrd_mode, atpg_bsr_scan_in, atpg_bsr_scan_shift_clk,
   atpg_bsr_scan_shift, jtag_clkdr, jtag_scan_en, jtag_scanin,
   jtag_scanout
   );

// Over-ride control signal from ATPG controller
input                    atpg_bsr_ovrd_mode;

// ATPG signals from codec
//
input                    atpg_bsr_scan_in;
input                    atpg_bsr_scan_shift_clk;
input                    atpg_bsr_scan_shift;
// ATPG signal to codec
output                   atpg_bsr_scan_out;

// BSR signals from JTAG TAP controller
//
input                    jtag_clkdr;
input                    jtag_scan_en;
input                    jtag_scanin;

// BSR signal from AIB IO Channel
input                    jtag_scanout;

// ATPG/BSR signals to AIB IO Channel
//
output                   atpg_jtag_clkdr;
output                   atpg_jtag_scan_en;
output                   atpg_jtag_scanin;

// Multiplex signals from ATPG code with signals from JTAG TAP. Select/over-ride by mode.
assign atpg_jtag_clkdr   = atpg_bsr_ovrd_mode ? atpg_bsr_scan_shift_clk : jtag_clkdr;
assign atpg_jtag_scan_en = atpg_bsr_ovrd_mode ? atpg_bsr_scan_shift     : jtag_scan_en;
assign atpg_jtag_scanin  = atpg_bsr_ovrd_mode ? atpg_bsr_scan_in        : jtag_scanin;

//lint: feed through scan out to ATPG port
//lint_checking FDTHRU off
assign atpg_bsr_scan_out = jtag_scanout;

endmodule
