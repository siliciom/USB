
class usb2p0_host_fs_ct_set_feature_in_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_fs_ct_set_feature_in_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_fs_ct_set_feature_in_sequence");
            super.new(name);
       endfunction

    task body();
           `uvm_info("FS_SET_FEATURE","ENTERED_INTO_FS_SET_FEATURE_SEQ ",UVM_LOW)
            req = USB2p0_sequence_item::type_id::create("req");
	    if(!req.randomize() with {transfer_type==CONTROL_TRANSFER;
                                      op_mode     == 2'b00;
	                              tx_valid    == 1'b1;
	                              tx_validh   == 1'b0;
	                              word_if     == 1'b0;
	                              fsls_serialmode  ==  1; 
	                              suspend_n        ==  0;
	                              term_select      ==  1;
	                              xcvr_select      ==  2'b01;
	                              fsls_low_power   ==  0;
	                              otg_dppulldown   ==  1;
	                              otg_dmpulldown   ==  0;
	                              otg_vbusvalid    ==  1'b1;
                                      setup_token_pid  ==   USB2p0_sequence_item::PID_SETUP;
                                      setup_data_pid   ==   USB2p0_sequence_item::PID_DATA0;
                                      addr             ==  7'd0;
                                      endp             ==  4'd0;
                                      bmRequestType    ==  8'd0;
                                      bRequest         ==  8'd3; 
                                      wValue           ==  16'd1;//0000_0000_0000_0001 
   	                              wIndex 	       ==  16'd0;  
                                      wLength          ==  16'd0;     
                                      status_stage_pid_in ==   USB2p0_sequence_item::PID_IN;
                                      rx_valid         ==  'd0;
			              rx_validh        == 'd0; }) begin
		`uvm_fatal("RAND_FAIL", "HOST_FS_data_stage_seq_Randomization failed")
	    end 
          start_item(req);
          finish_item(req);
	  req.print(); 
           `uvm_info("FS_SET_FEATURE","COMPLETED_FS__SET_FEATURE ",UVM_LOW)

    endtask
endclass

