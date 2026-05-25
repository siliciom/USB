// ============================================================
// USB 2.0 SystemVerilog Assertions
// Covers: signal, packet, transaction, SOF, bus state layers
// Clock: 60 MHz (FS = 12 Mbps -> 5 clocks/bit)
// ============================================================

`define USB_CLK_PER   16.67  // ns, 60 MHz
`define BITS_PER_CLK  5      // FS: 60 MHz / 12 MHz

// ============================================================
// 1. SIGNAL LAYER
// ============================================================

// --- 1.1 NRZI: no consecutive identical bits without stuff ---
property p_nrzi_no_run_of_7;
  @(posedge clk) disable iff (reset)
  // 7 consecutive 1s is illegal without a stuff bit
  !(dp === 1'b1 && dm === 1'b0)[*7];
endproperty
a_nrzi_no_run_of_7: assert property (p_nrzi_no_run_of_7)
  else $error("NRZI: 7 consecutive 1s – bit stuffing violation");

// --- 1.2 Differential pair never both high (except chirp) ---
property p_dp_dm_not_both_high;
  @(posedge clk) disable iff (reset)
  not (dp === 1'b1 && dm === 1'b1);
endproperty
a_dp_dm_not_both_high: assert property (p_dp_dm_not_both_high)
  else $error("Signal: dp and dm both high – invalid state");

// --- 1.3 SE0 (both low) must be released within EOP window ---
// SE0 for exactly 2 bit-times then J
property p_se0_eop_width;
  @(posedge clk) disable iff (reset)
  (dp === 1'b0 && dm === 1'b0)  // SE0 starts
  |-> ##[1:3] (dp === 1'b1 && dm === 1'b0);  // must return to J
endproperty
a_se0_eop_width: assert property (p_se0_eop_width)
  else $error("EOP: SE0 not followed by J state within 3 bits");

// --- 1.4 Sync pattern: KJKJKJKK (8 bits) ---
// Represented as alternating level then two same = KK
property p_sync_pattern;
  @(posedge clk) disable iff (reset)
  $rose(pkt_start) |->
    // K J K J K J K K (K=10, J=01 in dp:dm)
    (usb_state == K)[*1] ##1 (usb_state == J)[*1]
    ##1 (usb_state == K)[*1] ##1 (usb_state == J)[*1]
    ##1 (usb_state == K)[*1] ##1 (usb_state == J)[*1]
    ##1 (usb_state == K)[*2];
endproperty
a_sync_pattern: assert property (p_sync_pattern)
  else $error("Sync field: incorrect KJKJKJKK pattern");

// ============================================================
// 2. PACKET LAYER
// ============================================================

// --- 2.1 PID byte: upper nibble must be bitwise complement of lower ---
property p_pid_check;
  @(posedge clk) disable iff (reset)
  $rose(pid_valid) |->
    (pid_byte[7:4] == ~pid_byte[3:0]);
endproperty
a_pid_check: assert property (p_pid_check)
  else $error("PID: upper nibble not complement of lower nibble");

// --- 2.2 PID value must be a defined USB 2.0 token ---
// SOF=A5, OUT=E1, IN=69, SETUP=2D,
// DATA0=C3, DATA1=4B, DATA2=87, MDATA=0F,
// ACK=D2, NAK=5A, STALL=1E, NYET=96,
// PRE=3C, ERR=3C, SPLIT=78, PING=B4
property p_pid_legal;
  @(posedge clk) disable iff (reset)
  $rose(pid_valid) |->
    pid_byte[3:0] inside {
      4'h5, // SOF
      4'h1, // OUT
      4'h9, // IN
      4'hD, // SETUP
      4'h3, // DATA0
      4'hB, // DATA1
      4'h7, // DATA2
      4'hF, // MDATA
      4'h2, // ACK
      4'hA, // NAK
      4'hE, // STALL
      4'h6, // NYET
      4'hC, // PRE/ERR
      4'h8, // SPLIT
      4'h4  // PING
    };
endproperty
a_pid_legal: assert property (p_pid_legal)
  else $error("PID: undefined PID value received");

// --- 2.3 Token packet: ADDR field must not be 0x7F (reserved) ---
property p_addr_not_reserved;
  @(posedge clk) disable iff (reset)
  (token_valid && !sof_pkt) |->
    token_addr != 7'h7F;
endproperty
a_addr_not_reserved: assert property (p_addr_not_reserved)
  else $error("Token: ADDR=0x7F is reserved");

// --- 2.4 CRC5 on token packets ---
property p_crc5_token;
  @(posedge clk) disable iff (reset)
  $fell(token_valid) |->  // check at end of token packet
    token_crc5 == compute_crc5({token_endp, token_addr});
endproperty
a_crc5_token: assert property (p_crc5_token)
  else $error("CRC5: token packet CRC5 mismatch");

// --- 2.5 CRC16 on data packets ---
property p_crc16_data;
  @(posedge clk) disable iff (reset)
  $fell(data_valid) |->
    data_crc16 == compute_crc16(data_payload);
endproperty
a_crc16_data: assert property (p_crc16_data)
  else $error("CRC16: data packet CRC16 mismatch");

// --- 2.6 DATA packet max payload: 64 bytes FS, 8 bytes LS ---
property p_data_maxpkt_fs;
  @(posedge clk) disable iff (reset)
  (data_valid && speed == FS) |->
    data_byte_count <= 64;
endproperty
a_data_maxpkt_fs: assert property (p_data_maxpkt_fs)
  else $error("DATA: FS packet exceeds 64 byte max payload");

property p_data_maxpkt_ls;
  @(posedge clk) disable iff (reset)
  (data_valid && speed == LS) |->
    data_byte_count <= 8;
endproperty
a_data_maxpkt_ls: assert property (p_data_maxpkt_ls)
  else $error("DATA: LS packet exceeds 8 byte max payload");

// --- 2.7 Inter-packet delay: min 2 bit times between packets ---
// At 60 MHz FS = 10 clocks
property p_inter_packet_gap;
  @(posedge clk) disable iff (reset)
  $fell(pkt_active) |->
    ##[10:$] $rose(pkt_active);  // at least 2 bit-times idle
endproperty
// Note: used as a cover or weak check, converted to a minimum delay
a_inter_packet_gap: assert property (p_inter_packet_gap)
  else $warning("IPG: next packet started before 2-bit gap elapsed");

// ============================================================
// 3. TRANSACTION LAYER
// ============================================================

// --- 3.1 IN transaction: Token → DATA → ACK/NAK/STALL ---
property p_in_transaction_order;
  @(posedge clk) disable iff (reset)
  (token_valid && pid_is_in) |->
    ##[1:32] data_valid
    ##[1:32] handshake_valid;
endproperty
a_in_transaction_order: assert property (p_in_transaction_order)
  else $error("Transaction: IN token not followed by DATA then handshake");

// --- 3.2 OUT transaction: Token → DATA → ACK/NAK/STALL ---
property p_out_transaction_order;
  @(posedge clk) disable iff (reset)
  (token_valid && pid_is_out) |->
    ##[1:32] data_valid
    ##[1:32] handshake_valid;
endproperty
a_out_transaction_order: assert property (p_out_transaction_order)
  else $error("Transaction: OUT token not followed by DATA then handshake");

// --- 3.3 SETUP transaction: Token → DATA0 (8 bytes) → ACK ---
property p_setup_uses_data0;
  @(posedge clk) disable iff (reset)
  (token_valid && pid_is_setup) |->
    ##[1:32] (data_valid && pid_byte[3:0] == 4'h3);  // DATA0
endproperty
a_setup_uses_data0: assert property (p_setup_uses_data0)
  else $error("Transaction: SETUP not followed by DATA0");

property p_setup_data_length;
  @(posedge clk) disable iff (reset)
  (token_valid && pid_is_setup) ##[1:32] data_valid |->
    data_byte_count == 8;
endproperty
a_setup_data_length: assert property (p_setup_data_length)
  else $error("Transaction: SETUP data stage must be exactly 8 bytes");

// --- 3.4 No data packet without preceding token ---
property p_data_needs_token;
  @(posedge clk) disable iff (reset)
  $rose(data_valid) |->
    $past(token_valid, 1, 32);  // token seen within 32 cycles before
endproperty
a_data_needs_token: assert property (p_data_needs_token)
  else $error("Transaction: data packet with no preceding token");

// --- 3.5 Handshake never directly after token (no data stage skip for OUT) ---
property p_no_handshake_after_token_direct;
  @(posedge clk) disable iff (reset)
  $rose(token_valid) |->
    !handshake_valid[*1:5];
endproperty
a_no_handshake_after_token_direct: assert property (p_no_handshake_after_token_direct)
  else $error("Transaction: handshake appeared immediately after token – data stage skipped");

// --- 3.6 DATA toggle: DATA0 and DATA1 must alternate in bulk/interrupt ---
property p_data_toggle_alternates;
  @(posedge clk) disable iff (reset)
  (data_valid && bulk_or_intr) |->
    ##[1:$] (data_valid |-> (data_pid != $past(data_pid)));
endproperty
a_data_toggle: assert property (p_data_toggle_alternates)
  else $error("Transaction: DATA0/DATA1 toggle violation");

// --- 3.7 STALL: no further data after STALL until cleared by SETUP ---
property p_no_data_after_stall;
  @(posedge clk) disable iff (reset)
  (handshake_valid && pid_is_stall) |->
    not data_valid[->1] ##0 !setup_seen;
endproperty
a_no_data_after_stall: assert property (p_no_data_after_stall)
  else $error("Transaction: data received on stalled endpoint before SETUP clear");

// ============================================================
// 4. SOF AND FRAME TIMING
// ============================================================

// --- 4.1 SOF arrives every 1 ms ± 500 ns  ---
// At 60 MHz: 60,000 clocks per ms, tolerance = 30 clocks
localparam SOF_MIN = 59970;
localparam SOF_MAX = 60030;

property p_sof_interval;
  @(posedge clk) disable iff (reset)
  $rose(sof_valid) |->
    ##[SOF_MIN:SOF_MAX] $rose(sof_valid);
endproperty
a_sof_interval: assert property (p_sof_interval)
  else $error("SOF: frame interval out of 1 ms ± 500 ns window");

// --- 4.2 SOF frame number increments by 1 (wraps at 0x7FF) ---
property p_sof_frame_number;
  @(posedge clk) disable iff (reset)
  $rose(sof_valid) && (sof_frame_num != 11'h7FF) |->
    ##[SOF_MIN:SOF_MAX]
    (sof_valid && sof_frame_num == ($past(sof_frame_num) + 1));
endproperty
a_sof_frame_number: assert property (p_sof_frame_number)
  else $error("SOF: frame number did not increment correctly");

// --- 4.3 SOF frame number wraps 0x7FF -> 0x000 ---
property p_sof_frame_wrap;
  @(posedge clk) disable iff (reset)
  (sof_valid && sof_frame_num == 11'h7FF) |->
    ##[SOF_MIN:SOF_MAX]
    (sof_valid && sof_frame_num == 11'h000);
endproperty
a_sof_frame_wrap: assert property (p_sof_frame_wrap)
  else $error("SOF: frame number did not wrap 0x7FF -> 0x000");

// --- 4.4 Token timeout: device must respond within 16 bit-times (FS) ---
// 16 bits * 5 clocks/bit = 80 clocks
property p_token_response_timeout;
  @(posedge clk) disable iff (reset)
  $fell(token_valid) |->
    ##[1:80] (data_valid || handshake_valid || timeout_ack);
endproperty
a_token_response_timeout: assert property (p_token_response_timeout)
  else $error("Timeout: device did not respond within 16 bit-times of token");

// ============================================================
// 5. BUS STATE AND POWER
// ============================================================

// --- 5.1 Reset: SE0 ≥ 2.5 µs = 150 clocks at 60 MHz ---
localparam RESET_MIN_CLK = 150;

property p_reset_min_se0;
  @(posedge clk)
  $rose(se0_detect) |->
    se0_detect[*RESET_MIN_CLK];
endproperty
a_reset_min_se0: assert property (p_reset_min_se0)
  else $warning("Reset: SE0 asserted for less than 2.5 µs minimum");

// --- 5.2 Suspend: idle ≥ 3 ms = 180,000 clocks ---
localparam SUSPEND_MIN_CLK = 180000;

property p_suspend_detect;
  @(posedge clk) disable iff (reset)
  $rose(bus_idle) |->
    bus_idle[*SUSPEND_MIN_CLK] |-> $rose(suspend_state);
endproperty
a_suspend_detect: assert property (p_suspend_detect)
  else $error("Suspend: 3 ms idle not flagging suspend state");

// --- 5.3 Resume: K-state must be held ≥ 20 ms ---
localparam RESUME_K_MIN = 1200000; // 20ms at 60 MHz

property p_resume_k_width;
  @(posedge clk) disable iff (!suspend_state)
  $rose(resume_k) |->
    resume_k[*RESUME_K_MIN];
endproperty
a_resume_k_width: assert property (p_resume_k_width)
  else $error("Resume: K-state held for less than 20 ms");

// --- 5.4 No transactions during suspend ---
property p_no_txn_during_suspend;
  @(posedge clk)
  suspend_state |-> !(token_valid || data_valid || handshake_valid);
endproperty
a_no_txn_during_suspend: assert property (p_no_txn_during_suspend)
  else $error("Suspend: transaction detected while bus is suspended");

// ============================================================
// 6. COVER PROPERTIES (functional coverage goals)
// ============================================================

cv_in_ack:   cover property (@(posedge clk) pid_is_in  ##[1:50] pid_is_ack);
cv_out_ack:  cover property (@(posedge clk) pid_is_out ##[1:50] pid_is_ack);
cv_setup_ack:cover property (@(posedge clk) pid_is_setup ##[1:50] pid_is_ack);
cv_nak:      cover property (@(posedge clk) pid_is_nak);
cv_stall:    cover property (@(posedge clk) pid_is_stall);
cv_data0:    cover property (@(posedge clk) data_valid && pid_byte[3:0] == 4'h3);
cv_data1:    cover property (@(posedge clk) data_valid && pid_byte[3:0] == 4'hB);
cv_sof:      cover property (@(posedge clk) sof_valid);
cv_reset:    cover property (@(posedge clk) se0_detect[*RESET_MIN_CLK]);
cv_suspend:  cover property (@(posedge clk) suspend_state);
cv_resume:   cover property (@(posedge clk) $rose(resume_k));

// ============================================================
// END OF USB 2.0 SVA MODULE
// ============================================================
