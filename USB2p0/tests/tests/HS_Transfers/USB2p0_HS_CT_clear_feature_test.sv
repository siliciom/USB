class USB2p0_HS_CT_clear_feature_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_HS_CT_clear_feature_test)
 
    usb2p0_hs_ct_clear_feature_vsequence         hs_clear_feature_vseq; 
  
    function new(string name="USB2p0_HS_CT_clear_feature_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_HS;
   	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        hs_clear_feature_vseq = usb2p0_hs_ct_clear_feature_vsequence::type_id::create("hs_clear_feature_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("HS_CONTROL_TRANSFER_TEST","ENTERED_USB2p0_HS_CT_CLEAR_FEATURE",UVM_LOW)
      phase.raise_objection(this);
        hs_clear_feature_vseq.start(usb_environment.usb_vseqr);
         #2000000;
        phase.drop_objection(this);   
     `uvm_info("HS_CONTROL_TRANSFER_TEST","COMPLETED_USB2p0_HS_CT_CLEAR_FEATURE",UVM_LOW)
  endtask

endclass




