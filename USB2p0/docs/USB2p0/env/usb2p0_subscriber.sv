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

   /* function bit [4:0] calc_crc5(bit [6:0] addr, bit [3:0] endp);
       bit [10:0] token_bits;
       bit [4:0] crc;
       bit din;
       int i;

       token_bits = {addr, endp};   // ADDR + ENDP (correct order)
       crc = 5'b11111;
       for (i = 10; i >= 0; i--) begin
         din = token_bits[i] ^ crc[4];
         crc = {crc[3:0], 1'b0};
         if (din)
           crc ^= 5'b00101;
       end
       return ~crc;
    endfunction*/
      


   /* covergroup usb_pid_cg;
               cp_setup_token: coverpoint usb_seq_item.setup_token_pid {
                                                                        bins setup = {PID_SETUP};
                                                                        ignore_bins others = default;
                                                                       }

               cp_setup_data: coverpoint usb_seq_item.setup_data_pid {
                                                                       bins data0 = {PID_DATA0};
                                                                       ignore_bins others = default;
                                                                      }

               cp_setup_handshake: coverpoint usb_seq_item.setup_handshake_pid {
                                                                                bins handshake[] = {PID_ACK};
                                                                                ignore_bins others = default;
                                                                               }

               cp_data_token: coverpoint usb_seq_item.data_token_pid {
                                                                      bins in_out[] = {PID_IN, PID_OUT};
                                                                      ignore_bins others = default;
                                                                     }

               cp_data_data: coverpoint usb_seq_item.data_data_pid {
                                                                    bins data0 = {PID_DATA0,PID_DATA1};
                                                                    ignore_bins others = default;
                                                                   }

               cp_data_handshake: coverpoint usb_seq_item.data_handshake_pid {
                                                                              bins handshake[] = {PID_ACK};
                                                                              ignore_bins others = default;
                                                                             }

              cp_status_token: coverpoint usb_seq_item.status_token_pid {
                                                                         bins in_out[] = {PID_IN, PID_OUT};
                                                                         ignore_bins others = default;
                                                                        }

              cp_status_handshake: coverpoint usb_seq_item.status_handshake_pid {
                                                                                 bins ack = {PID_ACK};
                                                                                 ignore_bins others = default;
                                                                                }

              cross_setup_packet : cross cp_setup_token, cp_setup_data, cp_setup_handshake;
              cross_data_packet  : cross cp_data_token,  cp_data_data,  cp_data_handshake;
              cross_status_packet: cross cp_status_token,cp_status_handshake;

               cp_addr: coverpoint usb_seq_item.addr{
                                                     bins addr0 = {0};
                                                     ignore_bins others = default;
                                                     }

               cp_endp: coverpoint usb_seq_item.endp{
                                                     bins endp0 = {0};
                                                     ignore_bins others = default;
                                                     }

               cp_direction: coverpoint usb_seq_item.direction {
                                                                bins host_to_dev = {0};
                                                                bins dev_to_host = {1};
                                                               }

               cp_type: coverpoint usb_seq_item.request_type {
                                                              bins standard = {0};
                                                              bins class    = {1};
                                                              bins vendor   = {2};
                                                             }

              cp_recipient: coverpoint usb_seq_item.recipient {
                                                               bins device    = {0};
                                                               bins interface = {1};
                                                               bins endpoint  = {2};
                                                               bins other     = {3};
                                                              }

               cp_brequest: coverpoint usb_seq_item.bRequest {
                                                              bins get_status        = {8'h00};
                                                              bins clear_feature     = {8'h01};
                                                              bins set_feature       = {8'h03};
                                                              bins set_address       = {8'h05};
                                                              bins get_descriptor    = {8'h06};
                                                              bins set_descriptor    = {8'h07};
                                                              bins get_config        = {8'h08};
                                                              bins set_config        = {8'h09};
                                                              bins get_interface     = {8'h0A};
                                                              bins set_interface     = {8'h0B};
                                                              bins synch_frame       = {8'h0C};
                                                              ignore_bins others = default;
                                                             }
     endgroup*/

endclass




    
