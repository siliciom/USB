class USB2p0_DEVICE_hs_setup_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_hs_setup_sequence)
   USB2p0_sequence_item     req;

     function new(string name="USB2p0_DEVICE_hs_setup_sequence");
        super.new(name);
     endfunction
 
    task body();
        `uvm_info("HS_CONTROL_TRANSFER_SEQ","STARTED_DEVICE_HS_CONTROL_TRANSFER_SEQ ",UVM_LOW)
        req = USB2p0_sequence_item::type_id::create("req");
	if(!req.randomize() with { otg_dmpulldown == 0;
                                   otg_dppulldown == 1;
                                   op_mode        == 2'b00;
                                   word_if        == 1'b1;
                                   tx_valid       == 1'b1;
                                   tx_validh       == 1'b1;
                                   rx_valid       == 1'b1;
                                   blength             == 8'h12;
                                   bdescriptors_type   == 8'h01;
	                           bcd_usb             == 16'h0110;
	                           bDevice_class       ==  8'h00;
	                           bDevice_subclass    ==  8'h00; 
	                           bDevice_protocol    ==  8'h00;
	                           bMax_packetsize     ==  8'h40;
	                           idvendor            == 16'h0781;
	                           idproduct           == 16'h5567;
	                           bcdDevice           == 16'h0126;
	                           imanufacture        ==  8'h01;
	                           iproduct            == 8'h02;
                                   iserial_number      == 8'h03;
                                   bNum_configuration  ==   8'h01;
                                   rx_validh       == 1'b1;
                                   length == 7;
                                   foreach(device_payload[i])
                                   !(device_payload[i] inside {8'h04, 8'h7F});
                                   }) begin
				   `uvm_fatal("RAND_FAIL", "Randomization failed")
			   end
                             foreach(req.device_payload[i]) begin
                                `uvm_info("DEVICE_PAYLOAD", $sformatf("device_payload[%0d] = %0h",i,req.device_payload[i]), UVM_LOW)
                             end
         start_item(req);
         finish_item(req);
         `uvm_info("HS_CONTROL_TRANSFER_SEQ","COMPLETED_DEVICE_HS_CONTROL_TRANSFER_SEQ",UVM_LOW)
    endtask

 endclass
