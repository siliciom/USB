class USB2p0_HOST_sequence extends uvm_sequence #(USB2p0_sequence_item);

   `uvm_object_utils(USB2p0_HOST_sequence)
    USB2p0_sequence_item     usb_host_seq_item;


    function new(string name="USB2p0_HOST_sequence");
       super.new(name);
    endfunction
 
endclass

