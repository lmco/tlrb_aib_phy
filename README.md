[1]: https://www.intel.com/content/www/us/en/architecture-and-technology/programmable/heterogeneous-integration/overview.html
[2]: https://github.com/intel/aib-phy-hardware

# tlrb_aib_phy

This project implements the Register-Transfer Level (RTL) digital design for a TSMC 16FFC Long Reach Base (TLRB)
Advanced Interface Bus (AIB) PHY developed by Intrinsix Corporation and is compliant with the AIB Specification v1.0.
The TLRB AIB PHY digital logic supports the following:

* an AIB Base configuration
  * Configurable for either DDR mode or SDR mode synchronous data
  * Redundancy scheme
  * JTAG boundary scan
  * No OSC clock
  * No serial shift register (SR)
  * No DLL or DCC
    * A placeholder manual mode DLL block is internally bypassed to implement a fixed ~500 ps delay for SDR mode
    * DDR mode (up to 400 MHz) requires a ~625 ps delay
  * No AIB Adapter logic
  * Superset option for Master/Slave
* 1 AIB IO channel
  * Total of 90 AIB IO cells (associated with 90 ubumps) partitioned (without Adapter logic) as follows:
    * 80 synchronous data (40 TX and 40 RX)
      * Designed to also support fewer connected microbumps (e.g. 40 data with 20 TX and 20 RX)
    * 4 clock (2 TX and 2 RX for differential ended clocks)
    * 4 reset
    * 2 spare (active redundancy support per channel)
* 1 AIB AUX channel
  * 4 ubumps for POR and device detect (using passive redundancy)
    * Only 2 AIB IO cells due to a passive redundancy scheme using “double microbumps”
  * No JTAG controller (assuming a TAP controller implementing AIB JTAG instructions exists elsewhere in the chiplet).
  * No OSC clock oscillator
  * No non-volatile memory for storing Redundancy repair information is implemented within the TLRB AIB PHY AUX channel.
* Interfaces
  * An 80-bit synchronous TX/RX data interface suitable for simple adaptation to CPI (Chiplet Protocol Interface).
  According to the AIB Architecture specification, the minimum synchronous data width supported by any AIB channel is 40
  ubumps. The synchronous data interface is 80 bits wide in each direction (TX/RX) when the AIB is in DDR mode. The
  synchronous interface in SDR mode uses only the low 40-bits of the interface.
  * AIB IO cell configuration interface
    * No configuration programming controller logic nor any configuration RAM is implemented within the AIB PHY
  * Active Redundancy engage interface (input signal per pair of AIB IO cells)
  * Reset and config_done interface
    * Observe config_done (package level C4 signal) to hold AIB block in standby
  * JTAG DFT interface to a TAP controller implemented outside of the AIB PHY
* Target a maximum of 1 GHz AIB synchronous data clocking (SDR), and 400 MHz DDR.
  * These targets are the maximums allowed for an AIB Base configuration without a DLL
  * Timing closure may limit the specified maximums actually realized
* Expected AIB synchronous data clocking is about ~250 MHz. This is one of the frequency points used for application
bandwidth and latency performance calculations.

More information on the AIB and its specification can be found on Intel's website [here][1].

## Cloning

Since this repository uses git submodules, it's recommended to use the --recurse-submodules flag when cloning:
```
git clone --recurse-submodules https://github.com/lmco/tlrb_aib_phy.git
```

Otherwise the submodules can be pulled in to an already cloned repository by running the following git command:
```
git submodule update --init
```

## Dependencies

* [aib-phy-hardware][2]

## Directory Structure

```
.
|   LICENSE                                             # License file
|   README.md                                           # This file
|       
+---doc                                                 # Documentation
|       ITRX_TRLB_AIB_PHY_Specification_0-8.pdf         # Intrinsix's TLRB AIB PHY Specification v0.8
|       
+---lib                                                 # Submodules
|   \---aib-phy-hardware
|               
\---rtl                                                 # Source files for TLRB AIB PHY
    |   tlrb_aib_phy_ext.sv
    |   
    +---itrx_aib_phy
    |       itrx_aib_phy.sv
    |       itrx_aib_phy_apbs.sv
    |       itrx_aib_phy_aux_chan.sv
    |       itrx_aib_phy_bit_sync.v
    |       itrx_aib_phy_bscan.v
    |       itrx_aib_phy_bsr.v
    |       itrx_aib_phy_clk_bc.v
    |       itrx_aib_phy_consts.vh
    |       itrx_aib_phy_dll.v
    |       itrx_aib_phy_ext.sv
    |       itrx_aib_phy_in_bc.v
    |       itrx_aib_phy_io_buf.v
    |       itrx_aib_phy_io_buf_decode.v
    |       itrx_aib_phy_io_buf_rx.v
    |       itrx_aib_phy_io_buf_rx_dist.v
    |       itrx_aib_phy_io_buf_tx.v
    |       itrx_aib_phy_io_buf_tx_clk.v
    |       itrx_aib_phy_io_cell.v
    |       itrx_aib_phy_io_chan.sv
    |       itrx_aib_phy_io_chan_param2.vh
    |       itrx_aib_phy_jtag.sv
    |       itrx_aib_phy_jtag_clkdr.v
    |       itrx_aib_phy_out_bc.v
    |       itrx_aib_phy_redn.v
    |       itrx_aib_phy_redn_3to1_mux.v
    |       itrx_aib_phy_repair_enc.sv
    |       itrx_aib_phy_stdcell_clk_mux.v
    |       itrx_aib_phy_stdcell_dff.v
    |       itrx_aib_phy_stdcell_dffn.v
    |       itrx_aib_phy_stdcell_icg.v
    |       itrx_aib_phy_stdcell_lat.v
    |       itrx_aib_phy_stdcell_latn.v
    |       itrx_aib_phy_sync_rstn.v
    |       pdl.v
    |       
    \---itrx_aib_phy_io_buf_ana
            itrx_aib_phy_io_buf_ana.v

```

## Authors

* Lockheed Martin Corporation
* Intrinsix Corporation

## License

This project is licensed under the Apache 2.0 License - see the LICENSE file for more details

## Distribution Statement

DISTRIBUTION STATEMENT A. Approved for public release.

The views, opinions and/or findings expressed are those of the author and should not be interpreted as representing the
official views or policies of the Department of Defense or the U.S. Government.
