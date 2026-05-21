class USB2p0_LS_CT_set_configuration_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_LS_CT_set_configuration_test)
 
    usb2p0_ls_ct_set_configuration_vsequence         ls_set_config_vseq; 
  
    function new(string name="USB2p0_LS_CT_set_configuration_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_LS;
   	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        ls_set_config_vseq = usb2p0_ls_ct_set_configuration_vsequence::type_id::create("ls_set_config_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("LS_CONTROL_TRANSFER_TEST","ENTERED_USB2p0_LS_CT_SET_CONFIGURATION",UVM_LOW)
      phase.raise_objection(this);
        ls_set_config_vseq.start(usb_environment.usb_vseqr);
        #200000;
      phase.drop_objection(this);   
     `uvm_info("LS_CONTROL_TRANSFER_TEST","COMPLETED_USB2p0_LS_CT_SET_CONFIGURATION",UVM_LOW)
  endtask

endclass




