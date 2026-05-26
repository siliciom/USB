class usb2p0_ls_random_set_vsequence extends usb2p0_base_virtual_sequence;
   `uvm_object_utils(usb2p0_ls_random_set_vsequence)

    USB2p0_phy_LS_detect_sequence                phy_ls_det;
    USB2p0_DEVICE_ls_setup_hs_sequence           device_ls_det;
    USB2p0_DEVICE_ls_send_hs_sequence            device_handshake_send;
    usb2p0_host_ls_set_random_sequence           set_random_seq;
    bit [7:0] selected_set_request;
  function new (string name = "usb2p0_ls_random_set_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_ls_random_set_vsequence::body();

     `uvm_info("LS_RANDOM_VSEQ","ENTERED_INTO_LS_RANDOM_VSEQ ",UVM_LOW)
    phy_ls_det=USB2p0_phy_LS_detect_sequence::type_id::create("phy_ls_det");
    device_ls_det=USB2p0_DEVICE_ls_setup_hs_sequence::type_id::create("device_ls_det");
    device_handshake_send=USB2p0_DEVICE_ls_send_hs_sequence::type_id::create("device_handshake_send");
    set_random_seq=usb2p0_host_ls_set_random_sequence::type_id::create("set_random_seq");

      fork 
	set_random_seq.start(p_sequencer.host_seqr);
	phy_ls_det.start(p_sequencer.phy_seqr);
	device_ls_det.start(p_sequencer.device_seqr); 
	device_handshake_send.start(p_sequencer.device_seqr); 
     join

    selected_set_request =  set_random_seq.selected_set_request;
 
      `uvm_info("LS_RANDOM_VSEQ","COMPLETED_LS_RANDOM_VSEQ ",UVM_LOW)
endtask


