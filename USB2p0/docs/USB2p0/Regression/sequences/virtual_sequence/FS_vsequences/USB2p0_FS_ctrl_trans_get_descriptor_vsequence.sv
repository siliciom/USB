class usb2p0_fs_ctrl_trans_get_descriptor_vsequence extends usb2p0_base_virtual_sequence;
   `uvm_object_utils(usb2p0_fs_ctrl_trans_get_descriptor_vsequence)

    usb2p0_fs_ctrl_trans_get_descriptor_seq    fs_get_descri_seq;
    USB2p0_phy_FS_detect_sequence              phy_fs_det;
    USB2p0_DEVICE_fs_setup_sequence           device_fs_det;
    USB2p0_DEVICE_fs_send_hs_sequence         fs_device_handshake_send;
    USB2p0_DEVICE_DESCRIPTOR_FS_sequence      dev_descrip_fs_seq;
   function new(string name="usb2p0_fs_ctrl_trans_get_descriptor_vsequence");
       super.new(name);
   endfunction

   extern task body();
  
endclass

task usb2p0_fs_ctrl_trans_get_descriptor_vsequence::body();

   `uvm_info("FS_DETECT_VSEQ","ENTERED_INTO_FS_DEVICE_DETECT_VSEQ ",UVM_LOW)
    fs_get_descri_seq=usb2p0_fs_ctrl_trans_get_descriptor_seq::type_id::create("fs_get_descri_seq");
    phy_fs_det=USB2p0_phy_FS_detect_sequence::type_id::create("phy_fs_det");
    device_fs_det=USB2p0_DEVICE_fs_setup_sequence::type_id::create("device_fs_det");
    fs_device_handshake_send=USB2p0_DEVICE_fs_send_hs_sequence::type_id::create("fs_device_handshake_send");
    dev_descrip_fs_seq=USB2p0_DEVICE_DESCRIPTOR_FS_sequence::type_id::create("dev_descrip_fs_seq");

     fork 
	fs_get_descri_seq.start(p_sequencer.host_seqr);
	phy_fs_det.start(p_sequencer.phy_seqr);
	device_fs_det.start(p_sequencer.device_seqr);
	dev_descrip_fs_seq.start(p_sequencer.device_seqr);
     join_none
     //join
	fs_device_handshake_send.start(p_sequencer.device_seqr); 
        `uvm_info("FS_CONTROL_TRANSFER_VSEQ","COMPLETED_INTO_LS_CONTROL_TRANSFER_VSEQ",UVM_LOW)
         

endtask
 
 
 
