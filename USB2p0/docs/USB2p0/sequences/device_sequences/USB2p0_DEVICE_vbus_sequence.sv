class USB2p0_DEVICE_vbus_sequence extends USB2p0_DEVICE_sequence;

      `uvm_object_utils(USB2p0_DEVICE_vbus_sequence)

       USB2p0_sequence_item     usb_device_seq_item;

     function new(string name="USB2p0_DEVICE_vbus_sequence");
         super.new(name);
     endfunction
 
     virtual task body();
      usb_device_seq_item = USB2p0_sequence_item::type_id::create("usb_device_seq_item");
      
        start_item(usb_device_seq_item);
     
        finish_item(usb_device_seq_item);
      endtask
  
endclass 

