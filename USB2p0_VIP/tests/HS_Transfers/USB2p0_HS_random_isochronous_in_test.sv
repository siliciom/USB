class USB2p0_HS_random_isochronous_in_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_HS_random_isochronous_in_test)
 
    usb2p0_hs_random_isochronous_in_vsequence         hs_random_vseq; 
  
    function new(string name="USB2p0_HS_random_isochronous_in_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_HS;
   	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        hs_random_vseq = usb2p0_hs_random_isochronous_in_vsequence::type_id::create("hs_random_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("HS_TEST","ENTERED_INTO_HIGHSPEED_ISOCHRONOUS_IN_RANDOM_TEST",UVM_LOW)
      phase.raise_objection(this);
        hs_random_vseq.start(usb_environment.usb_vseqr);
         #20000;
        phase.drop_objection(this);   
     `uvm_info("HS_TEST","COMPLETED_HIGHSPEED_ISOCHRONOUS_IN_RANDOM_TEST",UVM_LOW)
  endtask

endclass




