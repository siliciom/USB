class usb2p0_host_fs_isochronous_in_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_fs_isochronous_in_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_fs_isochronous_in_sequence");
            super.new(name);
       endfunction

    task body();
           `uvm_info("FS_ISO_SEQUENCE","ENTERED_INTO_FS_ISO_SEQ ",UVM_LOW)
            req = USB2p0_sequence_item::type_id::create("req");
	    if(!req.randomize() with {transfer_type == ISO_CHRONOUS_TRANSFER;
                                      direction   ==  'b1;
                                      op_mode     == 2'b00;
	                              tx_valid    == 1'b1;
	                              tx_validh   == 1'b0;
	                              word_if     == 1'b0;
	                              fsls_serialmode  ==  1; 
	                              suspend_n        ==  0;
	                              term_select      ==  0;
	                              xcvr_select      ==  2'b1;
	                              fsls_low_power   ==  0;
                                     // otg_dppulldown   ==  0;
	                             // otg_dmpulldown   ==  1;
                                      otg_vbusvalid    ==  1'b1;
                                      iso_in_pid ==   USB2p0_sequence_item::PID_IN;
                                      addr             ==  7'd0;
                                      endp             ==  4'd6;
                                      rx_valid         ==  'd0;
	         		      rx_validh        ==  'd0; }) begin
		`uvm_fatal("RAND_FAIL", "HOST_LS_data_stage_seq_Randomization failed")
	    end 
          start_item(req);
          finish_item(req);
	  req.print(); 
           `uvm_info("FS_ISO_SEQUENCE","COMPLETED_FS_ISO_SEQ ",UVM_LOW)

    endtask
endclass

