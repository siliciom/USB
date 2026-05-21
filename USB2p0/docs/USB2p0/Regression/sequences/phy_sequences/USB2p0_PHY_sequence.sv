class USB2p0_PHY_sequence extends uvm_sequence #(USB2p0_sequence_item);
  
    USB2p0_sequence_item     usb_phy_seq;
  
   `uvm_object_utils(USB2p0_PHY_sequence)
  
  
    function new(string name="USB2p0_PHY_sequence");
       super.new(name);
    endfunction
  
    task body();
         usb_phy_seq = USB2p0_sequence_item::type_id::create("usb_phy_seq");
      start_item(usb_phy_seq);
    
      finish_item(usb_phy_seq);
    endtask
 
endclass
