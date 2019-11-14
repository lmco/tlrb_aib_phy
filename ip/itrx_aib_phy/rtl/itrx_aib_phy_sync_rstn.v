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
// Filename       : itrx_aib_phy_sync_rstn.v
// Description    : AIB reset synchronizer
//
// ==========================================================================
//
//    $Rev:: 5038                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-05-04 12:42:03 -0400#$: Date of last commit
//
// ==========================================================================
// Generate a reset that negates (=1) synchronously relative to the input clock
// from an input reset that is otherwise not synchronous to the input clock.
// Bypass sync DFFs in DFT scan mode.

//lint: combinatorial path to output is expected for DFT mode.
//lint_checking IOCOMB off
module itrx_aib_phy_sync_rstn #( parameter NDFFS = 32'd2 ) (
    input           scan_mode, // (I) select feed thru of rst_n to output (DFT)
    input           rst_n,  // (I) reset, active LO
    input           clk,    // (I) clock

    output wire     dout    // (O) sync'd reset signal out
    );
//lint_checking IOCOMB on

reg  [NDFFS-1:0] sync_rstn;

always @(posedge clk or negedge rst_n)
  begin
    if (!rst_n)
      begin
        sync_rstn <= {NDFFS{1'b0}};
      end
    else
      begin
//lint: Inferred flip-flop 'sync_rstn[0]' has a constant data input.
//lint_checking FFCSTD off
        sync_rstn <= {sync_rstn[NDFFS-2:0], 1'b1};
//lint_checking FFCSTD on
      end
    end

    assign dout = scan_mode ? rst_n : sync_rstn[NDFFS-1];

endmodule
