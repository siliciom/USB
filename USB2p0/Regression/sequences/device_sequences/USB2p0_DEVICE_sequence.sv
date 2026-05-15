class USB2p0_DEVICE_sequence extends uvm_sequence #(USB2p0_sequence_item);

  `uvm_object_utils(USB2p0_DEVICE_sequence)
   USB2p0_sequence_item     usb_device_seq_item;

    function new(string name="USB2p0_DEVICE_sequence");
       super.new(name);
    endfunction
 
    virtual task body();
      usb_device_seq_item = USB2p0_sequence_item::type_id::create("usb_device_seq_item");
          
          start_item(usb_device_seq_item);
     
              //////////---------------HIGH SPEED DEVICE DESCRIPTORS----////////////////////
		   
		   /* usb_device_seq_item.HS.blength=8'h12;  //18 bytes are fixed blength 
		      usb_device_seq_item.HS.bdescriptors_type=8'h01;  //Device Descriptors
		      usb_device_seq_item.HS.bcd_usb=16'h0200;           //USB2.0 version
		      usb_device_seq_item.HS.bDevice_class=8'h00;
		      usb_device_seq_item.HS.bDevice_subclass=8'h00;
		      usb_device_seq_item.HS.bDevice_protocol=8'h00;
		      usb_device_seq_item.HS.bMax_packetsize=8'h40; //based on speed it will send for high speed 64 bytes, low speed 8 bytes
		      usb_device_seq_item.HS.idvendor=16'h0781;       //Western Digital ,Sandisk 
		      usb_device_seq_item.HS.idproduct=16'h5567;   
		      usb_device_seq_item.HS.bcdDevice=16'h0126;
		      usb_device_seq_item.HS.imanufacture=8'h01;     // string Descriptors 1
		      usb_device_seq_item.HS.iproduct=8'h02;          //string Descriptors 2
		      usb_device_seq_item.HS.iserial_number=8'h03;     //string descriptors 3
		      usb_device_seq_item.HS.bNum_configuration=8'h01;*/ //configuration 1
      
           finish_item(usb_device_seq_item);
      endtask
  
endclass




 

  






















