class USB2p0_HS_isochronous_out_error_test extends USB2p0_base_test;
  
   `uvm_component_utils(USB2p0_HS_isochronous_out_error_test)
     
    usb2p0_hs_isochronous_out_error_vsequence                 hs_iso_vseq;

    function new(string name="USB2p0_HS_isochronous_out_error_test",uvm_component parent);
       super.new(name,parent);
     endfunction
    
    function void build_phase(uvm_phase phase);
    	super.build_phase(phase);
      	usb_speed = USB_HS;
    	uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed);
        hs_iso_vseq = usb2p0_hs_isochronous_out_error_vsequence::type_id::create("hs_iso_vseq"); 	
    endfunction
  

   task run_phase(uvm_phase phase);
     `uvm_info("HS_ISO_TRANSFER_TEST","ENTERED_USB2p0_HS_ISO_OUT_ERROR",UVM_LOW)
      phase.raise_objection(this);
        hs_iso_vseq.start(usb_environment.usb_vseqr);
        #200000;
      phase.drop_objection(this);   
     `uvm_info("HS_ISO_TRANSFER_TEST","COMPLETED_USB2p0_HS_ISO_OUT_ERROR",UVM_LOW)
  endtask

endclass




