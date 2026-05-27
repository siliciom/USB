
class usb2p0_host_hs_random_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_hs_random_sequence)
  	USB2p0_sequence_item req;

       function new(string name="usb2p0_host_hs_random_sequence");
            super.new(name);
       endfunction

   task body();

   `uvm_info(get_full_name(),
   "ENTERED_INTO_RANDOM_CONTROL_SEQUENCE",
   UVM_LOW)

   req = USB2p0_sequence_item::type_id::create("req");
   start_item(req);
   if(!req.randomize() with {
      transfer_type   == CONTROL_TRANSFER;
      usb_speed       == USB_HS;
      //hs_chirp_enable == 0;
      otg_vbusvalid   == 1'b1;
      addr            == 7'd0;
      endp            == 4'd0;
   }) begin
      `uvm_fatal(get_full_name(),"RANDOMIZATION_FAILED")
   end
   finish_item(req);
   req.print();

endtask

endclass

