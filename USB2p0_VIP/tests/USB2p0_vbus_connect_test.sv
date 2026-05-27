class USB2p0_vbus_connect_test extends USB2p0_base_test;
  
  `uvm_component_utils(USB2p0_vbus_connect_test)
  
   usb2p0_vbus_connect_vsequence  vbus_connect_vseq; 
  
    function new(string name="USB2p0_vbus_connect_test",uvm_component parent);
    	super.new(name,parent);
    endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
        vbus_connect_vseq = usb2p0_vbus_connect_vsequence::type_id::create("vbus_connect_vseq"); 	
    endfunction
  
   task run_phase(uvm_phase phase);
     `uvm_info("VBUS_CONNECT_TEST","ENTERED_VBUS_CONNECT_TEST",UVM_LOW)
      phase.raise_objection(this);
        vbus_connect_vseq.start(usb_environment.usb_vseqr);
         #200000;
        phase.drop_objection(this);   
     `uvm_info("VBUS_CONNECT_TEST","COMPLETED_VBUS_CONNECT_TEST",UVM_LOW)
  endtask

endclass

