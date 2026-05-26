
class usb2p0_host_ls_set_random_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_ls_set_random_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_ls_set_random_sequence");
            super.new(name);
       endfunction

   bit [7:0] selected_set_request;

    task body();
 
       `uvm_info(get_full_name(),"ENTERED_INTO_RANDOM_CONTROL_SEQUENCE",UVM_LOW)
        //repeat(100) begin
        req = USB2p0_sequence_item::type_id::create("req");
 
        start_item(req);
        if(!req.randomize() with {
                                  transfer_type == CONTROL_TRANSFER;
				  otg_vbusvalid ==  1'b1;
                                  addr             ==  7'd0;
                                  endp             ==  4'd0;
                                  //bRequest         ==  SET_CONFIGURATION;
                                  bRequest inside {SET_CONFIGURATION,SET_INTERFACE}; 
        }) begin
           `uvm_fatal(get_full_name(),"RANDOMIZATION_FAILED")
           end
        selected_set_request = req.bRequest;

        finish_item(req);
        req.print();
 
        `uvm_info(get_full_name(),
                $sformatf("RANDOMIZED_TRANSACTION :: SPEED=%s TRANSFER_TYPE=%s BREQUEST=%0d selected_set_request=%0d",
                req.usb_speed.name(),
                req.transfer_type.name(),
                req.bRequest,selected_set_request),
                UVM_LOW)
       //end
 
         `uvm_info(get_full_name(),"COMPLETED_RANDOM_CONTROL_SEQUENCE",UVM_LOW)
 
    endtask

endclass

