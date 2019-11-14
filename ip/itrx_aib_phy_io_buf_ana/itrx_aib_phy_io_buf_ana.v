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
//
//Verilog HDL for "lmat101_RevA", "itrx_aib_phy_io_buf_ana" "verilog"

`ifdef POWER_PINS
module itrx_aib_phy_io_buf_ana
  ( iclkn, indrv, ipdrv, oclk, oclk_b, por_vcc_dig,
    por_vcc_io, rx_dat_en, rx_clk_en, ubump, ubump_odig, ubump_odig_async, tx_en_buf, txdat_mux, weakp0,
    weakp1, vcc_dig, vcc_io, vss );
   inout vss;
   inout vcc_io;
   inout vcc_dig;
`else
module itrx_aib_phy_io_buf_ana
  ( iclkn, indrv, ipdrv, oclk, oclk_b, por_vcc_dig,
    por_vcc_io, rx_dat_en, rx_clk_en, ubump, ubump_odig, ubump_odig_async, tx_en_buf, txdat_mux, weakp0,
    weakp1);
`endif // !`ifdef POWER_PINS

  inout ubump;
  input txdat_mux;
  input por_vcc_io;
  output oclk_b;
  output ubump_odig;
  output ubump_odig_async;
  input [1:0] ipdrv;
  input [1:0] indrv;
  input por_vcc_dig;
  output oclk;
  input rx_clk_en;
  input weakp1;
  input weakp0;
  input tx_en_buf;
  input rx_dat_en;
  input iclkn;

    tri ubump;
    tri ubump_int;
    wire ubump_odig_int;
    wire iclkn_int;
    wire oclk_int;
    wire oclk_b_int;
    wire ubump_odig_por;
    wire oclk_por;
    wire oclk_b_por;
    wire vcc_io_good;
    wire por_either;
    wire iclk_xor;

    supply0 su0;
    supply1 su1;

   // Power pin check
`ifdef POWER_PINS
   assign vcc_io_good = vcc_io;
   assign vcc_dig_good = vcc_dig;
`else
   assign vcc_io_good = 1'b1;
   assign vcc_dig_good = 1'b1;
`endif
    and IGOOD (pwr_good, vcc_io_good, vcc_dig_good);

    //Internal pad
    nmos    u1(ubump, ubump_int, 1'b1);   // Drive output pad
    //nmos    u2(iclkn, iclkn_int, 1'b1); // iclkn is an input. Why is this needed?

    // POR
    or  IPOR  (por_either, por_vcc_io, por_vcc_dig);

    // Receiver logic - Rx data
    and IDAT   (ubump_odig_int, ubump/*_int*/, rx_dat_en);        // Rx data is set to logic 0 when rx_dat_en is deasserted
    assign ubump_odig_por = (por_either) ? 1'b0 : ubump_odig_int; // Rx data is set to logic 0 when por is asserted
    assign ubump_odig     = (pwr_good)   ? ubump_odig_por : 1'bx; // Rx data output. Set to X if pwr is not good.
    assign ubump_odig_async   = ubump_odig;                          // Rx data asynchronous output

    // Receiver logic - Rx differential clock
    and ICLK   (oclk_int,       ubump/*_int*/, rx_clk_en);        // oclk_int is set to logic 0 when rx_clk_en is deasserted
    or  ICLKN  (iclkn_int,      iclkn,        ~rx_clk_en);        // oclk_int and iclkn_int_int are set to opposite states when rx_clk_en is deasserted
//    or  ICLKN2 (oclk_b_int,     iclkn_int,    ~rx_clk_en);        // oclk_b_int is set to logic 1 when rx_clk_en is deasserted
    or  ICLKN2 (oclk_b_int,     ~ubump/*_int*/,    ~rx_clk_en);        // oclk_b_int is set to logic 1 when rx_clk_en is deasserted
    //xor IXOR   (iclk_xor,       iclkn_int,     oclk_int);         // iclk_xor is asserted when oclk_int and iclkn_int are opposite state
    assign iclk_xor = 1'b1; // REVISIT - Set to 1 to eliminate output glitch on oclk and oclk_b

    assign oclk_por       = (por_either) ? 1'b0 : oclk_int      ; // oclk is set to logic 0 when por is asserted
    assign oclk_b_por     = (por_either) ? 1'b1 : oclk_b_int    ; // oclk_b is set to logic 0 when por is asserted
    assign oclk_2         = (pwr_good)   ? oclk_por       : 1'bx; // set oclk to X if pwr is not good (do this for oclk_b as well?)
    assign oclk_2b         = (pwr_good)  ? oclk_b_por     : 1'bx; // set oclk_b to X if pwr is not good
    assign oclk           = (iclk_xor)   ? oclk_2         : 1'bx; // oclk output driver. Output set to X is diff clk drv inputs are the same.
    assign oclk_b         = (iclk_xor)   ? oclk_2b        : 1'bx; // oclk_b output driver. Output set to X is diff clk drv inputs are the same.

    // Driver logic
    assign txdat_por = (por_vcc_io) ? 1'b0 : txdat_mux;           // Tx data input. Set to 0 on por.
    bufif1 utx(ubump_int, txdat_por, tx_en_buf);                  // Drive Tx data when tx_en_buf is asserted.
    rnmos  up1(ubump_int, su1, weakp1);                           // Weak driver
    or     dn0(enp0, weakp0, por_vcc_io);                         // Enable weak pull down on POR
    rnmos  dn1(ubump_int, su0, enp0);                             // Weak driver

endmodule
