class usb2p0_fs_ct_get_interface_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_fs_ct_get_interface_vsequence)

     USB2p0_DEVICE_fs_send_hs_sequence               device_handshake_send;
     usb2p0_host_fs_ct_get_interface_sequence         get_interface_seq;

  function new (string name = "usb2p0_fs_ct_get_interface_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_fs_ct_get_interface_vsequence::body();

     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","ENTERED_INTO_LS_CONTROL_TRANSFER_SET_CONFIGURATION_VSEQ ",UVM_LOW)
      device_handshake_send=USB2p0_DEVICE_fs_send_hs_sequence::type_id::create("device_handshake_send");
      get_interface_seq=usb2p0_host_fs_ct_get_interface_sequence::type_id::create("get_interface_seq");

//     fork 
//	status_in_token_seq.start(p_sequencer.host_seqr);
//	phy_ls_det.start(p_sequencer.phy_seqr);
//	device_ls_det.start(p_sequencer.device_seqr); 
//     join_none 
//	device_handshake_send.start(p_sequencer.device_seqr); 
//	//phy_data_stage_seq.start(p_sequencer.phy_seqr);
//
      fork 
       get_interface_seq.start(p_sequencer.host_seqr);
	   device_handshake_send.start(p_sequencer.device_seqr); 
     join
     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","COMPLETED_INTO_LS_CONTROL_TRANSFER_SET_CONFIGURATION_VSEQ ",UVM_LOW)
endtask


