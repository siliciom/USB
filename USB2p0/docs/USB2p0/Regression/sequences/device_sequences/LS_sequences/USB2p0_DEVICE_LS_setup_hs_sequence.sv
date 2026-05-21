class USB2p0_DEVICE_ls_setup_hs_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_ls_setup_hs_sequence)
   USB2p0_sequence_item     req;

     function new(string name="USB2p0_DEVICE_ls_setup_hs_sequence");
        super.new(name);
     endfunction
 
    task body();
        `uvm_info("LS_CONTROL_TRANSFER_SEQ","STARTED_DEVICE_LS_CONTROL_TRANSFER_SEQ ",UVM_LOW)
        req = USB2p0_sequence_item::type_id::create("req");
	if(!req.randomize() with { otg_dmpulldown == 1;
				       op_mode == 'd0;
			           rx_valid == 1;
			           rx_validh == 0;
			           tx_valid ==1;
				       word_if == 'd0;
			           tx_validh ==0;
                       otg_dppulldown == 0;}) begin
				   `uvm_fatal("RAND_FAIL", "Randomization failed")
			   end
         start_item(req);
         finish_item(req);
         `uvm_info("LS_CONTROL_TRANSFER_SEQ","COMPLETED_DEVICE_LS_CONTROL_TRANSFER_SEQ ",UVM_LOW)

    endtask

 endclass
