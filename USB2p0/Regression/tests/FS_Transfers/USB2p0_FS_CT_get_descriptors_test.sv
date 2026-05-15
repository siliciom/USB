class usb2p0_fs_ctrl_trans_get_descriptors_test extends USB2p0_base_test;
   `uvm_component_utils(usb2p0_fs_ctrl_trans_get_descriptors_test)

    usb2p0_fs_ctrl_trans_get_descriptor_vsequence         fs_get_descri_vseq; 

   function new(string name="usb2p0_fs_ctrl_trans_get_descriptors_test",uvm_component parent);
       super.new(name,parent);
   endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_FS;
   	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        fs_get_descri_vseq = usb2p0_fs_ctrl_trans_get_descriptor_vsequence::type_id::create("fs_get_descri_vseq"); 	
    endfunction

    task run_phase(uvm_phase phase);
      `uvm_info("FS_CONTROL_TRANSFER_TEST","ENTERED_usb2p0_fs_ctrl_trans_get_descriptors_test",UVM_LOW)
        phase.raise_objection(this);
        fs_get_descri_vseq.start(usb_environment.usb_vseqr);
        phase.phase_done.set_drain_time(this,2000000000);
      phase.drop_objection(this);
      `uvm_info("FS_CONTROL_TRANSFER_TEST","COMPLETED_usb2p0_fs_ctrl_trans_get_descriptors_test",UVM_LOW)
         
  endtask
 
 
endclass

 





