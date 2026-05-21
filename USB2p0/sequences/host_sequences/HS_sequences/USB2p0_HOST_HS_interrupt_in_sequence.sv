class usb2p0_host_hs_interrupt_in_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_hs_interrupt_in_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_hs_interrupt_in_sequence");
            super.new(name);
       endfunction

    task body();
           `uvm_info("HS_INTERRUPT_SEQUENCE","ENTERED_INTO_HS_INTERRUPT_SEQ ",UVM_LOW)
            req = USB2p0_sequence_item::type_id::create("req");
	    if(!req.randomize() with {transfer_type == INTERRUPT_TRANSFER;
                                  direction   ==  'b1;
                                  op_mode     == 2'b00;
	                              tx_valid    == 1'b1;
	                              tx_validh   == 1'b1;
	                              word_if     == 1'b1;
	                              fsls_serialmode  ==  1; 
	                              suspend_n        ==  0;
	                              term_select      ==  0;
	                              xcvr_select      ==  2'b0;
	                              fsls_low_power   ==  0;
                                  // otg_dppulldown   ==  0;
	                              // otg_dmpulldown   ==  1;
                                  otg_vbusvalid    ==  1'b1;
                                  interrupt_in_pid ==  4'b1001;
                                  addr             ==  7'd0;
                                  endp             ==  4'd3;
                                  rx_valid         ==  'd1;
	         		              rx_validh        ==  'd1; }) begin
		`uvm_fatal("RAND_FAIL", "HOST_LS_data_stage_seq_Randomization failed")
	    end 
          start_item(req);
          finish_item(req);
	  req.print(); 
           `uvm_info("HS_INTERRUPT","COMPLETED_HS_INTERRUPT_SEQ ",UVM_LOW)

    endtask
endclass

