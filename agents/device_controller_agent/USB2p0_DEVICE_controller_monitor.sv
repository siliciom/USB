class USB2p0_DEVICE_controller_monitor extends uvm_monitor;
  
  `uvm_component_utils(USB2p0_DEVICE_controller_monitor)

   virtual USB2p0_device_utmi_interface     utmi_interface_tx;
   virtual USB2p0_device_utmi_interface     utmi_interface_rx;
  
    USB2p0_sequence_item             usb_device_rx_seq_item;
    USB2p0_sequence_item             usb_device_tx_seq_item;

    //uvm_analysis_port #(USB2p0_sequence_item) device_tx_mon_ap;
    //uvm_analysis_port #(USB2p0_sequence_item) device_rx_mon_ap;

   
      bit [15:0] data16;
      bit [7:0]  data8;
      bit [DATA_WIDTH-1:0] tx_queue[$];
      uvm_event data_stage_done_ev;
      uvm_event ack_done_ev;
      uvm_event ack_done_driv;
     function new(string name="USB2p0_DEVICE_controller_monitor", uvm_component parent);
          super.new(name,parent);
     endfunction
  
     function void build_phase(uvm_phase phase);
       super.build_phase(phase);
       //device_tx_mon_ap = new("device_tx_mon_ap", this);
       //device_rx_mon_ap = new("device_rx_mon_ap", this);
        data_stage_done_ev = uvm_event_pool::get_global_pool().get("DATA_STAGE_DONE_EVENT");
        ack_done_ev = uvm_event_pool::get_global_pool().get("ACK_DONE_EVENT");
        ack_done_driv = uvm_event_pool::get_global_pool().get("ACK_DONE_DRIVER_EVENT");
       if (!uvm_config_db#(virtual USB2p0_device_utmi_interface)::get(this, "", "USB_DEVICE_UTMI_INTERFACE", utmi_interface_rx))
         `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")
       if (!uvm_config_db#(virtual USB2p0_device_utmi_interface)::get(this, "", "USB_DEVICE_UTMI_INTERFACE", utmi_interface_tx))
         `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")
      endfunction
       

     task run_phase(uvm_phase phase); 
         //forever begin
           fork
             collect_from_utmi_rx();
             collect_from_utmi_tx();
           join_none
         //end
     endtask
  
task collect_from_utmi_tx();
   bit packet_started;
   bit [7:0] first_byte_8;
   bit [15:0] first_byte_16;
  
   forever begin
    `uvm_info("DEVICE_MONITOR","ENTERED_INTO_DEVICE_COLLECT_UTMI_TX_SIGNALS",UVM_LOW)
     usb_device_tx_seq_item = USB2p0_sequence_item::type_id::create("usb_device_tx_seq_item");
     tx_queue.delete();
    wait (utmi_interface_tx.utmi_txvalid && utmi_interface_tx.utmi_txready);
    // tx_queue.delete();
      @(negedge utmi_interface_tx.cb_utmi_device_controller_monitor);
      while ((utmi_interface_tx.utmi_txvalid || utmi_interface_tx.utmi_txvalidh)) begin
        // @(negedge utmi_interface_tx.cb_utmi_device_controller_monitor);
         usb_device_tx_seq_item.tx_valid = utmi_interface_tx.utmi_txvalid;
         usb_device_tx_seq_item.tx_validh = utmi_interface_tx.utmi_txvalidh;
         usb_device_tx_seq_item.tx_ready = utmi_interface_tx.utmi_txready;
         usb_device_tx_seq_item.suspend_n = utmi_interface_tx.utmi_suspend_n;
         usb_device_tx_seq_item.op_mode = utmi_interface_tx.utmi_opmode;
         usb_device_tx_seq_item.word_if = utmi_interface_tx.utmi_word_if;
         usb_device_tx_seq_item.term_select = utmi_interface_tx.utmi_termselect;
         usb_device_tx_seq_item.xcvr_select = utmi_interface_tx.utmi_xcvrselect;
         usb_device_tx_seq_item.fsls_low_power = utmi_interface_tx.utmi_fsls_low_power;
         usb_device_tx_seq_item.fsls_serialmode = utmi_interface_tx.utmi_fslsserialmode;
         usb_device_tx_seq_item.otg_dppulldown = utmi_interface_tx.utmiotg_dppulldown;
         usb_device_tx_seq_item.otg_dmpulldown = utmi_interface_tx.utmiotg_dmpulldown;
         //usb_device_tx_seq_item.utmi_txdata.delete();
         `uvm_info("DEVICE_MONITOR","COLLECT_VALID_VALIDH",UVM_LOW)
         if (usb_device_tx_seq_item.word_if && usb_device_tx_seq_item.tx_validh) begin
            tx_queue.push_back(utmi_interface_tx.utmi_txdata);
            //tx_queue.push_back(utmi_interface_tx.utmi_txdata[7:0]);
            //tx_queue.push_back(utmi_interface_tx.utmi_txdata[15:8]);
            `uvm_info("DEVICE_MONITOR",$sformatf("16BIT_CAPTURED_TX_DATA = %p",tx_queue),UVM_LOW)
         end
         else begin
         tx_queue.push_back(utmi_interface_tx.utmi_txdata[7:0]);
         `uvm_info("DEVICE_MONITOR",$sformatf("8BIT_CAPTURED_TX_DATA = %p",tx_queue),UVM_LOW)
         end
         @(negedge utmi_interface_tx.cb_utmi_device_controller_monitor);
         usb_device_tx_seq_item.utmi_txdata = tx_queue;
         `uvm_info("DEVICE_MONITOR","DEVICE_MONITOR_COLLECTED_UTMI_TX_SIGNALS",UVM_LOW)
      end //while begin end
        `uvm_info("DEVICE_MONITOR","COLLECTED_UTMI_TX_SIGNALS",UVM_LOW)
         usb_device_tx_seq_item.print();
         
    end
endtask


task collect_from_utmi_rx();
   bit [15:0] collect_data16;
   bit [7:0]  collect_data8;
   bit [7:0]  first_byte;
  
  forever begin
   usb_device_rx_seq_item = USB2p0_sequence_item::type_id::create("usb_device_rx_seq_item");
   wait (utmi_interface_rx.utmi_rxvalid || utmi_interface_rx.utmi_rxvalidh);
     @(negedge utmi_interface_rx.cb_utmi_device_controller_monitor);
     usb_device_rx_seq_item.rx_valid       = utmi_interface_rx.utmi_rxvalid;
     usb_device_rx_seq_item.rx_validh      = utmi_interface_rx.utmi_rxvalidh;
     usb_device_rx_seq_item.rx_active      = utmi_interface_rx.utmi_rxactive;  
     usb_device_rx_seq_item.word_if        = utmi_interface_rx.utmi_word_if;
     usb_device_rx_seq_item.rx_active      = utmi_interface_rx.utmi_rxactive;
     first_byte = utmi_interface_rx.utmi_rxdata[7:0];
     usb_device_rx_seq_item.rx_data.push_back(first_byte);
     while(utmi_interface_rx.utmi_rxvalid)begin
       @(negedge utmi_interface_rx.cb_utmi_device_controller_monitor);
        if (usb_device_rx_seq_item.rx_valid && usb_device_rx_seq_item.rx_validh) begin 
            collect_data16 = utmi_interface_rx.utmi_rxdata;
            `uvm_info("DEVICE_MONITOR",$sformatf("16BIT_DATA_ON_RX = %b validh=%0d", collect_data16,usb_device_rx_seq_item.rx_validh),UVM_LOW)
             usb_device_rx_seq_item.rx_data.push_back(collect_data16);
           `uvm_info("DEVICE_MONITOR",$sformatf("16BIT_DATA_ON_RX = %p", usb_device_rx_seq_item.rx_data),UVM_LOW)
         end
         else if(usb_device_rx_seq_item.rx_valid && !usb_device_rx_seq_item.rx_validh) begin 
            collect_data8 = utmi_interface_rx.utmi_rxdata;
            `uvm_info("DEVICE_MONITOR",$sformatf("8BIT_DATA_ON_RX = %h valid=%0d", collect_data8,usb_device_rx_seq_item.rx_valid),UVM_LOW)
             usb_device_rx_seq_item.rx_data.push_back(collect_data8);
            `uvm_info("DEVICE_MONITOR",$sformatf("8BIT_DATA_ON_RX = %p", usb_device_rx_seq_item.rx_data),UVM_LOW)
         end
        end
         `uvm_info("DEVICE_MONITOR","DEVICE_RX_PACKET_COMPLETE",UVM_LOW)
          usb_device_rx_seq_item.print();
           //if (usb_device_rx_seq_item.rx_data.size() > 0) begin
           if (usb_device_rx_seq_item.rx_data.size() == 1 &&  usb_device_rx_seq_item.rx_data[0] == 8'h2D) begin
             // if (usb_device_rx_seq_item.rx_data[0] == 8'h2D) begin // ACK PID
                  `uvm_info("DEVICE_MONITOR","ACK_RECEIVED_FROM_HOST_DATA_STAGE_COMPLETE",UVM_LOW)
                   data_stage_done_ev.trigger();
              //end
           end
           ack_done_ev.trigger();
           ack_done_driv.trigger();
      end
endtask
 
endclass

