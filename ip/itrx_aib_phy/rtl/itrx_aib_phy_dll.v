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
// Filename       : itrx_aib_phy_dll.v
// Description    : AIB DLL
//
// ==========================================================================
//
//    $Rev:: 5429                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-12-11 16:46:02 -0500#$: Date of last commit
//
// ==========================================================================

//`timescale 1ps/1ps
module itrx_aib_phy_dll (/*AUTOARG*/
   // Outputs
   dll_lock, dll_outclk,
   // Inputs
   dll_enable, dll_fbclk, dll_refclk, dll_lock_req, dll_adjust
   );

parameter MANUAL_MODE = 1'b1; // Only manual mode is implemented for now.
parameter DLYW = 32'd10; // Adjust bit width

input            dll_enable;
input            dll_fbclk;
input            dll_refclk;
input            dll_lock_req;
input [DLYW-1:0] dll_adjust;

output       dll_lock;
output       dll_outclk;

wire unused_ok;

genvar ii;

generate
  if (MANUAL_MODE) begin :gc_mode

//  Programmable Delay Line

  wire [63:0] bk;

  for (ii=0; ii < 63; ii = ii + 1) begin : gl_bk
    assign bk[ii] = (dll_adjust > ii[DLYW-1:0]);
  end

  assign bk[63] = 1'b0;

   pdl u_pdl (// Outputs
              .out_p                    (dll_outclk),
              // Inputs
              .in_p                     (dll_refclk),
              .bk                       (bk[63:0]));
//------------------------------------------------------------------------------




  // Transport delay of approximated 500ps for SDR strobe/sample clock

/*
  always @(dll_refclk) begin
    dll_outclk <= #500 dll_refclk;
  end
*/

  assign dll_lock = 1'b0;

  assign unused_ok = &{dll_enable, dll_fbclk, dll_lock_req};

end
endgenerate

endmodule
