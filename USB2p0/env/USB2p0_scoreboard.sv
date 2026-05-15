class usb2p0_scoreboard extends uvm_scoreboard;
  
   `uvm_component_utils(usb2p0_scoreboard)
  
    USB2p0_sequence_item                                        usb_seq_item;

  function new(string name="usb2p0_scoreboard",uvm_component parent);
    super.new(name,parent);  
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
  

endclass










/*`uvm_analysis_imp_decl(_host_tx)
`uvm_analysis_imp_decl(_host_rx)
`uvm_analysis_imp_decl(_device_tx)
`uvm_analysis_imp_decl(_device_rx)
 
class usb2p0_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(usb2p0_scoreboard)
     
     virtual USB2p0_UTMI_interface       utmi_interface_tx;
     virtual USB2p0_PHY_interface        usb_phy_interface;
     uvm_analysis_imp_host_tx #(USB2p0_sequence_item,usb2p0_scoreboard)   host_tx_analysis_imp;
     uvm_analysis_imp_host_rx #(USB2p0_sequence_item,usb2p0_scoreboard)   host_rx_analysis_imp;
     uvm_analysis_imp_device_tx #(USB2p0_sequence_item,usb2p0_scoreboard) device_tx_analysis_imp;
     uvm_analysis_imp_device_rx #(USB2p0_sequence_item,usb2p0_scoreboard) device_rx_analysis_imp;
     
     USB2p0_sequence_item usb_host_tx_seq_item[$];
     USB2p0_sequence_item usb_host_rx_seq_item[$];
     USB2p0_sequence_item usb_device_tx_seq_item[$];
     USB2p0_sequence_item usb_device_rx_seq_item[$];
   
     uvm_event                           decoder_event;
 
     typedef enum {control_transfer, bulk_transfer, interrupt_transfer, isochronus_transfer} transfer;
//----------------------------------- ENDPOINTS ---------------------------//
//endpoint 0 - control_transfer;
//endpoint 1 - bulk_in_transfer;
//endpoint 2 - bulk_out_transfer;
//endpoint 3 - interrupt_transfer;
//endpoint 4 - isochronous_transfer;

     enum{ep_in, ep_out}endpoint[16];

//--------------------------------------------------------------------------//
 
bit [15:0] phy_16_tx_data[$];
bit [7:0] host_tx_data[$];
 
//--------------------------------------------------------------------------//

//  control_transfer setup_stage, data_stage, status_stage;

//

//  setup stage

//     token_pkt {pid, addr, ep, crc5};   //pid - 1byte, addr - 7bit, endpoint - 4bit, crc - 5bit

//     data_pkt {pid, data[bmreq,breq,wvalue,windex,wlength], crc_16}; //pid - 1byte, bmreq - 1byte,breq - 1byte, wvalue - 2byte, windex - 2byte, wlength - 2byte, crc_16 - 2byte 

//     handshake_pkt {pid[ack,nack,stall]};  // pid - 1byte

//

//  data stage

//     token_pkt {pid, addr, ep, crc5};

//     data_pkt {pid, data(64bytes) , crc_16};

//     handshake_pkt {pid[ack,nack,stall]};

//

//  Status Stage

//     token_pkt {pid, addr, ep, crc5};
   
//     data_pkt {pid, data(0 byte), crc_16};

//     handshake_pkt {pid[ack,nack,stall]};

//      

//---------------------------------------------------------------------------//
 
struct {bit [7:0] token_pkt [2:0]; bit [7:0] data_pkt [10:0]; bit [7:0] hs_pkt;} setup_stage;
struct {bit [7:0] token_pkt [2:0]; bit [7:0] data_pkt [63:0]; bit [7:0] hs_pkt;} data_stage;
struct {bit [7:0] token_pkt [2:0]; bit [7:0] data_pkt;        bit [7:0] hs_pkt;} status_stage;

//struct {byte token_pkt [2:0], byte data_pkt[63:0], byte hs_pkt} setup_stage;
//struct {byte token_pkt [2:0], byte data_pkt[63:0], byte hs_pkt} data_stage;
//struct {byte token_pkt [2:0], bit data_pkt, byte hs_pkt} status_stage;
 
//------------------------------ Transmit State FSM --------------------//

//  Collects UTMI_Tx Data and adding sync and EOP for each packet in each 

//   statge and removes while sending it on UTMI_Rx

//

//  Control transfer

//   setup stage

//     token_pkt {sync,pid, addr, ep, crc5,eop};   //pid - 1byte, addr - 7bit,endpoint - 4bit, crc - 5bit

//     data_pkt {sync,pid, data[bmreq,breq,wvalue,windex,wlength], crc_16,eop}; //pid - 1byte, bmreq - 1byte,breq - 1byte, wvalue - 2byte, windex - 2byte, wlength - 2byte,crc_16 - 2byte

//     handshake_pkt {sync,pid[ack,nack,stall],eop};  // pid - 1byte

//

//   data stage

//     token_pkt {sync,pid, addr, ep, crc5,eop};

//     data_pkt {sync,pid, data(64bytes) , crc_16, eop};

//     handshake_pkt {sync,pid[ack,nack,stall],eop};

//

//   Status Stage

//     token_pkt {sync,pid, addr, ep, crc5,eop};

//     data_pkt {sync,pid, data(0 byte), crc_16,eop};

//     handshake_pkt {sync,pid[ack,nack,stall],eop};

//      

//--------------------------- Transmitter State machine -------------------------//
     typedef enum bit[2:0]{  RESET       =1, 

            		        TX_WAIT     =2, 

                         	SEND_SYNC   =3,  

                         	TX_DATA_LOAD=4, 

                        	TX_DATA_WAIT=5, 

                    		SEND_EOP    =6} tx_state_m;

     tx_state_m     tx_present_state, tx_next_state ;
//-------------------------------------------------------------------------------//
 
//-------------------------- Receiver State machine -----------------------------//

//     Dp/Dm

//     NRZI Decoder

//     Bit Unstuffing

//     SIPO

//---------------------------------------------------------------------------//
 
typedef enum bit [3:0]{ RESET        = 0,

		        RX_WAIT      = 1,

		        STRIP_SYNC   = 2,

		        RX_DATA      = 3,

		        RX_DATA_WAIT = 4,

		        STRIP_EOP    = 5,

		        RX_ERROR     = 6,

		        ABORT1       = 7,

		        ABORT2       = 8,

		        TERMINATE    = 9} rx_state_m ;
 
  rx_state_m  rx_present_state,rx_next_state ;
 
//NEW FUNCTION

function new(string name="usb2p0_scoreboard",uvm_component parent);
 
	super.new(name,parent);
         if(!uvm_config_db#(virtual USB2p0_UTMI_interface)::get(this, "", "USB_UTMI_INTERFACE_TX", utmi_interface_tx))
  		     `uvm_fatal("NOVIF", "USB_UTMI_INTERFACE not found")
  
      	if(!uvm_config_db#(virtual USB2p0_PHY_interface)::get(this, "", "USB_PHY_INTERFACE", usb_phy_interface))
      	  	     `uvm_fatal("NOVIF", "USB_PHY_INTERFACE not found")
        decoder_event = new();
	host_tx_analysis_imp   = new("host_tx_analysis_imp",this);
	host_rx_analysis_imp   = new("host_rx_analysis_imp",this);
	device_tx_analysis_imp = new("device_tx_analysis_imp",this);
	device_rx_analysis_imp = new("device_rx_analysis_imp",this);
      //  tx_present_state = RESET;			

endfunction	
 
function void write_host_tx(USB2p0_sequence_item host_tx_seq_item);
 
    bit [7:0] token_pid, data_pid, hs_pid;

    bit [6:0] token_addr;

    bit [3:0] token_ep;

    bit [4:0] token_crc5;

    bit [511:0] data_payload;

    bit [15:0] data_crc16;

    bit [31:0] token_packet;

    bit [87:0] data_packet;
 
    usb_host_tx_seq_item.push_back(host_tx_seq_item);


    if(usb_host_tx_seq_item.size()>0)begin

    	if(host_tx_seq_item.tx_valid || host_tx_seq_item.tx_validh) begin
     		   //wait(host_tx_seq_item.tx_ready) begin	
		   host_tx_data.push_back(host_tx_seq_item.tx_data[7:0]);
		end
	//end 

        if(host_tx_data.size()>0) begin

           token_pid  = host_tx_data.pop_front();

           token_addr = host_tx_data.pop_front();

           token_ep   = host_tx_data.pop_front();

           token_crc5 = host_tx_data.pop_front();

           data_pid   = host_tx_data.pop_front();

           for(int i=0;i<8;i++) begin

              data_payload = host_tx_data.pop_front();

           end

           for(int i=0;i<2;i++) begin

              data_crc16   = host_tx_data.pop_front();

           end

        end

        token_packet = {token_pid, token_addr, token_ep, token_crc5};

        data_packet  = {data_pid,data_payload, data_crc16};

        `uvm_info("USB2p0_SB",$sformatf("token_packet=%0h, data_packet=%0h",token_packet,data_packet),UVM_LOW) 

      //  host_tx_expected_gen(1,1,1,0,token_pid,token_addr,token_ep,token_crc5,data_pid,data_payload,data_crc16,hs_pid);	
      //  host_tx_expected_gen(host_tx_seq_item.tx_valid,host_tx_seq_item.tx_validh,host_tx_seq_item.tx_ready,host_tx_seq_item.word_if,token_pid,token_addr,token_ep,token_crc5,data_pid,data_payload,data_crc16,hs_pid);	
        //host_tx_expected_gen(usb_host_tx_seq_item.tx_valid,usb_host_tx_seq_item.tx_validh,usb_host_tx_seq_item.tx_ready,usb_host_tx_seq_item.tx_word_if,token_pid,token_addr,token_ep,token_crc5,data_pid,data_payload,data_crc16,hs_pid);	

    end

endfunction
 
task host_tx_expected_gen(bit tx_valid,tx_validh,tx_ready,tx_word_if,bit [7:0]token_pid, bit [6:0]token_addr, bit [3:0]token_ep, bit [4:0]token_crc, bit [7:0]data_pid,bit [511:0]data_payload,bit [15:0]data_crc, bit [7:0]hs_pid);
 

 
     //-------------------------- Transmit State Machine -------------------------------//

     //     PISO

     //     Bit stuffing

     //     NRZI Encoder

     //     Dp/Dm

     //-----------------------------------------------------------------------------//

     typedef enum bit[2:0]{  RESET       =1, 

            		        TX_WAIT     =2, 

                         	SEND_SYNC   =3,  

                         	TX_DATA_LOAD=4, 

                        	TX_DATA_WAIT=5, 

                    		SEND_EOP    =6} tx_state_m;

     tx_state_m     tx_present_state, tx_next_state;
 
    //Expected host_tx gen
 
     //Inputs

     bit reset;

    // bit tx_valid;

     bit tx_hold_reg_empty;

     bit tx_hold_reg_full;

     bit eop_done;

     bit [7:0] tx_data_load[];

     bit [7:0] tx_control_load_data[$];

     // Output

    // bit tx_ready;

     logic [7:0] tx_fifo [9]; //fifo to store the tx_data
     
      `uvm_info("USB2P0_SB","ENTERED_INTO_HOST_TX_EXPECTED_GEN",UVM_LOW)
      `uvm_info("USB2P0_SB",$sformatf("token_pid=%0h \n,token_addr=%0h \n,token_ep =%0h \n,token_crc=%0h \n,data_pid =%0h \n,data_payload =%0h \n,data_crc =%0h \n,hs_pid =%0h \n",token_pid,token_addr,token_ep,token_crc,data_pid,data_payload,data_crc,hs_pid),UVM_LOW)
 
      tx_present_state = RESET;
 
    forever begin
        `uvm_info(get_full_name(),$sformatf("tx_present_state=%s", tx_present_state),UVM_LOW)

      case (tx_present_state)


        RESET:begin

          `uvm_info("TX_FSM", "Entered into RESET State ", UVM_LOW)

	   if(reset == 0 && tx_ready == 1)  begin

	       tx_ready = 0;

	       tx_next_state = TX_WAIT;

	       `uvm_info(get_full_name(),"ENTER INTO TX_WAIT STATE FROM  RESET STATE",UVM_LOW)

	   end

	   else

	      tx_next_state = RESET;

        end
 
        TX_WAIT: begin

          `uvm_info("TX_FSM", "Entered into TX_WAIT State ", UVM_LOW)

           tx_ready = 0;

	   if(tx_valid)begin

	       tx_next_state = SEND_SYNC;

	       `uvm_info(get_full_name(),"ENTER INTO SEND_SYNC FROM TX_WAIT STATE",UVM_LOW)

	    end 

	    else begin

	       tx_next_state = TX_WAIT; 

	      `uvm_info(get_full_name(),"REMAINS SAME IN TX_WAIT STATE",UVM_LOW)

	    end

        end
 
        SEND_SYNC: begin

          `uvm_info("TX_FSM", "Entered into SEND SYNC State ", UVM_LOW)

           send_sync(tx_word_if,tx_valid,tx_validh);

           tx_next_state   = TX_DATA_LOAD;

        end
 
        TX_DATA_LOAD: begin

          `uvm_info("TX_FSM", "Entered into TX_DATA_LOAD State ", UVM_LOW)

          tx_ready =1'b1;

          load_tx_holding_register(token_pid, token_addr, token_ep, token_crc, data_pid, data_payload, data_crc);

          tx_piso(tx_data_load,tx_data_load.size());

          tx_next_state = TX_DATA_WAIT;

        end
 
        TX_DATA_WAIT: begin

          `uvm_info("TX_FSM", " Entered into TX_DATA_WAIT State ", UVM_LOW)

          tx_next_state = SEND_EOP;

        end
 
        SEND_EOP: begin

          `uvm_info("TX_FSM", "Entered into SEND_EOP State ", UVM_LOW)

          tx_next_state = TX_WAIT;

        end
 
      endcase

     end

endtask
 
task load_tx_holding_register(token_pid,token_addr, token_ep, token_crc, data_pid, data_payload, data_crc);


  bit [7:0] tx_buffer[$]; // queue
    $display("[TX_DATA_LOAD] Loading data into TX Holding Register");

endtask
 
task send_sync(bit word_if,valid,validh);
 
      bit [31:0] hs_32bit_sync;

      bit [7:0]  ls_fs_8bit_sync;

      bit [15:0] tx_fifo_sync[$];

      bit [15:0] tx_16bit_piso_data;

      bit [7:0]  tx_8bit_piso_data;

      int        tx_size;

       if(word_if && valid && validh )begin

	     hs_32bit_sync = 32'b10101010_10101010_10101010_10101011;

	     tx_fifo_sync.push_back(hs_32bit_sync[15:0]);

	     tx_fifo_sync.push_back(hs_32bit_sync[31:16]);

	     `uvm_info(get_full_name(),$sformatf("SEND SYNC  HS_SYNC =%b : %0h",hs_32bit_sync,hs_32bit_sync),UVM_LOW)

       end

       else if(!word_if && valid && !validh)begin

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
 
task tx_piso( input bit[15:0]piso_data_in,int size);
 
	bit piso_data_out;
 
	`uvm_info("USB2p0_SB",$sformatf("Entered into TX_PISO Task "),UVM_LOW) 

	`uvm_info("DEBUG",$sformatf("size = %0d",size),UVM_LOW) 

    	@(posedge utmi_interface_tx.utmi_clk);

	for(int i=0;i<size;i++)begin

    	   piso_data_out = piso_data_in[i];

   	   `uvm_info(get_full_name(), $sformatf("TRANSMITTER: PISO - %b size=%0d",piso_data_out,size),UVM_LOW)        

    	   tx_bit_stuffing(piso_data_out);

     	end  

endtask  

task tx_bit_stuffing(input data_in_stuffing);
 

	static bit [2:0] count; //using static keyword it will increment the count. without static inside task by default it will be automatic it will create diff memory each time so count will be re-initialize.

	bit data_out_stuffing;

        if(data_in_stuffing == 1)

           count=count+1;

        else

           count=0;

        if(count == 'd7)begin

           data_out_stuffing = 0;

           count =0;

        end

        else begin

          data_out_stuffing = data_in_stuffing;

          `uvm_info(get_full_name(),$sformatf("BIT STUFFING:data_in_stuffing = %0b, data_out_stuffing = %0b,count=%0d", data_in_stuffing,data_out_stuffing,count),UVM_LOW)

          tx_nrzi_encoder(data_out_stuffing);

        end

endtask 

task tx_nrzi_encoder(input bit nrzi_input);

      static bit nrzi_output;
      int  count_trigger ;
      bit Dp;
 
     `uvm_info("USB2p0_SB",$sformatf("Entered into Tx_bit_stuffing Task "),UVM_LOW)
 
      if(nrzi_input == 0)

        nrzi_output = ~nrzi_output;

      else

        nrzi_output = nrzi_output;      

      `uvm_info(get_full_name(),$sformatf("ENCODER: nrzi_input=%0b,nrzi_output %0b",nrzi_input,nrzi_output),UVM_LOW)

       Dp = nrzi_output;

       @(posedge usb_phy_interface.phy_clk);

         usb_phy_interface.Dp <= Dp;

         usb_phy_interface.Dm <=~Dp;

       @(negedge usb_phy_interface.phy_clk);

       `uvm_info("NRZI_ENCODER",$sformatf("WRITTEN_TO_PHY"),UVM_LOW);

       if(count_trigger>=0)begin 

          `uvm_info("NRZI_ENCODER",$sformatf("EVENT_BEING_TRIGGER"),UVM_LOW);

          decoder_event.trigger(); 

          count_trigger++;     

          `uvm_info("NRZI_ENCODER",$sformatf("EVENT_TRIGGER"),UVM_LOW);

       end

endtask


task eop_generate(bit word_if,valid,validh);
 
   bit [7:0]  hs_eop,fs_ls_eop;

   bit [7:0] tx_fifo_eop[$];

   bit [7:0]  tx_8bit_piso_data;

   int        tx_size;
 
  if(word_if && valid && validh) begin

     hs_eop = 8'b0111_1111;

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

   	 tx_8bit_piso_data = tx_fifo_eop.pop_front();

	 tx_size = 8;

	 tx_piso(tx_8bit_piso_data, tx_size);

       end

       else if(valid && !validh) begin

	  tx_8bit_piso_data = tx_fifo_eop.pop_front();

           tx_size = 8; 

           tx_piso(tx_8bit_piso_data, tx_size);

       end

   end

end

endtask
 
  

function void write_host_rx(USB2p0_sequence_item host_rx_seq_item);

endfunction
 
function void write_device_tx(USB2p0_sequence_item device_tx_seq_item);

endfunction
 
function void write_device_rx(USB2p0_sequence_item device_rx_seq_item);

endfunction
 
     
endclass   */ 
