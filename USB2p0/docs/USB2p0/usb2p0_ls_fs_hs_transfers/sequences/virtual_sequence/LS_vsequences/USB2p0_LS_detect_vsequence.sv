class usb2p0_ls_detect_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_ls_detect_vsequence)

    usb2p0_host_LS_detect_sequence     host_ls_det;
    USB2p0_phy_LS_detect_sequence      phy_ls_det;
    USB2p0_DEVICE_LS_detect_sequence   device_ls_det;
  
  function new (string name = "usb2p0_ls_detect_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_ls_detect_vsequence::body();

     `uvm_info("LS_DETECT_VSEQ","ENTERED_INTO_LS_DEVICE_DETECT_VSEQ ",UVM_LOW)
        host_ls_det=usb2p0_host_LS_detect_sequence::type_id::create("host_ls_det");
        phy_ls_det=USB2p0_phy_LS_detect_sequence::type_id::create("phy_ls_det");
        device_ls_det=USB2p0_DEVICE_LS_detect_sequence::type_id::create("device_ls_det");

     fork 
	host_ls_det.start(p_sequencer.host_seqr);
	phy_ls_det.start(p_sequencer.phy_seqr);
	device_ls_det.start(p_sequencer.device_seqr); 
     join
 
endtask


