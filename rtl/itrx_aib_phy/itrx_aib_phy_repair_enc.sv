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
// ==========================================================================
// Original Author: Intrinsix Corporation
// Filename       : itrx_aib_phy_repair_enc.sv
// Description    : Encode Intel AIB Spec repair info format to "redn_enage" 
//                  shift signals.
//
// ==========================================================================
//
//    $Rev:: 5217                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2018-10-10 11:23:30 -0400#$: Date of last commit
//
// ==========================================================================

module itrx_aib_phy_repair_enc (/*AUTOARG*/
   // Outputs
   redun_engage,
   // Inputs
   repair_info_nvm, repair_info_vld
   );

parameter MAXCH = 32'd1;

//lint: 1 pin bus OK. Single channel case.
//lint_checking ONPNSG off
input [MAXCH-1:0] [10:0] repair_info_nvm;
input [MAXCH-1:0]        repair_info_vld;
//lint_checking ONPNSG on

output reg [44:0] redun_engage;

/*
CHIPS AIB Architecture Specification (v1_0)

Memory blocks should include redundancy information
for each of 24 channels, starting from channel 0. Each row includes up to 11 bits
(2048 addresses for up to 900 IOs per AIB channel) to indicate the location of the
faulty connection within the respective channel. Address[0] is for the first two bits
which are adjacent to the spare bits. The MSB (bit[10]) indicates direction of
redundancy repair (logic 1 for TX direction, logic 0 for RX direction) as spare bits
are located in the middle of the IO chain.
*/

always_comb begin
  if (!repair_info_vld[0]) begin // NO Repair
    redun_engage = 45'd0;
  end else if (repair_info_nvm[0][10]) begin // TX
   case (repair_info_nvm[0][9:0])
    10'd0  : redun_engage = 45'h0000_0060_0000;

    10'd1  : redun_engage = 45'h0000_0070_0000;
    10'd2  : redun_engage = 45'h0000_0078_0000;
    10'd3  : redun_engage = 45'h0000_007C_0000;
    10'd4  : redun_engage = 45'h0000_007E_0000;

    10'd5  : redun_engage = 45'h0000_007F_0000;
    10'd6  : redun_engage = 45'h0000_007F_8000;
    10'd7  : redun_engage = 45'h0000_007F_C000;
    10'd8  : redun_engage = 45'h0000_007F_E000;

    10'd9  : redun_engage = 45'h0000_007F_F000;
    10'd10 : redun_engage = 45'h0000_007F_F800;
    10'd11 : redun_engage = 45'h0000_007F_FC00;
    10'd12 : redun_engage = 45'h0000_007F_FE00;

    10'd13 : redun_engage = 45'h0000_007F_FF00;
    10'd14 : redun_engage = 45'h0000_007F_FF80;
    10'd15 : redun_engage = 45'h0000_007F_FFC0;
    10'd16 : redun_engage = 45'h0000_007F_FFE0;

    10'd17 : redun_engage = 45'h0000_007F_FFF0;
    10'd18 : redun_engage = 45'h0000_007F_FFF8;
    10'd19 : redun_engage = 45'h0000_007F_FFFC;
    10'd20 : redun_engage = 45'h0000_007F_FFFE;

    10'd21 : redun_engage = 45'h0000_007F_FFFF;

    default : redun_engage = 45'd0;
   endcase
  end else begin                             // RX
   case (repair_info_nvm[0][9:0])
    10'd0  : redun_engage = 45'h0000_0080_0000; 

    10'd1  : redun_engage = 45'h0000_0180_0000; 
    10'd2  : redun_engage = 45'h0000_0380_0000; 
    10'd3  : redun_engage = 45'h0000_0780_0000; 
    10'd4  : redun_engage = 45'h0000_0F80_0000; 

    10'd5  : redun_engage = 45'h0000_1F80_0000; 
    10'd6  : redun_engage = 45'h0000_3F80_0000; 
    10'd7  : redun_engage = 45'h0000_7F80_0000; 
    10'd8  : redun_engage = 45'h0000_FF80_0000; 

    10'd9  : redun_engage = 45'h0001_FF80_0000; 
    10'd10 : redun_engage = 45'h0003_FF80_0000; 
    10'd11 : redun_engage = 45'h0007_FF80_0000; 
    10'd12 : redun_engage = 45'h000F_FF80_0000; 

    10'd13 : redun_engage = 45'h001F_FF80_0000; 
    10'd14 : redun_engage = 45'h003F_FF80_0000; 
    10'd15 : redun_engage = 45'h007F_FF80_0000; 
    10'd16 : redun_engage = 45'h00FF_FF80_0000; 

    10'd17 : redun_engage = 45'h01FF_FF80_0000; 
    10'd18 : redun_engage = 45'h03FF_FF80_0000; 
    10'd19 : redun_engage = 45'h07FF_FF80_0000; 
    10'd20 : redun_engage = 45'h0FFF_FF80_0000; 

    10'd21 : redun_engage = 45'h1FFF_FF80_0000; 
   
    default : redun_engage = 45'd0;
   endcase
  end
end

endmodule
