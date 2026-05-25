class USB2p0_PHY_driver extends uvm_driver #(USB2p0_sequence_item);
  
  `uvm_component_utils(USB2p0_PHY_driver)
  
   virtual USB2p0_host_utmi_interface         host_utmi_interface_tx;
   virtual USB2p0_host_utmi_interface         host_utmi_interface_rx;
   virtual USB2p0_device_utmi_interface      device_utmi_interface_rx;
   virtual USB2p0_device_utmi_interface      device_utmi_interface_tx;
   virtual USB2p0_PHY_interface                           usb_phy_interface;

   int tx_data_count=0;   
   USB2p0_sequence_item                usb_seq_item;
   USB2p0_phy_sequence_item            usb_phy_seq_item;
   
   uvm_event                           decoder_event;
   uvm_event                           synchronization_event;
   semaphore decoder_sem, device_decoder_sem;
   string test_name;

   speed_state usb_speed;

   bit hs_eop_enable = 0;
   static int tx_stuff_count = 0; 
   int               count;
   bit  	     decoded;
   bit  	     transition;
   bit  	     dp_prev;
   bit        [15:0] sync_low;
   bit               eop_latched;
   int               collect_sync;
   bit               rx_reset;
   bit               sync_detected;
   static bit [15:0] serial_reg;
   static bit [7:0]  token_pkt_pid;
   static bit [7:0]  token_pkt_pid_addr;
   static bit [15:0]  pid_addr;
   static bit [6:0]  token_pkt_addr;
   static bit [3:0]  token_pkt_endpoint;
   static bit [4:0]  token_pkt_crc;
   int        	     eop_detected;
   static bit [7:0]  dp_shift;
   bit        [7:0]  data_queue[$];
   bit               vbus;
   bit       [DATA_WIDTH-1:0]  rx_data_queue[$];
   bit       [DATA_WIDTH-1:0]  utmi_data_queue[$];
   bit               word_if;
   bit       [15:0]  rx_shift_reg;
   int               rx_bit_count =1;
   bit               serial_bit;
   int               count_trigger; 
   int               width;  
   bit       [7:0]   sync_8bit;
   bit       [7:0]   sipo_data;
   bit       [7:0]   sipo_data_low;
   bit       [7:0]   sipo_data_high;
   bit       [31:0]  pop_data[$];
   bit 	             strip_eop=0;
   int               send_task_count=0 ;
   bit        [7:0]  pid_temp_high_data,pid_temp_low_setup,pid_temp_low_data,pid_temp_handshake;
   bit        [15:0] pid_temp_high_setup; 
   typedef enum bit [1:0] {
                           ACK_FROM_NONE   = 2'b00,
                           ACK_FROM_HOST   = 2'b01,
                           ACK_FROM_DEVICE = 2'b10
                           }ack_source_e;

                           ack_source_e  ack_source;
  
   typedef enum bit [3:0]{
			    RESET        = 0,
			    RX_WAIT      = 1,
			    STRIP_SYNC   = 2,
			    RX_DATA      = 3,
			    RX_DATA_WAIT = 4,
			    STRIP_EOP    = 5,
			    RX_ERROR     = 6,
			    ABORT1       = 7,
			    ABORT2       = 8,
			    TERMINATE    = 9
                         } rx_state_m;

 			  rx_state_m rx_present_state ; 

   function new(string name="USB2p0_PHY_driver", uvm_component parent);
   	super.new(name,parent);
    	`uvm_info("PHY_DRIVER", $sformatf("ENTERED_INTO_PHY_DRIVER NEW_FUNCTION "),UVM_LOW) 
   endfunction
  
   function void build_phase(uvm_phase phase);
    	`uvm_info("PHY_DRIVER", $sformatf("ENTERED_INTO_PHY_DRIVER BUILD_PHASE "),UVM_LOW) 
    	super.build_phase(phase);
        decoder_event = new();
	decoder_sem = new(0);
	device_decoder_sem = new(0);
        synchronization_event=uvm_event_pool::get_global_pool().get("SYNCHRONIZATION_EVENT");

        if(!uvm_config_db#(virtual USB2p0_host_utmi_interface)::get(this, "", "USB_HOST_UTMI_INTERFACE", host_utmi_interface_tx))
    	     `uvm_fatal("NOVIF", "USB_UTMI_INTERFACE not found")

        if (!uvm_config_db#(virtual USB2p0_host_utmi_interface)::get(this, "", "USB_HOST_UTMI_INTERFACE", host_utmi_interface_rx))
    	     `uvm_fatal("NO VIF", "UTMI_INTERFACE not found")

        if(!uvm_config_db#(virtual USB2p0_device_utmi_interface)::get(this, "", "USB_DEVICE_UTMI_INTERFACE", device_utmi_interface_tx))
    	     `uvm_fatal("NOVIF", "USB_UTMI_INTERFACE not found")

        if(!uvm_config_db#(virtual USB2p0_device_utmi_interface)::get(this, "", "USB_DEVICE_UTMI_INTERFACE", device_utmi_interface_rx))
    	     `uvm_fatal("NOVIF", "USB_UTMI_INTERFACE not found")

        if(!uvm_config_db#(virtual USB2p0_PHY_interface)::get(this, "", "USB_PHY_INTERFACE", usb_phy_interface))
      	     `uvm_fatal("NOVIF", "USB_PHY_INTERFACE not found")
              usb_seq_item = USB2p0_sequence_item::type_id::create("usb_seq_item");

        if(!uvm_config_db#(speed_state)::get(this,"","USB_SPEED",usb_speed))
            `uvm_fatal("NO USB SPEED","USB_SPEED IS NOT FOUND")
            rx_present_state = RESET ; 
    endfunction
      
  task run_phase(uvm_phase phase);
    bit rx_tx_threads_started;
    `uvm_info("PHY_DRIVER",$sformatf("ENTERED_INTO_PHY_DRIVER_RUN_PHASE "),UVM_LOW)
    @(host_utmi_interface_tx.cb_utmi_host_controller_driver);

  if (!rx_tx_threads_started) begin
    rx_tx_threads_started = 1;

    fork
      begin : host_tx_listener
        forever begin
          `uvm_info("PHY_DRIVER", $sformatf("COLLECTING_HOST_TX_DATA"), UVM_LOW)
            receiving_hc_tx_data(host_utmi_interface_tx);
           // receiving_dc_tx_data(device_utmi_interface_tx);
         end
      end

      begin : device_tx_listener
        forever begin
          `uvm_info("PHY_DRIVER", $sformatf("COLLECTING_DEVICE_TX_DATA"), UVM_LOW)
            receiving_dc_tx_data(device_utmi_interface_tx);
           // receiving_hc_tx_data(host_utmi_interface_tx);
           // receiving_dc_tx_data(device_utmi_interface_tx);
         end
      end

      begin : host_rx_decoder
         forever begin
           sending_hc_rx_data();
         end
      end

     // begin : device_tx_listener
     //   sending_dc_rx_data();
     // end

      //begin : device_rx_decoder
      //  sending_dc_rx_data();
      //end
    join_none
  end

  forever begin
    seq_item_port.get_next_item(req);

    `uvm_info("PHY_DRIVER",
              $sformatf("GET_NEXT_ITEM "),
              UVM_LOW)

    repeat (8)
      @(posedge usb_phy_interface.cb_phy_driver);

    usb_phy_interface.Vbus <= host_utmi_interface_tx.utmiotg_vbusvalid;

    if (host_utmi_interface_tx.utmiotg_vbusvalid == 1) begin
      `uvm_info("PHY_DRIVER",
                $sformatf("PHY_DRIVER: PHY_Vbus=%b", usb_phy_interface.Vbus),
                UVM_LOW)

      @(posedge usb_phy_interface.cb_phy_driver);
      detect_device_pullup_from_device();
      detect_line_state();
    end
    seq_item_port.item_done();
  end
endtask

//////////////////////////DETECT DEVICE PULL UP FROM DEVICE TO PHY//////////////////

task detect_device_pullup_from_device();
     `uvm_info("PHY_DR","ENTERED INTO DETECT DEVICE PULLUP FROM DEVICE TASK",UVM_LOW)
     //#1;
     wait ((device_utmi_interface_tx.utmiotg_dppulldown !== 1'bx) && (device_utmi_interface_tx.utmiotg_dmpulldown !== 1'bx));
     `uvm_info("PHY_DRIVER",$sformatf("phy_driver_DP=%0b,dm =%0b",device_utmi_interface_tx.utmiotg_dppulldown,device_utmi_interface_tx.utmiotg_dmpulldown),UVM_LOW)
      
      if (device_utmi_interface_tx.utmiotg_dppulldown && !device_utmi_interface_tx.utmiotg_dmpulldown) begin
    	usb_phy_interface.Dp<=1;
    	usb_phy_interface.Dm<=0;
   	`uvm_info("PHY_DRIVER","HS OR FS SPEED IS DETECTING",UVM_LOW)
      end else
      if(!device_utmi_interface_tx.utmiotg_dppulldown && device_utmi_interface_tx.utmiotg_dmpulldown) begin
   	usb_phy_interface.Dp<=0;
        usb_phy_interface.Dm<=1;
   	`uvm_info("PHY_DRIVER","LS SPEED IS DETECTING",UVM_LOW)
      end
endtask



  
task detect_line_state();
      `uvm_info("PHY_DR","ENTERED_INTO_DETECT_LINE_STATE ",UVM_LOW) 

       @(posedge usb_phy_interface.cb_phy_driver)
       `uvm_info("PHY_DRIVER",$sformatf("dp=%b  dm=%b",usb_phy_interface.Dp,usb_phy_interface.Dm),UVM_LOW)

       case({usb_phy_interface.Dp,usb_phy_interface.Dm})
    	2'b10: host_utmi_interface_rx.utmi_linestate <= 2'b10; //J
    	2'b01: host_utmi_interface_rx.utmi_linestate <= 2'b01; //K
    	2'b00: host_utmi_interface_rx.utmi_linestate <= 2'b00; //SE0
       endcase
               host_utmi_interface_rx.utmisrp_bvalid <=1;
       `uvm_info("PHY_DRIVER",$sformatf("sent_Line_state_value=%0b",host_utmi_interface_rx.utmi_linestate),UVM_LOW) 
endtask

task receiving_dc_tx_data(virtual USB2p0_device_utmi_interface  device_utmi_interface_tx);
     //bit [15:0] tx_fifo[$];
	  bit [DATA_WIDTH-1:0] tx_fifo[$];
	  bit [1:0]  opmode;
	  bit        suspend_n;
	  bit        term_select;
	  bit  [1:0] xcvr_select;
	  bit        fsls_low_power;
	  bit        fsls_serial_mode;
	  bit        otg_dppulldown;
	  bit        otg_dmpulldown;
	  bit        tx_valid;
	  bit        tx_validh;
	  bit        pid_enable=1;
	  bit        tx_ready;
	  bit [7:0]  temp_8_bit;
	  bit [15:0] temp_16_bit;
     
          `uvm_info("PHY_DRV","ENTERED_INTO_RECEIVING_DC_TX_DATA",UVM_LOW)
           //tx_fifo.delete();
          wait(device_utmi_interface_tx.utmi_txvalid || device_utmi_interface_tx.utmi_txvalidh);    
            @(negedge device_utmi_interface_tx.cb_utmi_device_controller_monitor);
            `uvm_info("PHY_DRV",$sformatf("TXVALID_VALIDH_IS_HIGH  valid=%0d validh=%0d opmode=%0d",device_utmi_interface_tx.utmi_txvalid,device_utmi_interface_tx.utmi_txvalidh,device_utmi_interface_tx.utmi_opmode),UVM_LOW)
            opmode = device_utmi_interface_tx.utmi_opmode;
            if(opmode == 2'b00)begin
              `uvm_info("PHY_DRV","VALID_OPMODE_00",UVM_LOW)
               while ((device_utmi_interface_tx.utmi_txvalid || device_utmi_interface_tx.utmi_txvalidh)) begin
                device_utmi_interface_tx.utmi_txready <=1;
                tx_valid         =  device_utmi_interface_tx.utmi_txvalid;
                tx_validh        =  device_utmi_interface_tx.utmi_txvalidh;
                word_if          = device_utmi_interface_tx.utmi_word_if;
                suspend_n        = device_utmi_interface_tx.utmi_suspend_n;
                term_select      = device_utmi_interface_tx.utmi_termselect;   
                xcvr_select      = device_utmi_interface_tx.utmi_xcvrselect;
                fsls_low_power   = device_utmi_interface_tx.utmi_fsls_low_power;
                fsls_serial_mode = device_utmi_interface_tx.utmi_fslsserialmode;
                otg_dppulldown   = device_utmi_interface_tx.utmiotg_dppulldown;
                otg_dmpulldown   = device_utmi_interface_tx.utmiotg_dmpulldown;
                tx_ready         = device_utmi_interface_tx.utmi_txready;   //collecting ready signal from interface for tx state machine
                `uvm_info("PHY_DRV"," PHY_COLLECTED_DEVICE_UTMI_TX_SIGNALS",UVM_LOW)
                if(word_if && tx_valid && tx_validh)begin
                   temp_16_bit = device_utmi_interface_tx.utmi_txdata;
                        `uvm_info(get_full_name(), $sformatf("RECEIVNG_16BIT_FROM_UTMI_TX - %b",temp_16_bit),UVM_LOW)  
                       if(temp_16_bit[7:0] == 8'h2d || temp_16_bit[7:0] == 8'hb4 || temp_16_bit[7:0] == 8'he1)begin
                          ack_source = ACK_FROM_DEVICE;
                          `uvm_info("PHY_DRV",$sformatf("ACK_SOURCE_FROM_DEVICE=%0d",ack_source),UVM_LOW)
                       end
                   tx_fifo.push_back(temp_16_bit);
                  `uvm_info(get_full_name(), $sformatf("RECEIVNG_16BIT_FROM_UTMI_TX_SIE_PI - %p",tx_fifo),UVM_LOW)  
                  `uvm_info(get_full_name(),$sformatf("RECEIVING_SIE_PI:word_if=%d,fslsserial_mode=%d,valid=%d,validh=%d,opmode=%d",word_if,fsls_serial_mode,tx_valid,tx_validh,opmode),UVM_LOW)
                end
                else if(!word_if && tx_valid )begin
                      tx_data_count++;
                      `uvm_info("PHY_DRV"," COLLECTING_DEVICE_UTMI_TX_DATA_8_bit",UVM_LOW)
                      //temp_8_bit = device_utmi_interface_tx.utmi_txdata[7:0];
                      temp_8_bit = device_utmi_interface_tx.utmi_txdata;
                       if(temp_8_bit == 8'h2d || temp_8_bit == 8'hb4 || temp_8_bit == 8'he1)begin
                          ack_source = ACK_FROM_DEVICE;
                          `uvm_info("PHY_DRV",$sformatf("ACK_SOURCE_FROM_DEVICE=%0d",ack_source),UVM_LOW)
                       end
                      `uvm_info(get_full_name(), $sformatf("RECEIVNG: SIE_PI_TX_FIFO_BEFORE_PUSH - %p,SIZE=%d device_utmi_interface_tx.utmi_txdata=%0d tx_data_count=%0d temp_8_bit=%0d",tx_fifo, tx_fifo.size(),device_utmi_interface_tx.utmi_txdata,tx_data_count,temp_8_bit),UVM_LOW)  
                      tx_fifo.push_back(temp_8_bit);
                      `uvm_info(get_full_name(), $sformatf("RECEIVNG: SIE_PI_TX_FIFO_AFTER_PUSH - %p,SIZE=%d",tx_fifo, tx_fifo.size()),UVM_LOW)  
                   // if (temp_8_bit == 8'h2D || temp_8_bit == 8'h5A ||  temp_8_bit == 8'h1E)begin
                   //    `uvm_info("PHY_DRV", $sformatf("HANDSHAKE PID DETECTED = %0h", temp_8_bit),UVM_LOW)
                   //   break;
                   // end
                 end //else if begin_end
                 `uvm_info(get_full_name(), $sformatf("RECEIVNG: SIE_PI_TX_FIFO - %d",tx_fifo.size()),UVM_LOW)  
                 @(negedge device_utmi_interface_tx.cb_utmi_device_controller_monitor);
               end //while begin_end
            end//opmode
            `uvm_info("PHY_DRV"," PHY_COLLECTED_DEVICE_UTMI_TX_DATA",UVM_LOW)

           tx_state_machine(tx_valid,tx_ready,pid_enable,tx_validh,word_if,tx_fifo); 
endtask
    
  
task receiving_hc_tx_data(virtual USB2p0_host_utmi_interface  host_utmi_interface_tx);
	  //bit [15:0] tx_fifo[$];
	  bit [DATA_WIDTH-1:0] tx_fifo[$];
	  bit [1:0]  opmode;
	  bit        suspend_n;
	  bit        term_select;
	  bit  [1:0] xcvr_select;
	  bit        fsls_low_power;
	  bit        fsls_serial_mode;
	  bit        otg_dppulldown;
	  bit        otg_dmpulldown;
	  bit        tx_valid;
	  bit        tx_validh;
	  bit        pid_enable=1;
	  bit        tx_ready;
	  bit [7:0]  temp_8_bit;
	  bit [15:0] temp_16_bit;
     
          `uvm_info("PHY_DRV","ENTERED_INTO_RECEIVING_HC_TX_DATA",UVM_LOW)
           //tx_fifo.delete();
          wait(host_utmi_interface_tx.utmi_txvalid || host_utmi_interface_tx.utmi_txvalidh);    
            @(negedge host_utmi_interface_tx.cb_utmi_host_controller_monitor);
            `uvm_info("PHY_DRV",$sformatf("TXVALID_VALIDH_IS_HIGH  valid=%0d validh=%0d opmode=%0d",host_utmi_interface_tx.utmi_txvalid,host_utmi_interface_tx.utmi_txvalidh,host_utmi_interface_tx.utmi_opmode),UVM_LOW)
            opmode = host_utmi_interface_tx.utmi_opmode;
            if(opmode == 2'b00)begin
              `uvm_info("PHY_DRV","VALID_OPMODE_00",UVM_LOW)
               while ((host_utmi_interface_tx.utmi_txvalid || host_utmi_interface_tx.utmi_txvalidh)) begin
                host_utmi_interface_tx.utmi_txready <=1;
                tx_valid         =  host_utmi_interface_tx.utmi_txvalid;
                tx_validh        =  host_utmi_interface_tx.utmi_txvalidh;
                word_if          = host_utmi_interface_tx.utmi_word_if;
                suspend_n        = host_utmi_interface_tx.utmi_suspend_n;
                term_select      = host_utmi_interface_tx.utmi_termselect;   
                xcvr_select      = host_utmi_interface_tx.utmi_xcvrselect;
                fsls_low_power   = host_utmi_interface_tx.utmi_fsls_low_power;
                fsls_serial_mode = host_utmi_interface_tx.utmi_fslsserialmode;
                otg_dppulldown   = host_utmi_interface_tx.utmiotg_dppulldown;
                otg_dmpulldown   = host_utmi_interface_tx.utmiotg_dmpulldown;
                tx_ready         = host_utmi_interface_tx.utmi_txready;   //collecting ready signal from interface for tx state machine
                `uvm_info("PHY_DRV"," PHY_COLLECTED_HOST_UTMI_TX_SIGNALS",UVM_LOW)
                if(word_if && tx_valid && tx_validh)begin
                   temp_16_bit = host_utmi_interface_tx.utmi_txdata;
                       if(temp_16_bit[7:0] == 8'h2d)begin
                          ack_source = ACK_FROM_HOST;
                          `uvm_info("PHY_DRV",$sformatf("ACK_SOURCE_FROM_HOST=%0d",ack_source),UVM_LOW)
                       end
                   tx_fifo.push_back(temp_16_bit);
                  `uvm_info(get_full_name(), $sformatf("RECEIVNG_16BIT_FROM_UTMI_TX_HOST: SIE_PI - %p",tx_fifo),UVM_LOW)  
                  `uvm_info(get_full_name(),$sformatf("RECEIVING_SIE_PI:word_if=%d,fslsserial_mode=%d,valid=%d,validh=%d,opmode=%d",word_if,fsls_serial_mode,tx_valid,tx_validh,opmode),UVM_LOW)
                end
                else if(!word_if && tx_valid )begin
                      tx_data_count++;
                      `uvm_info("PHY_DRV"," COLLECTING_UTMI_TX_DATA_8_bit",UVM_LOW)
                      //temp_8_bit = host_utmi_interface_tx.utmi_txdata[7:0];
                      temp_8_bit = host_utmi_interface_tx.utmi_txdata;
                       if(temp_8_bit == 8'h2d)begin
                          ack_source = ACK_FROM_HOST;
                          `uvm_info("PHY_DRV",$sformatf("ACK_SOURCE_FROM_HOST=%0d",ack_source),UVM_LOW)
                       end
                      `uvm_info(get_full_name(), $sformatf("RECEIVNG: SIE_PI_TX_FIFO_BEFORE_PUSH - %p,SIZE=%d host_utmi_interface_tx.utmi_txdata=%0d tx_data_count=%0d temp_8_bit=%0d",tx_fifo, tx_fifo.size(),host_utmi_interface_tx.utmi_txdata,tx_data_count,temp_8_bit),UVM_LOW)  
                      tx_fifo.push_back(temp_8_bit);
                      `uvm_info(get_full_name(), $sformatf("RECEIVNG: SIE_PI_TX_FIFO_AFTER_PUSH - %p,SIZE=%d",tx_fifo, tx_fifo.size()),UVM_LOW)  
                   // if (temp_8_bit == 8'h2D || temp_8_bit == 8'h5A ||  temp_8_bit == 8'h1E)begin
                   //    `uvm_info("PHY_DRV", $sformatf("HANDSHAKE PID DETECTED = %0h", temp_8_bit),UVM_LOW)
                   //   break;
                   // end
                 end //else if begin_end
                 `uvm_info(get_full_name(), $sformatf("RECEIVNG: SIE_PI_TX_FIFO - %d",tx_fifo.size()),UVM_LOW)  
                 @(negedge host_utmi_interface_tx.cb_utmi_host_controller_monitor);
                 `uvm_info("PHY_DRV","WHILE_LOOP_EXIT_IN_PHY_DRIVER",UVM_LOW)
               end //while begin_end
            end//opmode
            `uvm_info("PHY_DRV"," PHY_COLLECTED_HOST_UTMI_TX_DATA",UVM_LOW)

           tx_state_machine(tx_valid,tx_ready,pid_enable,tx_validh,word_if,tx_fifo); 
endtask
  
task tx_state_machine(bit tx_sm_valid,tx_sm_ready,pid_flag,tx_sm_validh, tx_sm_word_if,bit [DATA_WIDTH-1:0]data_tx_sm[$]);

          typedef enum bit[2:0]{  RESET=1, 
                    		  TX_WAIT=2, 
                    		  SEND_SYNC=3,  
                    		  TX_DATA_LOAD=4, 
                   		  TX_DATA_WAIT=5, 
               		          SEND_EOP=6
        		        }tx_state_m;
 
  		                 tx_state_m     present_state, next_state;

	  logic         tx_sm_hold_reg_empty=1;
	  logic         tx_sm_hold_reg_full=1;
	  logic         tx_sm_eop;
	  bit           tx_sm_reset_local;
	  bit           eop_not_done=1;
	  //bit [15:0]    tx_fifo_out[$];
	  bit [DATA_WIDTH-1:0]    tx_fifo_out[$];
	  bit [DATA_WIDTH-1:0]    tx_fifo_out2[$];
	  //bit [15:0]    tx_fifo_out2[$];
	  bit [15:0]    temp_16bit_data;
	  bit [7:0]     temp_8bit_data;
	  bit [15:0]   tx_16bit_piso_data;
	  bit [7:0]    tx_8bit_piso_data;
	  int          tx_size;
	  bit [31:0] tx_32bit_piso_data;

	  tx_sm_reset_local =1'b1;
	    #10;
	  tx_sm_reset_local =1'b0;

          if(tx_sm_reset_local == 1'b1 && tx_sm_ready == 1)
             begin
                 `uvm_info(get_full_name(),"ENTER INTO RESET STATE",UVM_LOW)
                  next_state = RESET;
             end 
          else begin
             next_state = TX_WAIT;
             `uvm_info(get_full_name(),"ENTER INTO TX_WAIT STATE FROM  RESET STATE",UVM_LOW)
          end

          do begin
             present_state = next_state;  
             `uvm_info(get_full_name(),$sformatf("present_state=%s", present_state),UVM_LOW)
             case(present_state)
	        RESET:begin
                        if(tx_sm_reset_local == 0 && tx_sm_ready == 0)
		          begin
		             next_state = TX_WAIT;
		            `uvm_info(get_full_name(),"ENTER INTO TX_WAIT STATE FROM  RESET STATE",UVM_LOW)
		          end
		        else
		           next_state = RESET;
	              end
	        TX_WAIT:begin
		          if(tx_sm_valid)begin
		              tx_sm_ready = 1;
		              next_state = SEND_SYNC;
		              `uvm_info(get_full_name(),"ENTER INTO SEND_SYNC FROM TX_WAIT STATE",UVM_LOW)
		           end 
		           else begin
		              next_state = TX_WAIT; 
		             `uvm_info(get_full_name(),"REMAINS SAME IN TX_WAIT STATE",UVM_LOW)
		           end
	                end
	        SEND_SYNC:begin
                           `uvm_info(get_full_name(),"ENTER INTO SEND_SYNC STATE",UVM_LOW)
                            if(tx_sm_ready)begin
                              if(pid_flag)begin   
                                `uvm_info(get_full_name(),$sformatf("PID FLAG & READY :pid=%d, ready=%d",pid_flag,tx_sm_ready),UVM_LOW)
                                 next_state   = TX_DATA_LOAD;
                                `uvm_info(get_full_name(),"ENTER INTO SEND_SYNC STATE TO TX DATA LOAD STATE",UVM_LOW)
                               end
                            end
                            else
                              next_state   = SEND_SYNC; 
                         end
	        TX_DATA_LOAD:begin 
		            `uvm_info(get_full_name(),"ENTER INTO TX_DATA_LOAD STATE",UVM_LOW)
                            if(tx_sm_hold_reg_full) begin  
		              wait(tx_sm_ready ==1'b1)begin 
		                `uvm_info(get_full_name(),$sformatf("REG FULL & READY :reg_full=%d, ready=%d",tx_sm_hold_reg_full,tx_sm_ready),UVM_LOW)
		                 while(data_tx_sm.size() > 0)begin 
		                   if(tx_sm_valid && tx_sm_validh)begin 
			            // if(pid_temp_high_setup == 0) begin
			                pid_temp_high_setup = data_tx_sm.pop_front();
			                `uvm_info(get_full_name(),$sformatf("PID_VALUE******************************* FOR SETUP =%b",pid_temp_high_setup),UVM_LOW)

                                    if((pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_SETUP, ~USB2p0_sequence_item::PID_SETUP}) || (pid_temp_high_setup[7:0] ==                                    {USB2p0_sequence_item::PID_DATA1, ~USB2p0_sequence_item::PID_DATA1}) || (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_OUT, ~USB2p0_sequence_item::PID_OUT}) || (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_DATA0,~USB2p0_sequence_item::PID_DATA0}) || (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_IN, ~USB2p0_sequence_item::PID_IN}) ||  (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_ACK,~USB2p0_sequence_item::PID_ACK}) || (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_STALL,~USB2p0_sequence_item::PID_STALL})) begin 

			                   send_sync(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
			                   data_tx_sm.push_front(pid_temp_high_setup);

			                if(pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_SETUP, ~USB2p0_sequence_item::PID_SETUP})begin
			                   //send_sync(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
			                   //data_tx_sm.push_front(pid_temp_high_setup);
			                   for(int i=0; i<2; i++)begin 
                                         `uvm_info("DEBUG_TX_DATA_LOAD_WORD_IF_ONE",$sformatf("WORD_IF_ONE_after_PID_CHECK_data_tx_sm_size=%0d data_tx_sm=%0p", data_tx_sm.size(),data_tx_sm),UVM_LOW)
			                   //for(int i=data_tx_sm.size(); i<= data_tx_sm.size(); i--)begin
                                             // if(i ==0)break; 
			    		      temp_16bit_data = data_tx_sm.pop_front();
			     		      tx_fifo_out.push_back(temp_16bit_data);
			                      `uvm_info(get_full_name(),$sformatf("16_BIT_DATA tx_fifo_out =%p,valid=%d,validh=%d",tx_fifo_out,tx_sm_valid,tx_sm_validh),UVM_LOW)
			                      if (tx_fifo_out.size()>0)begin 
					         `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d",tx_fifo_out.size()),UVM_LOW) 
			                         for(int j = 0; j < tx_fifo_out.size(); j++ )begin
						   `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d",tx_fifo_out.size()),UVM_LOW) 
				                   if(tx_sm_valid && tx_sm_validh)begin 
				                      tx_16bit_piso_data = tx_fifo_out.pop_front();
				                      tx_size = 16;
				                      tx_piso(tx_16bit_piso_data,tx_size);
				 		   end
		      				 end
		    			      end
          				   end 
                                           eop_generate(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
            				end 
				    // end  //setup begin_end

                		     //pid_temp_high_data = data_tx_sm.pop_front();
                		     //`uvm_info(get_full_name(),$sformatf("PID_VALUE**************************************** FOR DATA =%b",pid_temp_high_data),UVM_LOW)
                 		     else if((pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_DATA0, ~USB2p0_sequence_item::PID_DATA0}) || (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_IN, ~USB2p0_sequence_item::PID_IN}) || (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_DATA1, ~USB2p0_sequence_item::PID_DATA1}) || (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_OUT, ~USB2p0_sequence_item::PID_OUT}))begin
                  		       //send_sync(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
                                       //data_tx_sm.push_front(pid_temp_high_data);
                   		       //for(int i=0; i<6; i++)begin
                                     `uvm_info("DEBUG_TX_DATA_LOAD_WORD_IF_ONE",$sformatf("WORD_IF_ONE_after_PID_CHECK_FOR_DATA0_data_tx_sm_size=%0d data_tx_sm=%0p", data_tx_sm.size(),data_tx_sm),UVM_LOW)
                   		       for(int i=data_tx_sm.size(); i<=data_tx_sm.size(); i--)begin
                                          if(i==0) break;
                   			 temp_16bit_data = data_tx_sm.pop_front();
                     			 tx_fifo_out2.push_back(temp_16bit_data);
                    			 `uvm_info(get_full_name(),$sformatf("16_BIT_DATA tx_fifo_out =%p,valid=%d,validh=%d",tx_fifo_out2,tx_sm_valid,tx_sm_validh),UVM_LOW)
                 			 if (tx_fifo_out2.size()>0)begin
                   			   for(int j = 0; j < tx_fifo_out2.size(); j++ )begin
                       			      if(tx_sm_valid && tx_sm_validh)begin
                           		        tx_16bit_piso_data = tx_fifo_out2.pop_front();
                          		        tx_size = 16;
                           		        tx_piso(tx_16bit_piso_data,tx_size);
                         		      end
              				 end
              			       end
           			     end
                                      eop_generate(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
                 		   end
                                     //eop_generate(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
                       //////////////////////////////////////////////////////////////////////////////////////////////////////
			            else if((pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_ACK, ~USB2p0_sequence_item::PID_ACK}) || (pid_temp_high_setup[7:0] == {USB2p0_sequence_item::PID_STALL, ~USB2p0_sequence_item::PID_STALL}))begin
			                   //send_sync(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
			                   //data_tx_sm.push_front(pid_temp_high_setup);
			                   //for(int i=0; i<2; i++)begin 
                                         //`uvm_info("DEBUG_TX_DATA_LOAD_WORD_IF_ONE",$sformatf("WORD_IF_ONE_after_PID_CHECK_data_tx_sm_size=%0d data_tx_sm=%0p", data_tx_sm.size(),data_tx_sm),UVM_LOW)
			                   //for(int i=data_tx_sm.size(); i<= data_tx_sm.size(); i--)begin
                                             // if(i ==0)break; 
			    		      temp_16bit_data = data_tx_sm.pop_front();
			     		      tx_fifo_out.push_back(temp_16bit_data);
			                      `uvm_info(get_full_name(),$sformatf("16_BIT_DATA tx_fifo_out =%p,valid=%d,validh=%d",tx_fifo_out,tx_sm_valid,tx_sm_validh),UVM_LOW)
			                      if (tx_fifo_out.size()>0)begin 
					         `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d",tx_fifo_out.size()),UVM_LOW) 
			                         for(int j = 0; j < tx_fifo_out.size(); j++ )begin
						   `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d",tx_fifo_out.size()),UVM_LOW) 
				                   if(tx_sm_valid && tx_sm_validh)begin 
				                      tx_16bit_piso_data = tx_fifo_out.pop_front();
				                      tx_size = 16;
				                      tx_piso(tx_16bit_piso_data,tx_size);
				 		   end
		      				 end
		    			      end
          				   //end 
                                           eop_generate(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
            				end 


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                    end
			          end //tx_sm_validh =1 begin_end
                                  else if( tx_sm_valid && !tx_sm_validh) begin
              			    pid_temp_low_setup = data_tx_sm.pop_front();
               			    `uvm_info(get_full_name(),$sformatf("PID_VALUE_8bit******************************* FOR SETUP =%b",pid_temp_low_setup),UVM_LOW)
				    //ACK_PID_CHECK
                                    if((pid_temp_low_setup == {USB2p0_sequence_item::PID_ACK,~USB2p0_sequence_item::PID_ACK}) || (pid_temp_low_setup == {USB2p0_sequence_item::PID_STALL,~USB2p0_sequence_item::PID_STALL}))begin
                                       `uvm_info(get_full_name(),$sformatf("PID_VALUE******************************* FOR SETUP =%b4bit=%b,inv4bit=%b",pid_temp_low_setup,USB2p0_sequence_item::PID_ACK,~USB2p0_sequence_item::PID_ACK),UVM_LOW) 
                                       send_sync(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
                  		       data_tx_sm.push_front(pid_temp_low_setup);
                                       // for(int i=0; i<1; i++)begin
                   		       temp_8bit_data  = data_tx_sm.pop_front();
                    		       tx_fifo_out.push_back(temp_8bit_data);
                  		       `uvm_info(get_full_name(),$sformatf("8_BIT_DATA tx_fifo_out =%p,valid=%d,validh=%d",tx_fifo_out,tx_sm_valid,tx_sm_validh),UVM_LOW)
                  		       if(tx_fifo_out.size()>0)begin
				          `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d",tx_fifo_out.size()),UVM_LOW) 
                     			  for(int j = 0; j < tx_fifo_out.size(); j++ )begin
					    `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d",tx_fifo_out.size()),UVM_LOW) 
                        		    if(tx_sm_valid && !tx_sm_validh)begin
                           		      tx_8bit_piso_data = tx_fifo_out.pop_front();
                           		      tx_size = 8;
                          		      tx_piso(tx_8bit_piso_data,tx_size);
                         		    end
                     			  end
                 		       end
                 		       //end
                  		       eop_generate(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
                                    end
				    // SETUP_PID_CHECK || DATA_PID_CHECK
                                    if((pid_temp_low_setup == {USB2p0_sequence_item::PID_SETUP, ~USB2p0_sequence_item::PID_SETUP}) || (pid_temp_low_setup ==                                    {USB2p0_sequence_item::PID_DATA1, ~USB2p0_sequence_item::PID_DATA1}) || (pid_temp_low_setup == {USB2p0_sequence_item::PID_OUT, ~USB2p0_sequence_item::PID_OUT})) begin
                                      // `uvm_info(get_full_name(),$sformatf("data_tx_sm =%0p data_tx_sm.size()=%0d",data_tx_sm, data_tx_sm.size()),UVM_LOW)
                                       send_sync(tx_sm_word_if, tx_sm_valid, tx_sm_validh);
                                       data_tx_sm.push_front(pid_temp_low_setup);
                                       `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("data_tx_sm_size=%0d data_tx_sm=%0p", data_tx_sm.size(),data_tx_sm),UVM_LOW)
                                       if(pid_temp_low_setup == {USB2p0_sequence_item::PID_DATA1, ~USB2p0_sequence_item::PID_DATA1}) begin
                                         //for(int i = 0; i < 3; i++) begin
                                         `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("after_PID_CHECK_data_tx_sm_size=%0d data_tx_sm=%0p", data_tx_sm.size(),data_tx_sm),UVM_LOW)
                                         //for(int i = 0; i <= data_tx_sm.size(); i++) begin
                                         for(int i = data_tx_sm.size(); i <= data_tx_sm.size(); i--) begin
                                           if(i==0) break;
                                           temp_8bit_data = data_tx_sm.pop_front();
                                           tx_fifo_out.push_back(temp_8bit_data);
                                           `uvm_info(get_full_name(), $sformatf("8_BIT_DATA tx_fifo_out =%p,valid=%0d,validh=%0d tem_8bit_data=%0d data_tx_sm_size=%0d",tx_fifo_out, tx_sm_valid, tx_sm_validh,temp_8bit_data,data_tx_sm.size()), UVM_LOW)
                                           if(tx_fifo_out.size() > 0) begin
                                             `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d", tx_fifo_out.size()),UVM_LOW)
                                              for(int j = 0; j < tx_fifo_out.size(); j++) begin
                                                 `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d", tx_fifo_out.size()),UVM_LOW)
                                                  if(tx_sm_valid && !tx_sm_validh) begin
                                                    tx_8bit_piso_data = tx_fifo_out.pop_front();
                                                    tx_size = 8;
                                                    tx_piso(tx_8bit_piso_data, tx_size);
                                                  end
                                              end
                                           end
                                         end
				       end //pid_low_setup begin_end
                                 /////////////////////////////////////////////////////////
                                  // else if(pid_temp_low_setup == {USB2p0_sequence_item::PID_DATA1, ~USB2p0_sequence_item::PID_DATA1}) begin
                                  //       for(int i = 0; i < 2; i++) begin
                                  //         temp_8bit_data = data_tx_sm.pop_front();
                                  //         tx_fifo_out.push_back(temp_8bit_data);
                                  //         `uvm_info(get_full_name(), $sformatf("8_BIT_DATA tx_fifo_out =%p,valid=%0d,validh=%0d",tx_fifo_out, tx_sm_valid, tx_sm_validh), UVM_LOW)
                                  //         if(tx_fifo_out.size() > 0) begin
                                  //           `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d", tx_fifo_out.size()),UVM_LOW)
                                  //            for(int j = 0; j < tx_fifo_out.size(); j++) begin
                                  //               `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d", tx_fifo_out.size()),UVM_LOW)
                                  //                if(tx_sm_valid && !tx_sm_validh) begin
                                  //                  tx_8bit_piso_data = tx_fifo_out.pop_front();
                                  //                  tx_size = 8;
                                  //                  tx_piso(tx_8bit_piso_data, tx_size);
                                  //                end
                                  //            end
                                  //         end
                                  //       end
				  //     end //pid_low_setup begin_end
                                    
                                    
                                 /////////////////////////////////////////////////////
                                     else if(pid_temp_low_setup == {USB2p0_sequence_item::PID_OUT, ~USB2p0_sequence_item::PID_OUT}) begin
                                         //for(int i = 0; i < 7; i++) begin
                                         for(int i = data_tx_sm.size(); i <= data_tx_sm.size(); i--) begin
                                           if(i==0) break;
                                           temp_8bit_data = data_tx_sm.pop_front();
                                           tx_fifo_out.push_back(temp_8bit_data);
                                           `uvm_info(get_full_name(), $sformatf("8_BIT_DATA tx_fifo_out =%p,valid=%0d,validh=%0d",tx_fifo_out, tx_sm_valid, tx_sm_validh), UVM_LOW)
                                           if(tx_fifo_out.size() > 0) begin
                                             `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d", tx_fifo_out.size()),UVM_LOW)
                                              for(int j = 0; j < tx_fifo_out.size(); j++) begin
                                                 `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d", tx_fifo_out.size()),UVM_LOW)
                                                  if(tx_sm_valid && !tx_sm_validh) begin
                                                    tx_8bit_piso_data = tx_fifo_out.pop_front();
                                                    tx_size = 8;
                                                    tx_piso(tx_8bit_piso_data, tx_size);
                                                  end
                                              end
                                           end
                                         end
				       end //pid_low_setup begin_end




                                //////////////////////////////////////////////////////////
                                       else if(pid_temp_low_setup == {USB2p0_sequence_item::PID_SETUP, ~USB2p0_sequence_item::PID_SETUP}) begin
                                          for(int i = 0; i < 4; i++) begin
                                             temp_8bit_data = data_tx_sm.pop_front();
                                             tx_fifo_out.push_back(temp_8bit_data);
                                             `uvm_info(get_full_name(),
                                             $sformatf("8_BIT_DATA tx_fifo_out =%p,valid=%0d,validh=%0d",tx_fifo_out, tx_sm_valid, tx_sm_validh),UVM_LOW)
                                             if(tx_fifo_out.size() > 0) begin
                                                `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d", tx_fifo_out.size()), UVM_LOW)
                                                for(int j = 0; j < tx_fifo_out.size(); j++) begin
                                                  `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d", tx_fifo_out.size()),UVM_LOW)
                                                  if(tx_sm_valid && !tx_sm_validh) begin
                                                     tx_8bit_piso_data = tx_fifo_out.pop_front();
                                                     tx_size = 8;
                                                     tx_piso(tx_8bit_piso_data, tx_size);
                                                  end
                                                end
                                             end
                                          end
                                       end
                                       eop_generate(tx_sm_word_if, tx_sm_valid, tx_sm_validh);
                                    end
              			    else if(pid_temp_low_setup == {USB2p0_sequence_item::PID_IN, ~USB2p0_sequence_item::PID_IN})begin
                		       send_sync(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
                  		       data_tx_sm.push_front(pid_temp_low_setup);
                 		       //for(int i=0; i<4; i++)begin
                 		       for(int i=data_tx_sm.size(); i<=data_tx_sm.size(); i--)begin
                                           if(i==0) break;
                                          temp_8bit_data  = data_tx_sm.pop_front();
                    			  tx_fifo_out.push_back(temp_8bit_data);
                  			  `uvm_info(get_full_name(),$sformatf("8_BIT_DATA tx_fifo_out =%p,valid=%d,validh=%d",tx_fifo_out,tx_sm_valid,tx_sm_validh),UVM_LOW)
                  			   if(tx_fifo_out.size()>0)begin
                                             `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d",tx_fifo_out.size()),UVM_LOW)
                     			      for(int j = 0; j < tx_fifo_out.size(); j++ )begin
					        `uvm_info("DEBUG_TX_DATA_LOAD",$sformatf("tx_fifo_size=%0d",tx_fifo_out.size()),UVM_LOW)
                        			if(tx_sm_valid && !tx_sm_validh)begin
                           			   tx_8bit_piso_data = tx_fifo_out.pop_front();
                           			   tx_size = 8;
                          			   tx_piso(tx_8bit_piso_data,tx_size);
                         			end
                     			      end
                 			   end
                 		       end
                  		       eop_generate(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
             			    end
                	            if(data_tx_sm.size() > 0) begin
                		       pid_temp_low_data = data_tx_sm.pop_front();
                		       `uvm_info(get_full_name(),$sformatf("PID_VALUE**************************************** FOR DATA =%b",pid_temp_low_data),UVM_LOW)
               			       if(pid_temp_low_data == {USB2p0_sequence_item::PID_DATA0, ~USB2p0_sequence_item::PID_DATA0})begin
                  		          send_sync(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
                  			  data_tx_sm.push_front(pid_temp_low_data);
                   			  for(int i=0; i<11; i++)begin
                    			    temp_8bit_data  = data_tx_sm.pop_front();
                    			    tx_fifo_out2.push_back(temp_8bit_data);
                  			    `uvm_info(get_full_name(),$sformatf("8_BIT_DATA tx_fifo_out =%p,valid=%d,validh=%d",tx_fifo_out2,tx_sm_valid,tx_sm_validh),UVM_LOW)
              				    if (tx_fifo_out2.size()>0)begin
                   				for(int j = 0; j < tx_fifo_out2.size(); j++ )begin
                        			   if(tx_sm_valid && !tx_sm_validh)begin
  					              tx_8bit_piso_data = tx_fifo_out2.pop_front();
 					   	      tx_size = 8;
					              tx_piso(tx_8bit_piso_data,tx_size);
					           end
					        end
					    end
					  end
					  eop_generate(tx_sm_word_if,tx_sm_valid,tx_sm_validh);
				       end
                                    end
		                  end
                                 end//while
             		         tx_sm_ready =0;
              			 tx_sm_valid =0;
                                 next_state = SEND_EOP;
                                 `uvm_info(get_full_name(),"ENTER INTO SEND_EOP STATE FROM TX_DATA_LOAD STATE",UVM_LOW)
                               end
                            end
                            else if(tx_sm_hold_reg_full)begin
                 		`uvm_info(get_full_name(),$sformatf("VALID =%d",tx_sm_valid),UVM_LOW)
                  		 next_state = TX_DATA_WAIT;
                 		`uvm_info(get_full_name(),"ENTER INTO SEND_EOP FROM TX_DATA_LOAD STATE",UVM_LOW)
         		    end
         		    else if(tx_sm_hold_reg_empty)
                                 next_state = TX_DATA_LOAD;   

       		         end
	      TX_DATA_WAIT:begin
	  	             if(tx_sm_hold_reg_empty)begin
		                next_state = TX_DATA_LOAD;
		                `uvm_info(get_full_name(),$sformatf("REG EMPTY =%d",tx_sm_hold_reg_empty),UVM_LOW)
		                `uvm_info(get_full_name(),"ENTER INTO TX_DATA_LOAD STATE FROM TX_DATA_WAIT STATE",UVM_LOW)
		             end
	  	             else if(tx_sm_hold_reg_full)
		                   next_state = TX_DATA_WAIT;   
	                   end
	      SEND_EOP:begin
	   	         if(eop_not_done && ! tx_sm_ready)begin                   
		            `uvm_info(get_full_name(),"ENTER INTO SEND_EOP STATE FROM TX_DATA_LOAD STATE",UVM_LOW)
		             next_state = SEND_EOP;
		         end
		         else begin
		            next_state = TX_WAIT;
		            `uvm_info(get_full_name(),"ENTER INTO  TX_WAIT STATE FROM SEND EOP",UVM_LOW)
	                 end
	               end
	 endcase
	end while (present_state != SEND_EOP );
	      `uvm_info(get_full_name(),$sformatf("JUMPING TO NEXT STATE =%s",next_state),UVM_LOW)

	endtask   

task send_sync(word_if,valid,validh);
      
	      bit [31:0] hs_32bit_sync;
	      bit [7:0]  ls_fs_8bit_sync;
	      //bit [15:0] tx_fifo_sync[$];
	      bit [DATA_WIDTH-1:0] tx_fifo_sync[$];
	      
	      bit [15:0] tx_16bit_piso_data;
	      bit [7:0]  tx_8bit_piso_data;
	      int        tx_size;
	      
	       if(word_if && valid && validh )begin
		      hs_32bit_sync = 32'b10101010_10101010_10101010_10101011;
		     tx_fifo_sync.push_back(hs_32bit_sync[15:0]);
		     tx_fifo_sync.push_back(hs_32bit_sync[31:16]);
		     `uvm_info(get_full_name(),$sformatf("SEND SYNC  HS_SYNC =%b : %0h",hs_32bit_sync,hs_32bit_sync),UVM_LOW)
		     end
	      else if(!word_if && valid && ! validh)begin
		       ls_fs_8bit_sync =8'b10101011;
		       tx_fifo_sync.push_back(ls_fs_8bit_sync);
		     `uvm_info(get_full_name(),$sformatf("SEND SYNC LS_FS_SYNC =%b",ls_fs_8bit_sync),UVM_LOW)
		   end        
		   
	      while(tx_fifo_sync.size()>0)begin
		for(int j = 0; j < tx_fifo_sync.size(); j++ )begin
                       if(valid && validh)begin
                          tx_16bit_piso_data = tx_fifo_sync.pop_front();
                          tx_size = 16;
                          tx_piso(tx_16bit_piso_data,tx_size);
                         end
                    
                     else if(valid && !validh)begin
                          tx_8bit_piso_data = tx_fifo_sync.pop_front();
                          tx_size = 8;
                          tx_piso(tx_8bit_piso_data,tx_size);
                         end
            end 
           end //while
         
endtask
  
  
task eop_generate(bit word_if,valid,validh);

	  //bit [7:0]  hs_eop;
	  bit [7:0]   fs_ls_eop;
	  bit [15:0]  hs_eop;
	  bit [DATA_WIDTH-1:0]  tx_fifo_eop[$];
	  bit [7:0]   tx_8bit_piso_data;
	  bit [15:0]  tx_16bit_piso_data;
	  int         tx_size;
          `uvm_info(get_full_name(),"ENTER_INTO_TX_SEND_EOP_TASK",UVM_LOW)

	 if(word_if && valid && validh) begin
            `uvm_info(get_full_name(),"ENTER_INTO_TX_SEND_EOP_TASK_WORD_IF_ONE_CONDTION",UVM_LOW)
             tx_stuff_count =0;
             hs_eop_enable =1;
	     //hs_eop = 8'b0111_1111;
	    hs_eop = 16'b0000_0000_0111_1111;
	   // hs_eop = 16'b0000_0000_0000_0100;
	    tx_fifo_eop.push_back(hs_eop);
	    `uvm_info(get_full_name(),$sformatf("EOP_HS = %b", hs_eop), UVM_LOW)
	  end
	    
	  else if(!word_if && valid && !validh) begin
	    fs_ls_eop = 8'b00000_100; 
	    tx_fifo_eop.push_back(fs_ls_eop);
	    `uvm_info(get_full_name(),$sformatf("EOP_FS/LS = %b", fs_ls_eop), UVM_LOW)
	   end

	  while(tx_fifo_eop.size() > 0) begin
	     for(int j = 0; j < tx_fifo_eop.size(); j++) begin

	       if(valid && validh) begin
	  	 tx_16bit_piso_data = tx_fifo_eop.pop_front();
		 tx_size = 16;
		 tx_piso(tx_16bit_piso_data, tx_size);
	  	 //tx_8bit_piso_data = tx_fifo_eop.pop_front();
		 //tx_size = 8;
		 //tx_piso(tx_8bit_piso_data, tx_size);
	      end
	      else if(valid && !validh) begin
		  tx_8bit_piso_data = tx_fifo_eop.pop_front();
                  tx_size = 8; 
                  tx_piso(tx_8bit_piso_data, tx_size);
              end
          end
        end
        hs_eop_enable =0;
endtask

  
task tx_piso( input bit[15:0]piso_data_in,int size);

           bit    piso_data_out;
          `uvm_info(get_full_name(), $sformatf("ENTERED_INTO_TX_PISO_TASK piso_data_in=%0d",piso_data_in),UVM_LOW)        
	     //@(posedge host_utmi_interface_tx.cb_utmi_host_controller_driver)begin
	     @(negedge host_utmi_interface_tx.cb_utmi_host_controller_monitor)begin
   		 for(int i=0;i<size;i++)begin
             		piso_data_out = piso_data_in[i];
            		`uvm_info(get_full_name(), $sformatf("TRANSMITTER: PISO - %b size=%0d",piso_data_out,size),UVM_LOW)        
             		tx_bit_stuffing(piso_data_out);
	      	  end  
	      end  
endtask  
  
  

/*task tx_bit_stuffing(input bit data_in_stuffing);

   bit data_out_stuffing;

   `uvm_info(get_full_name(),
      $sformatf("ENTERED_INTO_TX_BIT_STUFFING_TASK data_in_stuffing=%b",
      data_in_stuffing), UVM_LOW)
   if(hs_eop_enable) begin
      data_out_stuffing = data_in_stuffing;
      `uvm_info("HS_EOP", $sformatf("HS_EOP_BYPASS_STUFFING data=%b", data_out_stuffing), UVM_LOW)
      tx_nrzi_encoder(data_out_stuffing);
      return;
   end

   if(data_in_stuffing == 1) begin
      tx_stuff_count++;
      if(tx_stuff_count == 6) begin
         data_out_stuffing = 0;
         `uvm_info(get_full_name(), "INSERTING_STUFFED_ZERO", UVM_LOW)
         tx_nrzi_encoder(data_out_stuffing);
         tx_stuff_count = 0;
         return;
      end
      else begin
         data_out_stuffing = 1;
      end
   end
   else begin
      tx_stuff_count = 0;
      data_out_stuffing = 0;
   end
   `uvm_info(get_full_name(), $sformatf("BIT_STUFFING:data_in_stuffing = %b, data_out_stuffing = %b,count=%0d", data_in_stuffing,data_out_stuffing,tx_stuff_count), UVM_LOW)
   tx_nrzi_encoder(data_out_stuffing);

endtask*/

task tx_bit_stuffing(input bit data_in_stuffing);

   bit data_out_stuffing;

   `uvm_info(get_full_name(),$sformatf("ENTERED_INTO_TX_BIT_STUFFING_TASK data_in_stuffing=%b", data_in_stuffing), UVM_LOW)
   if(hs_eop_enable) begin
      data_out_stuffing = data_in_stuffing;
      `uvm_info("HS_EOP",$sformatf("HS_EOP_BYPASS_STUFFING data=%b", data_out_stuffing), UVM_LOW)
      tx_nrzi_encoder(data_out_stuffing);
      return;
   end

   data_out_stuffing = data_in_stuffing;
   tx_nrzi_encoder(data_out_stuffing);

   if(data_in_stuffing == 1)
      tx_stuff_count++;
   else
      tx_stuff_count = 0;

   if(tx_stuff_count == 6) begin
      `uvm_info(get_full_name(),"INSERTING_STUFFED_ZERO", UVM_LOW)
      tx_nrzi_encoder(0);
      tx_stuff_count = 0;
   end
   `uvm_info(get_full_name(),$sformatf("BIT_STUFFING:data_in_stuffing=%b count=%0d",data_in_stuffing,tx_stuff_count), UVM_LOW)

endtask

  
  
task tx_nrzi_encoder(input bit nrzi_input);
        static bit nrzi_output;
        bit        Dp;

    
    `uvm_info(get_full_name(), $sformatf("ENTERED_INTO_TX_NRXI_ENCODER_TASK"),UVM_LOW)        
        if (nrzi_input == 0)
      		nrzi_output = ~nrzi_output;
   	 	else
      	    nrzi_output = nrzi_output;      
           `uvm_info(get_full_name(),$sformatf("ENCODER: nrzi_input=%0b,nrzi_output %0b",nrzi_input,nrzi_output),UVM_LOW)
         
   		    Dp = nrzi_output;
        
         //@(posedge usb_phy_interface.cb_phy_driver);
         @(posedge usb_phy_interface.phy_clk);
           usb_phy_interface.Dp <= Dp;
           usb_phy_interface.Dm <=~Dp;
         @(negedge usb_phy_interface.phy_clk);
         //@(negedge usb_phy_interface.cb_phy_driver);
 	     `uvm_info("NRZI_ENCODER",$sformatf("WRITTEN_TO_PHY"),UVM_LOW);
            if(count_trigger>=0)begin 
 	         `uvm_info("NRZI_ENCODER",$sformatf("EVENT_BEING_TRIGGER"),UVM_LOW);
            	  //decoder_event.trigger(); 
		  decoder_sem.put(1);
		  count_trigger++;     
 	        `uvm_info("NRZI_ENCODER",$sformatf("EVENT_TRIGGER"),UVM_LOW);
              end
endtask
  

task sending_hc_rx_data();
     `uvm_info("HC_RX_DATA",$sformatf("ENTERED_INTO_SENDING_HC_RX_DATA EOP_DETECTED=%0d",eop_detected),UVM_LOW);
     forever begin
       //decoder_event.wait_ptrigger(); //reset the event which got triggered for previous bit
       decoder_sem.get(1);
       `uvm_info("HC_RX_DATA",$sformatf("EVENT_GOT_TRIGGERED"),UVM_LOW);
       //@(posedge usb_phy_interface.cb_phy_driver);
       nrzi_decoder(usb_phy_interface.Dp,usb_phy_interface.Dm);
         @(posedge usb_phy_interface.phy_clk);
     end
endtask

task sending_dc_rx_data();
     `uvm_info("DC_RX_DATA",$sformatf("ENTERED_INTO_SENDING_DC_RX_DATA EOP_DETECTED=%0d",eop_detected),UVM_LOW);
     forever begin
       //decoder_event.wait_ptrigger(); //reset the event which got triggered for previous bit
       decoder_sem.get(1);
       `uvm_info("HC_RX_DATA",$sformatf("EVENT_GOT_TRIGGERED"),UVM_LOW);
       //@(posedge usb_phy_interface.cb_phy_driver);
       nrzi_decoder(usb_phy_interface.Dp,usb_phy_interface.Dm);
         @(posedge usb_phy_interface.phy_clk);
     end
endtask  
  
task nrzi_decoder(bit dp,dm);
    `uvm_info("NRZI_DECODER",$sformatf("ENTERED_INTO_NRZI_DECODER_TASK D+=%0b , Dm=%0b ", dp,dm),UVM_LOW); 
     transition = (dp != dp_prev);
     dp_prev = dp;
     decoded = transition ? 1'b0 : 1'b1;
     `uvm_info("NRZI_DECODER",$sformatf("D+=%0b , Transition=%0b , Decoded=%0b", dp, transition, decoded),UVM_LOW);
     bit_unstuffing(decoded);   
endtask

task bit_unstuffing(input bit data_in_unstuffing);

   bit data_out_unstuffing;

   static int one_count = 0;
   `uvm_info("NRZI_DECODER","ENTERED_INTO_BIT_UNSTUFFING_TASK",UVM_LOW);

   if(one_count == 6) begin

      if(data_in_unstuffing == 0) begin
         `uvm_info("BIT_UNSTUFF","REMOVING_STUFFED_ZERO", UVM_LOW)
         one_count = 0;
         return;
      end
      else begin
         `uvm_info("BIT_UNSTUFF","EXPECTED_STUFFED_ZERO_GOT_ONE",UVM_LOW)
         one_count = 0;
      end
   end
     data_out_unstuffing = data_in_unstuffing;
    `uvm_info("BIT_UNSTUFF",$sformatf("PASSING_REAL_BIT=%b", data_out_unstuffing),UVM_LOW)
     rx_state_machine(data_out_unstuffing);

   if(data_in_unstuffing == 1)
      one_count++;
   else
      one_count = 0;
      `uvm_info("BIT_UNSTUFF", $sformatf("ONE_COUNT=%0d", one_count),UVM_LOW)
endtask


//////////////////////////////////////////////////////////////////////
/* task bit_unstuffing(input bit data_in_unstuffing);

  bit data_out_unstuffing;
  static int un_count = 0;
  static bit skip_next = 0;

  `uvm_info("NRZI_DECODER","ENTERED_INTO_BIT_UNSTUFFING_TASK",UVM_LOW);

   if (skip_next) begin
       `uvm_info(get_full_name(),$sformatf("BIT_UNSTUFFING_BEFORE_ASSIGNED_TO_UNSTUFFING_INPUT: data_in_unstuffing=%b",data_in_unstuffing),UVM_LOW)     
 //////////////////////////////////////
            if(data_in_unstuffing == 1 && word_if) begin
            `uvm_info("HS_EOP", "HS_EOP_DETECTED",UVM_LOW);
             skip_next = 0;
             un_count = 0;
             // PASS THE 7th ONE
             data_out_unstuffing = data_in_unstuffing;
             `uvm_info("HS_EOP",$sformatf("HS_EOP data_out=%b",data_out_unstuffing), UVM_LOW);
             rx_state_machine(data_out_unstuffing);
             return;
           end
////////////////////////////////////////////
      if (data_in_unstuffing != 0) //begin
        `uvm_error("UNSTUFF", "Expected_stuffed_0_but_got 1");
     // end
      `uvm_info("UNSTUFF","Skipping_stuffed_0",UVM_LOW);
       skip_next = 0;
       un_count = 0;
       return;
  end

  if(data_in_unstuffing == 1)
     un_count++;
  else
     un_count = 0;

  if(un_count == 6) begin
    `uvm_info("BIT_UNSTUFF","Stuffed bit detected, skipping next bit",UVM_LOW);
    // un_count = 0;
     skip_next = 1; 
     //return;
  end
  data_out_unstuffing = data_in_unstuffing;
  `uvm_info("BIT_UNSTUFF",$sformatf("data_out=%b",data_out_unstuffing),UVM_LOW);
  rx_state_machine(data_out_unstuffing);
endtask*/
 
  
  task rx_sipo(bit serial_bit);

   bit [15:0] sipo_data_16bit;

   width = word_if ? 16 : 8;
   `uvm_info("SIPO",$sformatf("RX_WIDTH = %0d WORD_IF=%0d",width,word_if),UVM_LOW)
   rx_shift_reg = {serial_bit, rx_shift_reg[15:1]};
   `uvm_info("SIPO",$sformatf("RX_SHIFT_REG = %0b",rx_shift_reg),UVM_LOW)
   `uvm_info("SIPO",$sformatf("RX_COUNT_SIPO = %0d",rx_bit_count),UVM_LOW)
   if(rx_bit_count == width) begin
      if(width == 8) begin
         sipo_data = rx_shift_reg[15:8];
         `uvm_info("SIPO",$sformatf("SIPO_DATA_8BIT = %0d",sipo_data),UVM_LOW)
         if((sipo_data == 8'b00000100) && !word_if) begin
            `uvm_info("SIPO","EOP_DETECTED_IN_8BIT_MODE",UVM_LOW)
            eop_detected = 1;
            `uvm_info("SIPO", $sformatf("QUEUE_AFTER_EOP = %p",rx_data_queue), UVM_LOW)
         end
         else begin
            rx_data_queue.push_back(sipo_data);
            `uvm_info("SIPO",$sformatf("PARALLEL_DATA_QUEUE = %0p",rx_data_queue),UVM_LOW)
         end
      end
      else begin
         sipo_data_16bit = rx_shift_reg;
         `uvm_info("SIPO",$sformatf("SIPO_DATA_16BIT = %b",sipo_data_16bit),UVM_LOW)
         if((sipo_data_16bit == 16'b0000_0000_0111_1111) && word_if) begin
            `uvm_info("SIPO","HS_EOP_DETECTED",UVM_LOW)
            eop_detected = 1;
            `uvm_info("SIPO",$sformatf("QUEUE_AFTER_EOP = %p",rx_data_queue),UVM_LOW)
         end
         else begin
            rx_data_queue.push_back(sipo_data_16bit);
            `uvm_info("SIPO",$sformatf("RX_PARALLEL_DATA = %0p",rx_data_queue),UVM_LOW)
         end
      end
      rx_bit_count = 0;
   end
   rx_bit_count++;
endtask
  
task rx_state_machine(bit data_out_unstuffing);

    bit         RXActive;
    bit         RXValid;
    bit         RXError;
    bit         sync_detected;
    int         sync_count=0;
    bit         data;
    static int  pid_count=0;
    bit [7:0]   pid_bits;
    static int  byte_count=0;
    bit [15:0]  RX_hold_reg;
    bit [7:0]   local_reg;
    int         data_count=0;
    bit [2:0]   eop=3'b001;

    `uvm_info("RX_STATE_MACHINE", $sformatf(" ENTERED_INTO_RX_STATE_MACHINE_TASK "), UVM_LOW) 
     if (rx_present_state == RESET) begin
         `uvm_info("RX_STATE_MACHINE",$sformatf("RX FSM:RESET RXActive=%0b, RXValid=%0b",RXActive, RXValid),UVM_LOW)
         rx_present_state = RX_WAIT;
         `uvm_info("RX_STATE_MACHINE","RX FSM: Reset deasserted moving to RX_WAIT",UVM_LOW)
         RXActive=1'b0;
         RXValid=1'b0;
         rx_reset=0;
     end //RESEST
     
     case (rx_present_state)
	RX_WAIT: begin
	           `uvm_info("RX_STATE_MACHINE", $sformatf(" ENTERED_INTO_RX_WAIT_STATE "), UVM_LOW) 
		    count++;
		   `uvm_info("RX_STATE_MACHINE", $sformatf("count=%0d ",count), UVM_LOW)
		    serial_reg = { data_out_unstuffing,serial_reg[15:1]};         
		   `uvm_info("RX_STATE_MACHINE", $sformatf("SIPO_OUT=%0b : %0h Data_out_unstuffing=%b",serial_reg,serial_reg,data_out_unstuffing), UVM_LOW)
		    if(count == 'd8 && !word_if)begin
		       sync_8bit = serial_reg[15:8];
		       `uvm_info("RX_STATE_MACHINE", $sformatf("sync_8bit=%b,WORD_IF=%d,SERIAL_REG=%d",sync_8bit,word_if,serial_reg), UVM_LOW)
		        pop_data.push_back(sync_8bit);
		       `uvm_info("RX_STATE_MACHINE", $sformatf("pop_data=%0p",pop_data), UVM_LOW)
		        pop_data.delete();
			`uvm_info("RX_STATE_MACHINE", $sformatf("pop_size=%0p",pop_data.size()), UVM_LOW)
			sync_detected=1;
			count=0;
	            end
		    else if(count == 'd16 && word_if) begin
			sync_low = serial_reg;
			`uvm_info("RX_STATE_MACHINE", $sformatf("sync_low=%b,WORD_IF=%d,SERIAL_REG=%d",sync_low,word_if,serial_reg), UVM_LOW)
			pop_data.push_back(sync_low);
			`uvm_info("RX_STATE_MACHINE", $sformatf("POP_DATA VALUE=%0p",pop_data), UVM_LOW)
		    end
		    if(count == 'd32) begin
		       collect_sync = {serial_reg,sync_low};
		       pop_data.push_back(collect_sync);
   	               `uvm_info("RX_STATE_MACHINE", $sformatf("collect_sync=%b,WORD_IF=%d,SERIAL_REG=%d",collect_sync,word_if,serial_reg), UVM_LOW)
		       pop_data.delete();
		       `uvm_info("RX_STATE_MACHINE", $sformatf("SYNC_32BIT_DATA_AFTER_DELETEING =%0p queue_size=%d",pop_data,pop_data.size()), UVM_LOW)
		       sync_detected=1;
		       count=0;
		    end
////////////////////////////////////////////////////
            if(sync_detected == 1'b1) begin
              if(word_if) begin
               `uvm_info("RX_STATE_MACHINE", $sformatf("WORD_IF=1_DIRECTLY_MOVING_TO_RX_DATA"), UVM_LOW)
                data = 1'b1;
                rx_present_state = RX_DATA;
              end
             else begin
                `uvm_info("RX_STATE_MACHINE",$sformatf("WORD_IF=0_MOVING_TO_STRIP_SYNC"), UVM_LOW)
                 rx_present_state = STRIP_SYNC;
             end
           end
         end
//////////////////////////////////////////////////////

		  //  if(sync_detected==1'b1)
		    //   rx_present_state=STRIP_SYNC;
		    //end //begin
        STRIP_SYNC:begin
		     RXActive=1'b1;
                     device_utmi_interface_rx.utmi_rxactive <= RXActive;
                     //#1;
                     `uvm_info("SIPO",$sformatf("RXACTIVE_VALUE_AT_INTERFACE = %d",device_utmi_interface_rx.utmi_rxactive),UVM_LOW)
		     `uvm_info("RX_STATE_MACHINE", $sformatf(" ENTERRD INTO STRIP SYNC STATE AND RXACTIVE VALUE = %b ", RXActive), UVM_LOW) 
		     pid_count++;
		     `uvm_info("RX_STATE_MACHINE", $sformatf("count=%0d ",pid_count), UVM_LOW) 
		     if(!word_if)begin
		        token_pkt_pid = { data_out_unstuffing,token_pkt_pid[7:1]};  
		        `uvm_info("RX_STATE_MACHINE", $sformatf("PID_OUT= %0p,WORD_IF=%d",token_pkt_pid,word_if), UVM_LOW)
		     end
		     //else if(word_if)begin
		      // token_pkt_pid = { data_out_unstuffing,token_pkt_pid[7:1]};  
		      // `uvm_info("RX_STATE_MACHINE", $sformatf("PID_OUT= %0p",token_pkt_pid), UVM_LOW)
		     //end
		     if(pid_count==8) begin
		        rx_data_queue.push_back(token_pkt_pid); 
		        `uvm_info("RX_STATE_MACHINE", $sformatf("DATA_QUEUE_PID_VALUE=%0p",rx_data_queue), UVM_LOW)
		        data=1;
		        pid_count=0;
		        `uvm_info("RX_STATE_MACHINE",$sformatf("PID DETECTED MOVING TO RX_DATA STATE"),UVM_LOW)
		     end
       		     if(data==1)
         	       rx_present_state=RX_DATA;
       		     else
        	       rx_present_state=STRIP_SYNC;
      		     end
                     //RXActive=1'b1;
                     //utmi_interface_rx.utmi_rxactive <= RXActive;
                     //#1;
                     //`uvm_info("SIPO",$sformatf("RXACTIVE_VALUE_AT_INTERFACE = %d",utmi_interface_rx.utmi_rxactive),UVM_LOW)
      	RX_DATA: begin
       		   RXValid = 1'b1;
               if(!eop_detected)
       		   rx_sipo(data_out_unstuffing);
 		   if(eop_detected) begin
              	     `uvm_info("SIPO",$sformatf("EOP_DETECTED_VALUE = %p",eop_detected),UVM_LOW)
          	     `uvm_info("RX_FSM",$sformatf("EOP DETECTED MOVING TO STRIP_EOP =%0d",strip_eop),UVM_LOW)
		     send_task_count++;
                     `uvm_info("RX_FSM_RX_DATA",$sformatf("send_task_count=%d",send_task_count),UVM_LOW)
                     RXActive = 1'b0;
                     device_utmi_interface_rx.utmi_rxactive <= RXActive;
                 //    #1;
                   `uvm_info("SIPO",$sformatf("RXACTIVE_VALUE_AT_INTERFACE = %d",device_utmi_interface_rx.utmi_rxactive),UVM_LOW)
          	        rx_present_state = STRIP_EOP;
		     strip_eop =1;
          	     `uvm_info("RX_FSM",$sformatf("STRIP_EOP=%0d",strip_eop),UVM_LOW)
  		      rx_state_machine(0); // Immediately execute STRIP_EOP state
        	    end
                 end     
	STRIP_EOP: begin
  		     `uvm_info("RX_FSM","STRIP_EOP_STATE_ENTERED ",UVM_LOW)
                     `uvm_info("RX_FSM",$sformatf("RX_ACTIVE=%b,RXValid=%b,dp_shift=%b,serial_reg=%b,token_pkt_pid=%b",RXActive,RXValid,dp_shift,serial_reg,token_pkt_pid),UVM_LOW)
                     if(rx_data_queue.size() != 0) begin
                        bit [7:0] first_rx_byte;
                        first_rx_byte = rx_data_queue[0];

                      if(pid_temp_low_setup == 8'd45 || pid_temp_low_setup == 8'hb4 || pid_temp_low_setup == 8'he1 || pid_temp_high_setup[7:0] == 8'd45 || pid_temp_high_setup[7:0] ==8'hb4 || pid_temp_high_setup[7:0] == 8'he1)begin
                          `uvm_info("PHY_DRIVER",$sformatf("pid_temp_low_setup=%h",pid_temp_low_setup),UVM_LOW)
                          // repeat(1)begin
                              `uvm_info("PHY_DRIVER","BEFORE_ENTERING_INTO_COLLECTING_TASK",UVM_LOW)
                               collecting_from_rx_sipo();
                              `uvm_info("PHY_DRIVER","COMPLETED_THE_COLLECTING_TASK ",UVM_LOW)
		                      //send_utmi_rx_data_to_device(device_utmi_interface_rx);
                               if(ack_source == ACK_FROM_DEVICE)begin
                                 send_utmi_rx_data_to_host(host_utmi_interface_rx);
                                `uvm_info("PHY_DRIVER","SENDING_RX_DATA_TO_HOST ",UVM_LOW)
                               end
                               else if (ack_source == ACK_FROM_HOST)begin
		                       send_utmi_rx_data_to_device(device_utmi_interface_rx);
                               `uvm_info("PHY_DRIVER","SENDING_RX_DATA_TO_DEVICE ",UVM_LOW)
                               end
                           //end
                         end
                         else if((first_rx_byte[7:4] == USB2p0_sequence_item::PID_IN) || (first_rx_byte[7:4] == USB2p0_sequence_item::PID_OUT))begin
                             // Status stage for this no-data control transfer is a standalone IN
                             // token from host to device. Forward it to the device-side UTMI RX
                             // as soon as that token packet reaches EOP instead of waiting for a
                             // second packet as we do for the setup token + data aggregation path.
                            `uvm_info("PHY_DRIVER",$sformatf("FORWARDING_STANDALONE_IN_TOKEN first_rx_byte=%h", first_rx_byte),UVM_LOW)
                            `uvm_info("PHY_DRIVER","BEFORE_ENTERING_INTO_COLLECTING_TASK",UVM_LOW)
                             collecting_from_rx_sipo();
                            `uvm_info("PHY_DRIVER","COMPLETED_THE_COLLECTING_TASK ",UVM_LOW)
                             send_utmi_rx_data_to_device(device_utmi_interface_rx);
                            `uvm_info("PHY_DRIVER","COMPLETED_THE_SEND_TO_UTMI_RX_INTERFACE ",UVM_LOW)
                         end
                         else
                           `uvm_info("PHY_DRIVER","BEFORE_ENTERING_INTO_COLLECTING_TASK",UVM_LOW)
                            collecting_from_rx_sipo();
                           `uvm_info("PHY_DRIVER","COMPLETED_THE_COLLECTING_TASK ",UVM_LOW)
                           if(send_task_count ==2)begin
                              `uvm_info("RX_FSM_STRIP_EOP",$sformatf("send_task_count=%b",send_task_count),UVM_LOW)
                              `uvm_info("PHY_DRIVER","COMPLETED_THE_COLLECTING_TASK ",UVM_LOW)
		                       send_utmi_rx_data_to_device(device_utmi_interface_rx);
                              `uvm_info("PHY_DRIVER","COMPLETED_THE_SEND_TO_UTMI_RX_INTERFACE ",UVM_LOW)
                               send_task_count=0;
		                   end
                      end
	             RXActive            = 0;
	             RXValid             = 0;
	             dp_shift            = 0;
	             count               = 0;
	             pid_count           = 0;
	             sync_detected       = 0;
	             eop_detected        = 0;
	             serial_reg          = 16'b0;
	             token_pkt_pid       = 0;
	             token_pkt_addr      = 0;
	             token_pkt_endpoint  = 0;
	             token_pkt_crc       = 0;
	             strip_eop           = 0;
                    //rx_bit_count        = 0;
                    //rx_shift_reg        = 0;
	             rx_present_state = RX_WAIT;
	           end
                     
        RX_DATA_WAIT: begin
                        RXValid=0;
                      end
     endcase
endtask
     
task collecting_from_rx_sipo();
     `uvm_info("UTMI_RX_DATA",$sformatf("RX_DATA_8_16BIT_DATA_size = %0d rx_data=%0p",rx_data_queue.size(),rx_data_queue),UVM_LOW)
     for(int i=0;i<rx_data_queue.size();i++)begin
          utmi_data_queue.push_back(rx_data_queue[i]);
          `uvm_info("UTMI_RX_DATA",$sformatf("8/16BIT_DATA = %p",utmi_data_queue),UVM_LOW)
     end
     rx_data_queue.delete();
endtask

task send_utmi_rx_data_to_device(virtual USB2p0_device_utmi_interface   device_utmi_interface_rx);
     //bit [15:0] rx_data_drive;
     bit [DATA_WIDTH-1:0] rx_data_drive;
 
     `uvm_info("SEND_UTMI_RX_DATA",$sformatf("ENTERED_SEND_UTMI_RX_DATA"),UVM_LOW)
     device_utmi_interface_rx.utmi_word_if         = word_if;
     device_utmi_interface_rx.utmiotg_vbusvalid    = 1;
     device_utmi_interface_rx.utmisrp_bvalid       = 1;
     device_utmi_interface_rx.utmi_host_disconnect = 0;
     device_utmi_interface_rx.utmi_rxerror         = 0;
     //device_utmi_interface_rx.utmi_rxvalid         = 1;
     device_utmi_interface_rx.utmi_rxvalidh        = 0;
     device_utmi_interface_rx.utmi_rxactive        = 1;

     // Drive RXDATA on the falling edge first, then let RXVALID be observed on the
     // next rising edge. This avoids the host sampling 0/x as the first byte.
     while(utmi_data_queue.size()>0) begin
        @(posedge device_utmi_interface_rx.cb_utmi_device_controller_driver);
          rx_data_drive = '0;
          `uvm_info("UTMI_RX_QUEUE_SIZE",$sformatf("UTMI_RX_QUEUE_SIZE=%d",utmi_data_queue.size()),UVM_LOW)

          if(word_if) begin
         //     for (int i = 0; i < DATA_WIDTH/8; i++) begin
           //       if (utmi_data_queue.size() > 0)
             //         rx_data_drive[i*8 +: 8] = utmi_data_queue.pop_front();
              //    else
                //      rx_data_drive[i*8 +: 8] = 8'h00;
              //end

             // @(negedge utmi_interface_rx.utmi_clk);
              //for (int i = 0; i < DATA_WIDTH/8; i++) begin
                //  device_utmi_interface_rx.utmi_rxdata[i*8 +: 8] = rx_data_drive[i*8 +: 8];
              //end
               rx_data_drive  = utmi_data_queue.pop_front();
               device_utmi_interface_rx.utmi_rxdata = rx_data_drive;
               device_utmi_interface_rx.utmi_rxvalid  = 1;
               device_utmi_interface_rx.utmi_rxvalidh = 1;
               #1;
              `uvm_info("UTMI_RX_VALID",$sformatf("UTMI_RX_VALID=%b,UTMI_RX_VALIDH=%b",device_utmi_interface_rx.utmi_rxvalid,device_utmi_interface_rx.utmi_rxvalidh),UVM_LOW)
              `uvm_info("UTMI_RX_DATA",$sformatf("16BIT_DATA = %h",rx_data_drive),UVM_LOW)
          end
          else begin
              rx_data_drive = utmi_data_queue.pop_front();
               //@(posedge utmi_interface_rx.utmi_clk);
              device_utmi_interface_rx.utmi_rxdata   = rx_data_drive;
              device_utmi_interface_rx.utmi_rxvalid  = 1;
              device_utmi_interface_rx.utmi_rxvalidh = 0;
              `uvm_info("UTMI_RX_VALID",$sformatf("UTMI_RX_VALID=%b,UTMI_RX_VALIDH=%b",device_utmi_interface_rx.utmi_rxvalid,device_utmi_interface_rx.utmi_rxvalidh),UVM_LOW)
              //`uvm_info("PHY_DRIVER_SEND_TO_UTMI_RX",$sformatf("8BIT_DATA_RX_INTERFACE_QUEUE = %h utmi_data_queuesize=%0d,8BIT_DATA_RX_INTERFACE = %h",rx_data_drive,utmi_data_queue.size(),device_utmi_interface_rx.utmi_rxdata),UVM_LOW)
              `uvm_info("PHY_DRIVER_SEND_TO_UTMI_RX",$sformatf("8BIT_DATA_RX_INTERFACE_QUEUE = %h,8BIT_DATA_RX_INTERFACE = %h",rx_data_drive,device_utmi_interface_rx.utmi_rxdata),UVM_LOW)
              #1;
             //@(posedge device_utmi_interface_rx.cb_utmi_device_controller_driver);
          end
           end
     // @(negedge utmi_interface_rx.utmi_clk);
      `uvm_info("UTMI_RX_QUEUE_SIZE",$sformatf("UTMI_RX_QUEUE_SIZE=%d",utmi_data_queue.size()),UVM_LOW)
       device_utmi_interface_rx.utmi_rxvalid  = 0;
       device_utmi_interface_rx.utmi_rxvalidh = 0;
       device_utmi_interface_rx.utmi_rxactive = 0;
      `uvm_info("SEND_UTMI_RX_DATA",$sformatf("COMPLETED_SEND_UTMI_RX_DATA"),UVM_LOW)
          //`uvm_info("UTMI_RX_RESET_DATA",$sformatf("UTMI_RX_VALIDH=%b,UTMI_RX_VALID=%b,UTMI_RX_ACTIVE=%b",utmi_interface_rx.utmi_rxvalidh,utmi_interface_rx.utmi_rxvalid,utmi_interface_rx.utmi_rxactive),UVM_LOW)
endtask      
  
task send_utmi_rx_data_to_host(virtual USB2p0_host_utmi_interface   host_utmi_interface_rx);
     //bit [15:0] rx_data_drive;
     bit [DATA_WIDTH-1:0] rx_data_drive;
 
     `uvm_info("SEND_UTMI_RX_DATA",$sformatf("ENTERED_SEND_UTMI_RX_DATA"),UVM_LOW)
     host_utmi_interface_rx.utmi_word_if         = word_if;
     host_utmi_interface_rx.utmiotg_vbusvalid    = 1;
     host_utmi_interface_rx.utmisrp_bvalid       = 1;
     host_utmi_interface_rx.utmi_host_disconnect = 0;
     host_utmi_interface_rx.utmi_rxerror         = 0;
     host_utmi_interface_rx.utmi_rxvalid         = 0;
     host_utmi_interface_rx.utmi_rxvalidh        = 0;
     host_utmi_interface_rx.utmi_rxactive        = 1;

     // Drive RXDATA on the falling edge first, then let RXVALID be observed on the
     // next rising edge. This avoids the host sampling 0/x as the first byte.
     while(utmi_data_queue.size()>0) begin
         @(posedge host_utmi_interface_rx.cb_utmi_host_controller_driver);
          rx_data_drive = '0;
          `uvm_info("UTMI_RX_QUEUE_SIZE",$sformatf("UTMI_RX_QUEUE_SIZE=%d",utmi_data_queue.size()),UVM_LOW)

          if(word_if) begin
             // for (int i = 0; i < DATA_WIDTH/8; i++) begin
               //   if (utmi_data_queue.size() > 0)
                 //     rx_data_drive[i*8 +: 8] = utmi_data_queue.pop_front();
                 // else
                   //   rx_data_drive[i*8 +: 8] = 8'h00;
              //end

             // @(negedge utmi_interface_rx.utmi_clk);
              //for (int i = 0; i < DATA_WIDTH/8; i++) begin
                //  host_utmi_interface_rx.utmi_rxdata[i*8 +: 8] = rx_data_drive[i*8 +: 8];
              //end
              rx_data_drive = utmi_data_queue.pop_front();
              host_utmi_interface_rx.utmi_rxdata = rx_data_drive;
              host_utmi_interface_rx.utmi_rxvalid  = 1;
              host_utmi_interface_rx.utmi_rxvalidh = 1;
               #1;
              `uvm_info("UTMI_RX_VALID",$sformatf("UTMI_RX_VALID=%b,UTMI_RX_VALIDH=%b",host_utmi_interface_rx.utmi_rxvalid,host_utmi_interface_rx.utmi_rxvalidh),UVM_LOW)
              `uvm_info("UTMI_RX_DATA",$sformatf("16BIT_DATA = %h",rx_data_drive),UVM_LOW)
          end
          else begin
              rx_data_drive = utmi_data_queue.pop_front();
               //@(posedge utmi_interface_rx.utmi_clk);
              host_utmi_interface_rx.utmi_rxdata   = rx_data_drive;
              host_utmi_interface_rx.utmi_rxvalid  = 1;
              host_utmi_interface_rx.utmi_rxvalidh = 0;
              `uvm_info("UTMI_RX_VALID",$sformatf("UTMI_RX_VALID=%b,UTMI_RX_VALIDH=%b",host_utmi_interface_rx.utmi_rxvalid,host_utmi_interface_rx.utmi_rxvalidh),UVM_LOW)
              //`uvm_info("PHY_DRIVER_SEND_TO_UTMI_RX",$sformatf("8BIT_DATA_RX_INTERFACE_QUEUE = %h utmi_data_queuesize=%0d,8BIT_DATA_RX_INTERFACE = %h",rx_data_drive,utmi_data_queue.size(),host_utmi_interface_rx.utmi_rxdata),UVM_LOW)
              `uvm_info("PHY_DRIVER_SEND_TO_UTMI_RX",$sformatf("8BIT_DATA_RX_INTERFACE_QUEUE = %h,8BIT_DATA_RX_INTERFACE = %h",rx_data_drive,host_utmi_interface_rx.utmi_rxdata),UVM_LOW)
            #1;
             // @(posedge host_utmi_interface_rx.cb_utmi_host_controller_driver);
          end
           end
     // @(negedge utmi_interface_rx.utmi_clk);
      `uvm_info("UTMI_RX_QUEUE_SIZE",$sformatf("UTMI_RX_QUEUE_SIZE=%d",utmi_data_queue.size()),UVM_LOW)
       host_utmi_interface_rx.utmi_rxvalid  = 0;
       host_utmi_interface_rx.utmi_rxvalidh = 0;
       host_utmi_interface_rx.utmi_rxactive = 0;
      `uvm_info("SEND_UTMI_RX_DATA",$sformatf("COMPLETED_SEND_DEVICE_UTMI_RX_DATA"),UVM_LOW)
          //`uvm_info("UTMI_RX_RESET_DATA",$sformatf("UTMI_RX_VALIDH=%b,UTMI_RX_VALID=%b,UTMI_RX_ACTIVE=%b",utmi_interface_rx.utmi_rxvalidh,utmi_interface_rx.utmi_rxvalid,utmi_interface_rx.utmi_rxactive),UVM_LOW)
endtask      
  
endclass








                             /*if(send_task_count ==2)begin
                                `uvm_info("RX_FSM_STRIP_EOP",$sformatf("send_task_count=%b",send_task_count),UVM_LOW)
	                              send_utmi_rx_data();
                                      send_task_count=0;
	                  end*/

                        /* if(current_pkt_type == HANDSHAKE_PKT)
                             required_eop_count = 1;
                           else
                             required_eop_count = 2;

                        if(send_task_count == required_eop_count) begin
                          `uvm_info("RX_FSM_STRIP_EOP",$sformatf("send_task_count=%0d required=%0d",send_task_count, required_eop_count),UVM_LOW)
                           send_utmi_rx_data();
                           send_task_count = 0;
                        end*/


/*task run_phase(uvm_phase phase);
	bit rx_tx_threads_started;
    	`uvm_info("PHY_DRIVER", $sformatf("ENTERED_INTO_PHY_DRIVER_RUN_PHASE "),UVM_LOW) 
        @(host_utmi_interface_tx.cb_utmi_host_controller_driver);
           fork1951513
             begin
		forever begin
    	          `uvm_info("PHY_DRIVER", $sformatf("COLLECTING_TX_AND_SENDING_RX "),UVM_LOW) 
                  receiving_hc_tx_data(host_utmi_interface_tx);
                  sending_hc_rx_data();
                  //receiving_tx_data(host_utmi_interface_tx);
                  //sending_rx_data(device_utmi_interface_rx);
                end
                end
             //begin
             //   receiving_dc_tx_data(device_utmi_interface_tx);
             //   sending_dc_rx_data();
             //   //receiving_tx_data(device_utmi_interface_tx);
             //   //sending_rx_data(host_utmi_interface_rx);
             //end
           //join_any
   join_none

        forever begin
    	   seq_item_port.get_next_item(req);
    	   `uvm_info("PHY_DRIVER", $sformatf("GET_NEXT_ITEM "),UVM_LOW) 
    	   repeat(8)
           @(posedge usb_phy_interface.cb_phy_driver)

           usb_phy_interface.Vbus <= host_utmi_interface_tx.utmiotg_vbusvalid;
               
           if(host_utmi_interface_tx.utmiotg_vbusvalid==1) begin
    	       `uvm_info("PHY_DRIVER", $sformatf("PHY_DRIVER: PHY_Vbus=%b",usb_phy_interface.Vbus ),UVM_LOW) 
               @(posedge usb_phy_interface.cb_phy_driver)
    	       detect_device_pullup_from_device();
    	       detect_line_state();
           end
           seq_item_port.item_done(); 
        end

        //if(!rx_tx_threads_started) begin
           rx_tx_threads_started = 1;

            // Keep the PHY-side RX/TX infrastructure alive for the entire simulation.
            // The original fork...join blocked run_phase after the first packet, so the
            // host status-stage token was never re-captured by the PHY driver.
endtask*/

  /*task run_phase(uvm_phase phase);
  bit rx_tx_threads_started;

  `uvm_info("PHY_DRIVER",
            $sformatf("ENTERED_INTO_PHY_DRIVER_RUN_PHASE "),
            UVM_LOW)

  @(host_utmi_interface_tx.cb_utmi_host_controller_driver);

  if (!rx_tx_threads_started) begin
    rx_tx_threads_started = 1;

    fork
      begin : host_tx_listener
        forever begin
          `uvm_info("PHY_DRIVER", $sformatf("COLLECTING_HOST_TX_DATA"), UVM_LOW)
          fork
            receiving_hc_tx_data(host_utmi_interface_tx);
            receiving_dc_tx_data(device_utmi_interface_tx);
          join_any
          disable fork;
        end
      end

      begin : host_rx_decoder
        sending_hc_rx_data();
      end

     // begin : device_tx_listener
     //   sending_dc_rx_data();
     // end

      //begin : device_rx_decoder
      //  sending_dc_rx_data();
      //end
    join_none
  end

  forever begin
    seq_item_port.get_next_item(req);

    `uvm_info("PHY_DRIVER",
              $sformatf("GET_NEXT_ITEM "),
              UVM_LOW)

    repeat (8)
      @(posedge usb_phy_interface.cb_phy_driver);

    usb_phy_interface.Vbus <= host_utmi_interface_tx.utmiotg_vbusvalid;

    if (host_utmi_interface_tx.utmiotg_vbusvalid == 1) begin
      `uvm_info("PHY_DRIVER",
                $sformatf("PHY_DRIVER: PHY_Vbus=%b", usb_phy_interface.Vbus),
                UVM_LOW)

      @(posedge usb_phy_interface.cb_phy_driver);
      detect_device_pullup_from_device();
      detect_line_state();
    end

    seq_item_port.item_done();
  end
endtask*/

/* task tx_bit_stuffing(input bit data_in);
  bit data_out;
  static int one_count = 0;
  // If 6 ones already seen → insert stuffed 0 FIRST
  if (one_count == 6) begin
    data_out  = 0;   // stuffed bit
    one_count = 0;
    `uvm_info("STUFF","Inserted stuffed 0",UVM_LOW);
    return;  // ❗ IMPORTANT: do not consume current input yet
  end

  // Normal data flow
  data_out = data_in;

  if (data_in == 1)
    one_count++;
  else
    one_count = 0;

  `uvm_info("STUFF",$sformatf("data_in=%0b data_out=%0b count=%0d",
                             data_in, data_out, one_count),UVM_LOW);

   tx_nrzi_encoder(data_out);
endtask*/



/* task bit_unstuffing(input bit data_in_unstuffing);
      bit             data_out_unstuffing;
      static bit[2:0] un_count = 0;
     // static bit[2:0] un_count;
    
    `uvm_info("NRZI_DECODER",$sformatf("ENTERED_INTO_BIT_UNSTUFFING_TASK "),UVM_LOW); 
      if(un_count==6 || data_in_unstuffing == 1)
        un_count = un_count+1;
      else
        un_count = 0;
 
       `uvm_info(get_full_name(),$sformatf("BIT_UNSTUFFING_BEFORE_ASSIGNED_TO_UNSTUFFING_INPUT: data_in_unstuffing=%b",data_in_unstuffing),UVM_LOW)                        
      if(un_count == 7) begin   
      //if(un_count == 6) begin   
       `uvm_info(get_full_name(),$sformatf("BIT_UNSTUFFING_INSIDE_COUNT_CONDTION_VALUE: data_in_unstuffing=%b",data_in_unstuffing),UVM_LOW)                        
           data_out_unstuffing = 1;
           un_count =0;
      end
      else begin
        //else if(data_in_unstuffing == 0 || data_in_unstuffing == 1)begin
       `uvm_info(get_full_name(),$sformatf("BIT_UNSTUFFING_BEFORE_ASSIGNED_TO_UNSTUFFING_OUTPUT_ELSE_PART_FOR_ZERO_VALUE: data_in_unstuffing=%b",data_in_unstuffing),UVM_LOW)                        
        data_out_unstuffing = data_in_unstuffing;
        `uvm_info(get_full_name(),$sformatf("BIT_UNSTUFFING: data_out_unstuffing=%b",data_out_unstuffing),UVM_LOW)                        
         rx_state_machine(data_out_unstuffing);
      end
       //`uvm_info(get_full_name(),$sformatf("BIT_UNSTUFFING_BEFORE_ASSIGNED_TO_UNSTUFFING_OUTPUT_ELSE_PART_FOR_ZERO_VALUE: data_in_unstuffing=%b",data_in_unstuffing),UVM_LOW)                        
endtask*/


/*task tx_bit_stuffing(input data_in_stuffing);
    
    static bit [2:0] count; //using static keyword it will increment the count. without static inside task by default it will be automatic it will create diff memory each time so count will be re-initialize.
    bit data_out_stuffing;
      
    `uvm_info(get_full_name(), $sformatf("ENTERED_INTO_TX_BIT_STUFFING_TASK data_in_stuffing=%0d",data_in_stuffing),UVM_LOW)        

    if(data_in_stuffing == 1)
       count=count+1;
    else
       count=0;
     
    //if(count == 7)begin
    if(count == 6)begin
       	data_out_stuffing = 0;
       	count =0;
       // return;
    end
    else
      data_out_stuffing = data_in_stuffing;

      `uvm_info(get_full_name(),$sformatf("BIT_STUFFING:data_in_stuffing = %0b, data_out_stuffing = %0b,count=%0d", data_in_stuffing,data_out_stuffing,count),UVM_LOW)
       tx_nrzi_encoder(data_out_stuffing);
endtask */

 /* task rx_sipo(bit serial_bit);

   width = word_if ? 16 : 8;
   `uvm_info("SIPO",$sformatf("RX_WIDTH = %0d WORD_IF=%0d", width,word_if),UVM_LOW)
   rx_shift_reg = {serial_bit, rx_shift_reg[15:1]};

   `uvm_info("SIPO",$sformatf("RX_SHIFT_REG = %0b",rx_shift_reg),UVM_LOW)
   `uvm_info("SIPO",$sformatf("RX_COUNT_SIPO = %0d", rx_bit_count),UVM_LOW)
   if(rx_bit_count == width) begin
      if(width == 8) begin
         sipo_data = rx_shift_reg[15:8];
         `uvm_info("SIPO",$sformatf("SIPO_DATA_8BIT = %0d", sipo_data),UVM_LOW)
         if((sipo_data == 8'b00000100) && !word_if) begin
            `uvm_info("SIPO","EOP DETECTED IN 8BIT MODE",UVM_LOW)
            eop_detected = 1;
            `uvm_info("SIPO",$sformatf("QUEUE_AFTER_EOP = %p",rx_data_queue),UVM_LOW)
           // rx_shift_reg = 0;
           // rx_bit_count = 0;
         end
         else begin
            rx_data_queue.push_back(sipo_data);
            `uvm_info("SIPO",$sformatf("PARALLEL_DATA_QUEUE = %0p", rx_data_queue),UVM_LOW)
         end
      end
      else begin
         sipo_data_high = rx_shift_reg[15:8];
         sipo_data_low  = rx_shift_reg[7:0];
         `uvm_info("SIPO",$sformatf("SIPO_DATA_HIGH = %0d", sipo_data_high),UVM_LOW)
         `uvm_info("SIPO",$sformatf("SIPO_DATA_LOW  = %0d", sipo_data_low),UVM_LOW)
         //if(sipo_data_high == 8'h7F && word_if) begin
          if(sipo_data_high == 16'b0000_0000_0111_1111 && word_if) begin
            `uvm_info("SIPO","EOP_DETECTED_IN_HIGH_BYTE",UVM_LOW)
             rx_data_queue.push_back(sipo_data_low);
            eop_detected = 1;
            `uvm_info("SIPO",$sformatf("QUEUE_AFTER_EOP = %p",rx_data_queue),UVM_LOW)
         end
         //else if(sipo_data_low == 8'h7F && word_if) begin
          else if(sipo_data_low == 16'b0000_0000_0111_1111 && word_if) begin
          //else if(sipo_data_low == 16'h7F && word_if) begin
            `uvm_info("SIPO","EOP_DETECTED_IN_LOW_BYTE",UVM_LOW)
            rx_data_queue.push_back(sipo_data_high);
            `uvm_info("SIPO",$sformatf("QUEUE_AFTER_HIGH_PUSH = %p",rx_data_queue),UVM_LOW)
            eop_detected = 1;
         end
         else begin
            rx_data_queue.push_back(sipo_data_low);
            rx_data_queue.push_back(sipo_data_high);
            `uvm_info("SIPO",$sformatf("RX_PARALLEL_DATA = %0p", rx_data_queue),UVM_LOW)
         end
      end
      rx_bit_count = 0;
   end
   rx_bit_count++;

endtask*/

