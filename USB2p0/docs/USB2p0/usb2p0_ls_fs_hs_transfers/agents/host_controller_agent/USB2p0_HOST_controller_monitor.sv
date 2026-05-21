class USB2p0_HOST_controller_monitor extends uvm_monitor;
    
   `uvm_component_utils(USB2p0_HOST_controller_monitor)


      virtual USB2p0_host_utmi_interface         utmi_interface_tx;
      virtual USB2p0_host_utmi_interface         utmi_interface_rx;

      uvm_analysis_port #(USB2p0_sequence_item) host_tx_mon_ap;
      uvm_analysis_port #(USB2p0_sequence_item) host_rx_mon_ap;

      USB2p0_sequence_item  usb_host_tx_seq_item;
      USB2p0_sequence_item  usb_host_rx_seq_item;
      USB2p0_sequence_item usb_host_seq_item;
 
      bit [DATA_WIDTH-1:0] tx_queue[$];
     // bit [15:0] tx_queue[$];
      bit [15:0] data16;
      bit [7:0]  data8;
      uvm_event_pool usb_event_pool;
      uvm_event   ack_done_ev;
      uvm_event   ack_done_zlp_ev;
      uvm_event   ack_done_get_status_ev;
      uvm_event   interrupt_transfer_ev;

      function new(string name="USB2p0_HOST_controller_monitor", uvm_component parent);
        super.new(name,parent);
      endfunction
 
      function void build_phase(uvm_phase phase);
        super.build_phase(phase);
         host_tx_mon_ap = new("host_tx_mon_ap", this);
         host_rx_mon_ap = new("host_rx_mon_ap", this);
         usb_host_seq_item = USB2p0_sequence_item::type_id::create("usb_host_seq_item");
         usb_event_pool = uvm_event_pool::get_global_pool();
         ack_done_ev = usb_event_pool.get("ACK_DONE_EVENT");
         ack_done_zlp_ev = usb_event_pool.get("ACK_ZLP_DONE_EVENT");
         ack_done_get_status_ev = usb_event_pool.get("ACK_GET_STATUS_DONE_EVENT");
         interrupt_transfer_ev = usb_event_pool.get("INTERRUPT_TRANSFER_EVENT");
         if (!uvm_config_db#(virtual USB2p0_host_utmi_interface)::get(this, "", "USB_HOST_UTMI_INTERFACE", utmi_interface_tx)) begin
          `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")
        end
       if (!uvm_config_db#(virtual USB2p0_host_utmi_interface)::get(this, "", "USB_HOST_UTMI_INTERFACE", utmi_interface_rx))
         `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")
      endfunction
 
      task run_phase(uvm_phase phase);
        //forever begin
         fork
           collect_utmi_tx_data();
           collect_from_utmi_rx();
         join_none
        //end
     endtask

task collect_utmi_tx_data();
   bit packet_started;
   bit [7:0] first_byte_8;
   bit [15:0] first_byte_16;
forever begin
   `uvm_info("HOST_MONITOR","ENTERED_INTO_COLLECT_UTMI_TX_SIGNALS",UVM_LOW)
    usb_host_seq_item = USB2p0_sequence_item::type_id::create("usb_host_seq_item");
    tx_queue.delete();
   wait (utmi_interface_tx.utmi_txvalid && utmi_interface_tx.utmi_txready);
      @(negedge utmi_interface_tx.cb_utmi_host_controller_monitor);
      //@(negedge utmi_interface_tx.utmi_clk);
      while ((utmi_interface_tx.utmi_txvalid || utmi_interface_tx.utmi_txvalidh)) begin
         usb_host_seq_item.tx_valid     = utmi_interface_tx.utmi_txvalid;
         usb_host_seq_item.tx_validh    = utmi_interface_tx.utmi_txvalidh;
         usb_host_seq_item.tx_ready     = utmi_interface_tx.utmi_txready;
         usb_host_seq_item.suspend_n    = utmi_interface_tx.utmi_suspend_n;
         usb_host_seq_item.op_mode      = utmi_interface_tx.utmi_opmode;
         usb_host_seq_item.word_if      = utmi_interface_tx.utmi_word_if;
         usb_host_seq_item.term_select  = utmi_interface_tx.utmi_termselect;
         usb_host_seq_item.xcvr_select  = utmi_interface_tx.utmi_xcvrselect;
         usb_host_seq_item.fsls_low_power  = utmi_interface_tx.utmi_fsls_low_power;
         usb_host_seq_item.fsls_serialmode = utmi_interface_tx.utmi_fslsserialmode;
         usb_host_seq_item.otg_dppulldown  = utmi_interface_tx.utmiotg_dppulldown;
         usb_host_seq_item.otg_dmpulldown  = utmi_interface_tx.utmiotg_dmpulldown;
         `uvm_info("HOST_MONITOR","COLLECT_VALID_VALIDH",UVM_LOW)
         if (usb_host_seq_item.word_if && usb_host_seq_item.tx_validh) begin
            //tx_queue.push_back(utmi_interface_tx.utmi_txdata[7:0]);
            //tx_queue.push_back(utmi_interface_tx.utmi_txdata[15:8]);
            tx_queue.push_back(utmi_interface_tx.utmi_txdata);
            `uvm_info("HOST_MONITOR",$sformatf("16BIT_CAPTURED_TX_DATA = %p",tx_queue),UVM_LOW)
         end
         else begin
         tx_queue.push_back(utmi_interface_tx.utmi_txdata[7:0]);
         `uvm_info("HOST_MONITOR",$sformatf("8BIT_CAPTURED_TX_DATA = %p",tx_queue),UVM_LOW)
         end
         usb_host_seq_item.utmi_txdata = tx_queue;
         `uvm_info("HOST_MONITOR","HOST_MONITOR_COLLECTED_UTMI_TX_SIGNALS",UVM_LOW)
         @(negedge utmi_interface_tx.cb_utmi_host_controller_monitor);
         //@(negedge utmi_interface_tx.utmi_clk);
      end //while begin end
      `uvm_info("HOST_MONITOR","WHILE_LOOP_EXIT_IN_HOST_MONITOR",UVM_LOW)
       `uvm_info("HOST_MONITOR","COLLECTED_UTMI_TX_SIGNALS",UVM_LOW)
       usb_host_seq_item.print();
       host_tx_mon_ap.write(usb_host_seq_item);
     end
endtask


task collect_from_utmi_rx();
   bit [15:0] collect_data16;
   bit [7:0]  collect_data8;
   bit [7:0]  first_byte;
   bit [15:0]  first_byte_16;

forever begin
   usb_host_rx_seq_item = USB2p0_sequence_item::type_id::create("usb_host_rx_seq_item");
   tx_queue.delete();
   wait (utmi_interface_rx.utmi_rxvalid || utmi_interface_rx.utmi_rxvalidh);
     @(negedge utmi_interface_rx.cb_utmi_host_controller_monitor);
     usb_host_rx_seq_item.rx_valid       = utmi_interface_rx.utmi_rxvalid;
     usb_host_rx_seq_item.rx_validh      = utmi_interface_rx.utmi_rxvalidh;
     usb_host_rx_seq_item.rx_active      = utmi_interface_rx.utmi_rxactive;  
     usb_host_rx_seq_item.word_if        = utmi_interface_rx.utmi_word_if;
     usb_host_rx_seq_item.rx_active      = utmi_interface_rx.utmi_rxactive;
      if(!usb_host_rx_seq_item.word_if)begin
        first_byte = utmi_interface_rx.utmi_rxdata[7:0];
        usb_host_rx_seq_item.rx_data.push_back(first_byte);
       end
       else if (usb_host_rx_seq_item.word_if)begin
         first_byte_16 = utmi_interface_rx.utmi_rxdata;
         usb_host_rx_seq_item.rx_data.push_back(first_byte_16);
       end
        while(utmi_interface_rx.utmi_rxvalid)begin
         @(negedge utmi_interface_rx.cb_utmi_host_controller_monitor);
          if (usb_host_rx_seq_item.rx_valid && usb_host_rx_seq_item.rx_validh) begin 
              collect_data16 = utmi_interface_rx.utmi_rxdata;
              `uvm_info("HOST_MONITOR",$sformatf("16BIT_DATA_ON_RX = %h validh=%0d", collect_data16,usb_host_rx_seq_item.rx_validh),UVM_LOW)
               usb_host_rx_seq_item.rx_data.push_back(collect_data16);
             `uvm_info("HOST_MONITOR",$sformatf("16BIT_DATA_ON_RX = %p", usb_host_rx_seq_item.rx_data),UVM_LOW)
           end
           else if(usb_host_rx_seq_item.rx_valid && !usb_host_rx_seq_item.rx_validh) begin 
              collect_data8 = utmi_interface_rx.utmi_rxdata;
              `uvm_info("HOST_MONITOR",$sformatf("8BIT_DATA_ON_RX = %h valid=%0d", collect_data8,usb_host_rx_seq_item.rx_valid),UVM_LOW)
               usb_host_rx_seq_item.rx_data.push_back(collect_data8);
              `uvm_info("HOST_MONITOR",$sformatf("8BIT_DATA_ON_RX = %p", usb_host_rx_seq_item.rx_data),UVM_LOW)
           end
           //`uvm_info("HOST_MONITOR","HOST_RX_PACKET_COMPLETE",UVM_LOW)
            //usb_host_rx_seq_item.print();
            //host_rx_mon_ap.write(usb_host_rx_seq_item);
          end
           `uvm_info("HOST_MONITOR","HOST_RX_PACKET_COMPLETE",UVM_LOW)
            usb_host_rx_seq_item.print();
	    if(usb_host_rx_seq_item.rx_data.size() > 0)
            usb_host_rx_seq_item.rx_valid = 1'b1;
            if(usb_host_rx_seq_item.word_if &&
            usb_host_rx_seq_item.rx_data.size() > 0) begin
	    usb_host_rx_seq_item.rx_valid  = 1'b1;
            usb_host_rx_seq_item.rx_validh = 1'b1;
            end
            host_rx_mon_ap.write(usb_host_rx_seq_item);
          // if (usb_host_rx_seq_item.rx_data.size() == 1 &&  usb_host_rx_seq_item.rx_data[0] == 8'h2D) begin
          //        `uvm_info("DEVICE_MONITOR","ACK_RECEIVED_FROM_HOST_DATA_STAGE_COMPLETE",UVM_LOW)
          // end
            ack_done_ev.trigger();
            ack_done_zlp_ev.trigger();
            ack_done_get_status_ev.trigger();
            interrupt_transfer_ev.trigger();
          end
endtask
 

endclass

