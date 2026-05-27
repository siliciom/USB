class USB2p0_DEVICE_LS_detect_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_LS_detect_sequence)
   USB2p0_sequence_item     usb_device_seq_item;

     function new(string name="USB2p0_DEVICE_LS_detect_sequence");
        super.new(name);
     endfunction
 
    virtual task body();
      usb_device_seq_item = USB2p0_sequence_item::type_id::create("usb_device_seq_item");
  
        start_item(usb_device_seq_item);
            `uvm_info("LS_DETECT_VSEQ","ENTERED_INTO_DEVICE_LS_DEVICE_DETECT_VSEQ ",UVM_LOW)
          usb_device_seq_item.otg_dppulldown = 0;
          usb_device_seq_item.otg_dmpulldown = 1;
        finish_item(usb_device_seq_item);
            `uvm_info("LS_DETECT_VSEQ","COMPLETED_DEVICE_LS_DEVICE_DETECT_VSEQ ",UVM_LOW)

    endtask
 endclass



 
 
 
 
 
 
  

