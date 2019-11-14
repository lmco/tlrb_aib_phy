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
// Filename       : itrx_aib_phy_redn.v
// Description    : Redundancy multiplexing for each AIB IO cell
//
// ==========================================================================
//
//    $Rev:: 5107                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-06-28 18:54:37 -0400#$: Date of last commit
//
// ==========================================================================
// Redundancy multiplexing for each AIB IO cell
//
//lint_checking IOCOMB off
module itrx_aib_phy_redn (/*AUTOARG*/
   // Outputs
   rmux_oclk, rmux_oclk_b, idat0, idat1, async_data, rxen, txen,
   iddr_enable, idat_selb, ipdrv, indrv, rmux_odat0, rmux_odat1,
   rmux_odat_asyn,
   // Inputs
   oclk, oclk_b, redn_oclk, redn_oclk_b, redn_engage, spare_mode,
   jtag_mode, nrml_idat0, nrml_idat1, nrml_async_data, nrml_rxen,
   nrml_txen, redn_idat0, redn_idat1, redn_async_data, redn_rxen,
   redn_txen, jtag_idat0, jtag_idat1, jtag_async_data, jtag_rxen,
   jtag_txen, nrml_iddr_enable, redn_iddr_enable, nrml_idat_selb,
   redn_idat_selb, nrml_ipdrv, redn_ipdrv, nrml_indrv, redn_indrv,
   redn_odat0, odat0, redn_odat1, odat1, redn_odat_asyn, odat_asyn
   );

input                         oclk;       // Direct from IO Buffer
input                         oclk_b;

input                    redn_oclk;       // Redun input from other Cell
input                    redn_oclk_b;

output                   rmux_oclk;       // After Redun MUX
output                   rmux_oclk_b;

input redn_engage;
input spare_mode;
input jtag_mode;

// Normal inputs (only used in spare_mode)
//
input                    nrml_idat0;
input                    nrml_idat1;
input                    nrml_async_data;

input  [2:0]             nrml_rxen;
input                    nrml_txen;

// Redundant inputs used when rednundancy engaged.
//
input                    redn_idat0;
input                    redn_idat1;
input                    redn_async_data;

input  [2:0]             redn_rxen;
input                    redn_txen;

// JTAG inputs (from BSR)
//
input                    jtag_idat0;
input                    jtag_idat1;
input                    jtag_async_data;

input  [2:0]             jtag_rxen;
input                    jtag_txen;


// Outputs to IO Buffer
//
output                   idat0;
output                   idat1;
output                   async_data;

output [2:0]             rxen;
output                   txen;

// Outputs that go directly to IO Buffer
//
input                    nrml_iddr_enable;
input                    redn_iddr_enable;
output                        iddr_enable;

input                    nrml_idat_selb;
input                    redn_idat_selb;
output                        idat_selb;

input  [1:0]             nrml_ipdrv;
input  [1:0]             redn_ipdrv;
output [1:0]                  ipdrv;

input  [1:0]             nrml_indrv;
input  [1:0]             redn_indrv;
output [1:0]                  indrv;

// Outputs from IO Buffer (via BSR) muxed with redundant
//
input                    redn_odat0;
input                         odat0;
output                   rmux_odat0;

input                    redn_odat1;
input                         odat1;
output                   rmux_odat1;

input                    redn_odat_asyn;
input                         odat_asyn;
output                   rmux_odat_asyn;

//------------------------------------------------------------------------------
// 3 to 1 Redundancy MUX (supports Spare AIB IO Cell function)
/*
  Mux select =
   spare_mode
      ? (jtag_mode
           ? 0
            : (redn_engage ? 1 : 2))
       : (redn_engage ? 1 : 0)
*/

/*
itrx_aib_phy_redn_3to1_mux AUTO_TEMPLATE (
    .mux_do   (@"(substring vl-cell-name 2)"),
    .\(.*\)di (\1@"(substring vl-cell-name 2)"),
 ); */

itrx_aib_phy_redn_3to1_mux
  u_idat0(/*AUTOINST*/
          // Outputs
          .mux_do                       (idat0),                 // Templated
          // Inputs
          .spare_mode                   (spare_mode),
          .jtag_mode                    (jtag_mode),
          .redn_engage                  (redn_engage),
          .jtag_di                      (jtag_idat0),            // Templated
          .nrml_di                      (nrml_idat0),            // Templated
          .redn_di                      (redn_idat0));           // Templated

itrx_aib_phy_redn_3to1_mux
  u_idat1(/*AUTOINST*/
          // Outputs
          .mux_do                       (idat1),                 // Templated
          // Inputs
          .spare_mode                   (spare_mode),
          .jtag_mode                    (jtag_mode),
          .redn_engage                  (redn_engage),
          .jtag_di                      (jtag_idat1),            // Templated
          .nrml_di                      (nrml_idat1),            // Templated
          .redn_di                      (redn_idat1));           // Templated

itrx_aib_phy_redn_3to1_mux
  u_async_data(/*AUTOINST*/
               // Outputs
               .mux_do                  (async_data),            // Templated
               // Inputs
               .spare_mode              (spare_mode),
               .jtag_mode               (jtag_mode),
               .redn_engage             (redn_engage),
               .jtag_di                 (jtag_async_data),       // Templated
               .nrml_di                 (nrml_async_data),       // Templated
               .redn_di                 (redn_async_data));      // Templated

itrx_aib_phy_redn_3to1_mux #(.DWID(3))
  u_rxen(/*AUTOINST*/
         // Outputs
         .mux_do                        (rxen),                  // Templated
         // Inputs
         .spare_mode                    (spare_mode),
         .jtag_mode                     (jtag_mode),
         .redn_engage                   (redn_engage),
         .jtag_di                       (jtag_rxen),             // Templated
         .nrml_di                       (nrml_rxen),             // Templated
         .redn_di                       (redn_rxen));            // Templated

itrx_aib_phy_redn_3to1_mux
  u_txen(/*AUTOINST*/
         // Outputs
         .mux_do                        (txen),                  // Templated
         // Inputs
         .spare_mode                    (spare_mode),
         .jtag_mode                     (jtag_mode),
         .redn_engage                   (redn_engage),
         .jtag_di                       (jtag_txen),             // Templated
         .nrml_di                       (nrml_txen),             // Templated
         .redn_di                       (redn_txen));            // Templated

/*
assign idat0 =
  spare_mode ? (jtag_mode ? jtag_idat0
                          : (redn_engage ? redn_idat0 : nrml_idat0))
             : redn_engage ? redn_idat0 : jtag_idat0;

assign idat1 =
  spare_mode ? (jtag_mode ? jtag_idat1
                          : (redn_engage ? redn_idat1 : nrml_idat1))
             : redn_engage ? redn_idat1 : jtag_idat1;

assign async_data =
  spare_mode ? (jtag_mode ? jtag_async_data
                          : (redn_engage ? redn_async_data : nrml_async_data))
             : redn_engage ? redn_async_data : jtag_async_data;

assign rxen =
  spare_mode ? (jtag_mode ? jtag_rxen
                          : (redn_engage ? redn_rxen  : nrml_rxen))
             : redn_engage ? redn_rxen  : jtag_rxen;

assign txen =
  spare_mode ? (jtag_mode ? jtag_txen
                          : (redn_engage ? redn_txen  : nrml_txen))
             : redn_engage ? redn_txen  : jtag_txen;
*/
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
assign iddr_enable = redn_engage ? redn_iddr_enable : nrml_iddr_enable;
assign idat_selb   = redn_engage ? redn_idat_selb   : nrml_idat_selb;
assign ipdrv       = redn_engage ? redn_ipdrv       : nrml_ipdrv;
assign indrv       = redn_engage ? redn_indrv       : nrml_indrv;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------

// When AIB IO is a spare, the AIB IO spare outputs connect to JTAG.
//
wire redn_engage_not_spare = redn_engage & (~spare_mode);

assign rmux_odat0     = redn_engage_not_spare ? redn_odat0     : odat0;
assign rmux_odat1     = redn_engage_not_spare ? redn_odat1     : odat1;
assign rmux_odat_asyn = redn_engage_not_spare ? redn_odat_asyn : odat_asyn;
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// rmux_oclk & rmux_oclk_b are destined for JTAG BSR.
// The also could be destined for a direct output to the adapter,
// yet the architecture implements a redundancy mux outside of the IO array.
// RX "Clk Redundancy Mux"
//
itrx_aib_phy_stdcell_clk_mux
  u_oclk_mx(.din0(oclk),
            .din1(redn_oclk),
            .msel(redn_engage_not_spare),
            .dout(rmux_oclk));

itrx_aib_phy_stdcell_clk_mux
  u_oclk_b_mx(.din0(oclk_b),
              .din1(redn_oclk_b),
              .msel(redn_engage_not_spare),
              .dout(rmux_oclk_b));
//------------------------------------------------------------------------------

//lint_checking IOCOMB off
endmodule
