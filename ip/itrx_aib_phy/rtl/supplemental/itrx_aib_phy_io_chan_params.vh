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
  32'd9,  32'd8,
  32'd7,  32'd6,  32'd5,  32'd4,  32'd3,  32'd2,  32'd1,  32'd0,  NULLB,  NULLB};

// Redundancy input connections from corresponding output of protecting uBump
//
parameter [NBMP-1:0] [31:0] REDN_ORDERO = {
  32'd87, 32'd86, 32'd85, 32'd84, 32'd83, 32'd82, 32'd81, 32'd80, 32'd79, 32'd78,
  32'd77, 32'd76,
  32'd75, 32'd74, 32'd73, 32'd72, 32'd71, 32'd70, 32'd69, 32'd68, 32'd67, 32'd66,
  32'd65, 32'd64, 32'd63, 32'd62, 32'd61, 32'd60, 32'd59, 32'd58, 32'd57, 32'd56,
  32'd55, 32'd54, 32'd53, 32'd52, 32'd51, 32'd50, 32'd49, 32'd48, 32'd47, 32'd46,
  32'd45, 32'd44,
  NULLB,  NULLB,  // SPARES (unused redundancy input)
  32'd45, 32'd44,
  32'd43, 32'd42, 32'd41, 32'd40, 32'd39, 32'd38, 32'd37, 32'd36, 32'd35, 32'd34,
  32'd33, 32'd32, 32'd31, 32'd30, 32'd29, 32'd28, 32'd27, 32'd26, 32'd25, 32'd24,
  32'd23, 32'd22, 32'd21, 32'd20, 32'd19, 32'd18, 32'd17, 32'd16, 32'd15, 32'd14,
  32'd13, 32'd12,
  32'd11, 32'd10, 32'd9,  32'd8,  32'd7,  32'd6,  32'd5,  32'd4,  32'd3,  32'd2};

// JTAG scan input for each uBump cell from the scan output of the cell ID below
//
parameter [NBMP-1:0] [31:0] JTAG_ORDER = {
  32'd88, 32'd87, 32'd86, 32'd85, 32'd84, 32'd83, 32'd82, 32'd81, 32'd80, 32'd79,
  32'd78, 32'd77,
  32'd76, 32'd75, 32'd74, 32'd73, 32'd72, 32'd71, 32'd70, 32'd69, 32'd68, 32'd67,
  32'd66, 32'd65, 32'd64, 32'd63, 32'd62, 32'd61, 32'd60, 32'd59, 32'd58, 32'd57,
  32'd56, 32'd55, 32'd54, 32'd53, 32'd52, 32'd51, 32'd50, 32'd49, 32'd48, 32'd47,
  32'd46, 32'd45,
  32'd44, 32'd43,
  32'd42, 32'd41,
  32'd40, 32'd39, 32'd38, 32'd37, 32'd36, 32'd35, 32'd34, 32'd33, 32'd32, 32'd31,
  32'd30, 32'd29, 32'd28, 32'd27, 32'd26, 32'd25, 32'd24, 32'd23, 32'd22, 32'd21,
  32'd20, 32'd19, 32'd18, 32'd17, 32'd16, 32'd15, 32'd14, 32'd13, 32'd12, 32'd11,
  32'd10, 32'd9,
  32'd8,  32'd7,  32'd6,  32'd5,  32'd4,  32'd3,  32'd2,  32'd1,  32'd0,  NULLB};

parameter [31:0] JTAG_FIRST = 32'd0;
parameter [31:0] JTAG_LAST  = 32'd89;

// Map logical redundancy control input port to each AIB IO cell
// e.g. cell #89 and #88 use control bit 44 of redun_engage[]
//
parameter [NBMP-1:0] [31:0] RED_ENGAGE_MAP = {
 32'd44, 32'd44, 32'd43, 32'd43, 32'd42, 32'd42, 32'd41, 32'd41, 32'd40, 32'd40,
 32'd39, 32'd39,
 32'd38, 32'd38, 32'd37, 32'd37, 32'd36, 32'd36, 32'd35, 32'd35, 32'd34, 32'd34,
 32'd33, 32'd33, 32'd32, 32'd32, 32'd31, 32'd31, 32'd30, 32'd30, 32'd29, 32'd29,
 32'd28, 32'd28, 32'd27, 32'd27, 32'd26, 32'd26, 32'd25, 32'd25, 32'd24, 32'd24,
 32'd23, 32'd23,
 32'd22, 32'd22,
 32'd21, 32'd21,
 32'd20, 32'd20, 32'd19, 32'd19, 32'd18, 32'd18, 32'd17, 32'd17, 32'd16, 32'd16,
 32'd15, 32'd15, 32'd14, 32'd14, 32'd13, 32'd13, 32'd12, 32'd12, 32'd11, 32'd11,
 32'd10, 32'd10, 32'd9,  32'd9,  32'd8,  32'd8,  32'd7,  32'd7,  32'd6,  32'd6,
 32'd5,  32'd5,
 32'd4,  32'd4,  32'd3,  32'd3,  32'd2,  32'd2,  32'd1,  32'd1,  32'd0,  32'd0};

parameter RX_DAT_CLK_RED_ENGAGE = 32'd39; // Redundancy engage ctrl bit for RX Clk

parameter [NBMP-1:0] TX_CLK_GROUP = {
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // SPARES
 { 2{1'b1}},  // TX RSTS
 {10{1'b1}},  // TX D
 {10{1'b1}},  // TX D
 {10{1'b1}},  // TX D
 { 2{1'b1}},  // TX CLK
 {10{1'b1}}}; // TX D

parameter [NBMP-1:0] RX_CLK_GROUP = {
 {10{1'b1}},  // RX D
 { 2{1'b1}},  // RX CLK
 {10{1'b1}},  // RX D
 {10{1'b1}},  // RX D
 {10{1'b1}},  // RX D
 { 2{1'b1}},  // RX RSTS
 { 2{1'b0}},  // SPARES
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}}}; // TX D

//------------------------------------------------------------------------------
// RXDAT_GROUP specfies for each uBump 89-0 the associated rx_data bit (even).
//
parameter [NBMP-1:0] [31:0] RX_DAT_GROUP = {
 32'd0,  32'd2,  32'd4,  32'd6,  32'd8,  32'd10, 32'd12, 32'd14, 32'd16, 32'd18, // RX D
 {2{NULLB}},                                                                     // RX CLK
 32'd20, 32'd22, 32'd24, 32'd26, 32'd28, 32'd30, 32'd32, 32'd34, 32'd36, 32'd38, // RX D
 32'd40, 32'd42, 32'd44, 32'd46, 32'd48, 32'd50, 32'd52, 32'd54, 32'd56, 32'd58, // RX D
 32'd60, 32'd62, 32'd64, 32'd66, 32'd68, 32'd70, 32'd72, 32'd74, 32'd76, 32'd78, // RX D
 {2{NULLB}},                                                                     // RX RSTS
 {2{NULLB}},                                                                     // SPARES
 {2{NULLB}},                                                                     // TX RSTS
 {10{NULLB}},                                                                    // TX D
 {10{NULLB}},                                                                    // TX D
 {10{NULLB}},                                                                    // TX D
 {2{NULLB}},                                                                     // TX CLK
 {10{NULLB}}};                                                                   // TX D
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// TXDAT_GROUP specfies for each uBump 89-0 the associated tx_data bit (even).
//
parameter [NBMP-1:0] [31:0] TX_DAT_GROUP = {
 {10{NULLB}},                                                                    // RX D
 {2{NULLB}},                                                                     // RX CLK
 {10{NULLB}},                                                                    // RX D
 {10{NULLB}},                                                                    // RX D
 {10{NULLB}},                                                                    // RX D
 {2{NULLB}},                                                                     // RX RSTS
 {2{NULLB}},                                                                     // SPARES
 {2{NULLB}},                                                                     // TX RSTS
 32'd78, 32'd76, 32'd74, 32'd72, 32'd70, 32'd68, 32'd66, 32'd64, 32'd62, 32'd60, // TX D
 32'd58, 32'd56, 32'd54, 32'd52, 32'd50, 32'd48, 32'd46, 32'd44, 32'd42, 32'd40, // TX D
 32'd38, 32'd36, 32'd34, 32'd32, 32'd30, 32'd28, 32'd26, 32'd24, 32'd22, 32'd20, // TX D
 {2{NULLB}},                                                                     // TX CLK
 32'd18, 32'd16, 32'd14, 32'd12, 32'd10, 32'd8,  32'd6,  32'd4,  32'd2,  32'd0}; // TX D
//------------------------------------------------------------------------------
