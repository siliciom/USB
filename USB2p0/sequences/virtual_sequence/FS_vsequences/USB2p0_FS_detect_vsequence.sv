class usb2p0_fs_detect_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_fs_detect_vsequence)

    usb2p0_host_FS_detect_sequence     host_fs_det;
    USB2p0_phy_FS_detect_sequence      phy_fs_det;
    USB2p0_DEVICE_FS_detect_sequence   device_fs_det;
  
  function new (string name = "usb2p0_fs_detect_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_fs_detect_vsequence::body();

     `uvm_info("LS_DETECT_VSEQ","ENTERED_INTO_LS_DEVICE_DETECT_VSEQ ",UVM_LOW)
       host_fs_det=usb2p0_host_FS_detect_sequence::type_id::create("host_fs_det");
       phy_fs_det=USB2p0_phy_FS_detect_sequence::type_id::create("phy_fs_det");
       device_fs_det=USB2p0_DEVICE_FS_detect_sequence::type_id::create("device_fs_det");

     fork 
	host_fs_det.start(p_sequencer.host_seqr);
	phy_fs_det.start(p_sequencer.phy_seqr);
	device_fs_det.start(p_sequencer.device_seqr); 
     join
 
endtask


