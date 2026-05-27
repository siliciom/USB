class usb2p0_base_virtual_sequencer extends uvm_sequencer;
    `uvm_component_utils (usb2p0_base_virtual_sequencer)

    USB2p0_PHY_sequencer                 phy_seqr;
    USB2p0_HOST_controller_sequencer     host_seqr;
    USB2p0_DEVICE_controller_sequencer   device_seqr;
    usb2p0_env_config                    usb_ecfg;

  function new (string name = "usb2p0_base_virtual_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
 
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
      if(!uvm_config_db#(usb2p0_env_config)::get(this,"","usb2p0_env_config",usb_ecfg))
             	begin
             		`uvm_fatal("USB2p0_ENV","cannot get() config")
             	end
  endfunction
 
endclass



