// ============================================================
// USB 2.0 SystemVerilog Assertions
// ============================================================

`include "uvm_macros.svh"
import uvm_pkg::*;
import USB2p0_pkg::*;
// ============================================================
// 1. SIGNAL LAYER
// ============================================================
module USB2p0_assertions#(parameter DATA_WIDTH = 8)(

   input logic       clk,
   input logic       reset,
   input logic       dp,
   input logic       dm,
   input logic       txvalid,
   input logic       pid_valid,
   input logic       device_pid_valid,
   input logic [7:0] pid_byte,
   input logic [7:0] device_pid_byte,
   input logic       pkt_active,
   input bit                    utmi_clk,
   input logic                  utmi_rxvalid,
   input logic                  utmi_rxvalidh,
   input logic [DATA_WIDTH-1:0] utmi_rxdata,
   input logic                  utmi_txready,
   input logic                  utmi_rxactive,
   input logic [1:0]            utmi_linestate,
   input logic                  utmisrp_bvalid,
   input logic                  utmiotg_vbusvalid,
   input logic                  utmi_txvalid,
   input logic                  utmi_txvalidh,
   input logic [DATA_WIDTH-1:0] utmi_txdata,
   input logic                  utmi_word_if,
   input logic                  utmiotg_dppulldown,
   input logic                  utmiotg_dmpulldown,
   input logic [1:0]  usb_speed,
   input logic [1:0]  transfer_type
   );


   logic token_valid;
   logic data_valid;
   logic handshake_valid;
   logic device_data_valid;
   logic device_hs_valid;
   
   logic pid_is_in;
   logic pid_is_out;
   logic pid_is_setup;

   logic       [10:0] max_pkt_size;
   
   // Decode packet type
   assign token_valid = (pid_valid && pid_byte[3:0] inside {4'hE,4'h6,4'h2});
   
   assign data_valid =  (pid_valid && pid_byte[3:0] inside {4'hC,4'h4});
   
   assign handshake_valid = (pid_valid && pid_byte[3:0] inside {4'hD,4'h5,4'h1});

   assign device_data_valid = (device_pid_valid &&  device_pid_byte[3:0] inside {4'h4});

   assign device_hs_valid = (device_pid_valid && device_pid_byte[3:0] inside {4'hD,4'h5,4'h1});
   
   // Decode specific token PID
   assign pid_is_in    = (pid_valid && pid_byte[3:0] == 4'h6);
   assign pid_is_out   = (pid_valid && pid_byte[3:0] == 4'hE);
   assign pid_is_setup = (pid_valid && pid_byte[3:0] == 4'h2);
   

   always_comb begin
   case(usb_speed)
    USB_LS:
        case(transfer_type)
           INTERRUPT_TRANSFER : max_pkt_size = 8;
        endcase

    USB_FS:
      case(transfer_type)
        CONTROL_TRANSFER      : max_pkt_size = 64;
        INTERRUPT_TRANSFER    : max_pkt_size = 64;
        BULK_TRANSFER         : max_pkt_size = 64;
        ISO_CHRONOUS_TRANSFER : max_pkt_size = 1023;
      endcase

    USB_HS:
      case(transfer_type)
        CONTROL_TRANSFER      : max_pkt_size = 64;
        BULK_TRANSFER         : max_pkt_size = 512;
        INTERRUPT_TRANSFER    : max_pkt_size = 1024;
        ISO_CHRONOUS_TRANSFER : max_pkt_size = 1024;
      endcase

  endcase

end


// ============================================================
// Differential pair never both high (except chirp) ---
// ============================================================
property usb2p0_p_dp_dm_not_both_high;
  @(posedge clk) disable iff (reset)
  not (dp === 1'b1 && dm === 1'b1);
endproperty
a_dp_dm_not_both_high: assert property (usb2p0_p_dp_dm_not_both_high)
  else
   `uvm_warning("USB_SVA","FAIL :dp_and_dm_both_high_invalid_state")


// ============================================================
//  PACKET LAYER
//  PID byte: upper nibble must be bitwise complement of lower ---
// ============================================================
property usb2p0_p_pid_check;
  @(posedge clk) disable iff (reset)
  $rose(pid_valid) |-> (pid_byte[7:4] == ~pid_byte[3:0]);
endproperty
a_pid_check: assert property (usb2p0_p_pid_check) 
  else
  `uvm_warning("USB_SVA","FAIL :PID:upper_nibble_must_be_bitwise_complement_of_lower ")


//// ============================================================
// PID value must be a defined USB 2.0 token ---
//  OUT=1E, IN=96, SETUP=D2,
// DATA0=3C, DATA1=B4,
// ACK=2D, NAK=A5, STALL=E1,
//// ============================================================
property usb2p0_p_pid_legal;
  @(posedge utmi_clk) disable iff (reset)
  $rose(pid_valid) |->
    pid_byte[3:0] inside {
      4'hE, // OUT
      4'h6, // IN
      4'h2, // SETUP
      4'hC, // DATA0
      4'h4, // DATA1
      4'hD, // ACK
      4'h5, // NAK
      4'h1 // STALL
    };
endproperty
a_pid_legal: assert property (usb2p0_p_pid_legal)
  else
  `uvm_warning("USB_SVA","FAIL :PID:UNDEFINED_PID_VALUEr ")


//=============================================================
// USB_FS == CONTROL_TRANSFER
//=============================================================
property p_data_maxpkt_hs;
  @(posedge utmi_clk) disable iff (reset)
  ((usb_speed == USB_FS && transfer_type == CONTROL_TRANSFER) |-> (max_pkt_size <= 64));
endproperty
a_data_maxpkt_hs: assert property (p_data_maxpkt_hs)begin
  `uvm_info("DATA","HS_PASS_packet_within_64_byteS","UVM_LOW");
  end 
  else 
  `uvm_warning("DATA"," HS_packet_exceeds_64_byte_max_payload");

//=============================================================
// USB_FS == INTERRRUPT_TRANSFER
//=============================================================
property p_data_maxpkt_fs;
 @(posedge utmi_clk) disable iff(reset)
  ((usb_speed==USB_FS && transfer_type==INTERRUPT_TRANSFER) -> (max_pkt_size <= 64));
endproperty
  a_data_maxpkt_fs: assert property (p_data_maxpkt_fs)begin
  `uvm_info("DATA","FS_PASS_packet_within_64_byteS","UVM_LOW");
  end 
  else 
 `uvm_warning("DATA:","FS_packet_exceeds_64_byte_max_payload");


//// ============================================================
////  Inter-packet delay: min 2 bit times between packets ---
//// ============================================================
property usb2p0_p_inter_packet_gap;
  @(posedge clk) disable iff (reset)
  $fell(pkt_active) |-> ##[10:$] $rose(pkt_active);  endproperty
a_inter_packet_gap: assert property (usb2p0_p_inter_packet_gap)
  else $warning("IPG: next_packet_started_before_2-bit_gap_elapsed");


//// ============================================================
////  TRANSACTION LAYER
///   IN transaction: Token → DATA → ACK/NAK/STALL ---
//// ============================================================
property usb2p0_p_in_transaction_order;
  @(posedge utmi_clk) disable iff (reset)
    (pid_valid && pid_byte[3:0] == 4'h6) |->
    ##[1:128] (device_pid_valid && device_pid_byte[3:0] == 4'h4)
    ##[1:128] (pid_valid && pid_byte[3:0] == 4'hd);
endproperty
   a_in_transaction_order: assert property (usb2p0_p_in_transaction_order)
  else 
  `uvm_warning("Transaction"," IN_token_not_followed_by_DATA_then_handshake");


//=============================================================
// OUT TXN: TOKEN-DATA1-ACK
//=============================================================
property usb2p0_p_out_transaction_order;
  @(posedge utmi_clk) disable iff (reset)
    $rose(txvalid && pid_byte[3:0]==4'he) |->
    ##[1:256] (pid_valid && pid_byte[3:0]==4'h4)
    ##[1:256] (device_pid_valid && device_pid_byte[3:0]==4'hd);
endproperty
a_out_transaction_order: assert property (usb2p0_p_out_transaction_order)
  else 
  `uvm_warning("Transaction"," OUT_token_not_followed_by_DATA_then_handshake");


//=============================================================
// SETUP TXN: TOKEN-DATA0-ACK
//=============================================================
property usb2p0_p_setup_uses_data0;
  @(posedge utmi_clk) disable iff (reset)
    $rose(txvalid && pid_byte[3:0] == 4'h2) |->
    ##[1:256] (data_valid || pid_byte[3:0] == 4'hc)  // DATA0
    ##[1:256] (device_pid_valid && device_pid_byte[3:0]==4'hd);
endproperty
a_setup_uses_data0: assert property (usb2p0_p_setup_uses_data0)
  else 
  `uvm_warning("Transaction_fail","SETUP_not_followed_by_DATA0");



//=============================================================
// HANDSHAKE NEVER DIRECTLY AFTER TOKEN
//=============================================================
property usb2p0_p_no_handshake_after_token_direct;
  @(posedge clk) disable iff (reset)
  $rose(token_valid) |-> !handshake_valid[*1:5];
endproperty
a_no_handshake_after_token_direct: assert property (usb2p0_p_no_handshake_after_token_direct)
  else 
  `uvm_warning("Transaction_fail","handshake_appeared_immediately_after_token_data_stage_skipped");


//=============================================================
// RXVALID_WITH_RXACTIVE
//=============================================================
property usb2p0_p_rxvalid_with_rxactive;
   @(posedge utmi_clk)
   utmi_rxvalid |-> utmi_rxactive;
endproperty
a_rxvalid_with_rxactive:assert property(usb2p0_p_rxvalid_with_rxactive)
else 
   `uvm_warning("USB2P0_ASSERTION","ASSERTION_FAIL_FOR_RXVALID_WITH_RXACTIVE")


//=============================================================
// TXVALID_TXREADY_HANDSHAKE
//=============================================================
property usb2p0_p_txvalid_txready_handshake;
   @(posedge utmi_clk)
   utmi_txvalid |-> ##[0:5] utmi_txready;
endproperty
a_txvalid_txready_handshake:assert property(usb2p0_p_txvalid_txready_handshake)
else 
`uvm_warning("USB2P0_ASSERTION","ASSERTION_FAIL_FOR_TXVALID_TXREADY_HANDSHAKE")


//=============================================================
// TXDATA_NOT_UNKNOWN
//=============================================================
property usb2p0_p_txdata_not_unknown;
   @(posedge utmi_clk)
   utmi_txvalid |-> (!$isunknown(utmi_txdata));
endproperty
a_txdata_not_unknown:assert property(usb2p0_p_txdata_not_unknown)
else 
   `uvm_warning("USB2P0_ASSERTION","ASSERTION_FAIL_FOR_TXDATA_UNKNOWN")


//=============================================================
// RXDATA_NOT_UNKNOWN
//=============================================================
property usb2p0_p_rxdata_not_unknown;
   @(posedge utmi_clk)
   utmi_rxvalid |-> (!$isunknown(utmi_rxdata));
endproperty
a_rxdata_not_unknown:assert property(usb2p0_p_rxdata_not_unknown)
else 
`uvm_warning("USB2P0_ASSERTION","ASSERTION_FAIL_FOR_RXDATA_UNKNOWN")


//=============================================================
// !TXVALIDH and !RXVALID and WORDIF IS ZERO
//=============================================================
property usb2p0_p_ls_fs_mode_check;
@(posedge utmi_clk)
    (!utmi_txvalidh && !utmi_rxvalidh && utmi_txvalid && utmi_rxvalid) |-> (utmi_word_if == 1'b0);
endproperty
a_ls_fs_mode_check:assert property(usb2p0_p_ls_fs_mode_check)begin
`uvm_info("USB2P0_ASSERTION","ASSERTION_PASS_FOR_RXVALIDH_TXVALIDH_WORDIF=0",UVM_LOW)
end
else 
`uvm_warning("USB2P0_ASSERTION","ASSERTION_FAIL_FOR_RXVALIDH_TXVALIDH_WORDIF_0")

//=============================================================
// TXVALIDH and RXVALID and WORDIF IS ONE
//=============================================================
property usb2p0_p_hs_mode_check;
    @(posedge utmi_clk)
    (utmi_txvalidh || utmi_rxvalidh) |-> (utmi_word_if == 1'b1);
endproperty
a_hs_mode_check:assert property(usb2p0_p_hs_mode_check)begin
`uvm_info("USB2P0_ASSERTION","ASSERTION_PASS_FOR_RXVALIDH_TXVALIDH_WORDIF_1",UVM_LOW)
end
else 
`uvm_warning("USB2P0_ASSERTION","ASSERTION_FAIL_FOR_RXVALIDH_TXVALIDH_WORDIF_1")


//=============================================================
// LINESTATE_KNOWN
// CHECK ONLY AFTER 9000ns
//=============================================================
property usb2p0_p_linestate_known;
   @(posedge utmi_clk)
   $rose(utmiotg_vbusvalid) |-> ##[1:10] (!$isunknown(utmi_linestate));
endproperty
a_linestate_known:assert property(usb2p0_p_linestate_known)
else 
   `uvm_warning("USB2P0_ASSERTION", "ASSERTION_FAIL_FOR_LINESTATE_UNKNOWN")


//=============================================================
// VBUS_VALID
// CHECK ONLY AFTER 9000ns
//=============================================================
property usb2p0_p_vbus_valid;
   @(posedge utmi_clk)
   disable iff(reset)
   $rose(utmiotg_vbusvalid) |-> ##[1:10] utmisrp_bvalid;
endproperty
a_vbus_valid:assert property(usb2p0_p_vbus_valid)
else 
   `uvm_warning("USB2P0_ASSERTION","ASSERTION_FAIL_FOR_VBUS_VALID")
// ============================================================
// END OF USB 2.0 SVA MODULE
// ============================================================

endmodule





















// ============================================================
//  NRZI: no consecutive identical bits without stuff ---
// ============================================================
//sequence s_dp_dm_7;
//   (dp == 1'b1 && dm == 1'b0) [*7];
//endsequence
//
//property p_nrzi_no_run_of_7;
//   @(posedge clk)
//   disable iff(reset)
//   txvalid |-> not s_dp_dm_7;
//endproperty
//
//a_nrzi_no_run_of_7:
//assert property(p_nrzi_no_run_of_7)
//else
//   `uvm_error("USB_SVA","FAIL : NRZI:7_consecutive_1s_bit_stuffing_violation")

