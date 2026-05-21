class USB2p0_FS_detect_test extends USB2p0_base_test;
  
  `uvm_component_utils(USB2p0_FS_detect_test)
  
   usb2p0_fs_detect_vsequence      fs_detect_vseq;
 
   function new(string name="USB2p0_FS_detect_test",uvm_component parent);
      super.new(name,parent);
   endfunction
    
   function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       usb_speed = USB_FS;
       fs_detect_vseq   = usb2p0_fs_detect_vsequence::type_id::create("fs_detect_vseq",this);
   endfunction
  
  task run_phase(uvm_phase phase);
     `uvm_info("FS_TEST","ENTERED_FS_SPEED_DETECT_TEST",UVM_LOW)
         phase.raise_objection(this);
         fs_detect_vseq.start(usb_environment.host_agent.host_controller_sequencer);
	 phase.drop_objection(this);  
     `uvm_info("FS_TEST","ENTERED_USB2p0_FS_SPEED_DETECT_TEST",UVM_LOW)
  endtask

endclass

