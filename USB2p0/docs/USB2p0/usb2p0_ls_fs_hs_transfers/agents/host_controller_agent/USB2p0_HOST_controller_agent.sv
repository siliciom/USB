class USB2p0_HOST_controller_agent extends uvm_agent;
  
      `uvm_component_utils(USB2p0_HOST_controller_agent)
  
       USB2p0_HOST_controller_driver        host_controller_driver;
       USB2p0_HOST_controller_monitor       host_controller_monitor;
       USB2p0_HOST_controller_sequencer     host_controller_sequencer;
  
      function new(string name="USB2p0_HOST_controller_agent",uvm_component parent);
        super.new(name,parent);
      endfunction
  
      function void build_phase(uvm_phase phase);
   	 super.build_phase(phase);   
    	 host_controller_driver    = USB2p0_HOST_controller_driver::type_id::create("host_controller_driver",this);
    	 host_controller_monitor   = USB2p0_HOST_controller_monitor::type_id::create("host_controller_monitor",this);
    	 host_controller_sequencer = USB2p0_HOST_controller_sequencer::type_id::create("host_controller_sequencer",this); 
      endfunction
  
      function void connect_phase(uvm_phase phase);
    	  super.connect_phase(phase);
          host_controller_driver.seq_item_port.connect(host_controller_sequencer.seq_item_export);
      endfunction
  
endclass
           
