class usb2p0_subscriber extends uvm_subscriber#(USB2p0_sequence_item);
  `uvm_component_utils(usb2p0_subscriber)

     USB2p0_sequence_item usb_seq_item;

     bit [DATA_WIDTH-1:0] pidsample_host_tx;
     bit [DATA_WIDTH-1:0] pidsample_host_rx;
     bit [DATA_WIDTH-1:0] pidsample_device_tx;
     bit [DATA_WIDTH-1:0] pidsample_device_rx;
     bit [7:0] bmRequestType_sample;
 
     bit [7:0]brequest_sample;
     bit [15:0] wValue_sample;
     bit [15:0] wIndex_sample;
     bit  [15:0] wLength_sample;
 
  covergroup usb_pid_cg;
     USB_PID_CP : coverpoint pidsample_host_tx {
                               bins setup_pid_htx = {8'hD2};
                               bins data0_pid_htx = {8'h3C};
                               bins ack_pid_htx   = {8'h2D};
                               bins in           = {8'h96};
                               bins out          = {8'h1E};
                               bins data1        = {8'hB4};
                              
                              }
 
     USB_ADDR_CP: coverpoint usb_seq_item.addr{
                                                bins device_addr0 = {0};
                                                ignore_bins others = {[0:127]} with (item != 0);                                                                                                             }
 
     USB_ENDPOINT_CP : coverpoint usb_seq_item.endp {
                     				 bins control_ep        = {0};
						 bins bulk_in_ep        = {1};
					         bins bulk_out_ep       = {2};
						 bins interrupt_in_ep   = {3};
						 bins interrupt_out_ep  = {5};
						 bins iso_in_ep         = {6};
						 bins iso_out_ep        = {7};
                                                 ignore_bins others = {[8:15]}; 
                                                                               }

     USB_BREQUEST_CP: coverpoint usb_seq_item.bRequest {
                                                    bins get_status        = {8'h00};
                                                    bins clear_feature     = {8'h01};
                                                    bins set_feature       = {8'h03};
                                                    bins set_address       = {8'h05};
                                                    bins get_descriptor    = {8'h06};
                                                    bins get_config        = {8'h08};
                                                    bins set_config        = {8'h09};
                                                    bins get_interface     = {8'h0A};
                                                    bins set_interface     = {8'h0B};
                                                    ignore_bins others = {[0:255]} with (!(item inside {
        8'h00,8'h01,8'h03,8'h05,8'h06,8'h07,8'h08,8'h09,8'h0A,8'h0B }));                                                         
                                                      }
 
     USB_BMREQUESTTYPE_CP : coverpoint  usb_seq_item.bmRequestType {
                                                                 bins std_out_device = {8'h00};
                                                                 bins std_device =     {8'h01};
                                                                 bins std_in_device  = {8'h80};
                                                             ignore_bins others = {[0:255]} with (!(item inside {8'h00,8'h01,8'h80,8'h81}));
                                                                                       }
 
     USB_WVALUE_CP : coverpoint usb_seq_item.wValue { 
                                                     bins zero = {16'h0000};
                                                     bins one  = {16'h0001};
                                                    ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0001}));                                                             
                                                               }
 
     USB_WINDEX_CP : coverpoint usb_seq_item.wIndex {
                                                    bins wzero = {16'h0000};
                                                    bins wone  = {16'h0001};
                                                    bins val_81 = {16'h0081};  
                                                   ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0001,16'h0081}));                                                   
                                                                   }
 
     USB_WLENGTH_CP : coverpoint  usb_seq_item.wLength {
                                                      bins zero = {16'h0000};
                                                      bins two  = {16'h0002};
                                                      bins desc = {16'h0012};
                                                      ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0002,16'h0012}));                                                       
                                                      }
 
 
     USB_BLENGTH_CP : coverpoint usb_seq_item.blength {
                                                        bins device_len = {8'h12};
                                                       ignore_bins others = {[0:255]} with (item != 8'h12);
                                                      }
 
     USB_DESC_TYPE_CP : coverpoint usb_seq_item.bdescriptors_type {
                                                               bins device_desc = {8'h01};
                                                                ignore_bins others = {[0:255]} with (item != 8'h01);  
                                                                                               }
 
     USB_BCD_USB_CP : coverpoint usb_seq_item.bcd_usb {
                                                      bins usb_1 = {16'h0110};
                                                     ignore_bins others = {[0:65535]} with (item != 16'h0110); 
                                                                                                        }
 
     USB_DEVICE_CLASS_CP : coverpoint usb_seq_item.bDevice_class {
                                                               bins bdeviceclass = {8'h00};
                                                              ignore_bins others = {[0:255]} with (item != 8'h00);
                                                                                                         }
 
     USB_DEVICE_SUBCLASS_CP : coverpoint usb_seq_item.bDevice_subclass {
                                                           bins subclass = {8'h00};
                                                         ignore_bins others = {[0:255]} with (item != 8'h00);  
                                                                                                       }
 
        
     USB_DEVICE_PROTOCOL_CP : coverpoint usb_seq_item.bDevice_protocol {
                                                             bins protocol = {8'h00};
                                                         ignore_bins others = {[0:255]} with (item != 8'h00);  
                                                                                                      }
 
     USB_MAX_PACKET_CP : coverpoint usb_seq_item.bMax_packetsize {
                                                          bins packetsize = {8'h40};
                                                          ignore_bins others = {[0:255]} with (item != 8'h40);
                                                            }
     USB_VENDOR_ID_CP : coverpoint usb_seq_item.idvendor {
                                                     bins vendor_781 = {16'h0781};
                                                         ignore_bins others = {[0:65535]} with (item != 16'h0781); 
                                                                                                  }
     USB_PRODUCT_ID_CP : coverpoint usb_seq_item.idproduct {
                                                      bins product_5567 = {16'h5567};
                                                     ignore_bins others = {[0:65535]} with (item != 16'h5567); 
                                                                                                 }
 
     USB_DEVICE_BCD_CP : coverpoint usb_seq_item.bcdDevice {
                                                        bins dev_ver = {16'h0126};
                                                         ignore_bins others = {[0:65535]} with (item != 16'h0126);                                                                                                 }
 
     USB_MANUF_STR_CP : coverpoint usb_seq_item.imanufacture {
                                                         bins mfg = {8'h01};
                                                      ignore_bins others = {[0:255]} with (item != 8'h01);
                                                      }
 
     USB_PROD_STR_CP : coverpoint usb_seq_item.iproduct {
                                                 bins product = {8'h02};
                                                ignore_bins others = {[0:255]} with (item != 8'h02);
                                                  }
 
     USB_NUM_CONFIG_CP : coverpoint usb_seq_item.bNum_configuration {
                                                          bins cfg = {8'h01};
                                                         ignore_bins others = {[0:255]} with (item != 8'h01);  
                                                                                                      }
   
     USB_TX_VALID_CP  : coverpoint usb_seq_item.tx_valid;
     USB_TX_VALIDH_CP : coverpoint usb_seq_item.tx_validh;
     USB_RX_VALID_CP  : coverpoint usb_seq_item.rx_valid;
     USB_RX_VALIDH_CP : coverpoint usb_seq_item.rx_validh;
     USB_WORD_IF_CP   : coverpoint  usb_seq_item.word_if;
 
     USB_OP_MODE_CP : coverpoint usb_seq_item.op_mode {
                                                 bins hs_only = {2'b00};
                                                ignore_bins others = {[0:3]} with (item != 2'b00);
                                                   }

     USB_TERM_SELECT_CP : coverpoint usb_seq_item.term_select;
     USB_XCVR_SELECT_CP : coverpoint usb_seq_item.xcvr_select;
     USB_SUSPEND_N_CP : coverpoint usb_seq_item.suspend_n;
     USB_FSLS_SERIALMODE_CP : coverpoint usb_seq_item.fsls_serialmode;
     USB_FSLS_LOW_POWER_CP : coverpoint usb_seq_item.fsls_low_power;
     USB_OTG_DPPULLDOWN_CP : coverpoint usb_seq_item.otg_dppulldown;
     USB_OTG_DMPULLDOWN_CP : coverpoint usb_seq_item.otg_dmpulldown;
 
     USB_UTMI_VALID_CROSS_CP : cross TX_VALID, RX_VALID;
 endgroup


  function new(string name="usb2p0_subscriber",uvm_component parent);
    super.new(name,parent); 
    usb_pid_cg = new();
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction
 
 
  virtual function void write(USB2p0_sequence_item t);
 
      usb_seq_item = t;
     `uvm_info("SUBSCRIBER_ENTERED_FUNCTION","SUBSCRIBER", UVM_LOW)
     `uvm_info("SUB_DEBUG",$sformatf("bRequest=%0h bmReq=%0h,wvalue=%h,windex=%h,wlength=%h", brequest_sample,bmRequestType_sample,wValue_sample,wIndex_sample,wLength_sample),UVM_LOW)
      brequest_sample      = t.bRequest;
      bmRequestType_sample = t.bmRequestType;
      wValue_sample        = t.wValue;
      wIndex_sample         =t.wIndex; 
      wLength_sample        =t.wLength;
    `uvm_info("SUB_DEBUG",$sformatf("bRequest=%0h bmReq=%0h,wvalue=%h,windex=%h,wlength=%h",brequest_sample,bmRequestType_sample,wValue_sample,wIndex_sample,wLength_sample),UVM_LOW)
 
   case(usb_seq_item.mon_type)
     USB2p0_sequence_item::HOST_TX: begin
         foreach(usb_seq_item.utmi_txdata[i]) begin
            pidsample_host_tx = usb_seq_item.utmi_txdata[i];
            `uvm_info("HOST_TX_PID",$sformatf("HOST_TX PID = %0h", pidsample_host_tx),UVM_LOW)
             usb_pid_cg.sample();
         end
      end
 
      USB2p0_sequence_item::HOST_RX: begin
         foreach(usb_seq_item.rx_data[i]) begin
         pidsample_host_rx = usb_seq_item.rx_data[i];
        `uvm_info("SUBSCRIBER HOST_RX_PID",$sformatf("HOST_RX PID = %0h", pidsample_host_rx),UVM_LOW)
         usb_pid_cg.sample();
         end
      end
 
      USB2p0_sequence_item::DEVICE_TX: begin
       foreach(usb_seq_item.utmi_txdata[i]) begin
       pidsample_device_tx = usb_seq_item.utmi_txdata[i];
       `uvm_info(" SUBSCRIBER DEVICE_TX_PID",$sformatf("DEVICE_TX PID = %0h", pidsample_device_tx),UVM_LOW)
       usb_pid_cg.sample();
         end
      end
 
      USB2p0_sequence_item::DEVICE_RX: begin
         foreach(usb_seq_item.rx_data[i]) begin
            pidsample_device_rx = usb_seq_item.rx_data[i];
            `uvm_info(" SUBSCRIBER DEVICE_RX_PID",$sformatf("DEVICE_RX PID = %0h", pidsample_device_rx),UVM_LOW)
            usb_pid_cg.sample();
         end
      end
    endcase
 endfunction
   
endclass


    
