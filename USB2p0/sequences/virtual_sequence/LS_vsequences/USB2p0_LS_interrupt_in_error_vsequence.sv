class usb2p0_ls_interrupt_in_error_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_ls_interrupt_in_error_vsequence)

    USB2p0_phy_LS_detect_sequence               phy_ls_det;
    USB2p0_DEVICE_ls_setup_hs_sequence          device_ls_det;
    USB2p0_DEVICE_ls_send_hs_sequence           device_handshake_send;
    usb2p0_host_ls_interrupt_in_error_sequence  interrupt_in_seq;

  function new (string name = "usb2p0_ls_interrupt_in_error_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_ls_interrupt_in_error_vsequence::body();

     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","ENTERED_INTO_INTERRUPT_IN_ERROR_VSEQ ",UVM_LOW)
    phy_ls_det=USB2p0_phy_LS_detect_sequence::type_id::create("phy_ls_det");
    device_ls_det=USB2p0_DEVICE_ls_setup_hs_sequence::type_id::create("device_ls_det");
    device_handshake_send=USB2p0_DEVICE_ls_send_hs_sequence::type_id::create("device_handshake_send");
    interrupt_in_seq=usb2p0_host_ls_interrupt_in_error_sequence::type_id::create("interrupt_in_seq");

      fork 
  	  interrupt_in_seq.start(p_sequencer.host_seqr);
	  phy_ls_det.start(p_sequencer.phy_seqr);
	  device_ls_det.start(p_sequencer.device_seqr); 
	  device_handshake_send.start(p_sequencer.device_seqr); 
     join 
     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","COMPLETED_INTO_INTERRUPT_IN_ERROR_VSEQ ",UVM_LOW)
endtask


