class usb2p0_hs_ct_set_configuration_error_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_hs_ct_set_configuration_error_vsequence)

    USB2p0_phy_HS_detect_sequence                         phy_hs_det;
    USB2p0_DEVICE_hs_send_hs_sequence                     device_hs_det;
    USB2p0_DEVICE_hs_setup_sequence                       device_handshake_send;
    usb2p0_host_hs_ct_set_configuration_in_error_sequence status_in_token_seq;

  function new (string name = "usb2p0_hs_ct_set_configuration_error_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_hs_ct_set_configuration_error_vsequence::body();

     `uvm_info("HS_CONTROL_TRANSFER_VSEQ","ENTERED_INTO_HS_CONTROL_TRANSFER_SET_CONFIG_ERROR_VSEQ ",UVM_LOW)
    phy_hs_det=USB2p0_phy_HS_detect_sequence::type_id::create("phy_hs_det");
    device_hs_det=USB2p0_DEVICE_hs_send_hs_sequence::type_id::create("device_hs_det");
    device_handshake_send=USB2p0_DEVICE_hs_setup_sequence::type_id::create("device_handshake_send");
    status_in_token_seq=usb2p0_host_hs_ct_set_configuration_in_error_sequence::type_id::create("status_in_token_seq");

     fork 
	status_in_token_seq.start(p_sequencer.host_seqr);
	phy_hs_det.start(p_sequencer.phy_seqr);
	device_hs_det.start(p_sequencer.device_seqr); 
	device_handshake_send.start(p_sequencer.device_seqr); 
     join 
     `uvm_info("HS_CONTROL_TRANSFER_VSEQ","COMPLETED_INTO_HS_CONTROL_TRANSFER_SET_CONFIG_ERROR_VSEQ ",UVM_LOW)
endtask


