class usb2p0_ls_ct_data_stage_vsequence extends usb2p0_base_virtual_sequence;
    `uvm_object_utils(usb2p0_ls_ct_data_stage_vsequence)

    USB2p0_phy_LS_detect_sequence             phy_ls_det;
    USB2p0_phy_LS_data_stage_sequence         phy_data_stage_seq;
    USB2p0_DEVICE_ls_setup_hs_sequence        device_ls_det;
    USB2p0_DEVICE_ls_send_hs_sequence         device_handshake_send;
    usb2p0_host_ls_ct_data_stage_in_sequence  data_in_token_seq;

  function new (string name = "usb2p0_ls_ct_data_stage_vsequence");
    super.new(name);
  endfunction

  extern task body();
  
endclass

task usb2p0_ls_ct_data_stage_vsequence::body();

     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","ENTERED_INTO_LS_CONTROL_TRANSFER_DATA_STAGE_VSEQ ",UVM_LOW)
    phy_ls_det=USB2p0_phy_LS_detect_sequence::type_id::create("phy_ls_det");
    phy_data_stage_seq=USB2p0_phy_LS_data_stage_sequence::type_id::create("phy_data_stage_seq");
    device_ls_det=USB2p0_DEVICE_ls_setup_hs_sequence::type_id::create("device_ls_det");
    device_handshake_send=USB2p0_DEVICE_ls_send_hs_sequence::type_id::create("device_handshake_send");
    data_in_token_seq=usb2p0_host_ls_ct_data_stage_in_sequence::type_id::create("data_in_token_seq");

     fork 
        begin
	   data_in_token_seq.start(p_sequencer.host_seqr);
	end

        begin
           phy_ls_det.start(p_sequencer.phy_seqr);
	end
   
        begin
   	  device_ls_det.start(p_sequencer.device_seqr); 
	end

        begin
  	  device_handshake_send.start(p_sequencer.device_seqr); 
	end

        begin
          phy_data_stage_seq.start(p_sequencer.phy_seqr);
	end

    join
     `uvm_info("LS_CONTROL_TRANSFER_VSEQ","COMPLETED_INTO_LS_CONTROL_TRANSFER_DATA_STAGE_VSEQ ",UVM_LOW)
endtask


