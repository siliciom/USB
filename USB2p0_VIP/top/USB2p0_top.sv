////////////////-----------TOP MODULE-----------////////////////////////

`include "uvm_macros.svh"
`include "USB2p0_UTMI_interface.sv"
`include "USB2p0_PHY_interface.sv"


module USB2p0_top;

import USB2p0_pkg::*;
 import uvm_pkg::*;

  
  bit   utmi_clk;
  bit   phy_clk;

 speed_state usb_speed;

 `ifdef UTMI_16BIT
      `define DATA_WIDTH 16
  `else
      `define DATA_WIDTH 8
  `endif


  USB2p0_host_utmi_interface       usb_host_utmi_intf(utmi_clk);
  USB2p0_device_utmi_interface     usb_device_utmi_intf(utmi_clk);
  USB2p0_PHY_interface             usb_phy_intf(phy_clk); 

initial begin
  real phy_period;
  real utmi_period;
  
  utmi_clk = 0;
  phy_clk  = 0;
  #1;

  if (!uvm_config_db#(speed_state)::get(null, "", "USB_SPEED", usb_speed)) begin
    $fatal("USB_SPEED not set from test");
  end

  case (usb_speed)

    USB_LS: begin
      phy_period  = 333.33;
      utmi_period = 2666.34;
   `uvm_info("TOP","LOW SPEED CLK",UVM_LOW);
    end

    USB_FS: begin
      phy_period  = 41.03;
      utmi_period = 333.33;
   `uvm_info("TOP","FULL SPEED CLK",UVM_LOW);
    end

    USB_HS: begin
      phy_period  = 1.041;
      utmi_period = 16.47;
   `uvm_info("TOP","HIGH SPEED CLK",UVM_LOW);
    end
  endcase

  fork
    forever #(phy_period)  phy_clk  = ~phy_clk;
    forever #(utmi_period) utmi_clk = ~utmi_clk;
  join
end
 
   
  
  initial begin
    //uvm_config_db#(virtual interface USB2p0_UTMI_interface)::set(null,"*","USB_UTMI_INTERFACE_TX", usb_utmi_intf_tx);
    //uvm_config_db#(virtual interface USB2p0_UTMI_interface)::set(null,"*","USB_UTMI_INTERFACE_RX", usb_utmi_intf_rx);
    uvm_config_db#(virtual interface USB2p0_host_utmi_interface)::set(null,"*","USB_HOST_UTMI_INTERFACE", usb_host_utmi_intf);
    uvm_config_db#(virtual interface USB2p0_device_utmi_interface)::set(null,"*","USB_DEVICE_UTMI_INTERFACE", usb_device_utmi_intf);
    uvm_config_db#(virtual interface USB2p0_PHY_interface)::set(null,"*","USB_PHY_INTERFACE",usb_phy_intf);
  end


  initial begin
    run_test(" ");
  end
    
endmodule
