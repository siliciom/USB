`include "uvm_macros.svh"
import uvm_pkg::*;

class USB2p0_sequence_item extends uvm_sequence_item;
  
    `uvm_object_utils(USB2p0_sequence_item)
    
     typedef enum bit{
                      DEVICE_TO_HOST=1,
                      HOST_TO_DEVICE=0
                     } direction_e;
    
     typedef enum bit [1:0]{
                            STANDARD = 2'b00,
                            CLASS    = 2'b01,
                            VENDOR   = 2'b10,
                            RESERVED = 2'b11
                           } request_type_e;

    typedef enum bit [4:0]{
                           DEVICE_RECIPIENT    = 5'd0,
                           INTERFACE_RECIPIENT = 5'd1,
                           ENDPOINT_RECIPIENT  = 5'd2,
                           OTHER_RECIPIENT     = 5'd3
                          } recipient_e;

    typedef enum bit [7:0]{
   			   GET_STATUS = 8'd0,
   			   CLEAR_FEATURE   = 8'd1,
   			   SET_FEATURE      = 8'd3,
   			   SET_ADDRESS    = 8'd5,
   			   GET_DESCRIPTOR  = 8'd6,
   			   SET_DESCRIPTOR   = 8'd7,
   			   GET_CONFIGURATION = 8'd8,
   			   SET_CONFIGURATION = 8'd9,
   			   GET_INTERFACE   = 8'd10,
   			   SET_INTERFACE  = 8'd11,
   			   SYNCH_FRAME     = 8'd12
                          } bRequest_e;
  
     typedef enum bit [3:0]{
                            PID_IN    = 4'b1001,
                            PID_OUT   = 4'b0001,
                            PID_SETUP = 4'b1101,
                            PID_DATA0 = 4'b0011,
                            PID_DATA1 = 4'b1011,
                            PID_ACK   = 4'b0010,
                            PID_NAK   = 4'b1010,
                            PID_STALL = 4'b1110
                           } pid_e;

     typedef enum{
                  CONTROL_TRANSFER,
                  INTERRUPT_TRANSFER,
                  BULK_TRANSFER,
                  ISO_CHRONOUS_TRANSFER
                  } transfers;
   
     typedef struct {
    		     bit [7:0]  blength;
    		     bit [7:0]  bdescriptors_type;
    		     bit [15:0] bcd_usb;
    		     bit [7:0]  bDevice_class;
    		     bit [7:0]  bDevice_subclass;
    		     bit [7:0]  bDevice_protocol;
    		     bit [7:0]  bMax_packetsize;
    		     bit [15:0] idvendor;
    		     bit [15:0] idproduct;
    		     bit [15:0] bcdDevice;
    		     bit [7:0]  imanufacture;
    		     bit [7:0]  iproduct;
    		     bit [7:0]  iserial_number;
    		     bit [7:0]  bNum_configuration;
                    } device_descriptor_s;
      device_descriptor_s LS;
      device_descriptor_s FS;
      device_descriptor_s HS;

      rand direction_e    direction;
      rand request_type_e request_type;
      rand recipient_e    recipient;
      rand transfers      transfer_type;
      //rand bRequest_e     bRequest; 
      rand pid_e          setup_token_pid, setup_data_pid, handshake_pid_ack,handshake_pid_nack,handshake_pid_stall,data1_pid,token_pid_in, token_pid_out;
      //rand bit [3:0]  setup_data_pid, setup_handshake_pid, data_token_pid,data_data_pid, data_handshake_pid, status_token_pid, status_data_pid, status_handshake_pid, start_of_frame_pid,interrupt_in_pid,interrupt_out_pid;
      //rand bit [3:0]  data_token_pid,data_data_pid,data_stage_pid_in,data_stage_pid_out,status_stage_pid_in,status_stage_pid_out,interrupt_in_pid,interrupt_out_pid;
      rand bit [3:0]   data_data_pid,data_stage_pid_in,data_stage_pid_out,status_stage_pid_in,status_stage_pid_out,interrupt_in_pid,interrupt_out_pid,iso_in_pid,iso_out_pid,bulk_in_pid,bulk_out_pid;
      rand bit [7:0]   bRequest;
      rand bit [7:0]   bmRequestType;
      rand bit [15:0]  wValue;
      rand bit [15:0]  wIndex;
      rand bit [15:0]  wLength; 
      rand bit [6:0]   addr;
      rand bit [3:0]   endp;
           bit [4:0]   crc5;
           bit         wait_chirp_hs; 
      rand bit         tx_valid;
      rand bit         tx_validh;
      rand bit         tx_ready;
           bit [DATA_WIDTH-1:0]  utmi_txdata[$];
           //bit [15:0]  utmi_txdata[$];
          // bit[15:0]   device_mon_rxdata[$];
      rand bit         rx_valid;
      rand bit         rx_validh;
           //bit[15:0]   rx_data[$];
           bit[DATA_WIDTH-1:0]   rx_data[$];
           //bit[DATA_WIDTH-1:0]   mon_rx_data[$];
           //bit[15:0]   mon_rx_data[$];
           bit         rx_active;
           bit         rx_error;
      rand bit [1:0]   op_mode;
      rand bit         suspend_n;
      rand bit         term_select;
      rand bit [1:0]   xcvr_select;
      rand bit         word_if;
      rand bit         fsls_low_power;
      rand bit         fsls_serialmode;
      rand bit         otg_dppulldown;
      rand bit         otg_dmpulldown;
           bit [1:0]   linestate;
           bit         hostdisconnect;
           bit         bvalid;
           bit         vbusvalid;
           bit [15:0]  crc16;
           bit [7:0]  crc_hi;
           bit [7:0]  crc_low;
      rand bit         otg_vbusvalid;
           bit         srp_bvalid;
           bit         ls_device_detected;
           bit         hs_device_detected;
           bit         fs_device_detected;
      rand bit [7:0]  blength;
      rand bit [7:0]  bdescriptors_type;
      rand bit [15:0] bcd_usb;
      rand bit [7:0]  bDevice_class;
      rand bit [7:0]  bDevice_subclass;
      rand bit [7:0]  bDevice_protocol;
      rand bit [7:0]  bMax_packetsize;
      rand bit [15:0] idvendor;
      rand bit [15:0] idproduct;
      rand bit [15:0] bcdDevice;
      rand bit [7:0]  imanufacture;
      rand bit [7:0]  iproduct;
      rand bit [7:0]  iserial_number;
      rand bit [7:0]  bNum_configuration;

      rand bit [7:0] host_payload[];
      rand bit [7:0] device_payload[];
      rand bit [7:0] payload[];
      rand bit [19:0] length;
      speed_state usb_speed;

      constraint op_mode_constraint{ op_mode inside {[0:1]};}

      constraint payload_length_device { length inside {[1:2060]};
                                        device_payload.size() == length;} 
      
      constraint payload_length_host { length inside {[1:2060]};
                                      host_payload.size() == length;} 

                                      
      ////////////////////////////////////////////////////////////////
      constraint usb_control_pid {
                                     setup_token_pid     == PID_SETUP;
                                     setup_data_pid      == PID_DATA0;
                                     handshake_pid_ack   == PID_ACK;
                                     handshake_pid_nack  == PID_NAK;
                                     handshake_pid_stall == PID_STALL;
                                     token_pid_in        == PID_IN; 
                                     token_pid_out       == PID_OUT;
                                     data1_pid           == PID_DATA1;
                                  }
 
       /*constraint usb_standard_req_c {
                                      bmRequestType inside {8'b00000000, 8'b00000001, 8'b00000010,8'b10000000, 8'b10000001,8'b10000010};
                                     if(bmRequestType == 8'b00000000) {
                                       bRequest inside {SET_ADDRESS,SET_CONFIGURATION,SET_DESCRIPTOR,CLEAR_FEATURE,SET_FEATURE};
    // SET_ADDRESS
                                     if (bRequest == SET_ADDRESS) {
                                         wValue[6:0] inside {[1:127]};
                                         wValue[15:7] == 0;
                                         wIndex == 0;
                                         wLength == 0;
                                        }

    // SET_CONFIGURATION
                                     else if (bRequest == SET_CONFIGURATION) {
                                              wValue inside {[1:5]};
                                              wIndex == 0;
                                              wLength == 0;
                                              }

    // SET_DESCRIPTOR
                                     else if (bRequest == SET_DESCRIPTOR) {
                                     wValue[15:8] inside {8'h01,8'h02,8'h03};
                                     wValue[7:0]  inside {[0:3]};
                                     wIndex inside {16'h0000,16'h0409};
                                     wLength > 0;
                                     }

    // CLEAR_FEATURE / SET_FEATURE
                                    else if (bRequest inside {CLEAR_FEATURE, SET_FEATURE}) {
                                    wValue inside {16'h0000,16'h0001};
                                    wIndex == 0;
                                    wLength == 0;
                                    }
                                   }
                                   else if (bmRequestType == 8'b00000001) {
                                   bRequest inside {SET_INTERFACE,CLEAR_FEATURE,SET_FEATURE};
    // SET_INTERFACE
                                  if (bRequest == SET_INTERFACE) {
                                  wValue inside {[0:3]};
                                  wIndex inside {[0:3]};
                                  wLength == 0;
                                  }

    // CLEAR_FEATURE / SET_FEATURE
                                  else if (bRequest inside {CLEAR_FEATURE, SET_FEATURE}) {
                                  wValue inside {16'h0000,16'h0001};
                                  wIndex inside {[0:15]};
                                  wLength == 0;
                                  }
                                 }
                                 else if (bmRequestType == 8'b00000010) {
                                 bRequest inside {CLEAR_FEATURE, SET_FEATURE};
                                 wValue inside {16'h0000,16'h0001};
                                 wIndex inside {[0:15]};
                                 wLength == 0;
                                 }
                                else if (bmRequestType == 8'b10000000) {
                                bRequest inside {
                                GET_STATUS,
                                GET_DESCRIPTOR,
                                GET_CONFIGURATION
                                };
    // GET_STATUS
                               if (bRequest == GET_STATUS) {
                               wValue == 0;
                               wIndex == 0;
                               wLength == 2;
                               }
    // GET_DESCRIPTOR
                               else if (bRequest == GET_DESCRIPTOR) {
                               wValue[15:8] inside {8'h01,8'h02,8'h03};
                               wValue[7:0]  inside {[0:3]};
                               wIndex inside {16'h0000,16'h0409};
                               wLength > 0;
                               }

    // GET_CONFIGURATION
                               else if (bRequest == GET_CONFIGURATION) {
                               wValue == 0;
                               wIndex == 0;
                               wLength == 1;
                               }
                              }
                              else if (bmRequestType == 8'b10000001) {
                              bRequest inside {GET_STATUS, GET_INTERFACE};
    // GET_STATUS
                             if (bRequest == GET_STATUS) {
                             wValue == 0;
                             wIndex inside {[0:15]};
                             wLength == 2;
                             }

    // GET_INTERFACE
                            else if (bRequest == GET_INTERFACE) {
                            wValue == 0;
                            wIndex inside {[0:3]};
                            wLength == 1;
                            }
                            }
                            else if (bmRequestType == 8'b10000010) {
                            bRequest inside {GET_STATUS, SYNCH_FRAME};
                          // GET_STATUS
                            if (bRequest == GET_STATUS) {
                            wValue == 0;
                            wIndex inside {[0:15]};
                            wLength == 2;
                            }
                      
                          // SYNCH_FRAME
                            else if (bRequest == SYNCH_FRAME) {
                            wValue == 0;
                            wIndex inside {[0:15]};
                            wLength == 2;
                            }
                            }
                            }  */
                       
                      


      ////////////////////////////////////////////////////////////////
      //constraint token_pid {
                          
      //constraint data_pid 

      // constraint handshake_pid
 
     // constraint brequest

     // constraint bmrequest
  
       function new(string name="USB2p0_sequence_item");
              super.new(name);
       endfunction
        
    function void do_print(uvm_printer printer);
  	 super.do_print(printer);
  	       printer.print_field("vbusvalid",       vbusvalid,       1,  UVM_DEC);	//initial power
  	       printer.print_field("hostdisconnect",  hostdisconnect,  1,  UVM_DEC);	
  	       printer.print_field("otg_dppulldown",  otg_dppulldown,  1,  UVM_DEC);	//dp
  	       printer.print_field("otg_dmpulldown",  otg_dmpulldown,  1,  UVM_DEC);	//dm
  	       printer.print_field("otg_vbusvalid",   otg_vbusvalid,   1,  UVM_DEC);	//vbus_valid interface signal
  	       printer.print_field("srp_bvalid",      srp_bvalid,      1,  UVM_DEC);	//vbus connected 
  	       printer.print_field("linestate",       linestate,       2,  UVM_DEC);	//00 : SE0 (IDLE), 01 : J state, 10 : kstate, 11 - SE1(reserved)
  	       printer.print_field("op_mode",         op_mode,         2,  UVM_DEC);	//00 - should be 00 , 01 : stop, suspend
  	       printer.print_field("term_select",     term_select,     1,  UVM_DEC);	// 1 - FS, 0 - HS
  	       printer.print_field("xcvr_select",     xcvr_select,     2,  UVM_DEC);	// 1 - FS, 0 - HS, 2 - LS
  	       printer.print_field("tx_valid",        tx_valid,        1,  UVM_DEC);	// 1/0
	       printer.print_field("tx_validh",       tx_validh,       1,  UVM_DEC);	// 1/0
  	       printer.print_field("word_if",         word_if,         1,  UVM_DEC);	// 1 -16bit phy intf, 0 - 8bit phy intf
  	       printer.print_field("tx_ready",        tx_ready,        1,  UVM_DEC);    //asserted by phy
  	       printer.print_field("setup_token_pid", setup_token_pid, 4,  UVM_HEX);    
  	       printer.print_field("addr",            addr,            7,  UVM_HEX);
  	       printer.print_field("endp",            endp,            4,  UVM_HEX);
  	       printer.print_field("crc5",            crc5,            5,  UVM_HEX);
  	       printer.print_field("setup_data_pid",  setup_data_pid,  4,  UVM_HEX);    
  	       printer.print_field("bmRequestType",   bmRequestType,   8,  UVM_HEX);
  	       printer.print_field("bRequest",        bRequest,        8,  UVM_HEX);    
  	       printer.print_field("wValue",          wValue,         16,  UVM_HEX);
  	       printer.print_field("wIndex",          wIndex,         16,  UVM_HEX);
  	       printer.print_field("wLength",         wLength,        16,  UVM_HEX);
  	       printer.print_field("crc16",           crc16,          16,  UVM_HEX);
  	       printer.print_field("data_stage_pid_in",data_stage_pid_in, 4,  UVM_HEX);
  	       printer.print_field("status_stage_pid_in",status_stage_pid_in, 4,  UVM_HEX);
  	       printer.print_field("tx_data_size",    utmi_txdata.size(), 16, UVM_HEX); 
               foreach (utmi_txdata[i]) begin
  	         printer.print_field($sformatf("tx_data[%0d]", i), utmi_txdata[i], 16, UVM_HEX);
  	       end
  	       printer.print_field("rx_valid",        rx_valid,        1,  UVM_HEX);
  	       printer.print_field("rx_validh",       rx_validh,       1,  UVM_HEX);
  	       printer.print_field("rx_active",       rx_active,       1,  UVM_HEX);	//assrted by phy
  	       printer.print_field("rx_data_size",    rx_data.size(),  16, UVM_HEX); 
  	       foreach (rx_data[i]) begin
  	        printer.print_field($sformatf("rx_data[%0d]", i), rx_data[i], 16, UVM_HEX);
  	       end
	         	       printer.print_field("blength",           blength,            8, UVM_HEX); 
  	       printer.print_field("bdescriptors_type", bdescriptors_type,  8, UVM_HEX); 
  	       printer.print_field("bcd_usb",           bcd_usb,            16, UVM_HEX); 
  	       printer.print_field("bDevice_class",     bDevice_class,      8, UVM_HEX); 
  	       printer.print_field("bDevice_subclass",  bDevice_subclass,   8, UVM_HEX); 
  	       printer.print_field("bDevice_protocol",  bDevice_protocol,   8, UVM_HEX); 
  	       printer.print_field("bMax_packetsize",   bMax_packetsize,    16, UVM_HEX); 
  	       printer.print_field("idvendor",          idvendor,           16, UVM_HEX); 
  	       printer.print_field("idproduct",         idproduct,          16, UVM_HEX); 
  	       printer.print_field("bcdDevice",         bcdDevice,          16, UVM_HEX); 
  	       printer.print_field("imanufacture",      imanufacture,       8, UVM_HEX); 
  	       printer.print_field("iserial_number",    iserial_number,     8, UVM_HEX); 
  	       printer.print_field("bNum_configuration",bNum_configuration, 8, UVM_HEX);

    endfunction
 
       
    constraint payload_size_by_type {
                                    if (transfer_type == CONTROL_TRANSFER || transfer_type == INTERRUPT_TRANSFER)
                                       payload.size() inside {[1:64]};
                                    else if (transfer_type == BULK_TRANSFER)
                                       payload.size() inside {[1:512]};
                                    else if (transfer_type == ISO_CHRONOUS_TRANSFER)
                                       payload.size() inside {[1:1024]};
                                    }  
endclass




