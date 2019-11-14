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
// Filename       : itrx_aib_phy_bit_sync.v
// Description    : Single bit synchronizer
//                   o Async active low reset
//                   o NUM_FLOPS DFFs
//
// ==========================================================================
//
//    $Rev:: 5217                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-10-10 11:23:30 -0400#$: Date of last commit
//
// ==========================================================================

module itrx_aib_phy_bit_sync #( parameter NUM_FLOPS = 32'd2) (      // default to 2-flop synchronizer

    input                   rst_n,  // (I) reset, active LO
    input                   clk,    // (I) clock
    input                   din,    // (I) data signal in

    output wire             dout    // (O) sync'd data signal out
    );

    reg  [NUM_FLOPS-1:0] sync_in;

    always @(posedge clk or negedge rst_n)
      begin
        if (!rst_n)
          begin
            sync_in <= {NUM_FLOPS{1'b0}};
          end
        else
          begin
            sync_in <= {sync_in[NUM_FLOPS-2:0], din};
          end
      end

    assign dout = sync_in[NUM_FLOPS-1];

endmodule
