class usb2p0_HOST_vbus_connect_sequence extends uvm_sequence #(USB2p0_sequence_item);
 
    `uvm_object_utils(usb2p0_HOST_vbus_connect_sequence)

     USB2p0_sequence_item usb_host_seq_item;

    function new(string name="usb2p0_HOST_vbus_connect_sequence");
       super.new(name);
    endfunction

    task body();
       usb_host_seq_item = USB2p0_sequence_item::type_id::create("usb_host_seq_item");

      start_item(usb_host_seq_item);

	//     usb_host_seq_item.op_mode        = 2'b00;  
	//     usb_host_seq_item.tx_valid       = 1'b1;
	//     usb_host_seq_item.tx_validh      = 1'b1;
	//     usb_host_seq_item.word_if        = 1'b1;
	//
	//
	//     usb_host_seq_item.op_mode          =  2'b00;
	//      usb_host_seq_item.word_if          =  1;
	//      
	//            
	//      assert(usb_host_seq_item.randomize());
	//      
	//        usb_host_seq_item.fsls_serialmode  =  1; 
	//        usb_host_seq_item.suspend_n        =  0;
	//        usb_host_seq_item.term_select      =  0;
	//        usb_host_seq_item.xcvr_select      =  0;
	//        usb_host_seq_item.fsls_low_power   =  0;
	//        usb_host_seq_item.otg_dppulldown   =  0;
	//        usb_host_seq_item.otg_dmpulldown   =  0;


               usb_host_seq_item.otg_vbusvalid  = 1'b1;    

     finish_item(usb_host_seq_item);
              `uvm_info("VBUS_ATTACHMENT","USB2.0 Power Connect sequence completed",UVM_LOW)
    endtask

endclass


