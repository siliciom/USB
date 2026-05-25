
class usb2p0_host_ls_ct_clear_feature_in_error_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_ls_ct_clear_feature_in_error_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_ls_ct_clear_feature_in_error_sequence");
            super.new(name);
       endfunction

    task body();
           `uvm_info("LS_CLEAR_ERROR","ENTERED_INTO_LS_CLEAR_FEATURE_ERROR_SEQ ",UVM_LOW)
            req = USB2p0_sequence_item::type_id::create("req");
	    if(!req.randomize() with {transfer_type == CONTROL_TRANSFER;
                                      op_mode       == 2'b00;
	                              tx_valid      == 1'b1;
	                              tx_validh     == 1'b0;
	                              word_if       == 1'b0;
	                              fsls_serialmode  ==  1; 
	                              suspend_n        ==  0;
	                              term_select      ==  0;
	                              xcvr_select      ==  0;
	                              fsls_low_power   ==  0;
	                              otg_dppulldown   ==  0;
	                              otg_dmpulldown   ==  0;
	                              otg_vbusvalid    ==  1'b1;
                                  setup_token_pid ==  4'b1101;
                                  setup_data_pid   ==  4'b0011;
                                  addr             ==  7'd0;
                                  endp             ==  4'd0;
                                  bmRequestType    ==  8'd2;//actual bmrequest is 0 ;
                                  bRequest         ==  8'd3; // actual brequest is 1;
                                  wValue           ==  16'd0; 
   	                              wIndex 	       ==  16'h0081;  
                                      wLength          ==  16'd0;     
                                      status_stage_pid_in ==  4'b1001;
                                      rx_valid         ==  'd0;
			              rx_validh        == 'd0; }) begin
		`uvm_fatal("RAND_FAIL", "HOST_LS_data_stage_seq_Randomization failed")
	    end 
          start_item(req);
          finish_item(req);
	  req.print(); 
           `uvm_info("LS_CLEAR_FEATURE_ERROR","COMPLETED_LS_CLEAR_FEATURE_ERROR_SEQ ",UVM_LOW)

    endtask
endclass

