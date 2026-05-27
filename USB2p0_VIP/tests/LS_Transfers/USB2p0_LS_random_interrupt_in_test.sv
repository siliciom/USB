class USB2p0_LS_random_interrupt_in_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_LS_random_interrupt_in_test)
 
    usb2p0_ls_random_interrupt_in_vsequence         ls_random_vseq; 
  
    function new(string name="USB2p0_LS_random_interrupt_in_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_LS;
   	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        ls_random_vseq = usb2p0_ls_random_interrupt_in_vsequence::type_id::create("ls_random_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("LS_TEST","ENTERED_INTO_LOWSPEED_INTERRUPT_RANDOM_IN_TEST",UVM_LOW)
      phase.raise_objection(this);
        ls_random_vseq.start(usb_environment.usb_vseqr);
         #200000;
        phase.drop_objection(this);   
     `uvm_info("LS_TEST","COMPLETED_LOWSPEED_INTERRUPT_RANDOM_IN_TEST",UVM_LOW)
  endtask

endclass




