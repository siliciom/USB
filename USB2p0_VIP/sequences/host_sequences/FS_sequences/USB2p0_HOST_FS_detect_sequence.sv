class usb2p0_host_FS_detect_sequence extends uvm_sequence #(USB2p0_sequence_item);
  	
      `uvm_object_utils(usb2p0_host_FS_detect_sequence)

       USB2p0_sequence_item usb_host_seq_item;

       function new(string name="usb2p0_host_FS_detect_sequence");
             super.new(name);
        endfunction

    task body();
         usb_host_seq_item = USB2p0_sequence_item::type_id::create("usb_host_seq_item");
          start_item(usb_host_seq_item);
      
           `uvm_info("FS_DETECT_SEQ","ENTERED_INTO_FS_DEVICE_DETECT_SEQ ",UVM_LOW)
            usb_host_seq_item.op_mode          = 2'b00;  
             usb_host_seq_item.tx_valid         = 1'b1;
     	     usb_host_seq_item.tx_validh        = 1'b0;
             usb_host_seq_item.word_if          = 1'b0;
            
             assert(usb_host_seq_item.randomize());
      
            usb_host_seq_item.fsls_serialmode  =  1; 
            usb_host_seq_item.suspend_n        =  0;
            usb_host_seq_item.term_select      =  0;
            usb_host_seq_item.xcvr_select      =  0;
            usb_host_seq_item.fsls_low_power   =  0;
            usb_host_seq_item.otg_dppulldown   =  1;
            usb_host_seq_item.otg_dmpulldown   =  0;
            usb_host_seq_item.otg_vbusvalid    =  1'b1;
	    usb_host_seq_item.print(); 
          finish_item(usb_host_seq_item);
           `uvm_info("FS_DETECT_SEQ","COMPLETED_FS_DEVICE_DETECT_SEQ ",UVM_LOW)

    endtask

    /*task body();
           `uvm_info("FS_SEQUENCE","ENTERED_INTO_FS_SPEED_TEST_SEQ",UVM_LOW)
            req = USB2p0_sequence_item::type_id::create("req");
	    if(!req.randomize() with {
                                      op_mode     == 2'b00;
	                              tx_valid    == 1'b1;
	                              tx_validh   == 1'b0;
	                              word_if     == 1'b0;
	                              fsls_serialmode  ==  1; 
	                              suspend_n        ==  0;
	                              term_select      ==  1;
	                              xcvr_select      ==  2'b01;
	                              fsls_low_power   ==  0;
	                              otg_dppulldown   ==  0;
	                              otg_dmpulldown   ==  0;
	                              otg_vbusvalid    ==  1'b1;
                                      setup_token_pid ==  4'b1101;
                                      setup_data_pid   ==  4'b0011;
                                      addr             ==  7'd0;
                                      endp             ==  4'd0;
                                      bmRequestType    ==  8'd0;
                                      bRequest         ==  8'd1; 
                                      wValue           ==  16'd0; 
   	                              wIndex 	       ==  16'h0081;//0000_0000_1000_0001  
                                      wLength          ==  16'd0;     
                                      status_stage_pid_in ==  4'b1001;
                                      rx_valid         ==  'd0;
			              rx_validh        == 'd0; }) begin
		`uvm_fatal("RAND_FAIL", "HOST_FS_data_stage_seq_Randomization failed")
	    end 
          start_item(req);
          finish_item(req);
	  req.print(); 
           `uvm_info("FS_SEQUENCE","COMPLETED_FS_SPEED_TEST_SEQ ",UVM_LOW)

    endtask*/


endclass

