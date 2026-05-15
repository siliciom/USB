class USB2p0_FS_detect_test extends USB2p0_base_test;
  
  `uvm_component_utils(USB2p0_FS_detect_test)
  
   usb2p0_host_FS_detect_sequence       host_hs_det;
   USB2p0_phy_FS_detect_sequence        phy_hs_det;
   USB2p0_DEVICE_FS_detect_sequence     device_hs_det;
  
   function new(string name="USB2p0_FS_detect_test",uvm_component parent);
      super.new(name,parent);
   endfunction
    
   function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       usb_speed = USB_FS;
       host_hs_det   = usb2p0_host_FS_detect_sequence::type_id::create("host_hs_det",this);
       phy_hs_det    = USB2p0_phy_FS_detect_sequence::type_id::create("phy_hs_det",this);
       device_hs_det = USB2p0_DEVICE_FS_detect_sequence::type_id::create("device_hs_det",this);
       uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed); 
      //usb_speed = USB_HS;
  endfunction
  
  task run_phase(uvm_phase phase);
      
     phase.raise_objection(this);
     
      fork 
	   begin
		       host_hs_det.start(usb_environment.host_agent.host_controller_sequencer);
      	   end
	     begin
	 	       phy_hs_det.start(usb_environment.phy_agent.phy_sequencer);
            end
         begin
                       device_hs_det.start(usb_environment.device_agent.device_controller_sequencer); 
         end 
     join 
            //  phase.phase_done.set_drain_time(this,100600);
	 phase.drop_objection(this);   
  endtask

endclass

