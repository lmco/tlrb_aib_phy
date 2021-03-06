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
// Filename       : itrx_aib_phy_consts.vh
// Description    : AIB Architectual Constants
//
// ==========================================================================
//
//    $Rev:: 5038                      $: Revision of last commit
// $Author:: Intrinsix Corp.           $: Author of last commit
//   $Date:: 2018-05-04 12:42:03 -0400#$: Date of last commit
//
// ==========================================================================
// Constants associated with the AIB Architecture
//
//localparam       SPARES_PCH = 32'd2; // # of spares per channel

localparam [2:0] RXEN_DDR = 3'b001;  // RX DDR input
localparam [2:0] RXEN_SDR = 3'b100;  // RX SDR input
localparam [2:0] RXEN_NRX = 3'b010;  // Not RX. RX Disabled
localparam [2:0] RXEN_ASI = 3'b000;  // RX Async Input
localparam [2:0] RXEN_CKI = 3'b011;  // RX Clock Input
