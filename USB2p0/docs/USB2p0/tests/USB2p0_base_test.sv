`include "uvm_macros.svh"
import uvm_pkg::*;
//import USB2p0_pkg::*;

class USB2p0_base_test extends uvm_test;
  
   `uvm_component_utils(USB2p0_base_test)
  
   USB2p0_environment       usb_environment;
   USB2p0_HOST_sequence     usb_host_sequence;
   USB2p0_PHY_sequence       phy_seq;
   USB2p0_DEVICE_sequence    usb_device_sequence;
   speed_state               usb_speed;
   usb2p0_env_config         usb_env_config;

    function new(string name="USB2p0_base_test",uvm_component parent);
        super.new(name,parent);
    endfunction
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
           usb_env_config = usb2p0_env_config::type_id::create("usb_env_config");
           uvm_config_db#(usb2p0_env_config)::set(this, "*", "usb2p0_env_config", usb_env_config);

	   uvm_config_db#(speed_state)::set(null, "*", "USB_SPEED",usb_speed); 

           usb_environment=USB2p0_environment::type_id::create("usb_environment",this);
 	   `uvm_info(" USB2p0_ENV ","CREATED USB_ENV  ",UVM_LOW)
           
     endfunction
  
     function void end_of_elaboration_phase(uvm_phase phase); 
          uvm_top.print_topology;
     endfunction

endclass
   







