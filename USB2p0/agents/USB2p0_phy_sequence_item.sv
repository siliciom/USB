`include "uvm_macros.svh"
import uvm_pkg::*;

class USB2p0_phy_sequence_item extends uvm_sequence_item;
  
    `uvm_object_utils(USB2p0_phy_sequence_item)
       bit dp,dm; 
       function new(string name="USB2p0_phy_sequence_item");
              super.new(name);
       endfunction
        
endclass




