class USB2p0_DEVICE_ls_interrupt_in_error_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_ls_interrupt_in_error_sequence)
   USB2p0_sequence_item     req;

     function new(string name="USB2p0_DEVICE_ls_interrupt_in_error_sequence");
        super.new(name);
     endfunction
 
    task body();
        `uvm_info("LS_INTERRUPT_TRANSFER_SEQ","STARTED_DEVICE_LS_INTERRUPT_IN_ERROR_SEQ ",UVM_LOW)
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
                                   length == 10;
                                   foreach(device_payload[i])
                                        !(device_payload[i] inside {8'h04,8'h7f}); 
                                   }) begin
				   `uvm_fatal("RAND_FAIL", "Randomization_failed")
			   end
         start_item(req);
         finish_item(req);
         `uvm_info("LS_INTERRUPT_TRANSFER_SEQ","COMPLETED_DEVICE_LS_INTERRUPT_IN_ERROR_SEQ ",UVM_LOW)

    endtask
 endclass






