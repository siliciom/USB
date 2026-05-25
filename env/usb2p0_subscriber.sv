class usb2p0_subscriber extends uvm_subscriber#(USB2p0_sequence_item);
  
  `uvm_component_utils(usb2p0_subscriber)
  
    USB2p0_sequence_item usb_seq_item;
  
  function new(string name="usb2p0_subscriber",uvm_component parent);
    super.new(name,parent);  
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  
    virtual function void write(USB2p0_sequence_item t);
       usb_seq_item = t;
    endfunction

endclass




    
