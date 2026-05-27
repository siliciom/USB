class USB2p0_FS_random_interrupt_out_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_FS_random_interrupt_out_test)
 
    usb2p0_fs_random_interrupt_out_vsequence         fs_random_vseq; 
  
    function new(string name="USB2p0_FS_random_interrupt_out_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_FS;
   	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        fs_random_vseq = usb2p0_fs_random_interrupt_out_vsequence::type_id::create("fs_random_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("FS_TEST","ENTERED_INTO_FULLSPEED_INTERRUPT_OUT_RANDOM_TEST",UVM_LOW)
      phase.raise_objection(this);
        fs_random_vseq.start(usb_environment.usb_vseqr);
         #200000;
        phase.drop_objection(this);   
     `uvm_info("FS_TEST","COMPLETED_FULLSPEED_INTERRUPT_OUT_RANDOM_TEST",UVM_LOW)
  endtask

endclass




