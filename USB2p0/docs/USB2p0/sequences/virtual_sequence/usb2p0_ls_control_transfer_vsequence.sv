class usb2p0_ls_control_transfer_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_ls_control_transfer_vsequence)

    USB2p0_DEVICE_token_pkt_hs_sequence     device_rx_valid;
    USB2p0_phy_LS_detect_sequence           phy_ls_det;
    usb2p0_host_ls_token_pkt_sequence       host_rx_valid;
    
  function new (string name = "usb2p0_ls_control_transfer_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_ls_control_transfer_vsequence::body();
    // super.body();
     `uvm_info("LS_DETECT_VSEQ","ENTERED_INTO_LS_CONTROL_TRANSFER_HS_SEND_VSEQ ",UVM_LOW)
    device_rx_valid=USB2p0_DEVICE_token_pkt_hs_sequence::type_id::create("device_rx_valid");
    phy_ls_det=USB2p0_phy_LS_detect_sequence::type_id::create("phy_ls_det");
    host_rx_valid=usb2p0_host_ls_token_pkt_sequence::type_id::create("host_rx_valid");

     fork 
	host_rx_valid.start(p_sequencer.device_seqr);
	phy_ls_det.start(p_sequencer.phy_seqr);
	device_rx_valid.start(p_sequencer.host_seqr);
     join_none 
endtask


