// Copyright 2019 © Lockheed Martin Corporation

module sr (

// The osc_clk input is from the AUX and used by the MASTER.
// The sr_ms_clk_in is from the SR input clock to the SLAVE and
// is used by the Slave.
// See "Figure 30. Sideband Control Shift Registers"


// The AIB SR bus serially transfers 81 bit registers MS-to-SL, and 73 bits SL-to-MS.
// Only 14 Bits are defined "for use", and are info exchanged between SMs.
//

//-----------------------------------------------------------------------------\
// MS-to-SL OSC CLock Calibration State Machines (msosc / slosc)
//

output      ms_osc_transfer_en,     // ms2sl ms OSC Clock SM (to sl via AIB SR)
output      sl_osc_transfer_en,     // ms2sl sl OSC Clock SM (to ms via AIB SR)
output      ms_osc_transfer_alive,  // ms2sl ms OSC Clock SM (to sl via AIB SR)

input       ms_osc_transfer_eni,    // Slave  side
input       sl_osc_transfer_eni,    // Master side
//-----------------------------------------------------------------------------/


//-----------------------------------------------------------------------------\
// MS-to-SL Data Path State Machines (mstxcal m>->s, m<-<s, <-<, >-> slrxcal)
//
input       ms_tx_dcc_dll_lock_req;  // Request from MS to start CAL. Remains 1.
input       sl_rx_dcc_dll_lock_req;  // Request from SL to start CAL. Remains 1. (remote MAC).

output      ms_tx_dcc_cal_done,      // ms2sl ms data path SM (to sl via AIB SR)
output      sl_rx_dll_lock,          // ms2sl sl data path SM (to ms via AIB SR)
output      sl_rx_transfer_en,       // ms2sl sl data path SM (to ms via AIB SR)
output      ms_tx_transfer_en,       // ms2sl ms data path SM (to sl via AIB SR)

input       sl_rx_transfer_eni,      // Master side
input       ms_tx_transfer_eni,      // Slave  side
//-----------------------------------------------------------------------------/


//-----------------------------------------------------------------------------\
// SL-to-MS Data Path State_Machines (msrxcal/sltxcal)
//
input       sl_tx_dcc_dll_lock_req;  // Request from SL to start CAL. Remains 1.
input       ms_rx_dcc_dll_lock_req;  // Request from SL to start CAL. Remains 1. (remote MAC).

output      sl_tx_dcc_cal_done,      // sl2ms sl data path SM (to ms via AIB SR)
output      ms_rx_dll_lock,          // sl2ms ms data path SM (to sl via AIB SR)
output      ms_rx_transfer_en,       // sl2ms ms data path SM (to sl via AIB SR)
output      sl_tx_transfer_en,       // sl2ms sl data path SM (to ms via AIB SR)

input       ms_rx_transfer_eni,      // Slave  side
//-----------------------------------------------------------------------------/


//-----------------------------------------------------------------------------\
// WHAT do these RESET OUTPUTS DO? NOTHING!
// They are unconnected in aib_channel.v which instantiates the aib_sm module.
// In the AIB Architecture Spec (AS) these resets are high from the
// initial state until LOCK? Odd discrepancy!
//
output      ms_rx_async_rst,         // high if NOT INTITAL state
output      ms_tx_async_rst,         // high if NOT INTITAL state
output      sl_rx_async_rst,         // high if NOT INTITAL state
output      sl_fifo_tx_async_rst,    // high if NOT INTITAL state
//-----------------------------------------------------------------------------/

//
output                  ms_rx_dll_lock_req,
output                  ms_tx_dcc_cal_req,

output                  sl_rx_dll_lock_req,
output                  sl_tx_dcc_cal_req,

);


/*AUTOWIRE*/

/*AUTOREGINPUT*/
// Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
reg                     atpg_mode;              // To u_aib_sm of aib_sm.v
reg                     ms_config_done;         // To u_aib_sm of aib_sm.v
reg                     ms_nsl;                 // To u_aib_sm of aib_sm.v
reg                     ms_rx_dll_locki;        // To u_aib_sm of aib_sm.v
reg                     ms_rx_dll_lockint;      // To u_aib_sm of aib_sm.v
reg                     ms_tx_dcc_cal_donei;    // To u_aib_sm of aib_sm.v
reg                     ms_tx_dcc_cal_doneint;  // To u_aib_sm of aib_sm.v
reg                     osc_clk;                // To u_aib_sm of aib_sm.v
reg                     reset_n;                // To u_aib_sm of aib_sm.v
reg                     sl_config_done;         // To u_aib_sm of aib_sm.v
reg                     sl_rx_dll_locki;        // To u_aib_sm of aib_sm.v
reg                     sl_rx_dll_lockint;      // To u_aib_sm of aib_sm.v
reg                     sl_tx_dcc_cal_donei;    // To u_aib_sm of aib_sm.v
reg                     sl_tx_dcc_cal_doneint;  // To u_aib_sm of aib_sm.v
reg                     sr_ms_clk_in;           // To u_aib_sm of aib_sm.v
// End of automatics


aib_sm u_aib_sm(/*AUTOINST*/
                // Outputs
                .ms_osc_transfer_en     (ms_osc_transfer_en),
                .ms_rx_transfer_en      (ms_rx_transfer_en),
                .ms_osc_transfer_alive  (ms_osc_transfer_alive),
                .ms_rx_async_rst        (ms_rx_async_rst),
                .ms_rx_dll_lock_req     (ms_rx_dll_lock_req),
                .ms_rx_dll_lock         (ms_rx_dll_lock),
                .ms_tx_async_rst        (ms_tx_async_rst),
                .ms_tx_dcc_cal_req      (ms_tx_dcc_cal_req),
                .ms_tx_dcc_cal_done     (ms_tx_dcc_cal_done),
                .ms_tx_transfer_en      (ms_tx_transfer_en),
                .sl_osc_transfer_en     (sl_osc_transfer_en),
                .sl_rx_transfer_en      (sl_rx_transfer_en),
                .sl_fifo_tx_async_rst   (sl_fifo_tx_async_rst),
                .sl_tx_dcc_cal_req      (sl_tx_dcc_cal_req),
                .sl_tx_dcc_cal_done     (sl_tx_dcc_cal_done),
                .sl_tx_transfer_en      (sl_tx_transfer_en),
                .sl_rx_async_rst        (sl_rx_async_rst),
                .sl_rx_dll_lock_req     (sl_rx_dll_lock_req),
                .sl_rx_dll_lock         (sl_rx_dll_lock),
                // Inputs
                .osc_clk                (osc_clk),
                .sr_ms_clk_in           (sr_ms_clk_in),
                .ms_config_done         (ms_config_done),
                .ms_rx_dcc_dll_lock_req (ms_rx_dcc_dll_lock_req),
                .ms_tx_dcc_dll_lock_req (ms_tx_dcc_dll_lock_req),
                .ms_rx_dll_lockint      (ms_rx_dll_lockint),
                .ms_tx_dcc_cal_doneint  (ms_tx_dcc_cal_doneint),
                .ms_tx_dcc_cal_donei    (ms_tx_dcc_cal_donei),
                .ms_rx_dll_locki        (ms_rx_dll_locki),
                .ms_rx_transfer_eni     (ms_rx_transfer_eni),
                .ms_tx_transfer_eni     (ms_tx_transfer_eni),
                .ms_osc_transfer_eni    (ms_osc_transfer_eni),
                .sl_config_done         (sl_config_done),
                .sl_tx_dcc_dll_lock_req (sl_tx_dcc_dll_lock_req),
                .sl_rx_dcc_dll_lock_req (sl_rx_dcc_dll_lock_req),
                .sl_rx_dll_lockint      (sl_rx_dll_lockint),
                .sl_rx_dll_locki        (sl_rx_dll_locki),
                .sl_tx_dcc_cal_donei    (sl_tx_dcc_cal_donei),
                .sl_tx_dcc_cal_doneint  (sl_tx_dcc_cal_doneint),
                .sl_rx_transfer_eni     (sl_rx_transfer_eni),
                .sl_osc_transfer_eni    (sl_osc_transfer_eni),
                .ms_nsl                 (ms_nsl),
                .atpg_mode              (atpg_mode),
                .reset_n                (reset_n));


endmodule
