class USB2p0_DEVICE_fs_setup_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_fs_setup_sequence)
   USB2p0_sequence_item     req;

     function new(string name="USB2p0_DEVICE_fs_setup_sequence");
        super.new(name);
     endfunction
 
    task body();
        `uvm_info("FS_CONTROL_TRANSFER_SEQ","STARTED_DEVICE_FS_CONTROL_TRANSFER_SEQ ",UVM_LOW)
        req = USB2p0_sequence_item::type_id::create("req");
	if(!req.randomize() with { otg_dmpulldown == 0;
                                   otg_dppulldown == 1;
                                   op_mode        == 2'b00;
                                   word_if        == 1'b0;
                                   tx_valid       == 1'b1;
                                   tx_validh       == 1'b0;
                                   }) begin
				   `uvm_fatal("RAND_FAIL", "Randomization failed")
			   end
         start_item(req);
         finish_item(req);
         `uvm_info("FS_CONTROL_TRANSFER_SEQ","COMPLETED_DEVICE_FS_CONTROL_TRANSFER_SEQ",UVM_LOW)
    endtask

 endclass
