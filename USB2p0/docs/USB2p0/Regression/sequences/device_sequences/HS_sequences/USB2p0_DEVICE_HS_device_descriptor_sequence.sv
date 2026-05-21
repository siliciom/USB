class USB2p0_DEVICE_DESCRIPTOR__HS_sequence extends USB2p0_DEVICE_sequence;
 
  `uvm_object_utils(USB2p0_DEVICE_sequence)
   USB2p0_sequence_item     usb_device_seq_item;
 
  function new(string name="USB2p0_DEVICE_sequence");
    super.new(name);
  endfunction

    virtual task body();
      usb_device_seq_item = USB2p0_sequence_item::type_id::create("usb_device_seq_item");
       start_item(usb_device_seq_item);
          usb_device_seq_item.HS.blength=8'h12;  
          usb_device_seq_item.HS.bdescriptors_type=8'h01;  
          usb_device_seq_item.HS.bcd_usb=16'h0200;           
          usb_device_seq_item.HS.bDevice_class=8'h00;
          usb_device_seq_item.HS.bDevice_subclass=8'h00;
          usb_device_seq_item.HS.bDevice_protocol=8'h00;
          usb_device_seq_item.HS.bMax_packetsize=8'h40;//fixed 64bytes 
          usb_device_seq_item.HS.idvendor=16'h0781;       
          usb_device_seq_item.HS.idproduct=16'h5567;   
          usb_device_seq_item.HS.bcdDevice=16'h0126;
          usb_device_seq_item.HS.imanufacture=8'h01;     
          usb_device_seq_item.HS.iproduct=8'h02;        
          usb_device_seq_item.HS.iserial_number=8'h03;     
          usb_device_seq_item.HS.bNum_configuration=8'h01;
       finish_item(usb_device_seq_item);
     endtask

endclass







