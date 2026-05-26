
class usb2p0_host_hs_bulk_random_out_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_hs_bulk_random_out_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_hs_bulk_random_out_sequence");
            super.new(name);
       endfunction

    task body();
 
       `uvm_info(get_full_name(),"ENTERED_INTO_RANDOM_CONTROL_SEQUENCE",UVM_LOW)
        //repeat(100) begin
        req = USB2p0_sequence_item::type_id::create("req");
 
        start_item(req);
        if(!req.randomize() with {
                                  transfer_type == BULK_TRANSFER;
				  otg_vbusvalid ==  1'b1;
                                  addr          ==  7'd0;
                                  bulk_dir      ==   0;
				  direction     ==   0;
 				  length == 5;
                                  foreach(host_payload[i])
                                        !(host_payload[i] inside {8'h04,8'h7f}); 
        }) begin
           `uvm_fatal(get_full_name(),"RANDOMIZATION_FAILED")
           end
        finish_item(req);
        req.print();
 
      //  `uvm_info(get_full_name(),
      //          $sformatf("RANDOMIZED_TRANSACTION :: SPEED=%s TRANSFER_TYPE=%s BREQUEST=%0d",
        //        req.usb_speed.name(),
          //      req.transfer_type.name(),
            //    req.bRequest),
              //  UVM_LOW)
       //end
 
         `uvm_info(get_full_name(),"COMPLETED_RANDOM_CONTROL_SEQUENCE",UVM_LOW)
 
    endtask

endclass

