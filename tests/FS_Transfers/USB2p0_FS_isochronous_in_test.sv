class USB2p0_FS_isochronous_in_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_FS_isochronous_in_test)
     
    usb2p0_fs_ct_get_descriptor_vsequence            fs_get_descri_vseq;
    usb2p0_fs_ct_set_configuration_vsequence         fs_set_config_vseq; 
    usb2p0_fs_isochronous_in_vsequence               fs_iso_vseq;
    //usb2p0_ls_ct_ep1_set_configuration_vsequence     ls_set_ep1_config_vseq; 

    function new(string name="USB2p0_FS_isochronous_in_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_FS;
    	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        fs_set_config_vseq = usb2p0_fs_ct_set_configuration_vsequence::type_id::create("fs_set_config_vseq"); 	
       // ls_set_ep1_config_vseq = usb2p0_ls_ct_ep1_set_configuration_vsequence::type_id::create("ls_set_ep1_config_vseq"); 	
        fs_iso_vseq = usb2p0_fs_isochronous_in_vsequence::type_id::create("fs_iso_vseq"); 	
        fs_get_descri_vseq = usb2p0_fs_ct_get_descriptor_vsequence::type_id::create("fs_get_descri_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("FS_ISO_TRANSFER_TEST","ENTERED_USB2p0_FS_ISO_IN",UVM_LOW)
      phase.raise_objection(this);
        fs_get_descri_vseq.start(usb_environment.usb_vseqr);
        #200000;
       // ls_set_ep1_config_vseq.start(usb_environment.usb_vseqr);
       //#200000;
        fs_set_config_vseq.start(usb_environment.usb_vseqr);
        #2000000;
        fs_iso_vseq.start(usb_environment.usb_vseqr);
        #2000000000;
      phase.drop_objection(this);   
     `uvm_info("FS_ISO_TEST","COMPLETED_USB2p0_FS_ISO_IN",UVM_LOW)
  endtask

endclass




