class USB2p0_HOST_controller_sequencer extends uvm_sequencer #(USB2p0_sequence_item);
  
  `uvm_component_utils(USB2p0_HOST_controller_sequencer)
  
  function new(string name="USB2p0_HOST_controller_sequencer",uvm_component parent);
    super.new(name,parent);
  endfunction
  
endclass
