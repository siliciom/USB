class USB2p0_DEVICE_hs_isochronous_in_error_sequence extends USB2p0_DEVICE_sequence;

  `uvm_object_utils(USB2p0_DEVICE_hs_isochronous_in_error_sequence)
   USB2p0_sequence_item     req;

     function new(string name="USB2p0_DEVICE_hs_isochronous_in_error_sequence");
        super.new(name);
     endfunction
 
    task body();
        `uvm_info("HS_ISO_TRANSFER_SEQ","STARTED_DEVICE_HS_ISO_TRASFER_ERROR_SEQ ",UVM_LOW)
        req = USB2p0_sequence_item::type_id::create("req");
	if(!req.randomize() with { otg_dmpulldown == 0;
                                   otg_dppulldown == 1;
                                   op_mode        == 2'b00;
                                   word_if        == 1'b1;
                                   tx_valid       == 1'b1;
                                   tx_validh       == 1'b1;
                                   rx_valid       == 1'b1;
                                   rx_validh       == 1'b1;
                                   length == 2056;
                                   foreach(device_payload[i])
                                   !(device_payload[i] inside {8'h04, 8'h7F});
                                   }) begin
				   `uvm_fatal("RAND_FAIL", "Randomization failed")
			   end
                             foreach(req.device_payload[i]) begin
                                `uvm_info("DEVICE_PAYLOAD", $sformatf("device_payload[%0d] = %0h",i,req.device_payload[i]), UVM_LOW)
                             end
         start_item(req);
         finish_item(req);
         `uvm_info("HS_BULK_TRANSFER_SEQ","COMPLETED_DEVICE_HS_BULK_TRANSFER__ERROR_SEQ",UVM_LOW)
    endtask

 endclass
