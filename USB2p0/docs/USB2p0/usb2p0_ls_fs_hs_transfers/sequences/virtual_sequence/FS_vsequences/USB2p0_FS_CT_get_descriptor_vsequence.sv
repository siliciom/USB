class usb2p0_fs_ct_get_descriptor_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_fs_ct_get_descriptor_vsequence)

     USB2p0_phy_FS_detect_sequence                  phy_fs_det;
     USB2p0_DEVICE_fs_setup_sequence                device_fs_det;
     USB2p0_DEVICE_fs_send_hs_sequence              device_handshake_send;
     usb2p0_host_fs_ct_get_descriptor_sequence      get_descrip_seq;
     //USB2p0_DEVICE_DESCRIPTOR_LS_sequence         device_descrip_seq;
 
  function new (string name = "usb2p0_fs_ct_get_descriptor_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_fs_ct_get_descriptor_vsequence::body();

     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","ENTERED_INTO_LS_CONTROL_TRANSFER_GET_STATUS_VSEQ ",UVM_LOW)
      //device_descrip_seq=USB2p0_DEVICE_DESCRIPTOR_LS_sequence::type_id::create("device_descrip_seq");
      phy_fs_det=USB2p0_phy_FS_detect_sequence::type_id::create("phy_fs_det");
      device_fs_det=USB2p0_DEVICE_fs_setup_sequence::type_id::create("device_fs_det");
      device_handshake_send=USB2p0_DEVICE_fs_send_hs_sequence::type_id::create("device_handshake_send");
      get_descrip_seq=usb2p0_host_fs_ct_get_descriptor_sequence::type_id::create("get_descrip_seq");

//     fork 
//	status_in_token_seq.start(p_sequencer.host_seqr);
//	phy_ls_det.start(p_sequencer.phy_seqr);
//	device_ls_det.start(p_sequencer.device_seqr); 
//     join_none 
//	device_handshake_send.start(p_sequencer.device_seqr); 
//	//phy_data_stage_seq.start(p_sequencer.phy_seqr);
//
      fork 
        get_descrip_seq.start(p_sequencer.host_seqr);
	   phy_fs_det.start(p_sequencer.phy_seqr);
	   device_fs_det.start(p_sequencer.device_seqr); 
	   device_handshake_send.start(p_sequencer.device_seqr); 
	   //device_descrip_seq.start(p_sequencer.device_seqr); 
     join
     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","COMPLETED_INTO_LS_CONTROL_TRANSFER_GET_STATUS_VSEQ ",UVM_LOW)
endtask


