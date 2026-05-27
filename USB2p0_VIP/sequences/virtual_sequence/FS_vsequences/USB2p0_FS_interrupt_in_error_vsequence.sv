class usb2p0_fs_interrupt_in_error_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_fs_interrupt_in_error_vsequence)

    USB2p0_phy_FS_detect_sequence                 phy_fs_det;
    USB2p0_DEVICE_fs_setup_sequence               device_fs_det;
    USB2p0_DEVICE_fs_interrupt_in_error_sequence  interrupt_error;
    usb2p0_host_fs_interrupt_in_error_sequence    interrupt_in_seq;

  function new (string name = "usb2p0_fs_interrupt_in_error_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_fs_interrupt_in_error_vsequence::body();

     `uvm_info("FS_INTERRUPT_TRANSFER_VSEQ","ENTERED_INTO_INTERRUPT_IN_ERROR_VSEQ ",UVM_LOW)
    phy_fs_det=USB2p0_phy_FS_detect_sequence::type_id::create("phy_fs_det");
    device_fs_det=USB2p0_DEVICE_fs_setup_sequence::type_id::create("device_fs_det");
    interrupt_error=USB2p0_DEVICE_fs_interrupt_in_error_sequence::type_id::create("interrupt_error");
    interrupt_in_seq=usb2p0_host_fs_interrupt_in_error_sequence::type_id::create("interrupt_in_seq");

      fork 
  	  interrupt_in_seq.start(p_sequencer.host_seqr);
	  phy_fs_det.start(p_sequencer.phy_seqr);
	  device_fs_det.start(p_sequencer.device_seqr); 
	  interrupt_error.start(p_sequencer.device_seqr); 
     join 
     `uvm_info("FS_INTERRUPT_TRANSFER_VSEQ","COMPLETED_INTO_INTERRUPT_IN_ERROR_VSEQ ",UVM_LOW)
endtask


