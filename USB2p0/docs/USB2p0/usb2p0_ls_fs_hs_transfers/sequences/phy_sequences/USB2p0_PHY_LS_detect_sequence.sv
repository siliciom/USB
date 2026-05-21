class USB2p0_phy_LS_detect_sequence extends USB2p0_PHY_sequence;
  
  USB2p0_sequence_item     usb_phy_seq;
  
  `uvm_object_utils(USB2p0_phy_LS_detect_sequence)
  
  
  function new(string name="USB2p0_phy_LS_detect_sequence");
    super.new(name);
  endfunction
  
  
  task body();
    usb_phy_seq = USB2p0_sequence_item::type_id::create("usb_phy_seq");
    start_item(usb_phy_seq);
      `uvm_info("LS_DETECT_SEQ","ENTERED_INTO_PHY_SEQ ",UVM_LOW)
    finish_item(usb_phy_seq);
      `uvm_info("LS_DETECT_SEQ","COMPLETED_PHY_SEQ ",UVM_LOW)
    
  endtask
  
endclass

