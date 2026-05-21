class usb2p0_base_virtual_sequence extends uvm_sequence;

    `uvm_object_utils(usb2p0_base_virtual_sequence)
    `uvm_declare_p_sequencer(usb2p0_base_virtual_sequencer)

   usb2p0_base_virtual_sequencer          usb_vseqr;
  
  function new (string name = "usb2p0_base_virtual_sequence");
    super.new(name);
  endfunction
  
endclass


