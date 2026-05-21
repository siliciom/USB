class USB2p0_DEVICE_DESCRIPTOR_LS_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_DESCRIPTOR_LS_sequence)

  USB2p0_sequence_item req;

  function new(string name="USB2p0_DEVICE_DESCRIPTOR_LS_sequence");
    super.new(name);
  endfunction


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
            `uvm_info("FS_DEVICE_DESCRIPTOR_SEQUENCE",$sformatf("blength = %h",req.blength),UVM_LOW)
          start_item(req);
          finish_item(req);
            `uvm_info("FS_DEVICE_DESCRIPTOR_SEQUENCE",$sformatf("blength = %h",req.blength),UVM_LOW)
	  req.print(); 
         `uvm_info("FS_DEVICE_DESCRIPTOR_SEQUENCE","COMPLETED_FS_DEVICE_DESCRIPTOR_SEQUENCE ",UVM_LOW)
   endtask

 endclass

