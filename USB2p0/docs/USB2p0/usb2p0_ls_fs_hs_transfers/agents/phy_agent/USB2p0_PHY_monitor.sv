class USB2p0_PHY_monitor extends uvm_monitor;
  
  `uvm_component_utils(USB2p0_PHY_monitor)
  
    virtual USB2p0_PHY_interface               usb_phy_interface;
  //  virtual USB2p0_UTMI_interface              utmi_interface_tx;
    
     USB2p0_sequence_item                       usb_seq_item;
  
    function new(string name="USB2p0_PHY_monitor", uvm_component parent);
        super.new(name,parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
         super.build_phase(phase);
   
       if (!uvm_config_db#(virtual USB2p0_PHY_interface)::get(this, "", "USB_PHY_INTERFACE", usb_phy_interface))
           `uvm_fatal("NOVIF", "USB_PHY_INTERFACE not found")
      
    //  if (!uvm_config_db#(virtual USB2p0_UTMI_interface)::get(this, "", "USB_UTMI_INTERFACE_TX", utmi_interface_tx))
    //       `uvm_fatal("NOVIF", "USB_UTMI_INTERFACE not found")
            usb_seq_item = USB2p0_sequence_item::type_id::create("usb_seq_item");
    endfunction
     
      
endclass



