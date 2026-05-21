class usb2p0_ls_control_transfer_test extends USB2p0_base_test;
  
   `uvm_component_utils(usb2p0_ls_control_transfer_test)
 
    usb2p0_ls_control_transfer_vsequence         ls_control_transfer_vseq; 
  
    function new(string name="usb2p0_ls_control_transfer_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_LS;
   	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        ls_control_transfer_vseq = usb2p0_ls_control_transfer_vsequence::type_id::create("ls_control_transfer_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
	   super.run_phase(phase);
     `uvm_info("LS_CTRL_TRSFR_TEST","ENTERED_INTO_LS_CONTROL_TRANSFER_TEST ",UVM_LOW)
      phase.raise_objection(this);
        ls_control_transfer_vseq.start(usb_environment.usb_vseqr);
        phase.phase_done.set_drain_time(this,2000000000);
      phase.drop_objection(this);   
     `uvm_info("LS_CTRL_TRSFR_TEST","COMPLETED_LS_CONTROL_TRANSFER_TEST ",UVM_LOW)
  endtask

endclass




