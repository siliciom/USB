class USB2p0_DEVICE_controller_driver extends uvm_driver #(USB2p0_sequence_item);
     
    `uvm_component_utils(USB2p0_DEVICE_controller_driver)
  
      USB2p0_sequence_item    usb_seq_item;
      USB2p0_sequence_item    usb_device_rx_seq_item;
      
      virtual USB2p0_device_utmi_interface       utmi_interface_tx;
      virtual USB2p0_device_utmi_interface       utmi_interface_rx;
      virtual USB2p0_host_utmi_interface         host_utmi_interface_rx,host_utmi_interface_tx;
      virtual USB2p0_PHY_interface               usb_phy_interface;

      uvm_event_pool 	usb_event_pool;
      uvm_event         seq_done_ev;
      uvm_event         reset_ev;
      uvm_event         synchronization_event;
      uvm_event         ack_done_ev;
      uvm_event         ack_done_driv;

      bit [4:0]  act_crc5;          
      bit [15:0] act_crc16;
      bit        word_if;
      bit [15:0] data16;
      bit [7:0]  data8;
      bit        valid_request;  
      bit [6:0]  device_address = 0;
      bit [7:0]  bmRequest;
      bit [7:0]  bRequest;
      bit [15:0] wValue;
      bit [15:0] wIndex;
      bit [15:0] wlength;
      bit [6:0]  token_addr;
      bit [3:0]  token_endp;
      bit [3:0]  control_transfer_endp=0;
      bit [3:0]  bulk_transfer_in_endp=1;
      bit [3:0]  bulk_transfer_out_endp=2;
      bit [3:0]  interrupt_transfer_in_endp=3;
      bit [3:0]  interrupt_transfer_out_endp=5;
      bit [3:0]  isochronous_transfer_in_endp=6;
      bit [3:0]  isochronous_transfer_out_endp=7;
      bit [7:0]  token_crc5;
      bit [15:0] crc16;
      bit [3:0]  token_pid_setup;
      bit [3:0]  token_pid_data0;
      bit [3:0]  token_pid_data1;
      bit [7:0] pid_byte_data0;
      bit [7:0] pid_byte_data1;
      bit [7:0] tx_data[$];
      //bit [DATA_WIDTH-1:0]tx_data[$];
      bit [DATA_WIDTH-1:0]data_received[$];
      bit [7:0] configuration_value;
      bit [7:0] interface_setting[16];
     speed_state usb_speed;

     function new(string name="USB2p0_DEVICE_controller_driver", uvm_component parent);
          super.new(name,parent);
     endfunction
  
     function void build_phase(uvm_phase phase);
    	 super.build_phase(phase);    
         usb_seq_item = USB2p0_sequence_item::type_id::create("usb_seq_item");

  	    if (!uvm_config_db#(virtual USB2p0_device_utmi_interface)::get(this, "", "USB_DEVICE_UTMI_INTERFACE", utmi_interface_tx))
      		`uvm_fatal("NO VIF", "UTMI_INTERFACE not found")

            if (!uvm_config_db#(virtual USB2p0_device_utmi_interface)::get(this, "", "USB_DEVICE_UTMI_INTERFACE", utmi_interface_rx))
       		 `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")
            
            if (!uvm_config_db#(virtual USB2p0_host_utmi_interface)::get(this, "", "USB_HOST_UTMI_INTERFACE", host_utmi_interface_rx))
       		 `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")

            if (!uvm_config_db#(virtual USB2p0_host_utmi_interface)::get(this, "", "USB_HOST_UTMI_INTERFACE", host_utmi_interface_tx))
       		 `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")

            if(!uvm_config_db#(virtual USB2p0_PHY_interface)::get(this, "", "USB_PHY_INTERFACE", usb_phy_interface))
       		`uvm_fatal("NOVIF", "USB_PHY_INTERFACE not found")  

            if(!uvm_config_db#(speed_state)::get(this,"","USB_SPEED",usb_speed))
                  `uvm_fatal("NO USB SPEED","USB_SPEED IS NOT FOUND")
     
       endfunction
       
       task run_phase(uvm_phase phase);
         bit rx_listener_started;
         bit device_attached = 0;
    	 `uvm_info("DEVICE_DRIVER", $sformatf("ENTERED_INTO_DEVICE_DRIVER RUN_PHASE "),UVM_LOW) 
    	 usb_event_pool = uvm_event_pool::get_global_pool();
    	 seq_done_ev=usb_event_pool.get("host_chirp_done");
       	 reset_ev=usb_event_pool.get("RESET_EVENT");
         synchronization_event=usb_event_pool.get("SYNCHRONIZATION_EVENT");
         ack_done_ev =usb_event_pool.get("ACK_DONE_EVENT");
         ack_done_driv =usb_event_pool.get("ACK_DONE_DRIVER_EVENT");
         forever begin
           @(posedge utmi_interface_tx.cb_utmi_device_controller_driver);
           seq_item_port.get_next_item(req);
	     `uvm_info("DEVICE_DRIVER","READ_FROM_DRIVER_SEQ",UVM_LOW)
	      req.print();
              @(posedge utmi_interface_tx.cb_utmi_device_controller_driver);
	      begin
                if(!rx_listener_started) begin
                   rx_listener_started = 1;
                   `uvm_info("DEVICE_DRIVER","STARTING_PARALLEL_UTMI_RX_LISTENER",UVM_LOW)
                   fork
                      forever begin
	                 `uvm_info("DEVICE_DRIVER","RECEIVE_RX_DATA_FROM_PHY",UVM_LOW)
                         receive_from_utmi();
                         //rx_listener_started = 0;
                      end
                   join_none
                end
                 if(!device_attached)begin
                      device_attach(req);
                     device_attached = 1;
                 end
	        `uvm_info("DEVICE_DRIVER_RUN_PHASE","DEVICE_ATTACHMENT_DONE",UVM_LOW)
              end
      	   seq_item_port.item_done();
	 end

       endtask

       task device_attach(USB2p0_sequence_item usb_seq_item);
       	 utmi_interface_rx.utmisrp_bvalid <= usb_phy_interface.Vbus;
         if(usb_phy_interface.Vbus==1) begin
      	    drive_device_attach(req);
	    `uvm_info("DEVICE_DRIVER_ATTACH","WAIT_FOR_RESET_COMPLETED",UVM_LOW)
	    `uvm_info("DEVICE_DRIVER_ATTACH","EVENT_TRIGGERED",UVM_LOW)
	    if(usb_speed == USB_HS) begin
     	       detect_host_chirp(usb_seq_item);
            end
         end
       endtask

      task drive_device_attach(USB2p0_sequence_item usb_seq_item);
          `uvm_info("DEVICE_CTRLR","ENTERED_INTO_DEVICE_ATTACH ",UVM_LOW)
          case (usb_speed)
           USB_LS: begin
	              utmi_interface_tx.utmiotg_dppulldown <=  usb_seq_item.otg_dppulldown;
		      utmi_interface_tx.utmiotg_dmpulldown <= usb_seq_item.otg_dmpulldown;
		      `uvm_info("DEV",$sformatf("LS ATTACH Dm pullup dp_pull_down=%0d, dm_pull_down=%0d",usb_seq_item.otg_dppulldown,usb_seq_item.otg_dmpulldown),UVM_LOW)
		   end
           USB_FS: begin
		      utmi_interface_tx.utmiotg_dppulldown <= usb_seq_item.otg_dppulldown;
		      utmi_interface_tx.utmiotg_dmpulldown <= usb_seq_item.otg_dmpulldown;
		      `uvm_info("DEV","FS ATTACH Dp pullup)",UVM_LOW)
		   end

           USB_HS: begin
		      utmi_interface_tx.utmiotg_dppulldown <= usb_seq_item.otg_dppulldown;
		      utmi_interface_tx.utmiotg_dmpulldown <= usb_seq_item.otg_dmpulldown;
		      `uvm_info("DEV","HS ATTACH Dp pullup)",UVM_LOW)
		   end
         endcase
          `uvm_info("DEVICE_CTRLR","COMPLETED_DEVICE_ATTACH ",UVM_LOW)
	  if( usb_seq_item.otg_dppulldown ==1 && usb_seq_item.otg_dmpulldown == 0 )
	  wait_for_reset();
      endtask

      task wait_for_reset();
        //#2;
        `uvm_info("DEVICE_DRIVER",$sformatf(" ENTERED_INTO_WAIT_FOR_RESET linestate=%0d",utmi_interface_rx.utmi_linestate ),UVM_LOW)
          //wait(utmi_interface_rx.utmi_linestate == 2'b00);
	    //if(utmi_interface_rx.utmi_linestate == 2'b00) begin
           wait(host_utmi_interface_tx.utmi_linestate == 2'b00);
	     if(host_utmi_interface_tx.utmi_linestate == 2'b00) begin
             #2.5us;
            `uvm_info("DEVICE","NOW RESET IS 0 FOR 2.5us",UVM_LOW)
            `uvm_info("DEVICE",$sformatf("USB SPEED DEVICE= %s",usb_speed),UVM_LOW)

           if(usb_speed == USB_HS) begin
               send_hs_chirp();
           end
           else if(usb_speed == USB_FS) begin
               `uvm_info("DEVICE","FULL SPEED DEVICE NO CHIRP HANDSHAKE",UVM_LOW)
           end
          end
        `uvm_info("DEVICE_DRIVER"," COMPLETED_WAIT_FOR_RESET ",UVM_LOW)
      endtask

   task send_hs_chirp();
     `uvm_info("DEV_HS","Device sending Chirp K",UVM_LOW)
      //utmi_interface_rx.utmi_linestate <= 2'b01; // K
       utmi_interface_tx.utmi_linestate <= 2'b01; // K
     `uvm_info("DEV_HS","Device Chirp K finished",UVM_LOW)
   endtask

   task detect_host_chirp(USB2p0_sequence_item usb_seq_item);
     bit [1:0] value;
     int count = 0;
     bit [1:0] prev_state = 2'b00;

     `uvm_info("DEV_HS","Waiting for Host Chirp KJ",UVM_LOW)
   
     while (count < 6) begin
        seq_done_ev.wait_ptrigger();
        @(posedge utmi_interface_tx.cb_utmi_device_controller_driver);
        //if (utmi_interface_tx.utmi_linestate != 2'b00) begin
            //value = utmi_interface_tx.utmi_linestate;
         wait (host_utmi_interface_tx.utmi_linestate != 2'b00)begin
            value = host_utmi_interface_tx.utmi_linestate;
           `uvm_info("DEV_HS", $sformatf("Transition %0d detected = %b",count,value ),UVM_LOW)
         end
        //seq_done_ev.wait_ptrigger();
        count++;
       // seq_done_ev.wait_ptrigger();
     end // while
     `uvm_info("DEV_HS","KJ chirp detected Enter HS",UVM_LOW)
      enter_high_speed();
   endtask

   task enter_high_speed();
     `uvm_info("DEV_HS","HIGH SPEED MODE ENTERED",UVM_LOW)
      utmi_interface_tx.utmiotg_dppulldown <= 1;
      utmi_interface_tx.utmiotg_dmpulldown <= 0;
      utmi_interface_tx.utmi_termselect <= 1;
   endtask

     task receive_from_utmi();
        bit [15:0] collect_data16;
        bit [7:0]  collect_data8;
        bit        sample_rxvalid;
        bit        sample_rxvalidh;
        `uvm_info("DEVICE_DRIVER","ENTERED_INTO_RECEIVING_RX_DATA",UVM_LOW)
         
        usb_device_rx_seq_item = USB2p0_sequence_item::type_id::create("usb_device_rx_seq_item");
        usb_device_rx_seq_item.rx_data.delete();
       
        wait (utmi_interface_rx.utmi_rxvalid || utmi_interface_rx.utmi_rxvalidh);
        sample_rxvalid  = utmi_interface_rx.utmi_rxvalid;
        sample_rxvalidh = utmi_interface_rx.utmi_rxvalidh;
        forever begin
          @(negedge utmi_interface_rx.utmi_clk);
          usb_device_rx_seq_item.rx_valid       = sample_rxvalid;
          usb_device_rx_seq_item.rx_validh      = sample_rxvalidh;
          usb_device_rx_seq_item.rx_active      = utmi_interface_rx.utmi_rxactive;  
          usb_device_rx_seq_item.word_if        = utmi_interface_rx.utmi_word_if;

          if (sample_rxvalidh) begin 
             collect_data16 = utmi_interface_rx.utmi_rxdata;
             `uvm_info("DEVICE_DRIVER",$sformatf("16BIT_DATA_ON_RX = %h validh=%0d", collect_data16,usb_device_rx_seq_item.rx_validh),UVM_LOW)
             usb_device_rx_seq_item.rx_data.push_back(collect_data16[7:0]);
             usb_device_rx_seq_item.rx_data.push_back(collect_data16[15:8]);
             `uvm_info("DEVICE_DRIVER",$sformatf("16BIT_DATA_ON_RX = %p", usb_device_rx_seq_item.rx_data),UVM_LOW)
          end
          else if(sample_rxvalid) begin 
             collect_data8 = utmi_interface_rx.utmi_rxdata[7:0];
             `uvm_info("DEVICE_DRIVER",$sformatf("8BIT_DATA_ON_RX = %h valid=%0d", collect_data8,usb_device_rx_seq_item.rx_valid),UVM_LOW)
             usb_device_rx_seq_item.rx_data.push_back(collect_data8);
             `uvm_info("DEVICE_DRIVER",$sformatf("8BIT_DATA_ON_RX = %p", usb_device_rx_seq_item.rx_data),UVM_LOW)
          end

          sample_rxvalid  = utmi_interface_rx.utmi_rxvalid;
          sample_rxvalidh = utmi_interface_rx.utmi_rxvalidh;
          if(!(sample_rxvalid || sample_rxvalidh))
            break;
        end

        if(usb_device_rx_seq_item.rx_data.size() != 0) begin
          `uvm_info("DEVICE_DRIVER","DEVICE_RX_PACKET_COMPLETE",UVM_LOW)
          usb_device_rx_seq_item.print();
          token_packet_received(req,usb_device_rx_seq_item.rx_data);
        end
       endtask

      task calc_crc5(bit [6:0]addr, bit [3:0]endp);
                  bit [10:0] token_bits;   
                  bit [4:0] crc,crc5;          
                  bit din;
                  int i;
                  `uvm_info("CRC5",$sformatf("ENTERED_INTO_CRC5_addr=%0h, endp=%0h",addr,endp),UVM_LOW)
                  token_bits = {addr,endp};
      
                  crc=5'b11111;
      
                  for (i=10;i>=0;i--) begin
                    din = token_bits[i] ^ crc[4];     
                    crc = {crc[3:0],1'b0};           
                    if (din) begin
                     crc^= 5'b00101;               
                    end
                  end
      
                  act_crc5=~crc;
                  `uvm_info("CRC5",$sformatf(" RECEIVED_CRC5 crc5=%0d crc=%0d",act_crc5,crc),UVM_LOW)
       endtask

     task calc_crc16(bit [7:0] bmRequestType, bRequest, bit [15:0] wValue,wIndex,wLength,crc16);
        
        bit [15:0] crc;
        bit din;
        bit [7:0] data[$];
        int i,j;
          `uvm_info("TOKEN_PKT",$sformatf("RECEIVEDbmrequest=%0h, brequest=%0h, wvalue=%0h,windex=%0h,wlength=%0h,crc16=%0h", bmRequestType,bRequest,wValue,wIndex,wLength,crc16),UVM_LOW)
        crc=16'hFFFF;
        `uvm_info("CRC_16",$sformatf("ENTERED_INTO_CRC16"),UVM_LOW)
        data.push_back(bmRequestType);
        data.push_back(bRequest);
        data.push_back(wValue[7:0]);
        data.push_back(wValue[15:8]);
        data.push_back(wIndex[7:0]);
        data.push_back(wIndex[15:8]);
        data.push_back(wLength[7:0]);
        data.push_back(wLength[15:8]);
        
        foreach(data[i]) begin
          for(j=0;j<8;j++) begin
            din = crc[15]^data[i][j];
            crc = {crc[14:0],1'b0};
                if( din) begin
                 crc^=16'h8005;
                end
          end
        end
       act_crc16 = ~crc;            
          `uvm_info("TOKEN_PKT",$sformatf("RECEIVED_CRC16 act_crc16=%0h,crc=%h",act_crc16,crc),UVM_LOW)
  endtask
  
  task token_packet_received(USB2p0_sequence_item usb_seq_item,bit [DATA_WIDTH-1:0]device_dri_rxdata[$]);
       
       bit [7:0] pid_byte;

       `uvm_info("TOKEN_PKT",$sformatf("ENTERED_INTO_ADDRESS_CHECK_TASK valid=%0d, valid_h=%0d  ",usb_seq_item.rx_valid,usb_seq_item.rx_validh),UVM_LOW)
       `uvm_info("TOKEN_PKT",$sformatf("device_dri_rxdata = %0p",device_dri_rxdata),UVM_LOW)
       data_received = device_dri_rxdata;
       `uvm_info("TOKEN_PKT",$sformatf("data_received = %0p",data_received),UVM_LOW)
       `uvm_info("TOKEN_PKT",$sformatf("device_dri_rxdata = %0p",device_dri_rxdata),UVM_LOW)
       pid_byte   = data_received.pop_front();
       token_pid_setup = pid_byte[7:4];
       `uvm_info("TOKEN_PKT",$sformatf("SETUP_TOKEN_PACKET: PID=%0h,",token_pid_setup),UVM_LOW)
       `uvm_info("TOKEN_PKT",$sformatf("SETUP_TOKEN_PACKET: PID=%0h,",pid_byte),UVM_LOW)
       if (token_pid_setup == PID_SETUP) begin
          token_addr = data_received.pop_front();
          token_endp = data_received.pop_front();
          token_crc5 = data_received.pop_front();
          calc_crc5(token_addr,token_endp);
          `uvm_info("TOKEN_PKT",$sformatf("RECEIVED_SETUP_STAGE_TOKEN_PKT - TOKEN: PID=%0h ADDR=%0d ENDP=%0d CRC_5=%0d",token_pid_setup, token_addr, token_endp,token_crc5),UVM_LOW)
          data_packet(data_received);
       end
       else if (token_pid_setup == PID_IN && wlength == 0) begin
          token_addr = data_received.pop_front();
          token_endp = data_received.pop_front();
          token_crc5 = data_received.pop_front();
          calc_crc5(token_addr,token_endp);
          `uvm_info("TOKEN_PKT",$sformatf("RECEIVED_STATUS_STAGE_IN_TOKEN - PID=%0h ADDR=%0d ENDP=%0d CRC_5=%0d",token_pid_setup, token_addr, token_endp, token_crc5),UVM_LOW)
          // For the no-data control-transfer case, the host status stage is an IN token.
          // Logging and decoding it here confirms that the PHY forwarded the packet from
          // the host driver to the device controller path.
         if(token_endp == control_transfer_endp )begin
          `uvm_info("DEVICE_DRIVER","RECEIVED_CONTROL_TRANSFER_ENDP",UVM_LOW)
             status_stage_zlp_pkt(PID_DATA1);
           end
         else if(token_endp == interrupt_transfer_in_endp)begin
          `uvm_info("DEVICE_DRIVER","RECEIVED_INTERRUPT_IN_ENDP",UVM_LOW)
            interrupt_transfer(PID_DATA1,req);
         end
         else if (token_endp == bulk_transfer_in_endp)begin
          `uvm_info("DEVICE_DRIVER","RECEIVED_BULK_IN_ENDP",UVM_LOW)
           Bulk_transfer(PID_DATA1,req);
         end
         else if(token_endp == isochronous_transfer_in_endp)begin
          `uvm_info("DEVICE_DRIVER","ENTERED_INTO_ISOCHRONOUS_IN_DATA",UVM_LOW)
            isochronous_transfer(PID_DATA1,req);
         end
       end
         else if (token_pid_setup == PID_OUT)begin
          token_addr = data_received.pop_front();
          token_endp = data_received.pop_front();
          token_crc5 = data_received.pop_front();
          calc_crc5(token_addr,token_endp);
          `uvm_info("TOKEN_PKT",$sformatf("RECEIVED_OUT_TOKEN_PKT - TOKEN: PID=%0h ADDR=%0d ENDP=%0d CRC_5=%0d",token_pid_setup, token_addr, token_endp,token_crc5),UVM_LOW)
           if(token_endp == control_transfer_endp)begin
              received_zlp_data(data_received);
           end
           else if(token_endp == interrupt_transfer_out_endp)begin
            `uvm_info("DEVICE_DRIVER","RECEIVED_INTERRUPT_OUT_ENDP",UVM_LOW)
               //receive_host_payload(data_received,usb_seq_item);
               receive_host_payload(data_received,USB2p0_sequence_item::INTERRUPT_TRANSFER);
           end
           else if(token_endp == bulk_transfer_out_endp)begin
            `uvm_info("DEVICE_DRIVER","ENTERED_INTO_BULK_OUT_DATA",UVM_LOW)
              //receive_host_payload(data_received,usb_seq_item);
               receive_host_payload(data_received,USB2p0_sequence_item::BULK_TRANSFER);
           end
           else if(token_endp == isochronous_transfer_out_endp)begin
            `uvm_info("DEVICE_DRIVER","ENTERED_INTO_ISO_OUT_DATA",UVM_LOW)
              //receive_host_payload(data_received,usb_seq_item);
               receive_host_payload(data_received,USB2p0_sequence_item::ISO_CHRONOUS_TRANSFER);
           end
         end
       else if (token_pid_setup == PID_IN && wlength[7:0] > 0) begin
          `uvm_info("DEVICE_DRIVER",$sformatf("DATA_STAGE_TOKEN_PID = %d WLength=%0d", token_pid_setup,wlength[7:0]),UVM_LOW)
      
         case (wlength[7:0])
         18: begin
                  token_addr = data_received.pop_front();
                  token_endp = data_received.pop_front();
                  token_crc5 = data_received.pop_front();
                 `uvm_info("TOKEN_PKT",$sformatf("RECEIVED_DATA_STAGE_IN_TOKEN - PID=%0h ADDR=%0d ENDP=%0d CRC_5=%0d",token_pid_setup, token_addr, token_endp, token_crc5),UVM_LOW) 
                  //device_descriptor_task(PID_DATA1,usb_seq_item);
                  ack_done_driv.wait_trigger();
                  device_descriptor_task(PID_DATA1,req);
             end
         1 : begin
               if(bRequest == 8'd8)
                 send_get_configuration(PID_DATA1);
               else 
                 send_get_interface(PID_DATA1);
             end
         2: begin
                send_get_status(PID_DATA1); 
            end
         endcase
    end
     begin
       `uvm_info("TOKEN_PKT",$sformatf("PID=%0h,",pid_byte),UVM_LOW)
       if(pid_byte[7:4] == PID_ACK)
          `uvm_info("HANSHAKE_PKT",$sformatf("RECEIVED_HANDSHAKE_ACK_PID=%0h,",pid_byte),UVM_LOW)
       if(pid_byte[7:4] == PID_NAK)
          `uvm_info("HANSHAKE_PKT",$sformatf("RECEIVED_HANDSHAKE_NACK_PID=%0h,",pid_byte),UVM_LOW)
       if(pid_byte[7:4] == PID_STALL)
          `uvm_info("HANSHAKE_PKT",$sformatf("RECEIVED_HANDSHAKE_STALL_PID=%0h",pid_byte),UVM_LOW)
      end

endtask

   task data_packet(bit [DATA_WIDTH-1:0] data_received[$]);
       `uvm_info("SETUP","ENTERING_INTO_DATA0PID",UVM_LOW)
        pid_byte_data0  = data_received.pop_front();
        token_pid_data0 = pid_byte_data0[7:4];
       `uvm_info("TOKEN_PKT",$sformatf("SETUP_DATA_PACKET: PID=%0h,PID =%b,",pid_byte_data0,token_pid_data0),UVM_LOW)
       if (token_pid_data0 == PID_DATA0) begin
           bmRequest = data_received.pop_front();
           bRequest  = data_received.pop_front();
           wValue[7:0]  = data_received.pop_front();
           wValue[15:8]  = data_received.pop_front();
           wIndex[7:0]  = data_received.pop_front();
           wIndex[15:8]  = data_received.pop_front();
           wlength[7:0]  = data_received.pop_front();
           wlength[15:8]  = data_received.pop_front();
           crc16[7:0]  = data_received.pop_front();
           crc16[15:8]  = data_received.pop_front();
           calc_crc16(bmRequest,bRequest,wValue,wIndex,wlength,crc16);
          `uvm_info("TOKEN_PKT",$sformatf("RECEIVED_DATA_PKT - TOKEN: PID=%0h bmrequest=%0h, brequest=%0h, wvalue=%0h,windex=%0h,wlength=%0h,crc16=%0h",token_pid_data0, bmRequest,bRequest,wValue,wIndex,wlength,crc16),UVM_LOW)

          /*if ((token_addr != device_address) || (token_endp > 6)) begin
             `uvm_fatal("SETUP","ADDR_MISMATCH")
              return;
          end
          else begin
              //send_handshake_packet(PID_ACK); 
              send_handshake_packet(PID_ACK,req); 
             `uvm_info("SETUP","ADDR_AND_ENDP_MATCHED",UVM_LOW)
           end*/

////////////////////////////////////////////////////////////////
             if ((token_addr != device_address) || (token_endp > 7)) begin
                   `uvm_warning("SETUP","ADDR_MISMATCH")
                    send_handshake_packet(PID_STALL,req);
                    return;
              end
      
             valid_request = 0;

            if((act_crc5 == token_crc5) && ( act_crc16 == crc16))begin
            `uvm_info("CRC_CHECK",$sformatf("CRC5_MATCHED RX_CRC5=%0h ACT_CAL_CRC5=%0h CRC16_MATCHED RX_CRC16=%0h ACT_CAL_CRC16=%0h",token_crc5,act_crc5,crc16, act_crc16),UVM_LOW)

            // GET_STATUS
         if(bmRequest == 8'd128 && bRequest == 8'd0 && wlength == 16'd2 && wIndex == 16'd0 && wValue == 16'd0 && token_endp == 4'd0 && token_addr == 7'd0)
               valid_request = 1;
 
            // CLEAR_FEATURE
          else if(bmRequest == 8'd0 && bRequest == 8'd1 && wlength == 16'd0 && wIndex == 16'd129 && wValue == 16'd0 && token_endp == 4'd0 && token_addr== 7'd0)
               valid_request = 1;
 
            // SET_FEATURE
            else if(bmRequest == 8'd0 && bRequest == 8'd3 && wlength ==16'd0 && wIndex == 16'd0 && wValue ==16'd1 && token_endp == 4'd0 && token_addr == 7'd0)
               valid_request = 1;
 
            // SET_ADDRESS
            else if(bmRequest == 8'd0 && bRequest == 8'd5 && wlength ==16'd0 && wIndex ==16'd0 && wValue == 16'd5 && token_endp == 4'd0 && token_addr ==7'd0)
               valid_request = 1;
 
            // GET_DESCRIPTOR
            else if(bmRequest == 8'd128 && bRequest == 8'd6 && wlength ==16'd18 && wIndex == 16'd0 && wValue == 16'd1 && token_endp == 4'd0 && token_addr ==7'd0)
               valid_request = 1;
 
            // GET_CONFIGURATION
            else if(bmRequest == 8'd128 && bRequest == 8'd8 && wlength == 16'd1 && wIndex ==16'd0 && wValue == 16'd0 && token_endp == 4'd0 && token_addr == 7'd0)
               valid_request = 1;
 
            // SET_CONFIGURATION
            else if(bmRequest == 8'd0 && bRequest == 8'd9 && wlength == 16'd0 && wIndex ==16'd0  && wValue ==16'd1 && token_endp == 4'd0 && token_addr ==7'd0)
               valid_request = 1;
 
            // GET_INTERFACE
            else if(bmRequest == 8'd129 && bRequest == 8'd10 && wlength == 16'd1 && wIndex ==16'd1 && wValue == 16'd0 && token_endp ==4'd0 && token_addr == 7'd0)
               valid_request = 1;
 
            // SET_INTERFACE
            else if(bmRequest == 8'd1 && bRequest == 8'd11 && wlength == 16'd0 && wIndex == 16'd1 && wValue == 16'd1 && token_endp == 4'd0  && token_addr ==7'd0 )
               valid_request = 1;
           end
           else begin
              `uvm_warning("CRC_CHECK",$sformatf("CRC_MISMATCH RX_CRC5=%0h CAL_CRC5=%0h RX_CRC16=%0h CAL_CRC16=%0h",token_crc5,act_crc5,crc16,act_crc16))
               send_handshake_packet(PID_STALL,req);
              return;
           end
 
            if(valid_request) begin
               `uvm_info("SETUP","VALID_STANDARD_REQUEST_RECEIVED", UVM_LOW)
                send_handshake_packet(PID_ACK,req);
            end
            else begin
               `uvm_warning("SETUP", $sformatf("INVALID_REQUEST bmRequest=%0h bRequest=%0h", bmRequest,bRequest))
                send_handshake_packet(PID_STALL,req);
               return;
            end
 
         ///set_configuration
          if(bmRequest == 8'd0 && bRequest == 8'd9)begin
             configuration_value = wValue[7:0];
             `uvm_info("TOKEN_PKT",$sformatf("RECEIVED_SET_CONFIGURATION_VALUE - configuration_value=%0h",configuration_value),UVM_LOW)
              if(configuration_value)
                 `uvm_info("TOKEN_PKT",$sformatf("DEVICE_ENABLES_ALL_TRANSFERS"),UVM_LOW)
                 
          end

         //set_interface
          if(bmRequest == 8'd1 && bRequest ==8'd11)begin 
            interface_setting[wIndex[7:0]] = wValue[7:0];
             `uvm_info("DEVICE_DRIVER",$sformatf("RECEIVED_INTERFACE_SETTING_VALUE interface_setting[%0d] = %0d", wIndex[7:0], interface_setting[wIndex[7:0]]),UVM_LOW)
         end
   end
  endtask
      
  task received_zlp_data(bit [DATA_WIDTH-1:0] data_received[$]);
       `uvm_info("STATUS_STAGE","ENTERING_INTO_DATA1PID_ZLP",UVM_LOW)
        pid_byte_data1  = data_received.pop_front();
        token_pid_data1 = pid_byte_data1[7:4];
       `uvm_info("TOKEN_PKT",$sformatf("SETUP_DATA_PACKET: PID=%0h,PID =%b,",pid_byte_data0,token_pid_data1),UVM_LOW)
       if (token_pid_data1 == PID_DATA1) begin
           crc16[7:0]  = data_received.pop_front();
           crc16[15:8] = data_received.pop_front();
          `uvm_info("TOKEN_PKT",$sformatf("RECEIVED_ZLP_PKT_STATUS_STAGE - TOKEN: PID=%0h,crc16=%0h",token_pid_data1,crc16),UVM_LOW)
       end
       ack_done_ev.wait_trigger();
       //send_handshake_packet(PID_ACK);
       send_handshake_packet(PID_ACK,req);
   endtask
  
  task send_handshake_packet(bit[3:0] handshake_pid, USB2p0_sequence_item usb_seq_item);
        bit [7:0] pid_byte;
	`uvm_info("DEVICE_DRIVER",$sformatf("handshake_pid=%0d",handshake_pid),UVM_LOW)
        pid_byte = {handshake_pid, ~handshake_pid};
          @(posedge utmi_interface_tx.cb_utmi_device_controller_driver);
         /*utmi_interface_tx.utmi_txvalid <= 1;
         if (usb_seq_item.word_if) begin
             `uvm_info("DEVICE_DRIVER",$sformatf("HANDSHAKE_PID_SENT_FOR_WORD_IF_ONE"), UVM_LOW)
              utmi_interface_tx.utmi_txvalidh <= 1;
               utmi_interface_tx.utmi_txdata <= pid_byte;
         end*/
           if(!utmi_interface_tx.utmi_word_if) begin
      utmi_interface_tx.utmi_word_if  <= 1'b0;
      utmi_interface_tx.utmi_txdata   <= pid_byte;
      utmi_interface_tx.utmi_txvalid  <= 1'b1;
      utmi_interface_tx.utmi_txvalidh <= 1'b0;
      `uvm_info("HOST_DRIVER",$sformatf("HOST_HANDSHAKE_8BIT txdata=%0h",pid_byte),UVM_LOW)
   end
     else begin
      utmi_interface_tx.utmi_word_if  <= 1'b1;
      //utmi_interface_tx.utmi_txdata   <= hs_pid_word;
      utmi_interface_tx.utmi_txdata   <= pid_byte;
      utmi_interface_tx.utmi_txvalid  <= 1'b1;
      utmi_interface_tx.utmi_txvalidh <= 1'b1;
      `uvm_info("HOST_DRIVER",$sformatf("HOST_HANDSHAKE_16BIT txdata=%0h",pid_byte),UVM_LOW)
   end

         /* else begin
             utmi_interface_tx.utmi_txvalidh <= 0;
             utmi_interface_tx.utmi_txdata  <= pid_byte;
            `uvm_info("DEVICE_DRIVER",$sformatf("HANDSHAKE_PID_SENT = %0b", utmi_interface_tx.utmi_txdata), UVM_LOW)
         end*/
             `uvm_info("DEVICE_DRIVER",$sformatf("HANDSHAKE_PID_SENT = %0b", pid_byte), UVM_LOW)
               synchronization_event.trigger();
             `uvm_info("DEVICE_DRIVER",$sformatf("SYNC_EVENT_TRIGGERED"), UVM_LOW)
               @(posedge utmi_interface_tx.cb_utmi_device_controller_driver);begin
              utmi_interface_tx.utmi_txvalid  <= 0;
              utmi_interface_tx.utmi_txvalidh <= 0;
            end
            if(handshake_pid == PID_ACK)
             `uvm_info("DEVICE_DRIVER",$sformatf("DEVICE_SENT_HANDSHAKE_ACK= %0h", pid_byte),UVM_LOW)
           else if(handshake_pid == PID_NAK)
             `uvm_info("DEVICE_DRIVER",$sformatf("DEVICE_SENT_HANDSHAKE_NACK= %0h", pid_byte),UVM_LOW)
           else 
             `uvm_info("DEVICE_DRIVER",$sformatf("DEVICE_SENT_HANDSHAKE_STALL= %0h", pid_byte),UVM_LOW)
    endtask

    task device_descriptor_task(bit [3:0] data1_pid,USB2p0_sequence_item usb_seq_item);
	    bit [7:0] data1_pid_byte;
	    `uvm_info("DEVICE_DRIVER",$sformatf("ENTERED_INTO_DEVICE_DESCRIPTOR_TASK_PKT_DATA_STAGE_DATA1_PID=%0d",data1_pid),UVM_LOW);
	    data1_pid_byte = {data1_pid,~data1_pid};
	    `uvm_info("DEVICE_DRIVER",$sformatf("data_stage_data1_pid=%0h",data1_pid_byte),UVM_LOW);
	    tx_data.push_back(data1_pid_byte);
	    `uvm_info("DEVICE_DRIVER",$sformatf("data_stage_tx_data pid_byte %0p",tx_data),UVM_LOW);
	    //device_descriptor(usb_seq_item);
	    device_descriptor(req);
        calc_data_crc16(usb_seq_item); 
	    tx_data.push_back(usb_seq_item.crc16[7:0]);
	    tx_data.push_back(usb_seq_item.crc16[15:8]);
	    `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_STAGE_DATA_PACKET_CRC16 =%0p",tx_data),UVM_LOW);
	    send_to_utmi(tx_data,req);
	    `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("FOR_DATA_STAGE_SEND_UTMI_TASK_COMPLETED"),UVM_LOW);
    endtask

      //task device_descriptor(USB2p0_sequence_item usb_seq_item);
      task device_descriptor(USB2p0_sequence_item req);
           `uvm_info("DEVICE_DRIVER",$sformatf("ENTERED_INTO_DEVICE_DISCRIPTOR_TASK"),UVM_LOW)
            usb_seq_item.print();		
           //tx_data.push_back(usb_seq_item.blength);
             tx_data.push_back(req.blength);
             `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BLENGTH=%0p",tx_data),UVM_LOW)                 
	      	//tx_data.push_back(usb_seq_item.bdescriptors_type);
	      	tx_data.push_back(req.bdescriptors_type);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BDESCRIPTORS_TYPE=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.bcd_usb[7:0]);
	      	//tx_data.push_back(usb_seq_item.bcd_usb[15:8]);
	      	tx_data.push_back(req.bcd_usb[7:0]);
	      	tx_data.push_back(req.bcd_usb[15:8]);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BCD_USB=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.bDevice_class);
	      	tx_data.push_back(req.bDevice_class);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BDEVICE_CLASS=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.bDevice_subclass);
	      	tx_data.push_back(req.bDevice_subclass);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BDEVICE_SUBCLASS=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.bDevice_protocol);
	      	tx_data.push_back(req.bDevice_protocol);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BDEVICE_PROTOCOL=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.bMax_packetsize);
	      	tx_data.push_back(req.bMax_packetsize);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BMAX_PACKETSIZE=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.idvendor[7:0]);
	      	//tx_data.push_back(usb_seq_item.idvendor[15:8]);
	      	tx_data.push_back(req.idvendor[7:0]);
	      	tx_data.push_back(req.idvendor[15:8]);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_IDVENDOR=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.idproduct[7:0]);
	      	//tx_data.push_back(usb_seq_item.idproduct[15:8]);
	      	tx_data.push_back(req.idproduct[7:0]);
	      	tx_data.push_back(req.idproduct[15:8]);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_IDPRODUCT=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.bcdDevice[7:0]);
	      	tx_data.push_back(req.bcdDevice[7:0]);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BCDDEVICE=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.bcdDevice[15:8]);
	      	tx_data.push_back(req.bcdDevice[15:8]);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BCDDEVICE=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.imanufacture);
	      	tx_data.push_back(req.imanufacture);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_IMANUFACTURE=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.iproduct);
	      	//tx_data.push_back(usb_seq_item.iproduct);
	      	tx_data.push_back(req.iproduct);
	      	tx_data.push_back(req.iproduct);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_IPRODUCT=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.iserial_number);
	      	tx_data.push_back(req.iserial_number);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_ISERIAL_NUMBER=%0p",tx_data),UVM_LOW)
	      	//tx_data.push_back(usb_seq_item.bNum_configuration);
	      	tx_data.push_back(req.bNum_configuration);
              `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("DATA_PACKET_BNUM_CONFIGURATION=%0p",tx_data),UVM_LOW)
              `uvm_info("DEVICE_DRIVER",$sformatf("DEVICE DESCRIPTOR QUEUE = %p",tx_data),UVM_LOW)
         endtask
///////////////////////////////////////////////////////////////////////////////////////////
         /*task receive_host_payload(bit [DATA_WIDTH-1:0] data_received[$]);
            bit [7:0] data;
            bit [7:0] payload[$];
           `uvm_info("DEVICE_DRIVER","ENTERED_INTO_PAYLOAD_TASK",UVM_LOW)

            data = data_received.pop_front();
            `uvm_info("DEVICE_DRIVER",$sformatf("DATA = %0h", data), UVM_LOW)

            while(data_received.size() > 0) begin
              payload.push_back(data_received.pop_front());
            end
            `uvm_info("TRANSFERS",$sformatf("TOTAL_DATA_SIZE = %0d",payload.size()),UVM_LOW)
            
           foreach(payload[i]) begin
             `uvm_info("TRANSFERS",$sformatf("DATA[%0d] = %0h",i,payload[i]),UVM_LOW)
           end
            //send_handshake_packet(PID_ACK);
            send_handshake_packet(PID_ACK,req);
          endtask*/


        //task receive_host_payload(bit [DATA_WIDTH-1:0] data_received[$], USB2p0_sequence_item usb_seq_item);
        task receive_host_payload(bit [DATA_WIDTH-1:0] data_received[$],USB2p0_sequence_item::transfers transfer_type);
              bit [7:0] pid;
              bit [7:0] payload[$];
              int max_pkt_size;
              `uvm_info("DEVICE_DRIVER","ENTERED_INTO_RECEIVE_HOST_PAYLOAD",UVM_LOW)

              pid = data_received.pop_front();
             `uvm_info("DEVICE_DRIVER",$sformatf("PID = %0h", pid),UVM_LOW)

              while(data_received.size() > 0) begin
                 payload.push_back(data_received.pop_front());
              end
               `uvm_info("DEVICE_DRIVER", $sformatf("PAYLOAD_SIZE = %0d", payload.size()), UVM_LOW)

             foreach(payload[i]) begin
              `uvm_info("DEVICE_DRIVER", $sformatf("PAYLOAD[%0d] = %0h", i, payload[i]), UVM_LOW)
             end

         case(usb_speed)

           USB_LS: begin
              case(transfer_type)
                 USB2p0_sequence_item::INTERRUPT_TRANSFER :  max_pkt_size = 8;
              endcase
            end

           USB_FS: begin
               case(transfer_type)
                    USB2p0_sequence_item::BULK_TRANSFER        : max_pkt_size = 64;
                    USB2p0_sequence_item::INTERRUPT_TRANSFER   : max_pkt_size = 64;
                    USB2p0_sequence_item::ISO_CHRONOUS_TRANSFER : max_pkt_size = 1023;
               endcase
           end

           USB_HS: begin
               case(transfer_type)
                    USB2p0_sequence_item::BULK_TRANSFER        : max_pkt_size = 512;
                    USB2p0_sequence_item::INTERRUPT_TRANSFER   : max_pkt_size = 1024;
                    USB2p0_sequence_item::ISO_CHRONOUS_TRANSFER : max_pkt_size = 1024;
               endcase
           end
         endcase

        if(payload.size() > max_pkt_size) begin
           `uvm_warning("DEVICE_DRIVER",$sformatf("PAYLOAD_SIZE_EXCEEDED_RECEIVED=%0d MAX=%0d",payload.size(),max_pkt_size))
            send_handshake_packet(PID_STALL, req);
        end
        else begin
            `uvm_info("DEVICE_DRIVER",$sformatf("VALID_PAYLOAD_RECEIVED MAX=%0d",max_pkt_size),UVM_LOW)
             send_handshake_packet(PID_ACK, req);
        end
     endtask
    /////////////////////////////////////////////////////////////////
          
        task interrupt_transfer(bit [3:0] pid_byte,USB2p0_sequence_item usb_seq_item);
           bit [7:0] interrupt_pid;
             interrupt_pid = {pid_byte, ~pid_byte};
             tx_data.delete();
            `uvm_info("DEVICE_DRIVER",$sformatf("INTERRUPT_PID = %h",interrupt_pid),UVM_LOW)
             tx_data.push_back(interrupt_pid);             
             //send_payload_data(req.device_payload);
             send_payload_data(usb_seq_item.device_payload, usb_seq_item);
          endtask
           
          task isochronous_transfer(bit [3:0] pid_byte,USB2p0_sequence_item usb_seq_item);
           bit [7:0] isochronous_pid;
             isochronous_pid = {pid_byte, ~pid_byte};
             tx_data.delete();
            `uvm_info("DEVICE_DRIVER",$sformatf("ISOCHRONOUS_PID = %h",isochronous_pid),UVM_LOW)
             tx_data.push_back(isochronous_pid);             
             send_payload_data(usb_seq_item.device_payload, usb_seq_item);
          endtask

          task Bulk_transfer(bit [3:0] pid_byte,USB2p0_sequence_item usb_seq_item);
           bit [7:0] bulk_pid;
             bulk_pid = {pid_byte, ~pid_byte};
             tx_data.delete();
            `uvm_info("DEVICE_DRIVER",$sformatf("BULK_PID = %h",bulk_pid),UVM_LOW)
             tx_data.push_back(bulk_pid);             
             send_payload_data(usb_seq_item.device_payload, usb_seq_item);
          endtask

      task send_payload_data(bit [7:0] payload[], USB2p0_sequence_item usb_seq_item);
           
           foreach (payload[i]) begin
             tx_data.push_back(payload[i]);
            `uvm_info("PAYLOAD_DATA",$sformatf("Payload[%0d] = %0h",i, payload[i]),UVM_LOW)
           end
           calc_crc16_payload(payload,usb_seq_item);
           tx_data.push_back(usb_seq_item.crc16[7:0]);
           tx_data.push_back(usb_seq_item.crc16[15:8]);
          `uvm_info("CRC16",$sformatf("CRC16 = %0h", usb_seq_item.crc16), UVM_LOW)
	   send_to_utmi(tx_data,req);
        endtask

        task calc_crc16_payload(input bit [7:0] payload [], USB2p0_sequence_item usb_seq_item);
              bit [15:0] crc;
              bit din;
              int i,j;
              crc = 16'hFFFF;
              foreach (payload[i]) begin
                 for (j = 0; j < 8; j++) begin
                    din = payload[i][j] ^ crc[15];
                    crc = {crc[14:0],1'b0};
                    if (din)begin
                     crc ^=  16'h8005;
                    end
                  end
               end
              usb_seq_item.crc16 = ~crc;
          endtask

///////////////////////////////////////////////////////////////



     task calc_data_crc16(USB2p0_sequence_item usb_seq_item);
        
        bit [15:0] crc;
        bit din;
        bit [7:0] data[$];
        int i,j;
        crc=16'hFFFF;
        `uvm_info("CRC_16",$sformatf("ENTERED_INTO_CRC16"),UVM_LOW)
	usb_seq_item.print();
		data.push_back(usb_seq_item.blength);
		data.push_back(usb_seq_item.bdescriptors_type);
		data.push_back(usb_seq_item.bcd_usb[7:0]);
		data.push_back(usb_seq_item.bcd_usb[15:8]);
		data.push_back(usb_seq_item.bDevice_class);
		data.push_back(usb_seq_item.bDevice_subclass);
		data.push_back(usb_seq_item.bDevice_protocol);
		data.push_back(usb_seq_item.bMax_packetsize);
		data.push_back(usb_seq_item.idvendor[7:0]);
		data.push_back(usb_seq_item.idvendor[15:8]);
		data.push_back(usb_seq_item.idproduct[7:0]);
		data.push_back(usb_seq_item.idproduct[15:8]);
		data.push_back(usb_seq_item.bcdDevice[7:0]);
		data.push_back(usb_seq_item.bcdDevice[15:8]);
		data.push_back(usb_seq_item.imanufacture);
		data.push_back(usb_seq_item.iproduct);
		data.push_back(usb_seq_item.iserial_number);
		data.push_back(usb_seq_item.bNum_configuration);
        
        foreach(data[i]) begin
          for(j=0;j<8;j++) begin
            din = crc[15]^data[i][j];
            crc = {crc[14:0],1'b0};
                if( din) begin
                 crc^=16'h8005;
                end
          end
        end
       usb_seq_item.crc16 = ~crc;            
       `uvm_info("CRC_16",$sformatf(" crc16=%0d crc=%0d",usb_seq_item.crc16,crc),UVM_LOW)
  endtask


   task send_get_status(bit [3:0] data1_pid);
     bit [7:0] data1_pid_byte;
     bit [7:0] status_data[2];
     bit remote_power = 1 ;
     bit self_power   = 1 ;

     `uvm_info("DEVICE_DRIVER",$sformatf("ENTERED_INTO_DEVICE_GET_STATUS_TASK_PKT_DATA_STAGE_DATA1_PID=%0d",data1_pid),UVM_LOW);
      data1_pid_byte = {data1_pid, ~data1_pid};
     `uvm_info("pidbyte",$sformatf("data1_pid_byte=%0d",data1_pid_byte),UVM_LOW)
      status_data[0] = {6'b0, remote_power, self_power};
      status_data[1] = 8'h00;
      tx_data.push_back(data1_pid_byte);
      tx_data.push_back(status_data[0]);
      tx_data.push_back(status_data[1]);
      `uvm_info("DRIVER",$sformatf("GET_STATUS DATA = %02h %02h",status_data[0], status_data[1]), UVM_LOW)
      req.print();
      send_to_utmi(tx_data,req);
   endtask

    task status_stage_zlp_pkt(bit [3:0] data1_pid);
	    bit [7:0] data1_pid_byte;
	    bit [15:0] crc16;
            tx_data.delete();
            //usb_seq_item.utmi_txdata.delete();
            req.utmi_txdata.delete();
            
	    `uvm_info("DEVICE_DRIVER",$sformatf("ENTERED_INTO_ZLP_PKT_status_stage_data1_pid=%0d",data1_pid),UVM_LOW);
	    data1_pid_byte = {data1_pid,~data1_pid};
	    `uvm_info("DEVICE_DRIVER",$sformatf("status_stage_data1_pid=%0h",data1_pid_byte),UVM_LOW);
	    tx_data.push_back(data1_pid_byte);
	    `uvm_info("DEVICE_DRIVER",$sformatf("status_stage_tx_data pid_byte %0p",tx_data),UVM_LOW);
	    calc_crc16_zlp();
	    tx_data.push_back(usb_seq_item.crc16[7:0]);
	    tx_data.push_back(usb_seq_item.crc16[15:8]);
	    `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("STATUS_STAGE_DATA_PACKET_CRC16 =%0p",tx_data),UVM_LOW);
             //foreach (tx_data[i]) begin
               //req.utmi_txdata.push_back(tx_data[i][7:0]);
             //end
	     //`uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("STATUS_STAGE_DATA"),UVM_LOW);
             // req.print();
              //usb_seq_item.print();
  	     send_to_utmi(tx_data,req);
	    `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("FOR_STATUS_STAGE_SEND_UTMI_TASK_COMPLETED"),UVM_LOW);
    endtask
  
    task calc_crc16_zlp();
      bit [15:0] crc;
      crc = 16'hFFFF;
      `uvm_info("CRC16_ZLP","ENTERED_INTO_CALC_CRC16_ZLP",UVM_LOW)
      // Zero Length Packet (ZLP)
      // No payload bytes are present
       usb_seq_item.crc16 = ~crc;
      `uvm_info("CRC16_ZLP",$sformatf("ZLP_CRC = %0d",usb_seq_item.crc16),UVM_LOW)
    endtask

    
      task send_get_interface(bit [3:0] data1_pid);
        bit [7:0] data;
        bit [7:0] data1_pid_byte;
        tx_data.delete();
       `uvm_info("DEVICE_DRIVER",$sformatf("ENTERED_INTO_DEVICE_GET_INTERFACE_TASK_PKT_DATA_STAGE_DATA1_PID =%0d tx_data=%0p",data1_pid,tx_data),UVM_LOW);
        data1_pid_byte = {data1_pid, ~data1_pid};
       `uvm_info("pidbyte",$sformatf("data1_pid_byte=%0d",data1_pid_byte),UVM_LOW)
        tx_data.push_back(data1_pid_byte);
        data = interface_setting[wIndex[7:0]];
        `uvm_info("DATA",$sformatf("GET_INTERFACE_DATA=%0B",data),UVM_LOW)
        tx_data.push_back(data);
        send_to_utmi(tx_data,req);
      endtask

      task send_get_configuration(bit [3:0] data1_pid);
        bit [7:0] data1_pid_byte;
        tx_data.delete();
       `uvm_info("DEVICE_DRIVER",$sformatf("ENTERED_INTO_DEVICE_GET_CONFIG_TASK_PKT_DATA_STAGE_DATA1_PID =%0d tx_data=%0p",data1_pid,tx_data),UVM_LOW);
       data1_pid_byte = {data1_pid, ~data1_pid};
      `uvm_info("pidbyte",$sformatf("data1_pid_byte=%0d",data1_pid_byte),UVM_LOW)
        tx_data.push_back(data1_pid_byte);
        tx_data.push_back(configuration_value);
        send_to_utmi(tx_data,req);
      endtask

     task send_to_utmi(bit [7:0]tx_data[$],USB2p0_sequence_item usb_seq_item);
     //task send_to_utmi(bit [DATA_WIDTH-1:0]tx_data[$],USB2p0_sequence_item usb_seq_item);
      bit [15:0] tx_data_drive;
      @(posedge utmi_interface_tx.cb_utmi_device_controller_driver);
      `uvm_info("DATA",$sformatf("ENTERED_INTO_SEND_TO_UTMI_TX tx_data.size=%0d, tx_data=%0p",tx_data.size(),tx_data),UVM_LOW)
      if(usb_seq_item.op_mode == 2'b00 &&  (usb_seq_item.tx_valid ||  usb_seq_item.tx_validh) ) begin
     //     @(posedge utmi_interface_tx.cb_utmi_device_controller_driver);
        utmi_interface_tx.utmi_word_if        <= usb_seq_item.word_if;
        utmi_interface_tx.utmi_opmode <= usb_seq_item.op_mode;
        utmi_interface_tx.utmi_txvalid        <= usb_seq_item.tx_valid;
        utmi_interface_tx.utmi_txvalidh       <= usb_seq_item.tx_validh;
        utmi_interface_tx.utmi_suspend_n      <= usb_seq_item.suspend_n;
        utmi_interface_tx.utmi_termselect     <= usb_seq_item.term_select;
        utmi_interface_tx.utmi_xcvrselect     <= usb_seq_item.xcvr_select;
        utmi_interface_tx.utmi_fsls_low_power <= usb_seq_item.fsls_low_power;
        utmi_interface_tx.utmi_fslsserialmode <= usb_seq_item.fsls_serialmode;
        utmi_interface_tx.utmiotg_dppulldown  <= usb_seq_item.otg_dppulldown;
        utmi_interface_tx.utmiotg_dmpulldown  <= usb_seq_item.otg_dmpulldown;
    
        while(tx_data.size() > 0) begin
            `uvm_info("DATA",$sformatf("TX_DATA_SIZE=%0d, tx_data=%0p ",tx_data.size(),tx_data),UVM_LOW)
          if(usb_seq_item.word_if && usb_seq_item.tx_valid && usb_seq_item.tx_validh) begin
            `uvm_info("DEVICE_DRIVER",$sformatf("ENTERED_INTO_SENDUTMI_WORDIF_ONE"),UVM_LOW);
              tx_data_drive[7:0]  = tx_data.pop_front();
              tx_data_drive[15:8] = tx_data.pop_front();
              //tx_data_drive = tx_data.pop_front();
            wait(utmi_interface_tx.utmi_txready);
              utmi_interface_tx.utmi_txdata[7:0]  <= tx_data_drive[7:0];
              utmi_interface_tx.utmi_txdata[15:8] <= tx_data_drive[15:8];
              //utmi_interface_tx.utmi_txdata <= tx_data_drive;
          end
          else if(!usb_seq_item.word_if && usb_seq_item.tx_valid && !usb_seq_item.tx_validh) begin
            tx_data_drive[7:0] = tx_data.pop_front();
            wait(utmi_interface_tx.utmi_txready);
            utmi_interface_tx.utmi_txdata[7:0] <= tx_data_drive[7:0];
             //`uvm_info("DATA",$sformatf("ENTERED_INTO_SEND_TO_UTMI_TX utmi_tx_data=%0h",utmi_interface_tx.utmi_txdata),UVM_LOW)
            //usb_seq_item.utmi_txdata.push_back(utmi_interface_tx.utmi_txdata);
          end
          @(posedge utmi_interface_tx.cb_utmi_device_controller_driver);
        end //while begin_end
          if(tx_data.size() ==0) begin
             utmi_interface_tx.utmi_txvalid  <= 0;
             utmi_interface_tx.utmi_txvalidh <= 0;
             utmi_interface_tx.utmi_word_if  <= 0;
              `uvm_info("DATA",$sformatf("SENT_TI_UTMI "),UVM_LOW)
              usb_seq_item.print();
           end
      end //if begin_end
    endtask
  
endclass



