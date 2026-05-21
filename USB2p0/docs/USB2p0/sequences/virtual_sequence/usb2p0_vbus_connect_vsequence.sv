class usb2p0_vbus_connect_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_vbus_connect_vsequence)

    usb2p0_HOST_vbus_connect_sequence  vbus_connect;
    USB2p0_PHY_vbus_sequence           phy_vbus;
    USB2p0_DEVICE_vbus_sequence        device_vbus;
  
  function new (string name = "usb2p0_vbus_connect_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_vbus_connect_vsequence::body();

     `uvm_info("POWER_CONNECT_VSEQ","ENTERED_INTO_VBUS__DETECT_VSEQ ",UVM_LOW)
      vbus_connect=usb2p0_HOST_vbus_connect_sequence::type_id::create("vbus_connect");
      phy_vbus=USB2p0_PHY_vbus_sequence::type_id::create("phy_vbus");
      device_vbus=USB2p0_DEVICE_vbus_sequence::type_id::create("device_vbus");

     fork 
	vbus_connect.start(p_sequencer.host_seqr);
	phy_vbus.start(p_sequencer.phy_seqr);
	device_vbus.start(p_sequencer.device_seqr); 
     join_none
 
endtask

