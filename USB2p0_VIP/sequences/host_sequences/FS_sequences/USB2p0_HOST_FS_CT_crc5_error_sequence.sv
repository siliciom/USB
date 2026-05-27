class usb2p0_host_fs_ct_crc5_error_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_fs_ct_crc5_error_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_fs_ct_crc5_error_sequence");
            super.new(name);
       endfunction

    task body();
           `uvm_info("LS_CLEAR_FEATURE_ERROR","ENTERED_INTO_FS_CLEAR_FEATURE_ERROR_SEQ ",UVM_LOW)
            req = USB2p0_sequence_item::type_id::create("req");
          start_item(req);
	    if(!req.randomize() with {
                                      transfer_type == CONTROL_TRANSFER;
                                      op_mode     == 2'b00;
	                              tx_valid    == 1'b1;
	                              tx_validh   == 1'b0;
	                              word_if     == 1'b0;
	                              fsls_serialmode  ==  1; 
	                              suspend_n        ==  0;
	                              term_select      ==  1;
	                              xcvr_select      ==  1;
	                              fsls_low_power   ==  0;
	                              //otg_dppulldown   ==  1;
	                              //otg_dmpulldown   ==  0;
	                              otg_vbusvalid    ==  1'b1;
                                      setup_token_pid  ==  4'b1101;
                                      setup_data_pid   ==  4'b0011;
                                      addr             ==  7'd0;
                                      endp             ==  4'd0;
                                      rx_valid         ==  'd0;
			              rx_validh        == 'd0; }) begin
		`uvm_fatal("RAND_FAIL", "HOST_FS_data_stage_seq_Randomization failed")
	    end
         req. inject_crc16_err = 1'b0;
	 req.inject_crc5_err  = 1'b1;

          finish_item(req);
	  req.print(); 
           `uvm_info("LS_CLEAR_FEATURE_ERROR","COMPLETED_FS_CRC5_ERROR_SEQ ",UVM_LOW)

    endtask
endclass

