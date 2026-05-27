class usb2p0_hs_detect_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_hs_detect_vsequence)

    usb2p0_host_HS_detect_sequence     host_hs_det;
    USB2p0_phy_HS_detect_sequence      phy_hs_det;
    USB2p0_DEVICE_HS_detect_sequence   device_hs_det;
  
  function new (string name = "usb2p0_hs_detect_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_hs_detect_vsequence::body();

     `uvm_info("HS_DETECT_VSEQ","ENTERED_INTO_HS_DEVICE_DETECT_VSEQ ",UVM_LOW)
       host_hs_det=usb2p0_host_HS_detect_sequence::type_id::create("host_hs_det");
       phy_hs_det=USB2p0_phy_HS_detect_sequence::type_id::create("phy_hs_det");
       device_hs_det=USB2p0_DEVICE_HS_detect_sequence::type_id::create("device_hs_det");

     fork 
	host_hs_det.start(p_sequencer.host_seqr);
	phy_hs_det.start(p_sequencer.phy_seqr);
	device_hs_det.start(p_sequencer.device_seqr); 
     join
 
endtask


