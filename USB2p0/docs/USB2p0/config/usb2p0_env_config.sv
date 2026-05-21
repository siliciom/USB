class usb2p0_env_config extends uvm_object;
 	`uvm_object_utils(usb2p0_env_config)

	bit has_host =1;
	bit has_phy =1;
 	bit has_device =1;
 
	bit has_passive_slave;
 
	bit has_sb = 1;
 	bit has_coverage = 1;
 	bit has_subscriber = 1;
 	bit has_virtual_sequencer = 1;
 
   extern function new (string name = "usb2p0_env_config");
 
endclass
 
function usb2p0_env_config::new(string name = "usb2p0_env_config");
 	super.new(name);
 endfunction
 
