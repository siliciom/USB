
class USB2p0_HOST_controller_driver extends uvm_driver #(USB2p0_sequence_item);
  
       `uvm_component_utils(USB2p0_HOST_controller_driver)
  
 	USB2p0_sequence_item usb_seq_item;
 
 	virtual USB2p0_host_utmi_interface                           utmi_interface_tx, utmi_interface_rx;
 	virtual USB2p0_device_utmi_interface                         device_utmi_interface_tx, device_utmi_interface_rx;
        virtual USB2p0_PHY_interface.cb_phy_driver                   usb_phy_interface;

        speed_state usb_speed;
        uvm_event_pool 	usb_event_pool;

        uvm_event   seq_done_ev; 
        uvm_event   reset_ev;
        uvm_event   fs_ev;
        uvm_event   ack_done_ev;
        uvm_event   ack_done_zlp_ev;
        uvm_event   ack_done_get_status_ev;
        uvm_event   data_stage_done_ev;
        uvm_event   interrupt_transfer_ev;
         bit [7:0] tx_data_queue[$]; 
         bit [15:0] data16;
         bit [7:0]  data8;
         bit [DATA_WIDTH-1:0] rx_data;
         bit [DATA_WIDTH-1:0] rx_data_zlp;
         bit [DATA_WIDTH-1:0] rx_data_get_status;
         bit [DATA_WIDTH-1:0] rx_data_interrupt;
         bit [DATA_WIDTH-1:0] rx_data_isochronous;
         bit [DATA_WIDTH-1:0] rx_data_bulk;
         bit [DATA_WIDTH-1:0] rx_data_ack_for_interrupt_out;
         bit [DATA_WIDTH-1:0] rx_data_ack_for_iso_out;
         bit [DATA_WIDTH-1:0] rx_data_ack_for_bulk_out;
         bit  device_detection_done;

	typedef enum bit [7:0] {setup_pid, setup_addr, setup_end_point, setup_crc5,data_pid,data_bmrequest,data_brequest,data_value_lsb,data_value_msb,data_windex_lsb,data_windex_msb,data_wlenght_lsb,data_wlenght_msb,data_crc16_lsb,data_crc16_msb}packet_format;

	function new(string name="USB2p0_HOST_controller_driver", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
	     super.build_phase(phase);
	
    	   if (!uvm_config_db#(virtual USB2p0_host_utmi_interface)::get(this, "", "USB_HOST_UTMI_INTERFACE", utmi_interface_tx))
            `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")

         if (!uvm_config_db#(virtual USB2p0_host_utmi_interface)::get(this, "", "USB_HOST_UTMI_INTERFACE", utmi_interface_rx))
            `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")

    	   if (!uvm_config_db#(virtual USB2p0_device_utmi_interface)::get(this, "", "USB_DEVICE_UTMI_INTERFACE", device_utmi_interface_rx))
            `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")
         
        if(!uvm_config_db#(virtual USB2p0_PHY_interface)::get(this, "", "USB_PHY_INTERFACE", usb_phy_interface))
     	      `uvm_fatal("NOVIF", "USB_PHY_INTERFACE not found")
	
	
  	     if(!uvm_config_db#(speed_state)::get(this,"","USB_SPEED",usb_speed))
                 `uvm_fatal("NO USB SPEED","USB_SPEED IS NOT FOUND")

		
                usb_seq_item=USB2p0_sequence_item::type_id::create("usb_seq_item");
  	endfunction

        task device_detection(USB2p0_sequence_item usb_seq_item);
	       `uvm_info("HOST_CONTROLLER_DRIVER", $sformatf("ENTERED_INTO_DEVICE_DETECTION_TASK"),UVM_LOW)
	   utmi_interface_tx.utmiotg_vbusvalid<=usb_seq_item.otg_vbusvalid; 
	
	   if(usb_seq_item.otg_vbusvalid==1 && usb_seq_item.tx_valid==1) begin  
	       `uvm_info(get_full_name(), $sformatf("HOST CONTROLLER DRIVER: VBUS=%b otg_vbusvalid=%0d",utmi_interface_tx.utmiotg_vbusvalid,usb_seq_item.otg_vbusvalid),UVM_LOW)      
	        wait(utmi_interface_rx.utmisrp_bvalid==1)
	       `uvm_info("HOST_CONTROLLER_DRIVER", $sformatf("HOST CONTROLLER DRIVER: utmisrp_bvalid=%b",utmi_interface_rx.utmisrp_bvalid),UVM_LOW)
	        if(utmi_interface_rx.utmisrp_bvalid==1) begin     
	         `uvm_info(get_full_name(), $sformatf("HOST_CONTROLLER_DRIVER: utmisrp_bvalid=%b",utmi_interface_rx.utmisrp_bvalid),UVM_LOW)
	          `uvm_info(get_full_name(), $sformatf("--- POWER_ON_DONE---"),UVM_LOW)
	          //@(posedge utmi_interface_tx.cb_utmi_host_controller_driver);
	          @(posedge utmi_interface_tx.utmi_clk);
	          detect_device_speed();
	          if(usb_speed == USB_LS) begin
	               send_to_utmi(usb_seq_item);
	               `uvm_info(get_full_name(), $sformatf("------- %s DEVICE_IS_CONNECTED_TO_HOST----------",usb_speed),UVM_LOW)
		        usb_seq_item.ls_device_detected=1;
	          end 
	          else
	          if(usb_speed == USB_FS)begin
	            `uvm_info(get_full_name(), $sformatf("-------HOST IS CONNECTED TO THE %s DEVICE----------",usb_speed),UVM_LOW)
	             send_reset();
	             send_to_utmi(usb_seq_item);
		     usb_seq_item.fs_device_detected =1;
	          end
	          else if(usb_speed == USB_HS)begin
	            `uvm_info(get_full_name(), $sformatf("-------HOST IS CONNECTED TO THE %s DEVICE----------",usb_speed),UVM_LOW)
	             send_reset();
	             send_to_utmi(usb_seq_item);
		     usb_seq_item.hs_device_detected =1;
	          end
                end
           end
           else if(usb_seq_item.otg_vbusvalid==0) begin  
              `uvm_fatal("HOST_DRIVER","---------POWER_IS_NOT_CONNECTED_TO_HOST_OR_POWER_DISCONNECT--------")
               
           end
         //`uvm_info(get_full_name(), $sformatf("---------DEVICE_DETECTION_DONE--------"),UVM_LOW)
         device_detection_done =1;
   endtask

   task send_to_utmi(USB2p0_sequence_item  usb_seq_item);
            //@(posedge utmi_interface_tx.cb_utmi_host_controller_driver)
	          @(posedge utmi_interface_tx.utmi_clk);
    	    utmi_interface_tx.utmi_opmode         <= usb_seq_item.op_mode;
    	 if(usb_seq_item.op_mode==2'b00)  begin
	    utmi_interface_tx.utmi_word_if        <= usb_seq_item.word_if;
      	    utmi_interface_tx.utmi_suspend_n      <= usb_seq_item.suspend_n;
      	    utmi_interface_tx.utmi_termselect     <= usb_seq_item.term_select;
      	    utmi_interface_tx.utmi_xcvrselect     <= usb_seq_item.xcvr_select;
      	    utmi_interface_tx.utmi_fsls_low_power <= usb_seq_item.fsls_low_power;
      	    utmi_interface_tx.utmi_fslsserialmode <= usb_seq_item.fsls_serialmode;
      	    utmi_interface_tx.utmiotg_dppulldown  <= usb_seq_item.otg_dppulldown;
      	    utmi_interface_tx.utmiotg_dmpulldown  <= usb_seq_item.otg_dmpulldown;
    
            if (usb_speed == USB_LS ) begin     
               `uvm_info("HDC","ENTERED_INTO_LOWSPEED",UVM_LOW)
                utmi_interface_tx.utmi_word_if  <= 1'b0;
                utmi_interface_tx.utmi_txvalid  <= usb_seq_item.tx_valid;
                utmi_interface_tx.utmi_txvalidh <= 1'b0;
            end 
            else if (usb_speed == USB_FS) begin     
              `uvm_info("HDC","ENTERED INTO FULLSPEED",UVM_LOW)
               utmi_interface_tx.utmi_word_if  <= 1'b0;
               utmi_interface_tx.utmi_txvalid  <= usb_seq_item.tx_valid;
               utmi_interface_tx.utmi_txvalidh <= 1'b0;
            end else  //HS
            begin
               utmi_interface_tx.utmi_word_if  <= usb_seq_item.word_if;
               utmi_interface_tx.utmi_txvalidh <= usb_seq_item.tx_validh;
               utmi_interface_tx.utmi_txvalid  <= usb_seq_item.tx_valid;
               `uvm_info("HDC","ENTERED INTO HIGHSPEED",UVM_LOW)
            end
            end

	endtask

 	task run_phase(uvm_phase phase);
	        usb_event_pool = uvm_event_pool::get_global_pool();
      		seq_done_ev=usb_event_pool.get("host_chirp_done");
      		reset_ev   =usb_event_pool.get("RESET_EVENT");
      		fs_ev      =usb_event_pool.get("FS_EVENT");
      		ack_done_ev =usb_event_pool.get("ACK_DONE_EVENT");
      		ack_done_zlp_ev =usb_event_pool.get("ACK_ZLP_DONE_EVENT");
      		ack_done_get_status_ev =usb_event_pool.get("ACK_GET_STATUS_DONE_EVENT");
                data_stage_done_ev = usb_event_pool.get("DATA_STAGE_DONE_EVENT");
                interrupt_transfer_ev = usb_event_pool.get("INTERRUPT_TRANSFER_EVENT");
    	       `uvm_info("HOST_DRIVER", $sformatf("ENTERED_INTO_HOST_DRIVER RUN_PHASE "),UVM_LOW) 
          forever begin
	    seq_item_port.get_next_item(req);
	    `uvm_info("HOST_DRIVER","READ_FROM_HOST_SEQ",UVM_LOW)
	     req.print();
           if(!device_detection_done)
	     device_detection(req);
             //control_transfer(req);
             start_transfer(req);
           if(device_detection_done)
            seq_item_port.item_done();
          end
      endtask

      task detect_device_speed();
          `uvm_info("HOST","Waiting_for_Detect_Device",UVM_LOW)
          // #1;
          `uvm_info("HOST",$sformatf("Line state value=%0d",utmi_interface_rx.utmi_linestate),UVM_LOW) 
           wait (utmi_interface_rx.utmi_linestate != 2'b00);

          `uvm_info("HOST_DRV","ENTERED INTO CASE",UVM_LOW)

    	case (utmi_interface_rx.utmi_linestate)

     	    2'b01: begin
        	usb_speed = USB_LS;
               `uvm_info("HOST","LOW_SPEED_DEVICE_IS_DETECTED_BY_THE_HOST",UVM_LOW)
            end

      	   2'b10: begin
        	usb_speed = USB_FS;
                `uvm_info("HOST","FULL SPEED DEVICE IS DETECTED ",UVM_LOW)
                `uvm_info("HOST","exit from send_reset",UVM_LOW)
               //detect_hs_chirp();
            end
         endcase

          `uvm_info("HOST","COMPLETED_for_Detect_Device",UVM_LOW)
     endtask


      task send_reset();

         `uvm_info("HOST","ASSERT RESET",UVM_LOW)
          utmi_interface_rx.utmi_linestate <= 2'b00;
          
          usb_phy_interface.Dp <= 1'b0;
          usb_phy_interface.Dm <= 1'b0;
            
          //#1;
         `uvm_info("HOST",$sformatf("UTMI LINESTATE AFTER RESET IS =%b",utmi_interface_rx.utmi_linestate),UVM_LOW)
         `uvm_info("HOST",$sformatf("FULL SPEED DEVICE IS DETECTED BY HOST"),UVM_LOW)
         `uvm_info("HCD",$sformatf("USB SPEED= %s",usb_speed),UVM_LOW)

   	 fork begin
      		wait(utmi_interface_rx.utmi_linestate == 2'b01);
                #3us;
                usb_speed = USB_HS;
                send_host_chirp_kj();
            end
         join_none
 	   
	    #10ms;
          
             usb_phy_interface.Dp <= 1'b1;
             usb_phy_interface.Dm <= 1'b0;

   	   if (usb_speed != USB_HS) begin
    	       usb_speed = USB_FS;
	       `uvm_info("HCD","FULL SPEED DEVICE IS DETECTED BY THE HOST",UVM_LOW)
               send_to_utmi(usb_seq_item);
            end
      endtask
  
	task detect_hs_chirp();

   	  `uvm_info("HOST_HS","Waiting Device Chirp K",UVM_LOW)
              wait (utmi_interface_rx.utmi_linestate == 2'b01);
		 #3us;
		`uvm_info("HOST_HS","Device Chirp Detected Capable of High Speed",UVM_LOW)
		 usb_speed = USB_HS;
	        `uvm_info("HOST_HS","HOST ENTERED HIGH SPEED",UVM_LOW)
		send_host_chirp_kj();
        endtask
  
	task send_host_chirp_kj();
  	     `uvm_info("HOST_HS","Sending KJ Chirp Sequence",UVM_LOW)

            repeat (3) begin
                 utmi_interface_tx.utmi_linestate <= 2'b01;
                 //seq_done_ev.trigger();
                 #50us;
                 utmi_interface_tx.utmi_linestate <= 2'b10;
                 //seq_done_ev.trigger();
		#50us;
		//seq_done_ev.trigger();
             end
        endtask
//////////////////////////////////////////////////////////////////////////////////

    task start_transfer(USB2p0_sequence_item usb_seq_item);
            `uvm_info("DRV", $sformatf("ENTER_INTO_TRANSFER_TYPE_AND_SPEED_Speed=%s Transfer=%s", usb_speed.name(), usb_seq_item.transfer_type.name()), UVM_LOW)
 
         case (usb_speed)
            USB_LS: begin
            case (usb_seq_item.transfer_type)
              USB2p0_sequence_item::CONTROL_TRANSFER: begin
                control_transfer(req);
              end
 
              USB2p0_sequence_item::INTERRUPT_TRANSFER: begin
                interrupt_transfer(req);
              end
 
              USB2p0_sequence_item::BULK_TRANSFER: begin
                `uvm_error("USB_PROTO","BULK_TRANSFER_NOT_SUPPORTED_IN_LOW_SPEED")
              end
 
              USB2p0_sequence_item::ISO_CHRONOUS_TRANSFER: begin
                 `uvm_error("TRANSFER_TYPE","ISOCHRONOUS_TRANSFER_NOT_SUPPORTED_IN_LOW_SPEED")
              end
            endcase
            end
 
           USB_FS: begin
            case (usb_seq_item.transfer_type)
              USB2p0_sequence_item::CONTROL_TRANSFER: begin
                control_transfer(req);
              end
 
              USB2p0_sequence_item::INTERRUPT_TRANSFER: begin
                interrupt_transfer(req);
              end
 
              USB2p0_sequence_item::BULK_TRANSFER: begin
                bulk_transfer(req);
              end
 
              USB2p0_sequence_item::ISO_CHRONOUS_TRANSFER: begin
                isochronous_transfer(req);
              end
            endcase
           end
           // ---------------- HIGH SPEED ----------------
          //USB_HS: begin
            //case (usb_seq_item.transfer_type)
             // CONTROL_TRANSFER:   control_fsm(usb_seq_item);
             // BULK_TRANSFER:      bulk_transfer();
             // INTERRUPT_TRANSFER: interrupt_transfer();
             // ISO_CHRONOUS_TRANSFER: isoch_transfer();
            //endcase
          //end
       endcase
 
     endtask


///////////////////////////////////////////////////////////////////////////////////////

      task control_transfer(USB2p0_sequence_item usb_seq_item);
	     `uvm_info("HOST_DRIVER",$sformatf("ENTERED_INTO_CONTROL_TRANSFER"),UVM_LOW)
              setup_stage();
              // For a no-data control transfer, advance to status stage only after the
              // device ACK has been received on the host RX interface.
             // wait(utmi_interface_rx.utmi_rxactive ==0);
               ack_done_ev.wait_trigger();
               if(usb_seq_item.wLength == 'd0  && rx_data =='h2d) begin
	         `uvm_info("HOST_DRIVER",$sformatf("CONTROL_TRANSFER_TASK_WLENGHT=%0b",usb_seq_item.wLength),UVM_LOW)
		  status_stage_in(req);
                end
               else begin
                  data_stage_in(req);
                  data_stage_done_ev.wait_trigger();                  
                  status_stage_out(req);
               end
      endtask

      task setup_stage();
	     `uvm_info("HOST_DRIVER",$sformatf("ENTERED_INTO_SETUP_STAGE"),UVM_LOW)
	     setup_data(req);
             handshake_pkt();
	     `uvm_info("HOST_DRIVER",$sformatf("COMPLETED_SETUP_STAGE"),UVM_LOW)
      endtask

      task data_stage_in(USB2p0_sequence_item usb_seq_item);
	 `uvm_info("HOST_DRIVER",$sformatf("ENTERED_INTO_DATA_STAGE"),UVM_LOW)
           req.print();
           //if(usb_seq_item.data_stage_pid_in == 'b1001) begin
           if(usb_seq_item.token_pid_in == 'b1001) begin
	    `uvm_info("HOST_DRIVER",$sformatf("RECEIVED_DATA_STAGE_IN_TOKEN_PKT"),UVM_LOW)
            //token_pkt(usb_seq_item.data_stage_pid_in,usb_seq_item.addr,usb_seq_item.endp);
            token_pkt(usb_seq_item.token_pid_in,usb_seq_item.addr,usb_seq_item.endp);
            send_to_utmi_tx(usb_seq_item);
            receive_get_status();
            ack_done_get_status_ev.wait_trigger();          
             wait(rx_data_get_status == 'hb4) begin
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("DATA_RECEIVED_FOR_GET_STATUS_SENDING_ACK"),UVM_LOW)
               send_host_handshake(PID_ACK);
               end
            end
      endtask

     task status_stage_in(USB2p0_sequence_item usb_seq_item);
         `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("ENTERED_INTO_STATUS_STAGE"),UVM_LOW) 
          //token_pkt(usb_seq_item.status_stage_pid_in,usb_seq_item.addr,usb_seq_item.endp);
          token_pkt(usb_seq_item.token_pid_in,usb_seq_item.addr,usb_seq_item.endp);
          send_to_utmi_tx(usb_seq_item);
          receive_status_stage_zlp();
          ack_done_zlp_ev.wait_trigger();          
           wait(rx_data_zlp == 'hb4) begin
            `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("STATUS_STAGE_DATA1/ZLP_RECEIVED_SEND_ACK"),UVM_LOW)
             send_host_handshake(PID_ACK);
            end
     endtask
  
     task status_stage_out(USB2p0_sequence_item usb_seq_item);
        `uvm_info("HOST_DRIVER","STATUS_STAGE_OUT",UVM_LOW)
         //token_pkt(usb_seq_item.status_stage_pid_out,usb_seq_item.addr,usb_seq_item.endp);
         token_pkt(usb_seq_item.token_pid_out,usb_seq_item.addr,usb_seq_item.endp);
         send_status_stage_zlp_pkt(PID_DATA1);
         send_to_utmi_tx(usb_seq_item);
        // handshake_pkt();
     endtask
     
     task setup_data(USB2p0_sequence_item usb_seq_item);
        bit [DATA_WIDTH-1:0]  tx_data_drive;
        bit [7:0]             pid_byte;
        packet_format pkt;
        pkt = setup_pid;
        `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("ENTERED_INTO_SETUP_DATA_TASK "),UVM_LOW) 
        //`uvm_info("HOST_CONTROLLER_DRIVER",$sformatf(" RECEIVED_FROM_SEQ setup_token_pid=%0h, addr=%0h, endp=%0h, data_token_pid=%0h ",usb_seq_item.setup_token_pid,usb_seq_item.addr,usb_seq_item.endp,usb_seq_item.data_stage_pid_in),UVM_LOW)
        `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf(" RECEIVED_FROM_SEQ setup_token_pid=%0h, addr=%0h, endp=%0h, data_token_pid=%0h ",usb_seq_item.setup_token_pid,usb_seq_item.addr,usb_seq_item.endp,usb_seq_item.token_pid_in),UVM_LOW)
            token_pkt(usb_seq_item.setup_token_pid,usb_seq_item.addr,usb_seq_item.endp);
            data_pkt(usb_seq_item);
            send_to_utmi_tx(usb_seq_item); 
     endtask

	task token_pkt(bit [3:0]pid,bit[6:0] addr,bit[3:0] endp);
	      bit [7:0] pid_byte;
               `uvm_info("HOST_DRIVER",$sformatf("ENTERED_INTO_TOKEN_PKT PID=%0h, addr=%0d, endp=%0d",pid,addr,endp),UVM_LOW)
               pid_byte = {pid,~pid};
               `uvm_info("HOST_DRIVER",$sformatf("PID_BYTE=%0h,PID_BYTE=%0d",pid_byte,pid_byte),UVM_LOW)
               tx_data_queue.push_back(pid_byte);          
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_TOKEN_PID =%p",tx_data_queue),UVM_LOW) 
              tx_data_queue.push_back(addr);
              tx_data_queue.push_back(endp);
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_TOKEN_ADDR AND END_POINT =%p",tx_data_queue),UVM_LOW) 
	      calc_crc5(addr,endp); 
            `uvm_info("CRC5",$sformatf(" crc5=%0d ",usb_seq_item.crc5),UVM_LOW)
              tx_data_queue.push_back(usb_seq_item.crc5);
             `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_TOKEN_PACKET END_POINT AND CRC5 =%p",tx_data_queue),UVM_LOW) 
        endtask

        task data_pkt(USB2p0_sequence_item usb_seq_item);
	   bit [7:0] pid_byte;
           `uvm_info("HOST_DRIVER",$sformatf("ENTERED_INTO_DATA_PKT "),UVM_LOW)
            usb_seq_item.print();
            
             pid_byte = {usb_seq_item.setup_data_pid,~usb_seq_item.setup_data_pid};
              tx_data_queue.push_back(pid_byte);
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_DATA_PACKET PID=%0p",tx_data_queue),UVM_LOW)                 
              usb_seq_item.bmRequestType=usb_seq_item.bmRequestType ;
              tx_data_queue.push_back(usb_seq_item.bmRequestType);
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_DATA_PACKET_ BMREQUEST_TYPE=%0p",tx_data_queue),UVM_LOW)
              
                tx_data_queue.push_back(usb_seq_item.bRequest);
               `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_DATA_PACKET_ BREQUEST=%0p",tx_data_queue),UVM_LOW)
              
              tx_data_queue.push_back(usb_seq_item.wValue[7:0]);
              tx_data_queue.push_back(usb_seq_item.wValue[15:8]);
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_DATA_PACKET  WVALUE=%0p",tx_data_queue),UVM_LOW)
              
              tx_data_queue.push_back(usb_seq_item.wIndex[7:0]);
              tx_data_queue.push_back(usb_seq_item.wIndex[15:8]);
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_DATA_PACKET  WINDEX=%0p",tx_data_queue),UVM_LOW)
              
              tx_data_queue.push_back(usb_seq_item.wLength[7:0]);
              tx_data_queue.push_back(usb_seq_item.wLength[15:8]);
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_DATA_PACKET  WLENGTH=%0p",tx_data_queue),UVM_LOW)
               
              calc_crc16(usb_seq_item);
              tx_data_queue.push_back(usb_seq_item.crc16[7:0]);
              tx_data_queue.push_back(usb_seq_item.crc16[15:8]);
              `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("SETUP_DATA_PACKET_CRC16 =%0p",tx_data_queue),UVM_LOW)
        endtask
     
        task send_status_stage_zlp_pkt(bit [3:0] data1_pid);
	    bit [7:0] data1_pid_byte;
	    bit [15:0] crc16;
            //tx_data_queue.delete();
            //req.utmi_txdata.delete();
	    `uvm_info("DEVICE_DRIVER",$sformatf("ENTERED_INTO_ZLP_PKT_status_stage_data1_pid=%0d",data1_pid),UVM_LOW);
	    data1_pid_byte = {data1_pid,~data1_pid};
	    `uvm_info("DEVICE_DRIVER",$sformatf("status_stage_data1_pid=%0h",data1_pid_byte),UVM_LOW);
	    tx_data_queue.push_back(data1_pid_byte);
	    `uvm_info("DEVICE_DRIVER",$sformatf("status_stage_tx_data pid_byte %0p",tx_data_queue),UVM_LOW);
	    calc_crc16_zlp();
	    tx_data_queue.push_back(usb_seq_item.crc16[7:0]);
	    tx_data_queue.push_back(usb_seq_item.crc16[15:8]);
	    `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("STATUS_STAGE_DATA_PACKET_CRC16 =%0p",tx_data_queue),UVM_LOW);
             //foreach (tx_data_queue[i]) begin
               //req.utmi_txdata.push_back(tx_data_queue[i][7:0]);
             //end
             //send_to_utmi_tx(usb_seq_item);
	    `uvm_info("DEVICE_CONTROLLER_DRIVER",$sformatf("FOR_STATUS_STAGE_SEND_UTMI_TASK_COMPLETED"),UVM_LOW);
    endtask



        task handshake_pkt();
	   `uvm_info("HOST_DRIVER",$sformatf("ENTERED_INTO_HANDSHAKE_PKT"),UVM_LOW)
           // Gate the handshake on RXACTIVE/RXVALID as well as RXDATA so the host does
           // not react to stale 0/x values before the PHY presents a real ACK beat.
           wait(utmi_interface_rx.utmi_rxactive && (utmi_interface_rx.utmi_rxvalid || utmi_interface_rx.utmi_rxvalidh) && utmi_interface_rx.utmi_rxdata == 'h2d) begin
	         `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_PID_HANDSHAKE_CHECK"),UVM_LOW)
                  rx_data = utmi_interface_rx.utmi_rxdata;
	         `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_PID_HANDSHAKE_CHECK rx_data=%0h",utmi_interface_rx.utmi_rxdata),UVM_LOW)
           end
         endtask

        task receive_status_stage_zlp();
           wait(utmi_interface_rx.utmi_rxvalid && utmi_interface_rx.utmi_rxdata == 'd180) begin
	         `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_ZLP_DATA_CHECK"),UVM_LOW)
                 rx_data_zlp = utmi_interface_rx.utmi_rxdata; 
	        `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_ZLP_DATA_COLLECTED=%d",rx_data_zlp),UVM_LOW)
            end
         endtask
  
      

       task send_host_handshake(bit [3:0] handshake_pid);
           bit [7:0] hs_pid_byte;
           hs_pid_byte = {handshake_pid,~handshake_pid};
	   @(posedge utmi_interface_tx.utmi_clk);
           utmi_interface_tx.utmi_word_if  <= 1'b0;
           utmi_interface_tx.utmi_txdata   <= hs_pid_byte;
           utmi_interface_tx.utmi_txvalid  <= 1'b1;
           utmi_interface_tx.utmi_txvalidh <= 1'b0;
           wait(utmi_interface_tx.utmi_txready);
	   @(posedge utmi_interface_tx.utmi_clk);
           utmi_interface_tx.utmi_txvalid  <= 1'b0;
           utmi_interface_tx.utmi_txvalidh <= 1'b0;
           utmi_interface_tx.utmi_word_if  <= 1'b0;
           if(handshake_pid == PID_ACK)
             `uvm_info("HOST_DRIVER",$sformatf("HOST_SENT_HANDSHAKE_ACK= %0h", hs_pid_byte),UVM_LOW)
           else if(handshake_pid == PID_NAK)
             `uvm_info("HOST_DRIVER",$sformatf("HOST_SENT_HANDSHAKE_NACK= %0h", hs_pid_byte),UVM_LOW)
           else 
             `uvm_info("HOST_DRIVER",$sformatf("HOST_SENT_HANDSHAKE_STALL= %0h", hs_pid_byte),UVM_LOW)
        endtask

///////////////////////////////////////////////////////////////////
     task send_to_utmi_tx(USB2p0_sequence_item usb_seq_item);
        bit [15:0] tx_data_drive;
        packet_format pkt;
        pkt = setup_pid;

        `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("ENTERED_INTO_SEND_TO_UTMI_TX"),UVM_LOW) 
        while(tx_data_queue.size()>0) begin
          @(utmi_interface_tx.cb_utmi_host_controller_driver); 
          if(usb_seq_item.word_if && usb_seq_item.tx_valid && usb_seq_item.tx_validh )begin
            int i;
            tx_data_drive = '0;
	    for( i=0 ;i<DATA_WIDTH/8;i++)begin	
                 tx_data_drive[i*8 +: 8] = tx_data_queue.pop_front();                      		
            end
            // Present TXDATA together with TXVALID so the PHY does not capture a stale
            // leading 0 byte before the real PID. This also re-arms TXVALID for later
            // packets such as the status-stage token.
            // Use immediate testbench drives here so the PHY sees the first PID byte
            // on the same beat that TXVALID is asserted, instead of sampling a stale 0.
            utmi_interface_tx.utmi_word_if  = usb_seq_item.word_if;
            utmi_interface_tx.utmi_txdata   = tx_data_drive;
            utmi_interface_tx.utmi_txvalid  = usb_seq_item.tx_valid;
            utmi_interface_tx.utmi_txvalidh = usb_seq_item.tx_validh;
            wait(utmi_interface_tx.utmi_txready);
	        `uvm_info("HOST_CONTROLLER_DRIVER_AFTER_POP",$sformatf("%s = %0d", pkt.name(), tx_data_drive),UVM_LOW)
	        pkt = packet_format'(pkt+1);
                `uvm_info("HOST_CONTROLLER_DRIVER_AFTER_POP",$sformatf("%s = %0d", pkt.name(), tx_data_drive),UVM_LOW)
	        pkt = packet_format'(pkt+1);
          end 
          else if(!usb_seq_item.word_if && usb_seq_item.tx_valid )begin
               tx_data_drive = tx_data_queue.pop_front();
               // Drive the byte and TXVALID in the same beat so PID d2 reaches the PHY
               // and device driver without an extra prefixed 00.
               utmi_interface_tx.utmi_word_if  = usb_seq_item.word_if;
               utmi_interface_tx.utmi_txdata   = tx_data_drive;
               utmi_interface_tx.utmi_txvalid  = usb_seq_item.tx_valid;
               utmi_interface_tx.utmi_txvalidh = 1'b0;
	       wait(utmi_interface_tx.utmi_txready); 
	       `uvm_info("HOST_CONTROLLER_DRIVER_AFTER_POP",$sformatf("%s = %0d", pkt.name(), tx_data_drive[7:0]),UVM_LOW)
	        pkt = packet_format'(pkt+1);
	  end
        end  //while begin_end
         `uvm_info("HOST_CONTROLLER_DRIVER",$sformatf("WHILE_LOOP_EXIT_IN_HOST_DRIVER"),UVM_LOW) 
	 @(posedge utmi_interface_tx.utmi_clk);//begin
           utmi_interface_tx.utmi_txvalid    = 0;
           utmi_interface_tx.utmi_txvalidh   = 0;
           utmi_interface_tx.utmi_word_if    = 0;
       // end
     endtask


      task receive_get_status();
           wait(utmi_interface_rx.utmi_rxvalid && utmi_interface_rx.utmi_rxdata == 'hb4) begin
                 rx_data_get_status = utmi_interface_rx.utmi_rxdata; 
	        `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_GET_STATUS_DATA_COLLECTED=%d",rx_data_get_status),UVM_LOW)
            end
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


    task receiving_interrupt_data_from_device();
         wait(utmi_interface_rx.utmi_rxvalid && utmi_interface_rx.utmi_rxdata == 'hb4) begin
             rx_data_interrupt = utmi_interface_rx.utmi_rxdata; 
	        `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_INTERRUPT_DATA_COLLECTED=%d",rx_data_interrupt),UVM_LOW)
          end
             interrupt_transfer_ev.wait_trigger();
             send_host_handshake(PID_ACK);
    endtask


   //////////////////////////////////////////////////////////////////
     task interrupt_transfer(USB2p0_sequence_item usb_seq_item);
          if (usb_seq_item.direction == 0) begin
               `uvm_info("INTERRUPT","OUT_TRANSFER",UVM_LOW)
               token_pkt(usb_seq_item.interrupt_out_pid,usb_seq_item.addr,usb_seq_item.endp);
              `uvm_info("FSM",$sformatf("DATA_STAGE_ENTERED_FROM_HOST_TO_DEIVCE"),UVM_LOW)
               data_pkt_payload(PID_DATA1,req);
               receive_ack_for_interrupt_out();
           end
         else begin
         `uvm_info("INTERRUPT","IN_TRANSFER",UVM_LOW)
           token_pkt(usb_seq_item.interrupt_in_pid,usb_seq_item.addr,usb_seq_item.endp);
          `uvm_info("FSM",$sformatf("DATA_STAGE_ENTERED_FROM_DEIVCE_TO_HOST"),UVM_LOW)
            send_to_utmi_tx(usb_seq_item);
            receiving_interrupt_data_from_device();
          end
     endtask
      
     
     task isochronous_transfer(USB2p0_sequence_item usb_seq_item);
          if (usb_seq_item.direction == 0) begin
               `uvm_info("ISOCHRONOUS","ISOCHRONOUS_OUT_TRANSFER",UVM_LOW)
               token_pkt(usb_seq_item.iso_out_pid,usb_seq_item.addr,usb_seq_item.endp);
              `uvm_info("FSM",$sformatf("DATA_STAGE_ENTERED_FROM_HOST_TO_DEIVCE"),UVM_LOW)
               data_pkt_payload(PID_DATA1,req);
               receive_ack_for_iso_out();
           end
         else begin
         `uvm_info("ISOCHRONOUS","ISOCHRONOUS_IN_TRANSFER",UVM_LOW)
           token_pkt(usb_seq_item.iso_in_pid,usb_seq_item.addr,usb_seq_item.endp);
          `uvm_info("FSM",$sformatf("DATA_STAGE_ENTERED_FROM_DEIVCE_TO_HOST"),UVM_LOW)
           send_to_utmi_tx(usb_seq_item);
           receiving_iso_data_from_device();
          end
     endtask
     
    task bulk_transfer(USB2p0_sequence_item usb_seq_item);
          if (usb_seq_item.direction == 0) begin
               `uvm_info("BULK","BULK_OUT_TRANSFER",UVM_LOW)
               token_pkt(usb_seq_item.bulk_out_pid,usb_seq_item.addr,usb_seq_item.endp);
              `uvm_info("FSM",$sformatf("DATA_STAGE_ENTERED_FROM_HOST_TO_DEIVCE"),UVM_LOW)
               data_pkt_payload(PID_DATA1,req);
               receive_ack_for_bulk_out();
           end
         else begin
         `uvm_info("BULK","BULK_IN_TRANSFER",UVM_LOW)
           token_pkt(usb_seq_item.bulk_in_pid,usb_seq_item.addr,usb_seq_item.endp);
          `uvm_info("FSM",$sformatf("DATA_STAGE_ENTERED_FROM_DEIVCE_TO_HOST"),UVM_LOW)
           send_to_utmi_tx(usb_seq_item);
           receiving_bulk_data_from_device();
          end
     endtask

     task receiving_iso_data_from_device();
         wait(utmi_interface_rx.utmi_rxvalid && utmi_interface_rx.utmi_rxdata == 'hb4) begin
             rx_data_isochronous = utmi_interface_rx.utmi_rxdata; 
	        `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_ISOCHRONOUS_DATA_COLLECTED=%d",rx_data_isochronous),UVM_LOW)
          end
             interrupt_transfer_ev.wait_trigger();
             send_host_handshake(PID_ACK);
     endtask

     task receiving_bulk_data_from_device();
         wait(utmi_interface_rx.utmi_rxvalid && utmi_interface_rx.utmi_rxdata == 'hb4) begin
             rx_data_bulk = utmi_interface_rx.utmi_rxdata; 
	        `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_BULK_DATA_COLLECTED=%d",rx_data_bulk),UVM_LOW)
          end
             interrupt_transfer_ev.wait_trigger();
             send_host_handshake(PID_ACK);
     endtask

        task receive_ack_for_interrupt_out();
           wait(utmi_interface_rx.utmi_rxvalid && utmi_interface_rx.utmi_rxdata == 'd45) begin
	         `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_INTERRUPT_OUT_ACK"),UVM_LOW)
                 rx_data_ack_for_interrupt_out = utmi_interface_rx.utmi_rxdata; 
	        `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_INTERRUPT_OUT_COLLECTED=%d",rx_data_ack_for_interrupt_out),UVM_LOW)
            end
         endtask
 
        task receive_ack_for_iso_out();
           wait(utmi_interface_rx.utmi_rxvalid && utmi_interface_rx.utmi_rxdata == 'd45) begin
	         `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_INTERRUPT_OUT_ACK"),UVM_LOW)
                 rx_data_ack_for_iso_out = utmi_interface_rx.utmi_rxdata; 
	        `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_ISO_OUT_COLLECTED=%d",rx_data_ack_for_iso_out),UVM_LOW)
            end
         endtask

        task receive_ack_for_bulk_out();
           wait(utmi_interface_rx.utmi_rxvalid && utmi_interface_rx.utmi_rxdata == 'd45) begin
	         `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_BULK_OUT_ACK"),UVM_LOW)
                 rx_data_ack_for_bulk_out = utmi_interface_rx.utmi_rxdata; 
	        `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_BULK_OUT_COLLECTED=%d",rx_data_ack_for_bulk_out),UVM_LOW)
            end
         endtask

     task data_pkt_payload(bit [3:0] pid,USB2p0_sequence_item usb_seq_item );
         int max_pkt;
         bit [7:0] pid_byte;
         pid_byte = {pid, ~pid};
         `uvm_info("DATA",$sformatf("PAYLOAD_DATA1_PID=%h",pid_byte),UVM_LOW)
          `uvm_info("INTERRUPT","ENTERED_INTO_OUT_TRANSFER_DATA_PKT",UVM_LOW)
        case (usb_seq_item.transfer_type)
          USB2p0_sequence_item::CONTROL_TRANSFER     : max_pkt = 64;
          USB2p0_sequence_item::INTERRUPT_TRANSFER   : max_pkt = 64;
          USB2p0_sequence_item::BULK_TRANSFER        : max_pkt = 512;
          USB2p0_sequence_item::ISO_CHRONOUS_TRANSFER: max_pkt = 1024;
       endcase
 
       if (usb_seq_item.host_payload.size() <= max_pkt) begin
          `uvm_info("SIZE_OK",$sformatf("Payload_size = %0d ,within_limit %0d",usb_seq_item.host_payload.size(), max_pkt),UVM_LOW)
       end
       else begin
       `uvm_fatal("SIZE_ERR",$sformatf("Payload_size= %0d, exceeds_max= %0d",usb_seq_item.host_payload.size(), max_pkt))
       end   
 
        tx_data_queue.push_back(pid_byte);
        foreach (usb_seq_item.host_payload[i])begin
          tx_data_queue.push_back(usb_seq_item.host_payload[i]);
          `uvm_info("PAYLOAD_DATA",$sformatf("Payload[%0d] = 0x%0h", i, usb_seq_item.host_payload[i]),UVM_LOW)
        end

        calc_crc16_payload(usb_seq_item.host_payload,usb_seq_item);
        tx_data_queue.push_back(usb_seq_item.crc16[7:0]);
        tx_data_queue.push_back(usb_seq_item.crc16[15:8]);
       `uvm_info("HOST_DRIVER",$sformatf("TX_DATA = 0x%0P", tx_data_queue),UVM_LOW)
        send_to_utmi_tx(usb_seq_item);
     endtask
 
 
   task calc_crc16_payload(input bit [7:0] payload[], USB2p0_sequence_item usb_seq_item);
      bit [15:0] crc;
      bit din;
      int i,j;
        `uvm_info("INTERRUPT","ENTERED_INTO_OUT_TRANSFER_DATA_CRC16_TASK",UVM_LOW)
      crc = 16'hFFFF;
      foreach (payload[i]) begin
        for (j = 0; j < 8; j++) begin
          din = crc[15] ^ payload[i][j];
          crc = {crc[14:0], 1'b0};
          if (din)
            crc ^= 16'h8005;
        end
      end
      usb_seq_item.crc16 = ~crc;
    endtask

 



   //////////////////////////////////////////////////////////////////    
      task calc_crc5(bit [6:0]addr, bit [3:0]endp);
                  bit [10:0] token_bits;   
                  bit [4:0] crc;          
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
      
                  usb_seq_item.crc5=~crc;
                  `uvm_info("CRC5",$sformatf(" crc5=%0d crc=%0d",usb_seq_item.crc5,crc),UVM_LOW)
       endtask

     task calc_crc16(USB2p0_sequence_item usb_seq_item);
        
        bit [15:0] crc;
        bit din;
        bit [7:0] data[$];
        int i,j;
        crc=16'hFFFF;
        `uvm_info("CRC_16",$sformatf("ENTERED_INTO_CRC16"),UVM_LOW)
	usb_seq_item.print();
        data.push_back(usb_seq_item.bmRequestType);
        data.push_back(usb_seq_item.bRequest);
        data.push_back(usb_seq_item.wValue[7:0]);
        data.push_back(usb_seq_item.wValue[15:8]);
        data.push_back(usb_seq_item.wIndex[7:0]);
        data.push_back(usb_seq_item.wIndex[15:8]);
        data.push_back(usb_seq_item.wLength[7:0]);
        data.push_back(usb_seq_item.wLength[15:8]);
        
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
  endtask

  endclass









   /* task receive_descriptor_data_utmi_rx();
      bit [15:0]data16;
      bit [7:0]data8;

    `uvm_info("HOST_DRIVER", "ENTERED_INTO_RECEIVE_DEVICE_DESCRIPTORS_FROM_UTMI_RX", UVM_LOW)
         @(posedge utmi_interface_tx.utmi_clk);
          wait(utmi_interface_rx.utmi_rxvalid || utmi_interface_rx.utmi_rxvalidh) begin
             if (utmi_interface_rx.utmi_rxvalid) begin
               if (utmi_interface_rx.utmi_rxvalidh) begin
                   data16 = utmi_interface_rx.utmi_rxdata;
                   `uvm_info("HOST_DRIVER",$sformatf("16BIT_DATA = %h", data16),UVM_LOW)
                    //usb_seq_item.device_rx_data.push_back(data16);
                   //`uvm_info("HOST_DRIVER",$sformatf("16BIT_DATA = %p validh=%0d", usb_seq_item.device_rx_data,usb_seq_item.rx_validh),UVM_LOW)
                end
                else begin
                    //data8 = utmi_interface_rx.utmi_rxdata[7:0];
                    data8 = utmi_interface_rx.utmi_rxdata;
                    `uvm_info("HOST_DRIVER",$sformatf("8BIT_DATA = %h", data8),UVM_LOW)
                    //usb_seq_item.device_rx_data.push_back(data8);
                   // `uvm_info("HOST_DRIVER",$sformatf("8BIT_DATA = %p rx_valid=%0d ", usb_seq_item.device_rx_data,usb_seq_item.rx_valid),UVM_LOW)
                end
                `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_RECEIVED_DEVICE_DESCRIPTORS_DATA"),UVM_LOW)
             end
          end
      `uvm_info("HOST_DRIVER",$sformatf("HOST_DRIVER_RX_DATA"),UVM_LOW)
       usb_seq_item.print();
      //`uvm_info("HOST_DRIVER",$sformatf("RX_DATA = %0p",usb_seq_item.device_rx_data),UVM_LOW)
       //descrip_data_packet_received(req,usb_seq_item.device_rx_data);
   endtask*/

/*class USB2p0_HOST_controller_driver extends uvm_driver #(USB2p0_sequence_item);
  
       `uvm_component_utils(USB2p0_HOST_controller_driver)
  
 	USB2p0_sequence_item usb_seq_item;
 
 	virtual USB2p0_UTMI_interface utmi_interface_tx;
        virtual USB2p0_UTMI_interface utmi_interface_rx;
        virtual USB2p0_PHY_interface        usb_phy_interface;
        speed_state usb_speed;
        uvm_event_pool 	usb_event_pool;

        uvm_event   seq_done_ev; 
        uvm_event   reset_ev;
        uvm_event   fs_ev;
	 //bit [15:0] tx_data_queue[$]; 
	 bit [7:0] tx_data_queue[$]; 
         bit [15:0] data16;
         bit [7:0]  data8;
          bit [4:0]   crc5;
	typedef enum bit [7:0] {setup_pid, setup_addr, setup_end_point, setup_crc5,data_pid,data_bmrequest,data_brequest,data_value_lsb,data_value_msb,data_windex_lsb,data_windex_msb,data_wlenght_lsb,data_wlenght_msb,data_crc16_lsb,data_crc16_msb}packet_format;

       
        typedef enum {SETUP_STAGE, DATA_STAGE, STATUS_STAGE} state_e;
        state_e present_state, next_state;

	function new(string name="USB2p0_HOST_controller_driver", uvm_component parent);
		super.new(name,parent);
	endfunction

	function void build_phase(uvm_phase phase);
	     super.build_phase(phase);
	
    	     if (!uvm_config_db#(virtual USB2p0_UTMI_interface)::get(this, "", "USB_UTMI_INTERFACE_TX", utmi_interface_tx))
		`uvm_fatal("NO VIF", "UTMI_INTERFACE not found")

	     if (!uvm_config_db#(virtual USB2p0_UTMI_interface)::get(this, "", "USB_UTMI_INTERFACE_RX", utmi_interface_rx))
  	         `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")

  	     if(!uvm_config_db#(speed_state)::get(this,"","USB_SPEED",usb_speed))
                 `uvm_fatal("NO USB SPEED","USB_SPEED IS NOT FOUND")

      	    if(!uvm_config_db#(virtual USB2p0_PHY_interface)::get(this, "", "USB_PHY_INTERFACE", usb_phy_interface))
      	  	     `uvm_fatal("NOVIF", "USB_PHY_INTERFACE not found")
                usb_seq_item=USB2p0_sequence_item::type_id::create("usb_seq_item");
  	endfunction

        task device_detection(USB2p0_sequence_item usb_seq_item);
	    `uvm_info("HOST_CONTROLLER_DRIVER", $sformatf("ENTERED_INTO_DEVICE_DETECTION_TASK"),UVM_LOW)
	     utmi_interface_tx.utmiotg_vbusvalid<=usb_seq_item.otg_vbusvalid; 
        
	   if(usb_seq_item.otg_vbusvalid==1 && usb_seq_item.tx_valid==1) begin  
	       `uvm_info(get_full_name(), $sformatf("HOST CONTROLLER DRIVER: VBUS=%b",utmi_interface_tx.utmiotg_vbusvalid),UVM_LOW)      
	        wait(utmi_interface_rx.utmisrp_bvalid==1)
	       `uvm_info("HOST_CONTROLLER_DRIVER", $sformatf("HOST CONTROLLER DRIVER: utmisrp_bvalid=%b",utmi_interface_rx.utmisrp_bvalid),UVM_LOW)
	        if(utmi_interface_rx.utmisrp_bvalid==1) begin     
	         `uvm_info(get_full_name(), $sformatf("HOST_CONTROLLER_DRIVER: utmisrp_bvalid=%b",utmi_interface_rx.utmisrp_bvalid),UVM_LOW)
	          @(posedge utmi_interface_tx.cb_utmi_host_controller_driver);
	          detect_device_speed();
	          if(usb_speed == USB_LS) begin
                        control_fsm(usb_seq_item);
	               `uvm_info(get_full_name(), $sformatf("------- %s DEVICE_IS_CONNECTED_TO_HOST----------",usb_speed),UVM_LOW)
		        usb_seq_item.ls_device_detected=1;
			`uvm_info("USB_LS_DETECTED",$sformatf("setup_token_pid=%0b",usb_seq_item.setup_token_pid),UVM_LOW)
	          end 
	          else
	          if(usb_speed == USB_FS)begin
	            `uvm_info(get_full_name(), $sformatf("-------HOST IS CONNECTED TO THE %s DEVICE----------",usb_speed),UVM_LOW)
	             send_reset();
	             //send_to_utmi(usb_seq_item);
		     usb_seq_item.fs_device_detected =1;
	          end
	          else if(usb_speed == USB_HS)begin
	            `uvm_info(get_full_name(), $sformatf("-------HOST IS CONNECTED TO THE %s DEVICE----------",usb_speed),UVM_LOW)
	             send_reset();
	            // send_to_utmi(usb_seq_item);
		     usb_seq_item.hs_device_detected =1;
	          end
                end
           end
           else if(usb_seq_item.otg_vbusvalid==0) begin  
              `uvm_info(get_full_name(), $sformatf("---------HOST IS NOT CONNECTED TO THE DEVICE--------"),UVM_LOW)
           end
         `uvm_info(get_full_name(), $sformatf("---------DEVICE_DETECTION_DONE--------"),UVM_LOW)
   endtask

   
 	task run_phase(uvm_phase phase);
	       usb_event_pool = uvm_event_pool::get_global_pool();

      		seq_done_ev=usb_event_pool.get("host_chirp_done");
      		reset_ev   =usb_event_pool.get("RESET_EVENT");
      		fs_ev      =usb_event_pool.get("FS_EVENT");
    	  `uvm_info("HOST_DRIVER", $sformatf("ENTERED_INTO_HOST_DRIVER RUN_PHASE "),UVM_LOW) 
          forever begin
	    seq_item_port.get_next_item(req);
	    `uvm_info("HOST_DRIVER","READ_FROM_HOST_SEQ",UVM_LOW)
	    req.print();
	    device_detection(req);
	   seq_item_port.item_done();
	  end
      endtask


      task detect_device_speed();
          `uvm_info("HOST","Waiting_for_Detect_Device",UVM_LOW)
          // #1;
          `uvm_info("HOST",$sformatf("Line state value=%0d",utmi_interface_rx.utmi_linestate),UVM_LOW) 
           wait (utmi_interface_rx.utmi_linestate != 2'b00);
          `uvm_info("HOST_DRV","ENTERED INTO CASE",UVM_LOW)

    	case (utmi_interface_rx.utmi_linestate)
     	    2'b01: begin
        	usb_speed = USB_LS;
               `uvm_info("HOST","LOW_SPEED_DEVICE_IS_DETECTED_BY_THE_HOST",UVM_LOW)
            end
      	   2'b10: begin
        	usb_speed = USB_FS;
                `uvm_info("HOST","FULL SPEED DEVICE IS DETECTED ",UVM_LOW)
                `uvm_info("HOST","exit from send_reset",UVM_LOW)
               //detect_hs_chirp();
            end
         endcase
          `uvm_info("HOST","COMPLETED_for_Detect_Device",UVM_LOW)
     endtask


      task send_reset();
         `uvm_info("HOST","ASSERT RESET",UVM_LOW)
          utmi_interface_rx.utmi_linestate <= 2'b00;
          usb_phy_interface.Dp <= 1'b0;
          usb_phy_interface.Dm <= 1'b0;
            
          //#1;
         `uvm_info("HOST",$sformatf("UTMI LINESTATE AFTER RESET IS =%b",utmi_interface_rx.utmi_linestate),UVM_LOW)
         `uvm_info("HOST",$sformatf("FULL SPEED DEVICE IS DETECTED BY HOST"),UVM_LOW)
         `uvm_info("HCD",$sformatf("USB SPEED= %s",usb_speed),UVM_LOW)

   	 fork begin
      		wait(utmi_interface_rx.utmi_linestate == 2'b01);
                #3us;
                usb_speed = USB_HS;
                send_host_chirp_kj();
            end
         join_none
	    #10ms;
             usb_phy_interface.Dp <= 1'b1;
             usb_phy_interface.Dm <= 1'b0;
   	   if (usb_speed != USB_HS) begin
    	       usb_speed = USB_FS;
	       `uvm_info("HCD","FULL SPEED DEVICE IS DETECTED BY THE HOST",UVM_LOW)
              // send_to_utmi(usb_seq_item);
            end
      endtask
  
	task detect_hs_chirp();
   	  `uvm_info("HOST_HS","Waiting Device Chirp K",UVM_LOW)
              wait (utmi_interface_rx.utmi_linestate == 2'b01);
		 #3us;
		`uvm_info("HOST_HS","Device Chirp Detected Capable of High Speed",UVM_LOW)
		 usb_speed = USB_HS;
	        `uvm_info("HOST_HS","HOST ENTERED HIGH SPEED",UVM_LOW)
		send_host_chirp_kj();
        endtask
  
	task send_host_chirp_kj();
  	     `uvm_info("HOST_HS","Sending KJ Chirp Sequence",UVM_LOW)
            repeat (3) begin
                 utmi_interface_tx.utmi_linestate <= 2'b01;
                 //seq_done_ev.trigger();
                 #50us;
                 utmi_interface_tx.utmi_linestate <= 2'b10;
                 //seq_done_ev.trigger();
		#50us;
		//seq_done_ev.trigger();
             end
        endtask


      task control_fsm(USB2p0_sequence_item usb_seq_item);
        present_state = SETUP_STAGE;
        forever begin
          case (present_state)
            SETUP_STAGE: begin
              `uvm_info("FSM","SETUP_STAGE",UVM_LOW)
              //tx_data_queue.delete();
              //token_pkt(USB2p0_sequence_item::PID_SETUP);
              token_pkt(usb_seq_item.setup_token_pid,usb_seq_item);
              data_pkt_setup(usb_seq_item.setup_data_pid,usb_seq_item);
              //data_pkt_setup(USB2p0_sequence_item::PID_DATA0);
              send_to_utmi();
              //wait_tx_done();
              handshake_rx();
              next_state = DATA_STAGE;
            end
      
            DATA_STAGE: begin
              `uvm_info("FSM","DATA_STAGE",UVM_LOW)
               //tx_data_queue.delete();
              if (usb_seq_item.direction == 1) begin
               `uvm_info("FSM","DATA_STAGE_ENTERED_FROM_DEVICE_TO_HOST",UVM_LOW)
                //token_pkt(usb_seq_item.in_token_pid);
               // token_pkt(USB2p0_sequence_item::PID_IN);
               `uvm_info("FSM",$sformatf("DATA_STAGE_ENTERED_FROM_DEVICE_TO_HOST"),UVM_LOW)
                send_to_utmi();
                wait_rx_data();
                handshake_tx();
                next_state = STATUS_STAGE;
              end
              else begin
               `uvm_info("FSM","DATA_STAGE_ENTERED_FROM_HOST_TO_DEVICE",UVM_LOW)
                //token_pkt(usb_seq_item.out_token_pid);
              //  token_pkt(USB2p0_sequence_item::PID_OUT);
               `uvm_info("FSM",$sformatf("DATA_STAGE_ENTERED_FROM_HOST_TO_DEVICE"),UVM_LOW)
                //data_pkt_payload(USB2p0_sequence_item::PID_DATA1);
                send_to_utmi();
                handshake_rx();
                next_state = STATUS_STAGE;
              end
            end
      
            STATUS_STAGE: begin
              tx_data_queue.delete();
              if (usb_seq_item.direction == 1) begin
                `uvm_info("FSM","STATUS_STAGE (OUT)",UVM_LOW)
               // token_pkt(usb_seq_item.out_token_pid);
                send_to_utmi();
                handshake_rx();
              end
              else begin
                `uvm_info("FSM","STATUS_STAGE (IN)",UVM_LOW)
               // token_pkt(usb_seq_item.in_token_pid);
                send_to_utmi();
                wait_rx_data();
                handshake_tx();
              end
              next_state = SETUP_STAGE;
              present_state = next_state;
              `uvm_info("FSM","CONTROL TRANSFER DONE",UVM_LOW)
              break;
            end
          endcase
          present_state = next_state;
        end
      endtask

      task token_pkt(bit [3:0] pid,USB2p0_sequence_item usb_seq_item);
 
       bit [7:0] pid_byte;
       pid_byte = {pid, ~pid};
       `uvm_info("TOKEN",$sformatf("SETUP_TOKEN_PID=%h",pid_byte),UVM_LOW)
       tx_data_queue.push_back(pid_byte);
       tx_data_queue.push_back(usb_seq_item.addr);
       tx_data_queue.push_back(usb_seq_item.endp);
       //calc_crc5();
       calc_crc5(usb_seq_item);
       tx_data_queue.push_back(usb_seq_item.crc5);
       `uvm_info("TOKEN",$sformatf("TOKEN=%p",tx_data_queue),UVM_LOW)
     endtask

     task data_pkt_setup(bit [3:0] pid, USB2p0_sequence_item usb_seq_item);
       bit [7:0] pid_byte;
       pid_byte = {pid, ~pid};
       `uvm_info("DATA",$sformatf("SETUP_DATA_PID=%h",pid_byte),UVM_LOW)
       tx_data_queue.push_back(pid_byte);
       tx_data_queue.push_back(usb_seq_item.bmRequestType);
       tx_data_queue.push_back(usb_seq_item.bRequest);
       tx_data_queue.push_back(usb_seq_item.wValue[7:0]);
       tx_data_queue.push_back(usb_seq_item.wValue[15:8]);
       tx_data_queue.push_back(usb_seq_item.wIndex[7:0]);
       tx_data_queue.push_back(usb_seq_item.wIndex[15:8]);
       tx_data_queue.push_back(usb_seq_item.wLength[7:0]);
       tx_data_queue.push_back(usb_seq_item.wLength[15:8]);
       calc_crc16(usb_seq_item);
       tx_data_queue.push_back(usb_seq_item.crc16[7:0]);
       tx_data_queue.push_back(usb_seq_item.crc16[15:8]);
       `uvm_info("DATA",$sformatf("DATA=%p",tx_data_queue),UVM_LOW)
     endtask
   
     task send_to_utmi();
     bit [15:0] tx_data_drive;
     packet_format pkt;
     pkt = setup_pid;
     //@(posedge utmi_interface_tx.cb_utmi_host_controller_driver);
	          @(posedge utmi_interface_tx.utmi_clk);
     utmi_interface_tx.utmi_opmode <= usb_seq_item.op_mode;
     if(usb_seq_item.op_mode == 2'b00) begin
       utmi_interface_tx.utmi_word_if        <= usb_seq_item.word_if;
       utmi_interface_tx.utmi_suspend_n      <= usb_seq_item.suspend_n;
       utmi_interface_tx.utmi_termselect     <= usb_seq_item.term_select;
       utmi_interface_tx.utmi_xcvrselect     <= usb_seq_item.xcvr_select;
       utmi_interface_tx.utmi_fsls_low_power <= usb_seq_item.fsls_low_power;
       utmi_interface_tx.utmi_fslsserialmode <= usb_seq_item.fsls_serialmode;
       utmi_interface_tx.utmiotg_dppulldown  <= usb_seq_item.otg_dppulldown;
       utmi_interface_tx.utmiotg_dmpulldown  <= usb_seq_item.otg_dmpulldown;

               if (usb_speed == USB_LS ) begin     
                  `uvm_info("HDC","ENTERED_INTO_LOWSPEED",UVM_LOW)
                   utmi_interface_tx.utmi_word_if  <= 1'b0;
                   utmi_interface_tx.utmi_txvalid  <= usb_seq_item.tx_valid;
                   utmi_interface_tx.utmi_txvalidh <= 1'b0;
               end 
               else if (usb_speed == USB_FS) begin     
                 `uvm_info("HDC","ENTERED INTO FULLSPEED",UVM_LOW)
                  utmi_interface_tx.utmi_word_if  <= 1'b0;
                  utmi_interface_tx.utmi_txvalid  <= usb_seq_item.tx_valid;
                  utmi_interface_tx.utmi_txvalidh <= 1'b0;
               end else  //HS
               begin
                  utmi_interface_tx.utmi_word_if  <= usb_seq_item.word_if;
                  utmi_interface_tx.utmi_txvalidh <= usb_seq_item.tx_validh;
                  utmi_interface_tx.utmi_txvalid  <= usb_seq_item.tx_valid;
                  `uvm_info("HDC","ENTERED INTO HIGHSPEED",UVM_LOW)
               end

       while(tx_data_queue.size() > 0) begin
         @(utmi_interface_tx.cb_utmi_host_controller_driver);
         if(usb_seq_item.word_if && usb_seq_item.tx_valid && usb_seq_item.tx_validh) begin
           tx_data_drive[7:0]  = tx_data_queue.pop_front();
           tx_data_drive[15:8] = tx_data_queue.pop_front();
           wait(utmi_interface_tx.utmi_txready);
           utmi_interface_tx.utmi_txdata[7:0]  <= tx_data_drive[7:0];
           utmi_interface_tx.utmi_txdata[15:8] <= tx_data_drive[15:8];
           `uvm_info("TX",$sformatf("%s = %0d", pkt.name(), tx_data_drive[7:0]),UVM_LOW)
           pkt = packet_format'(pkt+1);
           `uvm_info("TX",$sformatf("%s = %0d", pkt.name(), tx_data_drive[15:8]),UVM_LOW)
           pkt = packet_format'(pkt+1);
         end
         else if(!usb_seq_item.word_if && usb_seq_item.tx_valid) begin
           tx_data_drive[7:0] = tx_data_queue.pop_front();
           wait(utmi_interface_tx.utmi_txready);
           utmi_interface_tx.utmi_txdata[7:0] <= tx_data_drive[7:0];
           `uvm_info("TX",$sformatf("%s = %0d", pkt.name(), tx_data_drive[7:0]),UVM_LOW)
           pkt = packet_format'(pkt+1);
         end
       end
       @(negedge utmi_interface_tx.cb_utmi_host_controller_driver);
       utmi_interface_tx.utmi_txvalid  <= 0;
       utmi_interface_tx.utmi_txvalidh <= 0;
       utmi_interface_tx.utmi_word_if  <= 0;
     end
     endtask


  task handshake_rx();
    `uvm_info("HANDSHAKE","WAITING FOR DEVICE ACK",UVM_LOW)
     wait(utmi_interface_rx.utmi_rxvalid);
   // wait(utmi_interface_rx.utmi_rxactive == 0);
    `uvm_info("HANDSHAKE","DEVICE ACK RECEIVED",UVM_LOW)

  endtask

  task handshake_tx();
    bit [7:0] pid_byte;
    pid_byte = {4'b0010, ~4'b0010};
    `uvm_info("HANDSHAKE",$sformatf("DATA_HANDSHAKE_PID=%h",pid_byte),UVM_LOW)
  //  @(posedge utmi_interface_tx.cb_utmi_host_controller_driver);
	          @(posedge utmi_interface_tx.utmi_clk);
    wait(utmi_interface_tx.utmi_txready);
    utmi_interface_tx.utmi_txdata  <= pid_byte;
    utmi_interface_tx.utmi_txvalid <= 1;
   // @(posedge utmi_interface_tx.cb_utmi_host_controller_driver);
	          @(posedge utmi_interface_tx.utmi_clk);
    utmi_interface_tx.utmi_txvalid <= 0;
    `uvm_info("HANDSHAKE","HOST SENT ACK",UVM_LOW)
  endtask

 // task wait_tx_done();
 //   wait(utmi_interface_tx.utmi_txready);
 // endtask

  task wait_rx_data();
    wait(utmi_interface_rx.utmi_rxvalid);
  endtask

  task calc_crc5(USB2p0_sequence_item usb_seq_item);
    bit [10:0] token_bits;
    bit [4:0] crc;
    bit din;
    int i;

    token_bits = {usb_seq_item.endp, usb_seq_item.addr};
    crc = 5'b11111;
    for (i=10;i>=0;i--) begin
      din = token_bits[i] ^ crc[4];
      crc = {crc[3:0],1'b0};
      if (din) crc ^= 5'b00101;
    end
    usb_seq_item.crc5 = ~crc;
  endtask

  task calc_crc16(USB2p0_sequence_item usb_seq_item);
    bit [15:0] crc;
    bit din;
    bit [7:0] data[$];
    int i,j;
    crc = 16'hFFFF;
    data.push_back(usb_seq_item.bmRequestType);
    data.push_back(usb_seq_item.bRequest);
    data.push_back(usb_seq_item.wValue[7:0]);
    data.push_back(usb_seq_item.wValue[15:8]);
    data.push_back(usb_seq_item.wIndex[7:0]);
    data.push_back(usb_seq_item.wIndex[15:8]);
    data.push_back(usb_seq_item.wLength[7:0]);
    data.push_back(usb_seq_item.wLength[15:8]);
    foreach(data[i]) begin
      for(j=0;j<8;j++) begin
        din = crc[15]^data[i][j];
        crc = {crc[14:0],1'b0};
        if(din) crc ^= 16'h8005;
      end
    end
    usb_seq_item.crc16 = ~crc;
  endtask

  
  
endclass*/
