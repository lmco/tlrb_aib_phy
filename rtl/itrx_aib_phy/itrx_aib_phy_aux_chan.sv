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
// Filename       : itrx_aib_phy_aux_chan.v
// Description    : AIB AUX channel
//
// ==========================================================================
//
//    $Rev:: 5486                      $: Revision of last commit
// $Author:: Intrinsix Corporation     $: Author of last commit
//   $Date:: 2019-01-09 17:07:18 -0500#$: Date of last commit
//
// ==========================================================================

//lint: Combin paths from overrides, etc. to outputs.
//lint_checking IOCOMB off
module itrx_aib_phy_aux_chan (/*AUTOARG*/
   // Outputs
   dig_test_bus_aux, por_out, device_detect, o_osc_clk,
   por_aux_vcc_io,
   // Inouts
   ubump_aux,
   // Inputs
   ms_nsl, por_in, por_ovrd, device_detect_ovrd, por_vcc_io
   );
//lint_checking IOCOMB on

// ubump[0] = DD connects to 2 ubumps
// ubump[1] = POR connects to 2 ubumps

//lint: ubump is inout, ubump is multi-driven
//lint_checking IOPNTA MULWIR off

//lint_checking MLTDRV off
//inout                   vcc_dig;
/*
inout                   vcc_io;
inout                   vss_ana;
*/
//lint_checking MLTDRV on

inout [1:0] ubump_aux;
//lint_checking IOPNTA MULWIR on

output [7:0] dig_test_bus_aux;

input ms_nsl; // Master Not Slave

input  por_in;
output por_out;
input  por_ovrd;

//output device_detect_n;
output device_detect;
input  device_detect_ovrd;

output o_osc_clk;
wire por_out_vcc_io;
// Used when a slave (ms_nsl=0) 
// This input signal is broadcasted from slave to master.
// The slave creates this signal in the digital core.
// The signal is level shifted to the VCC IO to be compatible with AUX VCC IO.
//
input por_vcc_io; // POR From AIB slave por controller, and then shifted to VCC IO.
wire por_sl2sl_vcc_io;
// This output is meant to drive the por_vcc_io input of the AIB IO Channel block.
//
output por_aux_vcc_io;

assign por_aux_vcc_io = ms_nsl ? por_out_vcc_io : por_sl2sl_vcc_io; // Drives AIB IO Channel(s) 

localparam IDRV_PLUS_25PCT = 2'b10; // ipdrv/indrv encoding for 25% more than normal

wire [1:0] ipdrv = IDRV_PLUS_25PCT;
wire [1:0] indrv = IDRV_PLUS_25PCT;

// FIX ME (add provision to include and osc clock) 
//lint_checking TIELOG off
assign o_osc_clk = 1'b0;
assign dig_test_bus_aux = 8'd0;
//lint_checking TIELOG on

// There are no active spares in the AIB AUX Channel.
//
wire spare_mode = 1'b0;

// Unused active redundancy outputs from IO cells
//
wire [1:0]       nc_jtag_async_data;
//lint_checking NUMSUF off
wire [1:0]       nc_jtag_idat0;
wire [1:0]       nc_jtag_idat1;
//lint_checking NUMSUF on
wire [1:0]       nc_rmux_oclk;
wire [1:0]       nc_rmux_oclk_b;

wire [1:0]       nc_jtag_clkdr_n;

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [1:0]              nc_jtag_scanout;        // From u1_por_cell of itrx_aib_phy_io_cell.v, ...
// End of automatics

/*AUTOREGINPUT*/

//------------------------------------------------------------------------------
// Outputs from each AIB IO Cell
//
wire [1:0] oclk;
wire [1:0] oclk_b;
//lint_checking NUMSUF off
wire [1:0] nrml_odat0;
wire [1:0] nrml_odat1;
wire [1:0] odat0;
wire [1:0] odat1;
//lint_checking NUMSUF on
wire [1:0] nrml_odat_asyn;
wire [1:0] odat_asyn;


// Only the nrml_odat_asyn from the IO cell is used.
//
wire unused_ok = &{
                   nc_jtag_scanout,
                   nc_jtag_clkdr_n,
                   nc_rmux_oclk,
                   nc_rmux_oclk_b,
                   nc_jtag_async_data,
                   nc_jtag_idat0,
                   nc_jtag_idat1,
                   oclk,
                   oclk_b,
                   nrml_odat0,
                   nrml_odat1,
                   odat0,
                   odat1,
                   odat_asyn,
                   1'b0};
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Inputs to IO Cells assigned with internal logic below
//
wire [1:0] nrml_async_data;
wire [1:0] nrml_txen;
wire [1:0] [2:0] nrml_rxen;
//------------------------------------------------------------------------------


// Tie-offs for unused IO Cell inputs
//
wire       tie_low  = 1'b0;
wire [1:0] tie2_low = 2'b00;
wire [2:0] tie3_low = 3'b000;
wire       tie_high = 1'b1;
wire por_in_vcc_io;
//------------------------------------------------------------------------------
// POR logic
//
//assign nrml_async_data[1] = ms_nsl ? 1'b0 : (por_in & (~device_detect_n));
assign nrml_async_data[1] = ms_nsl ? 1'b0 : por_in_vcc_io;

assign por_out_vcc_io = ms_nsl ? (nrml_odat_asyn[1] | (~por_ovrd)) : 1'b0;
assign nrml_txen[1] = ~ms_nsl; // Slave transmits, Master receives
assign nrml_rxen[1] = ms_nsl ? 3'b000  // Async data input. Tristated TX. Master
                             : 3'b010; // Async data out. Disabled RX.    Slave 
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Device Detect logic
//
assign nrml_async_data[0] = ms_nsl ? 1'b1 : 1'b0; // Master drives 1 upon pwr up
//assign device_detect_n = ~(ms_nsl ? 1'b0 : (nrml_odat_asyn[0] | device_detect_ovrd));
wire   device_detect_vcc_io = ms_nsl ? 1'b0 : (nrml_odat_asyn[0] | device_detect_ovrd);
assign nrml_txen[0] = ms_nsl; // Master transmits, Slave receives
assign nrml_rxen[0] = ms_nsl ? 3'b010  // Async data out. Disabled RX.    Master
                             : 3'b000; // Async data input. Tristated TX. Slave 
//------------------------------------------------------------------------------


/*
itrx_aib_phy_io_cell AUTO_TEMPLATE (
  .nrml_\([rt].*\) (nrml_\1[@]),
  .ubump (ubump_aux[@]),
  .nrml_async_data (nrml_async_data[@]),
  .jtag_scanout (nc_jtag_scanout[@]),
  .o\(.*\) (o\1[@]),
  .nrml_o\(.*\) (nrml_o\1[@]),
  .\(.*\)i\(.*\)clk\(.*\) (tie_low),
  .\(.*\)i\(.*\)rstb\(.*\) (tie_high),
  .redn_rxen (tie3_low),
  .redn_\(.*\)drv (tie2_low),
  .redn_\(.*\) (tie_low),
  .prev_redn_\(.*\) (tie_low),
  .nrml_idat[01]\(.*\) (tie_low),
  .por\(.*\) (tie_low),
  .nrml_\(.*\)drv (\1drv[]),
  .nrml_idat_selb(tie_high),
  .nrml_iddr_enable(tie_low),
  .rmux_oclk(nc_rmux_oclk[@]),
  .rmux_oclk_b(nc_rmux_oclk_b[@]),

  .jtag_async_data (nc_@"vl-name"[@]),
  .jtag_idat0      (nc_@"vl-name"[@]),
  .jtag_idat1      (nc_@"vl-name"[@]),

  .jtag_clkdr_n    (nc_jtag_clkdr_n[@]),

  .jtag_clkdr      (tie_low),
  .jtag_clksel     (tie_low),
  .jtag_intest     (tie_low),
  .jtag_mode       (tie_low),
  .jtag_scan_en    (tie_low),
  .jtag_scanin     (tie_low),
  .jtag_weakpdn    (tie_low),
  .jtag_weakpu     (tie_low),

  .vcc_dig         (vcc_io),

 ); */

itrx_aib_phy_io_cell 
  u1_por_cell (/*AUTOINST*/
               // Outputs
               .jtag_scanout            (nc_jtag_scanout[1]),    // Templated
               .jtag_clkdr_n            (nc_jtag_clkdr_n[1]),    // Templated
               .jtag_async_data         (nc_jtag_async_data[1]), // Templated
               .jtag_idat0              (nc_jtag_idat0[1]),      // Templated
               .jtag_idat1              (nc_jtag_idat1[1]),      // Templated
               .oclk                    (oclk[1]),               // Templated
               .oclk_b                  (oclk_b[1]),             // Templated
               .rmux_oclk               (nc_rmux_oclk[1]),       // Templated
               .rmux_oclk_b             (nc_rmux_oclk_b[1]),     // Templated
               .nrml_odat0              (nrml_odat0[1]),         // Templated
               .odat0                   (odat0[1]),              // Templated
               .nrml_odat1              (nrml_odat1[1]),         // Templated
               .odat1                   (odat1[1]),              // Templated
               .nrml_odat_asyn          (nrml_odat_asyn[1]),     // Templated
               .odat_asyn               (odat_asyn[1]),          // Templated
               // Inouts
               .ubump                   (ubump_aux[1]),          // Templated
               // Inputs
               .por_vcc_io              (tie_low),               // Templated
               .por_vcc_dig             (tie_low),               // Templated
               .iclkn                   (tie_low),               // Templated
               .inclk                   (tie_low),               // Templated
               .inclk_dist              (tie_low),               // Templated
               .redn_engage             (tie_low),               // Templated
               .prev_redn_engage        (tie_low),               // Templated
               .spare_mode              (spare_mode),
               .redn_any                (tie_low),               // Templated
               .irstb                   (tie_high),              // Templated
               .tx_irstb                (tie_high),              // Templated
               .rx_irstb                (tie_high),              // Templated
               .jtag_clkdr              (tie_low),               // Templated
               .jtag_clksel             (tie_low),               // Templated
               .jtag_intest             (tie_low),               // Templated
               .jtag_mode               (tie_low),               // Templated
               .jtag_scan_en            (tie_low),               // Templated
               .jtag_scanin             (tie_low),               // Templated
               .jtag_weakpdn            (tie_low),               // Templated
               .jtag_weakpu             (tie_low),               // Templated
               .nrml_ilaunch_clk        (tie_low),               // Templated
               .nrml_async_data         (nrml_async_data[1]),    // Templated
               .nrml_idat0              (tie_low),               // Templated
               .nrml_idat1              (tie_low),               // Templated
               .nrml_idat_selb          (tie_high),              // Templated
               .nrml_iddr_enable        (tie_low),               // Templated
               .nrml_indrv              (indrv[1:0]),            // Templated
               .nrml_ipdrv              (ipdrv[1:0]),            // Templated
               .nrml_rxen               (nrml_rxen[1]),          // Templated
               .nrml_txen               (nrml_txen[1]),          // Templated
               .redn_ilaunch_clk        (tie_low),               // Templated
               .redn_async_data         (tie_low),               // Templated
               .redn_idat0              (tie_low),               // Templated
               .redn_idat1              (tie_low),               // Templated
               .redn_rxen               (tie3_low),              // Templated
               .redn_txen               (tie_low),               // Templated
               .redn_idat_selb          (tie_low),               // Templated
               .redn_iddr_enable        (tie_low),               // Templated
               .redn_indrv              (tie2_low),              // Templated
               .redn_ipdrv              (tie2_low),              // Templated
               .redn_oclk               (tie_low),               // Templated
               .redn_oclk_b             (tie_low),               // Templated
               .redn_odat0              (tie_low),               // Templated
               .redn_odat1              (tie_low),               // Templated
               .redn_odat_asyn          (tie_low));              // Templated

itrx_aib_phy_io_cell 
  u0_dd_cell (/*AUTOINST*/
              // Outputs
              .jtag_scanout             (nc_jtag_scanout[0]),    // Templated
              .jtag_clkdr_n             (nc_jtag_clkdr_n[0]),    // Templated
              .jtag_async_data          (nc_jtag_async_data[0]), // Templated
              .jtag_idat0               (nc_jtag_idat0[0]),      // Templated
              .jtag_idat1               (nc_jtag_idat1[0]),      // Templated
              .oclk                     (oclk[0]),               // Templated
              .oclk_b                   (oclk_b[0]),             // Templated
              .rmux_oclk                (nc_rmux_oclk[0]),       // Templated
              .rmux_oclk_b              (nc_rmux_oclk_b[0]),     // Templated
              .nrml_odat0               (nrml_odat0[0]),         // Templated
              .odat0                    (odat0[0]),              // Templated
              .nrml_odat1               (nrml_odat1[0]),         // Templated
              .odat1                    (odat1[0]),              // Templated
              .nrml_odat_asyn           (nrml_odat_asyn[0]),     // Templated
              .odat_asyn                (odat_asyn[0]),          // Templated
              // Inouts
              .ubump                    (ubump_aux[0]),          // Templated
              // Inputs
              .por_vcc_io               (tie_low),               // Templated
              .por_vcc_dig              (tie_low),               // Templated
              .iclkn                    (tie_low),               // Templated
              .inclk                    (tie_low),               // Templated
              .inclk_dist               (tie_low),               // Templated
              .redn_engage              (tie_low),               // Templated
              .prev_redn_engage         (tie_low),               // Templated
              .spare_mode               (spare_mode),
              .redn_any                 (tie_low),               // Templated
              .irstb                    (tie_high),              // Templated
              .tx_irstb                 (tie_high),              // Templated
              .rx_irstb                 (tie_high),              // Templated
              .jtag_clkdr               (tie_low),               // Templated
              .jtag_clksel              (tie_low),               // Templated
              .jtag_intest              (tie_low),               // Templated
              .jtag_mode                (tie_low),               // Templated
              .jtag_scan_en             (tie_low),               // Templated
              .jtag_scanin              (tie_low),               // Templated
              .jtag_weakpdn             (tie_low),               // Templated
              .jtag_weakpu              (tie_low),               // Templated
              .nrml_ilaunch_clk         (tie_low),               // Templated
              .nrml_async_data          (nrml_async_data[0]),    // Templated
              .nrml_idat0               (tie_low),               // Templated
              .nrml_idat1               (tie_low),               // Templated
              .nrml_idat_selb           (tie_high),              // Templated
              .nrml_iddr_enable         (tie_low),               // Templated
              .nrml_indrv               (indrv[1:0]),            // Templated
              .nrml_ipdrv               (ipdrv[1:0]),            // Templated
              .nrml_rxen                (nrml_rxen[0]),          // Templated
              .nrml_txen                (nrml_txen[0]),          // Templated
              .redn_ilaunch_clk         (tie_low),               // Templated
              .redn_async_data          (tie_low),               // Templated
              .redn_idat0               (tie_low),               // Templated
              .redn_idat1               (tie_low),               // Templated
              .redn_rxen                (tie3_low),              // Templated
              .redn_txen                (tie_low),               // Templated
              .redn_idat_selb           (tie_low),               // Templated
              .redn_iddr_enable         (tie_low),               // Templated
              .redn_indrv               (tie2_low),              // Templated
              .redn_ipdrv               (tie2_low),              // Templated
              .redn_oclk                (tie_low),               // Templated
              .redn_oclk_b              (tie_low),               // Templated
              .redn_odat0               (tie_low),               // Templated
              .redn_odat1               (tie_low),               // Templated
              .redn_odat_asyn           (tie_low));              // Templated

//------------------------------------------------------------------------------
// Level Shifters for AUX signals.
// Shift to Digital Levels
//

//lint: IPRTEX - A constant is used in a port expression.
//lint_checking IPRTEX off

//aibcr3aux_lvlshift
aibcr3aux_lvshift  u_lvshift_2dig_por (
`ifndef SYNTHESIS
                                       .vssl_aibcr3aux (1'b0),
                                       .vccl_aibcr3aux (1'b1), // in  vcc_io
                                       .vcc_aibcr3aux  (1'b1), // out vcc_dig
`endif
                                       .in             (por_out_vcc_io),
                                       .out            (por_out)
                                      );

aibcr3aux_lvshift  u_lvshift_2dig_dd  (
`ifndef SYNTHESIS
                                       .vssl_aibcr3aux (1'b0),
                                       .vccl_aibcr3aux (1'b1), // in  vcc_io
                                       .vcc_aibcr3aux  (1'b1), // out vcc_dig
`endif
                                       .in             (device_detect_vcc_io),
                                       .out            (device_detect)
                                      );
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Level Shifters for AUX signals.
// Shift to IO Levels
//
aibcr3aux_lvshift  u_lvshift_2io_por2m(
`ifndef SYNTHESIS
                                       .vssl_aibcr3aux (1'b0),
                                       .vccl_aibcr3aux (1'b1), // in  vcc_dig
                                       .vcc_aibcr3aux  (1'b1), // out vcc_io
`endif
                                       .in             (por_in),
                                       .out            (por_in_vcc_io)
                                      );

aibcr3aux_lvshift  u_lvshift_2io_por2s(
`ifndef SYNTHESIS
                                       .vssl_aibcr3aux (1'b0),
                                       .vccl_aibcr3aux (1'b1), // in  vcc_dig
                                       .vcc_aibcr3aux  (1'b1), // out vcc_io
`endif
                                       .in             (por_vcc_io),
                                       .out            (por_sl2sl_vcc_io)
                                      );
//lint_checking IPRTEX on
//------------------------------------------------------------------------------
endmodule
