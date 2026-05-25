class USB2p0_HS_interrupt_in_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_HS_interrupt_in_test)
     
    usb2p0_hs_ct_get_descriptor_vsequence            hs_get_descri_vseq;
    usb2p0_hs_ct_set_configuration_vsequence         hs_set_config_vseq; 
    usb2p0_hs_interrupt_in_vsequence                 hs_interrupt_vseq;

    function new(string name="USB2p0_HS_interrupt_in_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_HS;
    	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        hs_set_config_vseq = usb2p0_hs_ct_set_configuration_vsequence::type_id::create("hs_set_config_vseq"); 	
        hs_interrupt_vseq = usb2p0_hs_interrupt_in_vsequence::type_id::create("hs_interrupt_vseq"); 	
        hs_get_descri_vseq = usb2p0_hs_ct_get_descriptor_vsequence::type_id::create("hs_get_descri_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("HS_INTERRUPT_TRANSFER_TEST","ENTERED_USB2p0_HS_INTERRUPT_IN",UVM_LOW)
      phase.raise_objection(this);
        hs_get_descri_vseq.start(usb_environment.usb_vseqr);
        #200000;
       // ls_set_ep1_config_vseq.start(usb_environment.usb_vseqr);
       //#200000;
        hs_set_config_vseq.start(usb_environment.usb_vseqr);
        #2000000;
        hs_interrupt_vseq.start(usb_environment.usb_vseqr);
        #2000000;
      phase.drop_objection(this);   
     `uvm_info("HS_INTERRUPT_TRANSFER_TEST","COMPLETED_USB2p0_HS_INTERRUPT_IN",UVM_LOW)
  endtask

endclass




