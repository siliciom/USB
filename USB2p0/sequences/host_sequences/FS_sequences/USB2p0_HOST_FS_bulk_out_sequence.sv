class usb2p0_host_fs_bulk_out_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_fs_bulk_out_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_fs_bulk_out_sequence");
            super.new(name);
       endfunction

    task body();
           `uvm_info("FS_BULK_SEQUENCE","ENTERED_INTO_FS_BULK_SEQ ",UVM_LOW)
            req = USB2p0_sequence_item::type_id::create("req");
	    if(!req.randomize() with {transfer_type == BULK_TRANSFER;
                                      direction   ==  'b0;
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
                                      bulk_out_pid ==  4'b0001;
                                      addr             ==  7'd0;
                                      endp             ==  4'd2;
                                      length == 5;
                                      foreach(host_payload[i])
                                      !(host_payload[i] inside {8'h04, 8'h7F});
                                      rx_valid         ==  'd0;
	         		      rx_validh        ==  'd0; }) begin
		`uvm_fatal("RAND_FAIL", "HOST_LS_data_stage_seq_Randomization failed")
	    end 
                                  foreach(req.host_payload[i]) begin
                                   `uvm_info("HOST_PAYLOAD", $sformatf("host_payload[%0d] = %0h ,BULK_OUT =%d",i,req.host_payload[i],req.bulk_out_pid), UVM_LOW)
                                  end
          start_item(req);
          finish_item(req);
	  req.print(); 
           `uvm_info("FS_BULK","COMPLETED_FS_BULK_SEQ ",UVM_LOW)

    endtask
endclass

