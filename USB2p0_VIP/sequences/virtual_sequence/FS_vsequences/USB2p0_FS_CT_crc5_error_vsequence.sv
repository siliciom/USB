class usb2p0_fs_ct_crc5_error_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_fs_ct_crc5_error_vsequence)

    USB2p0_phy_FS_detect_sequence                           phy_fs_det;
    USB2p0_DEVICE_fs_send_hs_sequence                       device_handshake_send;
    USB2p0_DEVICE_fs_setup_sequence                         device_fs_det;
    usb2p0_host_fs_ct_crc5_error_sequence                    crc5_fs_seq;

  function new (string name = "usb2p0_fs_ct_crc5_error_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_fs_ct_crc5_error_vsequence::body();

     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","ENTERED_INTO_LS_CONTROL_TRANSFER_CRC5_ERROR_VSEQ ",UVM_LOW)
        phy_fs_det=USB2p0_phy_FS_detect_sequence::type_id::create("phy_fs_det");
        device_fs_det=USB2p0_DEVICE_fs_setup_sequence::type_id::create("device_fs_det");
        device_handshake_send=USB2p0_DEVICE_fs_send_hs_sequence::type_id::create("device_handshake_send");
        crc5_fs_seq=usb2p0_host_fs_ct_crc5_error_sequence::type_id::create("crc5_fs_seq");

      fork 
	crc5_fs_seq.start(p_sequencer.host_seqr);
	phy_fs_det.start(p_sequencer.phy_seqr);
	device_fs_det.start(p_sequencer.device_seqr); 
	device_handshake_send.start(p_sequencer.device_seqr); 
     join 
     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","COMPLETED_INTO_LS_CONTROL_TRANSFER_CRC5_ERROR_VSEQ ",UVM_LOW)
endtask


