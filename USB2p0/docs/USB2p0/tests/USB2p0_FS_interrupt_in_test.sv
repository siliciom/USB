class USB2p0_FS_interrupt_in_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_FS_interrupt_in_test)
     
    usb2p0_fs_ct_get_descriptor_vsequence            fs_get_descri_vseq;
    usb2p0_fs_ct_set_configuration_vsequence       fs_set_config_vseq; 
    usb2p0_fs_interrupt_in_vsequence                 fs_interrupt_vseq;

    function new(string name="USB2p0_FS_interrupt_in_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_FS;
    	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        fs_set_config_vseq = usb2p0_fs_ct_set_configuration_vsequence::type_id::create("fs_set_config_vseq"); 	
        fs_interrupt_vseq = usb2p0_fs_interrupt_in_vsequence::type_id::create("fs_interrupt_vseq"); 	
        fs_get_descri_vseq = usb2p0_fs_ct_get_descriptor_vsequence::type_id::create("fs_get_descri_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("FS_INTERRUPT_TRANSFER_TEST","ENTERED_USB2p0_FS_INTERRUPT_IN",UVM_LOW)
      phase.raise_objection(this);
        fs_get_descri_vseq.start(usb_environment.usb_vseqr);
        #200000;
       // ls_set_ep1_config_vseq.start(usb_environment.usb_vseqr);
       //#200000;
        fs_set_config_vseq.start(usb_environment.usb_vseqr);
        #2000000;
        fs_interrupt_vseq.start(usb_environment.usb_vseqr);
        #20000000;
      phase.drop_objection(this);   
     `uvm_info("FS_INTERRUPT_TRANSFER_TEST","COMPLETED_USB2p0_FS_INTERRUPT_IN",UVM_LOW)
  endtask

endclass




