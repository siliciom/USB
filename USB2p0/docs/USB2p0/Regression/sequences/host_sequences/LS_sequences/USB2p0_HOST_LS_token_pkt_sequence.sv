
class usb2p0_host_ls_token_pkt_sequence extends USB2p0_HOST_sequence;
  
	`uvm_object_utils(usb2p0_host_ls_token_pkt_sequence)

  	USB2p0_sequence_item usb_host_seq_item;

       function new(string name="usb2p0_host_ls_token_pkt_sequence");
            super.new(name);
       endfunction

    task body();
         usb_host_seq_item = USB2p0_sequence_item::type_id::create("usb_host_seq_item");
          start_item(usb_host_seq_item);
             
          /*  usb_host_seq_item.op_mode = 2'b00;  
            usb_host_seq_item.word_if         = 1'b0;
            usb_host_seq_item.tx_valid   =  1'b1;
            usb_host_seq_item.tx_validh   =  1'b0;
            
             assert(usb_host_seq_item.randomize());
      
            usb_host_seq_item.fsls_serialmode =  1; 
            usb_host_seq_item.suspend_n       =  0;
            usb_host_seq_item.term_select     =  0;
            usb_host_seq_item.xcvr_select     =  0;
            usb_host_seq_item.fsls_low_power  =  0;
            usb_host_seq_item.otg_dppulldown  =  0;
            usb_host_seq_item.otg_dmpulldown  =  0;
            usb_host_seq_item.otg_vbusvalid   =  1'b1;
          ///////////////////////// SETUP_TOEKN_PACKET///////////////////////////////////////////
            usb_host_seq_item.setup_token_pid    =  4'b1101;
            //usb_host_seq_item.setup_token_pid    =  PID_SETUP;
            usb_host_seq_item.addr               =  7'd0;
            usb_host_seq_item.endp               =  4'd0;
      ///////////////////////// SETUP_DATA_PACKET///////////////////////////////////////////   
            usb_host_seq_item.setup_data_pid     =  4'b0011;
            //usb_host_seq_item.setup_data_pid     =  PID_DATA0;
            usb_host_seq_item.bmRequestType      =  8'd0;
            usb_host_seq_item.bRequest           =  8'd5; 
            usb_host_seq_item.wValue             =  16'd5; 
   	    usb_host_seq_item.wIndex 	         =  16'd0;  
            usb_host_seq_item.wLength            =  16'd0;     
            usb_host_seq_item.rx_valid  = 1;*/
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
            usb_host_seq_item.otg_dppulldown   =  0;
            usb_host_seq_item.otg_dmpulldown   =  0;
            usb_host_seq_item.otg_vbusvalid    =  1'b1;
	    usb_host_seq_item.print(); 
 
          finish_item(usb_host_seq_item);
    endtask
endclass

