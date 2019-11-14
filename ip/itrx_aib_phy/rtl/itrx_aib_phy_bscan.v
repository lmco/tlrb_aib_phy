// Copyright 2019 © Lockheed Martin Corporation

module itrx_aib_phy_bscan (/*AUTOARG*/
   // Outputs
   jtag_scan_en, jtag_rstn_en, jtag_rstn, jtag_mode, jtag_clksel,
   jtag_weakpu, jtag_weakpdn, jtag_intest,
   // Inputs
   tck, reset_n, ir_latched
   );

parameter LATCHED_IR_WID = 32'd7;

input tck;
input reset_n;

input [LATCHED_IR_WID-1:0] ir_latched;

// jtag_* signals from Intel AIB Spec
//
output reg jtag_scan_en;
output reg jtag_rstn_en;
output reg jtag_rstn;
output reg jtag_mode;
output reg jtag_clksel;
output reg jtag_weakpu;
output reg jtag_weakpdn;
output reg jtag_intest;

localparam AIB_SHIFT_EN       = 7'b000_1100; // Enable serial shift operation (JAIB_SHIFT_EN = 1’b1)
localparam AIB_SHIFT_DIS      = 7'b000_1101; // Disable serial shift operation (JAIB_SHIFT_EN = 1’b0)
localparam AIB_TRANSMIT_EN    = 7'b000_1110; // Enable TX transmit output
localparam AIB_TRANSMIT_DIS   = 7'b000_1111; // Disable TX transmit output
localparam AIB_RESET_EN       = 7'b001_0000; // Enable reset
localparam AIB_RESET_DIS      = 7'b001_0001; // Disable reset
localparam AIB_WEAKPU_EN      = 7'b001_0010; // Enable weak pull up (JAIB_WEAKPU = 1’b1).
localparam AIB_WEAKPU_DIS     = 7'b001_0011; // Disable weak pull up (JAIB_WEAKPU = 1’b0).
localparam AIB_WEAKPDN_EN     = 7'b001_0100; // Enable weak pull down (JAIB_WEAKPDN = 1’b1).
localparam AIB_WEAKPDN_DIS    = 7'b001_0101; // Disable weak pull down (JAIB_WEAKPDN = 1’b0).
localparam AIB_INTEST_EN      = 7'b001_0110; // Enable in test operation (JAIB_INTEST= 1’b1)
localparam AIB_INTEST_DIS     = 7'b001_0111; // Disable in test operation (JAIB_INTEST= 1’b0)
localparam AIB_JTAG_CLKSEL    = 7'b001_1000; // Select clock for JTAG operation for AIB_IO clock
localparam AIB_RESET_OVRD_EN  = 7'b100_1000; // enable reset overriding for AIB IO’s reset signals via AIB_RESET_EN/DIS
localparam AIB_RESET_OVRD_DIS = 7'b100_1001; // disable reset overriding for AIB IO’s reset signal

//-----------------------------------------------------------------------------
// Decoded (combinatorial) instruction register signals
//
wire dec_shift_en          = (ir_latched == AIB_SHIFT_EN);
wire dec_shift_dis         = (ir_latched == AIB_SHIFT_DIS);

wire dec_transmit_en       = (ir_latched == AIB_TRANSMIT_EN);
wire dec_transmit_dis      = (ir_latched == AIB_TRANSMIT_DIS);

wire dec_jtag_rstn_en      = (ir_latched == AIB_RESET_EN);
wire dec_jtag_rstn_dis     = (ir_latched == AIB_RESET_DIS);

wire dec_jtag_rst_ovrd_en  = (ir_latched == AIB_RESET_OVRD_EN);
wire dec_jtag_rst_ovrd_dis = (ir_latched == AIB_RESET_OVRD_DIS);

wire dec_jtag_weakpu_en    = (ir_latched == AIB_WEAKPU_EN);
wire dec_jtag_weakpu_dis   = (ir_latched == AIB_WEAKPU_DIS);

wire dec_jtag_weakpdn_en   = (ir_latched == AIB_WEAKPDN_EN);
wire dec_jtag_weakpdn_dis  = (ir_latched == AIB_WEAKPDN_DIS);

wire dec_jtag_intest_en    = (ir_latched == AIB_INTEST_EN);
wire dec_jtag_intest_dis   = (ir_latched == AIB_INTEST_DIS);

wire dec_jtag_clksel       = (ir_latched == AIB_JTAG_CLKSEL);
//-----------------------------------------------------------------------------

/*
5.7 Jtag_clksel Mode
With the AIB_JTAG_CLKSEL instruction shifted in during Shift-IR,
upon UpdateIR, JTAG_CLKSEL will be asserted. This AIB_JTAG_CLKSEL instruction will
allow CLKDR to override ilaunch_clk of the AIB IO. When JTAG_CLKSEL = 1b’1,
JTAG_CLKDR will be sent to ilaunch_clk of the AIB IO. By default,
JTAG_CLKSEL = 1b’0, which is selecting functional CLK from Adapter. This
JTAG_CLKSEL is set to 0 by POR, to prevent glitch on the clock network due to
OSC clock. For stuck-at test, user is expected to shift in this instruction before
AIB_TRANSMIT_EN mode.
*/

always @(posedge tck or negedge reset_n) begin
  if (!reset_n) begin
    jtag_rstn <= 1'h1; // Intel AIB Spec: jtag_rstn defaults to 1.
    /*AUTORESET*/
    // Beginning of autoreset for uninitialized flops
    jtag_clksel <= 1'h0;
    jtag_intest <= 1'h0;
    jtag_mode <= 1'h0;
    jtag_rstn_en <= 1'h0;
    jtag_scan_en <= 1'h0;
    jtag_weakpdn <= 1'h0;
    jtag_weakpu <= 1'h0;
    // End of automatics
  end else begin

   jtag_clksel <= dec_jtag_clksel | jtag_clksel; // NOTE: Never cleared once set.

   jtag_scan_en <= dec_shift_en         | (~dec_shift_dis         & jtag_scan_en);
   jtag_intest  <= dec_jtag_intest_en   | (~dec_jtag_intest_dis   & jtag_intest);
   jtag_weakpdn <= dec_jtag_weakpdn_en  | (~dec_jtag_weakpdn_dis  & jtag_weakpdn);
   jtag_weakpu  <= dec_jtag_weakpu_en   | (~dec_jtag_weakpu_dis   & jtag_weakpu);
   jtag_rstn_en <= dec_jtag_rst_ovrd_en | (~dec_jtag_rst_ovrd_dis & jtag_rstn_en);
   jtag_rstn    <= ~(dec_jtag_rstn_en   | (~dec_jtag_rstn_dis     & (~jtag_rstn)));
   jtag_mode    <= dec_transmit_en      | (~dec_transmit_dis      & jtag_mode);

  end

end

endmodule
