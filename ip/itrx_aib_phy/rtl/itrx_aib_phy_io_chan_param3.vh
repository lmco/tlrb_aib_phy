// Copyright 2019 © Lockheed Martin Corporation
// MAP AIB<ID> ID numbers to the uBump functional name as in:
//  Advanced Interface Bus (AIB) Specification 2019.4.18 Revision 1.1
//  Table 36. Bump-Table Exemplar (AIB Base, Balanced)
//
parameter NULLB       = 32'd1023; // NULL ID flag

parameter SPARE_POS   = 32'd44; // Position of 1st spare

parameter RX_DAT_CLK_POS     = 32'd59; // RX synchronous Data Clock uBump position
parameter TX_DAT_CLK_POS     = 32'd30; // Position of TXCLK

parameter RX_RST_POS  = 32'd47;
parameter TX_RST_POS  = 32'd42;

parameter RX_ARST_POS = 32'd46;
parameter TX_ARST_POS = 32'd43;

// Redundancy input connections from corresponding input to protected uBump
//  Bump pair above in table for RX
//  Bump pair below in table for TX
//
parameter [NBMP-1:0] [31:0] REDN_ORDERI = {
  NULLB,  NULLB,  32'd89, 32'd88, 32'd87, 32'd86, 32'd85, 32'd84, 32'd83, 32'd82,  // RX D
  32'd81, 32'd80, 32'd79, 32'd78, 32'd77, 32'd76, 32'd75, 32'd74, 32'd73, 32'd72,  // RX D
  32'd71, 32'd70, 32'd69, 32'd68, 32'd67, 32'd66, 32'd65, 32'd64, 32'd63, 32'd62,  // RX D
  32'd61, 32'd60,                                                                  // RX CLK
  32'd59, 32'd58, 32'd57, 32'd56, 32'd55, 32'd54, 32'd53, 32'd52, 32'd51, 32'd50,  // RX D
  32'd49, 32'd48,                                                                  // RX RSTS
  32'd43, 32'd42,                                                                  // SPARES
  32'd41, 32'd40,                                                                  // TX RSTS
  32'd39, 32'd38, 32'd37, 32'd36, 32'd35, 32'd34, 32'd33, 32'd32, 32'd31, 32'd30,  // TX D
  32'd29, 32'd28,                                                                  // TX CLK
  32'd27, 32'd26, 32'd25, 32'd24, 32'd23, 32'd22, 32'd21, 32'd20, 32'd19, 32'd18,  // TX D
  32'd17, 32'd16, 32'd15, 32'd14, 32'd13, 32'd12, 32'd11, 32'd10, 32'd9,  32'd8,   // TX D
  32'd7,  32'd6,  32'd5,  32'd4,  32'd3,  32'd2,  32'd1,  32'd0,  NULLB,  NULLB};  // TX D

// Redundancy input connections from corresponding output of protecting uBump
//  Bump pair below in table for RX
//  Bump pair above in table for TX
//
parameter [NBMP-1:0] [31:0] REDN_ORDERO = {
  32'd87, 32'd86, 32'd85, 32'd84, 32'd83, 32'd82, 32'd81, 32'd80, 32'd79, 32'd78,  // RX D
  32'd77, 32'd76, 32'd75, 32'd74, 32'd73, 32'd72, 32'd71, 32'd70, 32'd69, 32'd68,  // RX D
  32'd67, 32'd66, 32'd65, 32'd64, 32'd63, 32'd62, 32'd61, 32'd60, 32'd59, 32'd58,  // RX D
  32'd57, 32'd56,                                                                  // RX CLK
  32'd55, 32'd54, 32'd53, 32'd52, 32'd51, 32'd50, 32'd49, 32'd48, 32'd47, 32'd46,  // RX D
  32'd45, 32'd44,                                                                  // RX RSTS
  NULLB,  NULLB,                                                                   // SPARES
  32'd45, 32'd44,                                                                  // TX RSTS
  32'd43, 32'd42, 32'd41, 32'd40, 32'd39, 32'd38, 32'd37, 32'd36, 32'd35, 32'd34,  // TX D
  32'd33, 32'd32,                                                                  // TX CLK
  32'd31, 32'd30, 32'd29, 32'd28, 32'd27, 32'd26, 32'd25, 32'd24, 32'd23, 32'd22,  // TX D
  32'd21, 32'd20, 32'd19, 32'd18, 32'd17, 32'd16, 32'd15, 32'd14, 32'd13, 32'd12,  // TX D
  32'd11, 32'd10, 32'd9,  32'd8,  32'd7,  32'd6,  32'd5,  32'd4,  32'd3,  32'd2};  // TX D

// JTAG scan input for each uBump cell from the scan output of the cell ID below
//
parameter [NBMP-1:0] [31:0] JTAG_ORDER = {
  32'd88, 32'd87, 32'd86, 32'd85, 32'd84, 32'd83, 32'd82, 32'd81, 32'd80, 32'd79,
  32'd78, 32'd77, 32'd76, 32'd75, 32'd74, 32'd73, 32'd72, 32'd71, 32'd70, 32'd69,
  32'd68, 32'd67, 32'd66, 32'd65, 32'd64, 32'd63, 32'd62, 32'd61, 32'd60, 32'd59,
  32'd58, 32'd57,
  32'd56, 32'd55, 32'd54, 32'd53, 32'd52, 32'd51, 32'd50, 32'd49, 32'd48, 32'd47,
  32'd46, 32'd45,
  32'd44, 32'd43,
  32'd42, 32'd41,
  32'd40, 32'd39, 32'd38, 32'd37, 32'd36, 32'd35, 32'd34, 32'd33, 32'd32, 32'd31,
  32'd30, 32'd29,
  32'd28, 32'd27, 32'd26, 32'd25, 32'd24, 32'd23, 32'd22, 32'd21, 32'd20, 32'd19,
  32'd18, 32'd17, 32'd16, 32'd15, 32'd14, 32'd13, 32'd12, 32'd11, 32'd10, 32'd9,
  32'd8,  32'd7,  32'd6,  32'd5,  32'd4,  32'd3,  32'd2,  32'd1,  32'd0,  NULLB};

parameter [31:0] JTAG_FIRST = 32'd0;
parameter [31:0] JTAG_LAST  = 32'd89;

// Map logical redundancy control input port to each AIB IO cell
// e.g. cell #89 and #88 use control bit 44 of redun_engage[]
//
parameter [NBMP-1:0] [31:0] RED_ENGAGE_MAP = {
 32'd44, 32'd44, 32'd43, 32'd43, 32'd42, 32'd42, 32'd41, 32'd41, 32'd40, 32'd40,
 32'd39, 32'd39, 32'd38, 32'd38, 32'd37, 32'd37, 32'd36, 32'd36, 32'd35, 32'd35,
 32'd34, 32'd34, 32'd33, 32'd33, 32'd32, 32'd32, 32'd31, 32'd31, 32'd30, 32'd30,
 32'd29, 32'd29,
 32'd28, 32'd28, 32'd27, 32'd27, 32'd26, 32'd26, 32'd25, 32'd25, 32'd24, 32'd24,
 32'd23, 32'd23,
 32'd22, 32'd22,
 32'd21, 32'd21,
 32'd20, 32'd20, 32'd19, 32'd19, 32'd18, 32'd18, 32'd17, 32'd17, 32'd16, 32'd16,
 32'd15, 32'd15,
 32'd14, 32'd14, 32'd13, 32'd13, 32'd12, 32'd12, 32'd11, 32'd11, 32'd10, 32'd10,
 32'd9,  32'd9,  32'd8,  32'd8,  32'd7,  32'd7,  32'd6,  32'd6,  32'd5,  32'd5,
 32'd4,  32'd4,  32'd3,  32'd3,  32'd2,  32'd2,  32'd1,  32'd1,  32'd0,  32'd0};

parameter [NBMP-1:0] [31:0] PREV_RED_ENGAGE_MAP = {
 NULLB,  NULLB,  32'd44, 32'd44, 32'd43, 32'd43, 32'd42, 32'd42, 32'd41, 32'd41, // RX D
 32'd40, 32'd40, 32'd39, 32'd39, 32'd38, 32'd38, 32'd37, 32'd37, 32'd36, 32'd36, // RX D
 32'd35, 32'd35, 32'd34, 32'd34, 32'd33, 32'd33, 32'd32, 32'd32, 32'd31, 32'd31, // RX D
 32'd30, 32'd30,                                                                 // RX CLK
 32'd29, 32'd29, 32'd28, 32'd28, 32'd27, 32'd27, 32'd26, 32'd26, 32'd25, 32'd25, // RX D
 32'd24, 32'd24,                                                                 // RX RSTS
 32'd21, 32'd21,                                                                 // SPARES
 32'd20, 32'd20,                                                                 // TX RSTS
 32'd19, 32'd19, 32'd18, 32'd18, 32'd17, 32'd17, 32'd16, 32'd16, 32'd15, 32'd15, // TX D
 32'd14, 32'd14,                                                                 // TX CLK
 32'd13, 32'd13, 32'd12, 32'd12, 32'd11, 32'd11, 32'd10, 32'd10, 32'd9,  32'd9,  // TX D
 32'd8,  32'd8,  32'd7,  32'd7,  32'd6,  32'd6,  32'd5,  32'd5,  32'd4,  32'd4,  // TX D
 32'd3,  32'd3,  32'd2,  32'd2,  32'd1,  32'd1,  32'd0,  32'd0,  NULLB,  NULLB}; // TX D

parameter RX_DAT_CLK_RED_ENGAGE = 32'd29; // Redundancy engage ctrl bit for RX Clk

parameter [NBMP-1:0] TX_CLK_GROUP = {
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX CLK
 {10{1'b0}},  // RX D
 { 2{1'b0}},  // RX RSTS
 { 2{1'b0}},  // SPARES
 { 2{1'b0}},  // TX RSTS
 {10{1'b1}},  // TX D
 { 2{1'b1}},  // TX CLK
 {10{1'b1}},  // TX D
 {10{1'b1}},  // TX D
 {10{1'b1}}}; // TX D

parameter [NBMP-1:0] RX_CLK_GROUP = {
 {10{1'b1}},  // RX D
 {10{1'b1}},  // RX D
 {10{1'b1}},  // RX D
 { 2{1'b1}},  // RX CLK
 {10{1'b1}},  // RX D
 { 2{1'b1}},  // RX RSTS
 { 2{1'b0}},  // SPARES
 { 2{1'b0}},  // TX RSTS
 {10{1'b0}},  // TX D
 { 2{1'b0}},  // TX CLK
 {10{1'b0}},  // TX D
 {10{1'b0}},  // TX D
 {10{1'b0}}}; // TX D

//------------------------------------------------------------------------------
// RXDAT_GROUP specfies for each uBump 89-0 the associated rx_data bit (even).
//
parameter [NBMP-1:0] [31:0] RX_DAT_GROUP = {
 32'd76, 32'd78, 32'd72, 32'd74, 32'd68, 32'd70, 32'd64, 32'd66, 32'd60, 32'd62, // RX D
 32'd56, 32'd58, 32'd52, 32'd54, 32'd48, 32'd50, 32'd44, 32'd46, 32'd40, 32'd42, // RX D
 32'd36, 32'd38, 32'd32, 32'd34, 32'd28, 32'd30, 32'd24, 32'd26, 32'd20, 32'd22, // RX D
 {2{NULLB}},                                                                     // RX CLK
 32'd16, 32'd18, 32'd12, 32'd14, 32'd8,  32'd10, 32'd4,  32'd6,  32'd0,  32'd2,  // RX D
 {2{NULLB}},                                                                     // RX RSTS
 {2{NULLB}},                                                                     // SPARES
 {2{NULLB}},                                                                     // TX RSTS
 {10{NULLB}},                                                                    // TX D
 {2{NULLB}},                                                                     // TX CLK
 {10{NULLB}},
 {10{NULLB}},                                                                    // TX D
 {10{NULLB}}};                                                                   // TX D
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// TXDAT_GROUP specfies for each uBump 89-0 the associated tx_data bit (even).
//
parameter [NBMP-1:0] [31:0] TX_DAT_GROUP = {
 {10{NULLB}},                                                                    // RX D
 {10{NULLB}},                                                                    // RX D
 {10{NULLB}},                                                                    // RX D
 {2{NULLB}},                                                                     // RX CLK
 {10{NULLB}},                                                                    // RX D
 {2{NULLB}},                                                                     // RX RSTS
 {2{NULLB}},                                                                     // SPARES
 {2{NULLB}},                                                                     // TX RSTS
 32'd2,  32'd0,  32'd6,  32'd4,  32'd10, 32'd8,  32'd14, 32'd12, 32'd18, 32'd16, // TX D
 {2{NULLB}},                                                                     // TX CLK
 32'd22, 32'd20, 32'd26, 32'd24, 32'd30, 32'd28, 32'd34, 32'd32, 32'd38, 32'd36, // TX D
 32'd42, 32'd40, 32'd46, 32'd44, 32'd50, 32'd48, 32'd54, 32'd52, 32'd58, 32'd56, // TX D
 32'd62, 32'd60, 32'd66, 32'd64, 32'd70, 32'd68, 32'd74, 32'd72, 32'd78, 32'd76};// TX D
//------------------------------------------------------------------------------
