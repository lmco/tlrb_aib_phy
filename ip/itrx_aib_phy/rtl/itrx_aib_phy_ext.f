// Copyright 2019 © Lockheed Martin Corporation
// Filelist for itrx_aib_phy_ext hier
//
-incdir .
//-incdir /projects/lmat101/vendor_lib/aib_full_05_30/c3dfx/rtl/tap

// RTL
//
./itrx_aib_phy_ext.sv
./itrx_aib_phy_apbs.sv
./itrx_aib_phy_bit_sync.v
./itrx_aib_phy_repair_enc.sv
./itrx_aib_phy_jtag.sv
./itrx_aib_phy_bscan.v
./itrx_aib_phy_jtag_clkdr.v
./itrx_aib_phy_stdcell_icg.v
///projects/lmat101/vendor_lib/aib_full_05_30/c3dfx/rtl/tap/dbg_test_jtagsm.v
./itrx_aib_phy.sv
./itrx_aib_phy_aux_chan.sv
./itrx_aib_phy_io_chan.sv
./itrx_aib_phy_io_cell.v
./itrx_aib_phy_redn.v
./itrx_aib_phy_bsr.v
./itrx_aib_phy_clk_bc.v
./itrx_aib_phy_in_bc.v
./itrx_aib_phy_out_bc.v
./itrx_aib_phy_io_buf.v
./itrx_aib_phy_io_buf_decode.v
./itrx_aib_phy_io_buf_tx_clk.v
./itrx_aib_phy_io_buf_tx.v
./itrx_aib_phy_io_buf_rx.v
./itrx_aib_phy_io_buf_rx_dist.v
./itrx_aib_phy_stdcell_clk_mux.v
./itrx_aib_phy_stdcell_dff.v
./itrx_aib_phy_stdcell_dffn.v
./itrx_aib_phy_stdcell_lat.v
./itrx_aib_phy_stdcell_latn.v
./itrx_aib_phy_dll.v
./itrx_aib_phy_redn_3to1_mux.v
./itrx_aib_phy_atpg_bsr.v

// NOT RTL. Verilog models (views) of Analog components (IO driver/receiver & AUX level shifter)
//
///projects/lmat101/engs/bdjones/cds/deliverables/itrx_aib_phy_io_buf_ana/verilog/itrx_aib_phy_io_buf_ana.v
///projects/lmat101/vendor_lib/aib_full_05_30/aibcr3aux_lib/rtl/aibcr3aux_lvshift.v

-v ../../itrx_aib_phy_io_buf_ana/itrx_aib_phy_io_buf_ana.v
../../itrx_aib_phy/analog_verilog_models/itrx_aib_aux_lvshift.v
./dbg_test_jtagsm.v


// Delay line from sshankel/jason
//
./pdl.v
-v ./pdl_4x_delay_cell.v
