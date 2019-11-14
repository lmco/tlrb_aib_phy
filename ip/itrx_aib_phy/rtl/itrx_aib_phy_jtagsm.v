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
// Original Author: Intrinsix Corp.
// Filename       : itrx_aib_phy_jtagsm.v
// Description    : AIB PHY standard 1149.1 JTAG TAP controller State Machine
//
// ==========================================================================
//
//    $Rev:: 5770                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2019-05-07 15:14:06 -0400#$: Date of last commit
//
// ==========================================================================

//lint: Extraneous logic present in unit that encodes an FSM. FSM for state reg does not adhere to STYLE guidelines.
//lint_checking EXTFSM BADFSM off
module itrx_aib_phy_jtagsm(/*AUTOARG*/
   // Outputs
   tdo, update_ir, update_dr, capture_dr, shift_ir, shift_dr,
   test_logic_reset, instruction, state_shift_dr_p,
   // Inputs
   tck, tms, reset_n, tdi
   );

parameter EFF_IR_SIZE = 32'd7;
parameter TOTAL_IR_SIZE = 32'd15;

// TAP state encodings
localparam SM_TEST_LOGIC_RESET = 4'b0000;
localparam SM_RUN_TEST_IDLE    = 4'b0001;
localparam SM_SELECT_DR_SCAN   = 4'b0010;
localparam SM_CAPTURE_DR       = 4'b0011;
localparam SM_SHIFT_DR         = 4'b0100;
localparam SM_EXIT1_DR         = 4'b0101;
localparam SM_PAUSE_DR         = 4'b0110;
localparam SM_EXIT2_DR         = 4'b0111;
localparam SM_UPDATE_DR        = 4'b1000;
localparam SM_SELECT_IR_SCAN   = 4'b1001;
localparam SM_CAPTURE_IR       = 4'b1010;
localparam SM_SHIFT_IR         = 4'b1011;
localparam SM_EXIT1_IR         = 4'b1100;
localparam SM_PAUSE_IR         = 4'b1101;
localparam SM_EXIT2_IR         = 4'b1110;
localparam SM_UPDATE_IR        = 4'b1111;

input tck;
input tms;
input reset_n;
input tdi;
output tdo;

output update_ir;
output update_dr;
output capture_dr;
output shift_ir;
output shift_dr;
output test_logic_reset;
output [EFF_IR_SIZE-1:0] instruction;
output reg state_shift_dr_p;

reg [3:0] current_state;
reg [3:0] next_state;
reg [TOTAL_IR_SIZE-1:0] ir;
reg [EFF_IR_SIZE-1:0] instruction;

// TAP state machine
//
//lint Both edges of clock signal 'tck' used.
//lint_checking EDGMIX off
always @(posedge tck or negedge reset_n)
begin
  if(reset_n == 1'b0) begin
    current_state <= SM_TEST_LOGIC_RESET;
  end else begin
    current_state <= next_state;
  end
end
//lint_checking EDGMIX on

always @(*)
begin
//lint: The case items of the case statement cover all values. The default clause is not required.
//       One-hot encoding not used for assigning states in state machine.
//lint_checking CDEFCV ONHOEN off
  case(current_state)
    SM_TEST_LOGIC_RESET: next_state = tms ? SM_TEST_LOGIC_RESET : SM_RUN_TEST_IDLE;

    SM_RUN_TEST_IDLE:    next_state = tms ? SM_SELECT_DR_SCAN   : SM_RUN_TEST_IDLE;

    SM_SELECT_DR_SCAN:   next_state = tms ? SM_SELECT_IR_SCAN   : SM_CAPTURE_DR;

    SM_CAPTURE_DR:       next_state = tms ? SM_EXIT1_DR         : SM_SHIFT_DR;

    SM_SHIFT_DR:         next_state = tms ? SM_EXIT1_DR         : SM_SHIFT_DR;

    SM_EXIT1_DR:         next_state = tms ? SM_UPDATE_DR        : SM_PAUSE_DR;

    SM_PAUSE_DR:         next_state = tms ? SM_EXIT2_DR         : SM_PAUSE_DR;

    SM_EXIT2_DR:         next_state = tms ? SM_UPDATE_DR        : SM_SHIFT_DR;

    SM_UPDATE_DR:        next_state = tms ? SM_SELECT_DR_SCAN   : SM_RUN_TEST_IDLE;

    SM_SELECT_IR_SCAN:   next_state = tms ? SM_TEST_LOGIC_RESET : SM_CAPTURE_IR;

    SM_CAPTURE_IR:       next_state = tms ? SM_EXIT1_IR         : SM_SHIFT_IR;

    SM_SHIFT_IR:         next_state = tms ? SM_EXIT1_IR         : SM_SHIFT_IR;

    SM_EXIT1_IR:         next_state = tms ? SM_UPDATE_IR        : SM_PAUSE_IR;

    SM_PAUSE_IR:         next_state = tms ? SM_EXIT2_IR         : SM_PAUSE_IR;

    SM_EXIT2_IR:         next_state = tms ? SM_UPDATE_IR        : SM_SHIFT_IR;

    SM_UPDATE_IR:        next_state = tms ? SM_SELECT_DR_SCAN   : SM_RUN_TEST_IDLE;

    default:             next_state = SM_TEST_LOGIC_RESET;
  endcase
//lint_checking CDEFCV ONHOEN on

  // Early version of shift_dr to enable (ICG) the JTAG clock (jtag_clkdr).
  state_shift_dr_p = (next_state == SM_SHIFT_DR);
end

// Decode output STATE signals current state.
//
assign shift_ir         = (current_state == SM_SHIFT_IR);
assign shift_dr         = (current_state == SM_SHIFT_DR);
assign capture_dr       = (current_state == SM_CAPTURE_DR);
assign update_ir        = (current_state == SM_UPDATE_IR);
assign update_dr        = (current_state == SM_UPDATE_DR);
assign test_logic_reset = (current_state == SM_TEST_LOGIC_RESET);

// TAP IR
// SHIFT-IR operation
always @(posedge tck or negedge reset_n)
begin
  if (reset_n == 1'b0) begin
    ir <= {TOTAL_IR_SIZE{1'b0}};
  end else if (test_logic_reset == 1'b1) begin
    ir <= {TOTAL_IR_SIZE{1'b0}};
  end else if (shift_ir) begin
    ir <= {tdi,ir[TOTAL_IR_SIZE-1:1]};
  end
end

assign tdo = ir[0];

// UPDATE-IR operation
//
//lint: Flip-flop is triggered at the negative edge of clock 'tck'.
//lint_checking NEFLOP off
always @(negedge tck or negedge reset_n)
begin
  if (reset_n == 1'b0) begin
    instruction <= {EFF_IR_SIZE{1'b0}};
  end else if (update_ir == 1'b1) begin
    instruction <= ir[EFF_IR_SIZE-1:0];
  end
end
//lint_checking NEFLOP on

//lint_checking EXTFSM BADFSM on
endmodule
