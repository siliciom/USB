class USB2p0_DEVICE_token_pkt_hs_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_token_pkt_hs_sequence)
   USB2p0_sequence_item     usb_device_seq_item;

     function new(string name="USB2p0_DEVICE_token_pkt_hs_sequence");
        super.new(name);
     endfunction
 
    virtual task body();
      usb_device_seq_item = USB2p0_sequence_item::type_id::create("usb_device_seq_item");
  
        start_item(usb_device_seq_item);
          usb_device_seq_item.otg_dppulldown = 0;
          usb_device_seq_item.otg_dmpulldown = 1;
          usb_device_seq_item.rx_valid  = 1;
          usb_device_seq_item.rx_validh  = 0;
	`uvm_info("USB_TOKEN_PKT_SEQ",$sformatf("rx_valid=%0d, rx_validh=%0d",usb_device_seq_item.rx_valid,usb_device_seq_item.rx_validh),UVM_LOW);
	usb_device_seq_item.print();
        finish_item(usb_device_seq_item);

    endtask
 endclass



 
 
 
 
 
 
  

