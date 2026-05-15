class USB2p0_DEVICE_ls_send_hs_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_ls_send_hs_sequence)
   USB2p0_sequence_item     req;

     function new(string name="USB2p0_DEVICE_ls_send_hs_sequence");
        super.new(name);
     endfunction
 
    task body();
        `uvm_info("LS_CONTROL_TRANSFER_SEQ","STARTED_DEVICE_LS_CONTROL_TRANSFER_HS_SEQ ",UVM_LOW)
        req = USB2p0_sequence_item::type_id::create("req");
	if(!req.randomize() with {
                                 otg_dmpulldown == 1;
                                 otg_dppulldown == 0; 
			                     rx_valid == 1;
			                     rx_validh == 0;
				                 op_mode == 'd0;
				                 word_if == 'd0;
			                     rx_validh == 0;
			                     tx_valid ==1;
			                     tx_validh ==0;
                                 blength             == 8'h12;
                                 bdescriptors_type   == 8'h01;
	                             bcd_usb             == 16'h0110;
	                             bDevice_class       ==  8'h00;
	                             bDevice_subclass    ==  8'h00; 
	                             bDevice_protocol    ==  8'h00;
	                             bMax_packetsize     ==  8'h08;
	                             idvendor            == 16'h0781;
	                             idproduct           == 16'h5567;
	                             bcdDevice           == 16'h0126;
	                             imanufacture        ==  8'h01;
	                             iproduct            == 8'h02;
                                 iserial_number      == 8'h03;
                                 bNum_configuration  ==   8'h01;
                                 length == 6;
                                foreach(device_payload[i])
                                        device_payload[i] == 'h55 ; 
                                }) begin
				   `uvm_fatal("RAND_FAIL", "Randomization failed")
			   end
         start_item(req);
         finish_item(req);
         `uvm_info("LS_CONTROL_TRANSFER_SEQ","COMPLETED_DEVICE_LS_CONTROL_TRANSFER_HS_SEQ ",UVM_LOW)

    endtask
 endclass



 class USB2p0_DEVICE_ls_send_hs_get_config_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_ls_send_hs_get_config_sequence)
   USB2p0_sequence_item     req;

     function new(string name="USB2p0_DEVICE_ls_send_hs_get_config_sequence");
        super.new(name);
     endfunction
 
    task body();
        `uvm_info("LS_CONTROL_TRANSFER_SEQ","STARTED_DEVICE_LS_CONTROL_TRANSFER_HS_SEQ ",UVM_LOW)
        req = USB2p0_sequence_item::type_id::create("req");
	if(!req.randomize() with {
			                   rx_valid   ==  1;
			                   rx_validh  ==  0;
				               op_mode    == 'd0;
				               word_if    == 'd0;
			                   rx_validh  ==  0;
			                   tx_valid   ==  1;
			                   tx_validh  ==  0;
                               }) begin
				              `uvm_fatal("RAND_FAIL", "Randomization failed")
			            end
                        start_item(req);
                        finish_item(req);
                        `uvm_info("LS_CONTROL_TRANSFER_SEQ","COMPLETED_DEVICE_LS_CONTROL_TRANSFER_HS_SEQ ",UVM_LOW)
    endtask
 endclass




