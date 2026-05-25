class usb2p0_fs_isochronous_out_error_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_fs_isochronous_out_error_vsequence)

    USB2p0_phy_FS_detect_sequence                   phy_fs_det;
    USB2p0_DEVICE_fs_setup_sequence                 device_fs_det;
    usb2p0_host_fs_isochronous_out_error_sequence    iso_out_seq;

  function new (string name = "usb2p0_fs_isochronous_out_error_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_fs_isochronous_out_error_vsequence::body();

     `uvm_info("FS_ISO_TRANSFER_VSEQ","ENTERED_INTO_ISO_IN_ERROR_VSEQ ",UVM_LOW)
    phy_fs_det=USB2p0_phy_FS_detect_sequence::type_id::create("phy_fs_det");
    device_fs_det=USB2p0_DEVICE_fs_setup_sequence::type_id::create("device_fs_det");
    iso_out_seq=usb2p0_host_fs_isochronous_out_error_sequence::type_id::create("iso_out_seq");

      fork 
  	  iso_out_seq.start(p_sequencer.host_seqr);
	  phy_fs_det.start(p_sequencer.phy_seqr);
	  device_fs_det.start(p_sequencer.device_seqr); 
     join 
     `uvm_info("FS_ISO_TRANSFER_VSEQ","COMPLETED_INTO_ISO_IN_ERROR_VSEQ ",UVM_LOW)
endtask


