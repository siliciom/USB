class USB2p0_environment extends uvm_env;

  `uvm_component_utils(USB2p0_environment)

 	 USB2p0_HOST_controller_agent      host_agent;
  	 USB2p0_PHY_agent                  phy_agent;
  	 USB2p0_DEVICE_controller_agent    device_agent;
  	 usb2p0_scoreboard                 usb_scoreboard;
  	 usb2p0_subscriber                 usb_subscriber;
 	 usb2p0_env_config 		   usb_ecfg;
         usb2p0_base_virtual_sequencer     usb_vseqr;

  	function new(string name="USB2P0_ENV",uvm_component parent);
    		super.new(name,parent);
  	endfunction

  	function void build_phase(uvm_phase phase);
 	  `uvm_info(" USB2p0_ENV ","ENTERED BUILD PHASE",UVM_LOW)
   	   super.build_phase(phase);

            if(!uvm_config_db#(usb2p0_env_config)::get(this,"","usb2p0_env_config",usb_ecfg))begin
               `uvm_fatal("USB2p0_ENV","cannot get() config")
            end

 	    `uvm_info(" USB2p0_ENV ","CREATED HOST AGENT ",UVM_LOW)
	    if(usb_ecfg.has_host) begin
 	      `uvm_info(" USB2p0_ENV ","CREATED HOST AGENT ",UVM_LOW)
    	       host_agent = USB2p0_HOST_controller_agent::type_id::create("host_agent",this);
 	      `uvm_info(" USB2p0_ENV ","CREATED HOST AGENT ",UVM_LOW)
	    end 
 
	    if(usb_ecfg.has_device) begin
    	      device_agent   =  USB2p0_DEVICE_controller_agent::type_id::create("device_agent",this);
 	      `uvm_info(" USB2p0_ENV ","CREATED DEVICE AGENT ",UVM_LOW)
	    end 
	    if(usb_ecfg.has_phy) begin
    	      phy_agent      =   USB2p0_PHY_agent::type_id::create("phy_agent",this);
 		`uvm_info(" USB2p0_ENV ","CREATED PHYS AGENT ",UVM_LOW)
	    end 
 
 	if(usb_ecfg.has_virtual_sequencer)
 	begin
 		usb_vseqr=usb2p0_base_virtual_sequencer::type_id::create("usb_vseqr",this);
 		`uvm_info(" USB2p0_ENV ","CREATED VIRTUAL SEQR ",UVM_LOW)
 	end
 
	if(usb_ecfg.has_sb)
 	begin
 		usb_scoreboard=usb2p0_scoreboard::type_id::create("usb_scoreboard",this);
 		`uvm_info(" USB2p0_ENV ","CREATED USB2P0 SCOREBOARD ",UVM_LOW)
 	end
 
	if(usb_ecfg.has_subscriber)
 	begin
 		usb_subscriber = usb2p0_subscriber::type_id::create("usb_subscriber",this);
 		`uvm_info(" ACE ENV ","ENTERED SUBSCRIBER ",UVM_LOW)
 	end
 		`uvm_info(" ACE ENV ","COMPLETED BUILD PHASE",UVM_LOW)

        endfunction

  	function void connect_phase(uvm_phase phase);
    		super.connect_phase(phase);
		`uvm_info(" USB2p0_ENV ","ENTERED CONNECT PHASE",UVM_LOW)
		if(usb_ecfg.has_virtual_sequencer) begin
 			`uvm_info(" USB2p0_ENV ","ENTERED CONNECT PHASE - HAS VIRTUAL SEQUENCER",UVM_LOW)
 			if(usb_ecfg.has_host) begin
 			   usb_vseqr.host_seqr=host_agent.host_controller_sequencer;
 			end
 			if(usb_ecfg.has_device)	begin
 			   usb_vseqr.device_seqr=device_agent.device_controller_sequencer;
//                           device_agent.device_controller_monitor.device_rx_mon_ap.connect(device_agent.device_controller_driver.fifo_ap.analysis_export);
 			end
 			if(usb_ecfg.has_phy) begin
 			   usb_vseqr.phy_seqr=phy_agent.phy_sequencer;
 			end
 		end
 
		if(usb_ecfg.has_sb)begin
 			`uvm_info(" USB2p0_ENV ","ENTERED CONNECT PHASE - SCOREBOARD ",UVM_LOW)
 			  host_agent.host_controller_monitor.host_tx_mon_ap.connect(usb_scoreboard.host_tx_imp);
 			  host_agent.host_controller_monitor.host_rx_mon_ap.connect(usb_scoreboard.host_rx_imp);
 		end
 		if(usb_ecfg.has_sb)begin
                          device_agent.device_controller_monitor.device_tx_mon_ap.connect(usb_scoreboard.device_tx_imp);
                          device_agent.device_controller_monitor.device_rx_mon_ap.connect(usb_scoreboard.device_rx_imp);
 		end
 
		if(usb_ecfg.has_subscriber)begin
 			`uvm_info(" USB2p0_ENV ","ENTERED CONNECT PHASE - SUBSCRIBER ",UVM_LOW)
 		     host_agent.host_controller_monitor.host_sub_tx_mon_ap.connect(usb_subscriber.analysis_export);
                     host_agent.host_controller_monitor.host_sub_rx_mon_ap.connect(usb_subscriber.analysis_export);        
 		end
 		if(usb_ecfg.has_subscriber)begin
 	         device_agent.device_controller_monitor.device_sub_tx_mon_ap.connect(usb_subscriber.analysis_export);
	         device_agent.device_controller_monitor.device_sub_rx_mon_ap.connect(usb_subscriber.analysis_export); 	
         	end
		`uvm_info(" USB2p0_ENV ","COMPLETED CONNECT PHASE",UVM_LOW)
  	endfunction

endclass
  
  

