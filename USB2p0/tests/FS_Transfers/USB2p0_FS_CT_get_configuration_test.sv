class USB2p0_FS_CT_get_configuration_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_FS_CT_get_configuration_test)
 
    usb2p0_fs_ct_get_configuration_vsequence         fs_get_config_vseq; 
    usb2p0_fs_ct_set_configuration_vsequence         fs_set_config_vseq;
    
    function new(string name="USB2p0_FS_CT_get_configuration_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_LS;
   	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        fs_get_config_vseq = usb2p0_fs_ct_get_configuration_vsequence::type_id::create("fs_get_config_vseq"); 	
        fs_set_config_vseq = usb2p0_fs_ct_set_configuration_vsequence::type_id::create("fs_set_config_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("fS_CONTROL_TRANSFER_TEST","ENTERED_USB2p0_FS_CT_SET_CONFIGURATION",UVM_LOW)
      phase.raise_objection(this);
        fs_set_config_vseq.start(usb_environment.usb_vseqr);
        #700000;
        fs_get_config_vseq.start(usb_environment.usb_vseqr);
        #2000000;
      phase.drop_objection(this);   
     `uvm_info("FS_CONTROL_TRANSFER_TEST","COMPLETED_USB2p0_FS_CT_SET_CONFIGURATION",UVM_LOW)
  endtask

endclass




