class USB2p0_DEVICE_DESCRIPTOR_FS_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_DESCRIPTOR_FS_sequence)

  USB2p0_sequence_item req;

  function new(string name="USB2p0_DEVICE_DESCRIPTOR_FS_sequence");
    super.new(name);
  endfunction


  /*virtual task body();

    usb_device_seq_item =USB2p0_sequence_item::type_id::create("usb_device_seq_item");
   `uvm_info("FS_DEVICE_DESCRIPTOR_SEQUENCE","ENTERED_INTO_FS_DEVICE_DESCRIPTOR_SEQUENCE ",UVM_LOW)

    start_item(usb_device_seq_item);
        usb_device_seq_item.FS.blength            = 8'h12;
        usb_device_seq_item.FS.bdescriptors_type  = 8'h01;
        usb_device_seq_item.FS.bcd_usb            = 16'h0110;
        usb_device_seq_item.FS.bDevice_class      = 8'h00;
        usb_device_seq_item.FS.bDevice_subclass   = 8'h00;
        usb_device_seq_item.FS.bDevice_protocol   = 8'h00;
        usb_device_seq_item.FS.bMax_packetsize    = 8'h40;// from 8 to 64 bytes
        usb_device_seq_item.FS.idvendor           = 16'h0781;
        usb_device_seq_item.FS.idproduct          = 16'h5567;
        usb_device_seq_item.FS.bcdDevice          = 16'h0126;
        usb_device_seq_item.FS.imanufacture       = 8'h01;
        usb_device_seq_item.FS.iproduct           = 8'h02;
        usb_device_seq_item.FS.iserial_number     = 8'h03;
        usb_device_seq_item.FS.bNum_configuration = 8'h01;
        finish_item(usb_device_seq_item);
       `uvm_info("FS_DEVICE_DESCRIPTOR_SEQUENCE","COMPLETED_FS_DEVICE_DESCRIPTOR_SEQUENCE ",UVM_LOW)
       `uvm_info("FS_SETUP_DATA","PRINTED_FROM_DEVICE_DESCRIPTOR_SEQ",UVM_LOW)
        usb_device_seq_item.print(); 
 
  endtask*/

     task body();
            `uvm_info("FS_DEVICE_DESCRIPTOR_SEQUENCE","ENTERED_INTO_FS_DEVICE_DESCRIPTOR_SEQUENCE ",UVM_LOW)
            req = USB2p0_sequence_item::type_id::create("req");
	    if(!req.randomize() with {op_mode        == 2'b00;
                                      word_if        == 1'b0;
                                      tx_valid       == 1'b1;
                                      tx_validh       == 1'b0;
                                      blength             == 8'h12;
	                              bdescriptors_type   == 8'h01;
	                              bcd_usb             == 16'h0110;
	                              bDevice_class       ==  8'h00;
	                              bDevice_subclass    ==  8'h00; 
	                              bDevice_protocol    ==  8'h00;
	                              bMax_packetsize     ==  8'h400;
	                              idvendor            == 16'h0781;
	                              idproduct           == 16'h5567;
	                              bcdDevice           == 16'h0126;
	                              imanufacture        ==  8'h01;
	                              iproduct            == 8'h02;
                                      iserial_number      == 8'h03;
                                      bNum_configuration  ==   8'h01;}) begin
		`uvm_fatal("RAND_FAIL", "FS_DEVICE_DESCRIPTOR_SEQUENCE_Randomization failed")
	    end 
          start_item(req);
          finish_item(req);
	  req.print(); 
         `uvm_info("FS_DEVICE_DESCRIPTOR_SEQUENCE","COMPLETED_FS_DEVICE_DESCRIPTOR_SEQUENCE ",UVM_LOW)

   endtask
  
endclass
 

