class usb2p0_fs_ct_set_address_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_fs_ct_set_address_vsequence)

    USB2p0_phy_FS_detect_sequence                phy_fs_det;
    //USB2p0_phy_FS_data_stage_sequence            phy_data_stage_seq;
    USB2p0_DEVICE_fs_setup_sequence              device_fs_det;
    USB2p0_DEVICE_fs_send_hs_sequence            device_handshake_send;
    usb2p0_host_fs_ct_set_address_in_sequence  status_in_token_seq;

  function new (string name = "usb2p0_fs_ct_set_address_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_fs_ct_set_address_vsequence::body();

     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","ENTERED_INTO_LS_CONTROL_TRANSFER_SET_ADDRESS_VSEQ ",UVM_LOW)
    phy_fs_det=USB2p0_phy_FS_detect_sequence::type_id::create("phy_fs_det");
    //phy_data_stage_seq=USB2p0_phy_FS_data_stage_sequence::type_id::create("phy_data_stage_seq");
    device_fs_det=USB2p0_DEVICE_fs_setup_sequence::type_id::create("device_fs_det");
    device_handshake_send=USB2p0_DEVICE_fs_send_hs_sequence::type_id::create("device_handshake_send");
    status_in_token_seq=usb2p0_host_fs_ct_set_address_in_sequence::type_id::create("status_in_token_seq");

//     fork 
//	status_in_token_seq.start(p_sequencer.host_seqr);
//	phy_ls_det.start(p_sequencer.phy_seqr);
//	device_ls_det.start(p_sequencer.device_seqr); 
//     join_none 
//	device_handshake_send.start(p_sequencer.device_seqr); 
//	//phy_data_stage_seq.start(p_sequencer.phy_seqr);
//
     fork 
	status_in_token_seq.start(p_sequencer.host_seqr);
	phy_fs_det.start(p_sequencer.phy_seqr);
	device_fs_det.start(p_sequencer.device_seqr); 
	device_handshake_send.start(p_sequencer.device_seqr); 
     join 
     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","COMPLETED_INTO_LS_CONTROL_TRANSFER_AE_ADDRESS_VSEQ ",UVM_LOW)
endtask


