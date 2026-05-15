class USB2p0_phy_LS_data_stage_sequence extends USB2p0_PHY_sequence;
  
  //USB2p0_sequence_item     usb_phy_seq;
  USB2p0_phy_sequence_item     req;
  
  `uvm_object_utils(USB2p0_phy_LS_data_stage_sequence)
  
  
  function new(string name="USB2p0_phy_LS_data_stage_sequence");
    super.new(name);
  endfunction
  
  
  task body();
    req = USB2p0_phy_sequence_item::type_id::create("req");
    start_item(req);
      `uvm_info("LS_DETECT_SEQ","ENTERED_INTO_PHY_DATA_STAGE_SEQ ",UVM_LOW)
    finish_item(req);
    
  endtask
  
endclass

