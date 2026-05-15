class USB2p0_PHY_agent extends uvm_agent;
  
    `uvm_component_utils(USB2p0_PHY_agent)
  
     USB2p0_PHY_driver        phy_driver;
     USB2p0_PHY_monitor       phy_monitor;
     USB2p0_PHY_sequencer     phy_sequencer;
  
     function new(string name="USB2p0_PHY_agent",uvm_component parent);
         super.new(name,parent);
     endfunction
  
     function void build_phase(uvm_phase phase);
         super.build_phase(phase);
          phy_driver     = USB2p0_PHY_driver::type_id::create("phy_driver",this);
          phy_monitor    = USB2p0_PHY_monitor::type_id::create("phy_monitor",this);
          phy_sequencer  = USB2p0_PHY_sequencer::type_id::create("phy_sequencer",this);
     endfunction
  
     function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
         phy_driver.seq_item_port.connect(phy_sequencer.seq_item_export);
     endfunction
      
endclass
           
