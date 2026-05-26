class usb2p0_subscriber extends uvm_subscriber#(USB2p0_sequence_item);
  
  `uvm_component_utils(usb2p0_subscriber)
  
    USB2p0_sequence_item usb_seq_item;
     bit [DATA_WIDTH-1:0] pidsample_host_tx;
     bit [DATA_WIDTH-1:0] pidsample_host_rx;
     bit [DATA_WIDTH-1:0] pidsample_device_tx;
     bit [DATA_WIDTH-1:0] pidsample_device_rx;
     bit [7:0] bmRequestType_sample;

     bit [7:0]brequest_sample;
     bit  [15:0] wValue_sample;
     bit [15:0] wIndex_sample;
     bit  [15:0] wLength_sample;

     covergroup usb_pid_cg;
     USB_PID_CP_HOST_TX : coverpoint pids {
                               bins setup_pid_htx = {8'hD2};
                               bins data0_pid_htx = {8'h3C};
                               bins ack_pid_htx   = {8'h2D};
                               bins in           = {8'h96};
                               bins out          = {8'h1E};
                               bins data1        = {8'hB4};
                              }

  /* USB_PID_CP_HOST_RX: coverpoint pidsample_host_rx {
                               bins data1_pid_hrx = {8'hB4};
                               bins ack_pid_hrx   = {8'h2D};
                                }
   USB_PID_CP_DEVICE_TX : coverpoint pidsample_device_tx {
                               bins data1_pid_dtx = {8'hB4};
                               bins ack_pid_dtx   = {8'h2D};
                                                     }

   USB_PID_CP_DEVICE_RX : coverpoint pidsample_device_rx {
                               bins setup_pid_drx = {8'hD2};
                               bins data0_pid_drx = {8'h3C};
                               bins ack_pid_drx   = {8'h2D};
                               bins ind   = {8'h96};
                               bins outd   = {8'h1E};
                               bins data1d   = {8'hB4};
                                }  */
      	
   
           ADDR: coverpoint usb_seq_item.addr{
                                                bins device_addr0 = {0};
                                                ignore_bins others = {[0:127]} with (item != 0);                                                                                                             }

       	DIRECTION: coverpoint usb_seq_item.direction {
                                                        bins host_to_dev = {0};
                                                        bins dev_to_host = {1};
                                                                    }
       ENDPOINT : coverpoint usb_seq_item.endp {
                     				 bins control_ep        = {0};
						 bins bulk_in_ep        = {1};
					         bins bulk_out_ep       = {2};
						 bins interrupt_in_ep   = {3};
						 bins interrupt_out_ep  = {5};
						 bins iso_in_ep         = {6};
						 bins iso_out_ep        = {7};
                                               ignore_bins others = {[8:15]}; 
                                                                               }
                                                      
 
     BREQUEST: coverpoint usb_seq_item.bRequest {
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

             BMREQUESTTYPE : coverpoint  usb_seq_item.bmRequestType {
                                                                 bins std_out_device = {8'h00};
                                                                 bins std_device =     {8'h01};
                                                                 bins std_in_device  = {8'h80};
                                                                                                                                                                                    ignore_bins others = {[0:255]} with (!(item inside {8'h00,8'h01,8'h80,8'h81}));
                                                                                       }

	  WVALUE : coverpoint usb_seq_item.wValue { 
                                                     bins zero = {16'h0000};
                                                     bins one  = {16'h0001};
                                                    ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0001}));                                                             
                                                               }

          WINDEX : coverpoint usb_seq_item.wIndex {
                                                    bins wzero = {16'h0000};
                                                    bins wone  = {16'h0001};
                                                    bins val_81 = {16'h0081};  
                                                   ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0001,16'h0081}));                                                   
                                                                   }

          WLENGTH : coverpoint  usb_seq_item.wLength {
                                                      bins zero = {16'h0000};
                                                      bins two  = {16'h0002};
                                                      bins desc = {16'h0012};
                                                      ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0002,16'h0012}));                                                       
                                                      }



           BLENGTH : coverpoint usb_seq_item.blength {
                                                        bins device_len = {8'h12};
                                                     //   ignore_bins others = {[0:255]} with (item != 8'h12);
                                                      }

           DESC_TYPE : coverpoint usb_seq_item.bdescriptors_type {
                                                               bins device_desc = {8'h01};
                                                            //    ignore_bins others = {[0:255]} with (item != 8'h01);  
                                                                                               }

           BCD_USB : coverpoint usb_seq_item.bcd_usb {
                                                      bins usb_1 = {16'h0110};
                                                    //  ignore_bins others = {[0:65535]} with (item != 16'h0110); 
                                                                                                        }

           DEVICE_CLASS : coverpoint usb_seq_item.bDevice_class {
                                                               bins bdeviceclass = {8'h00};
                                                             // ignore_bins others = {[0:255]} with (item != 8'h00);
                                                                                                         }

          DEVICE_SUBCLASS : coverpoint usb_seq_item.bDevice_subclass {
                                                           bins subclass = {8'h00};
                                                       //  ignore_bins others = {[0:255]} with (item != 8'h00);  
                                                                                                       }

        
          DEVICE_PROTOCOL : coverpoint usb_seq_item.bDevice_protocol {
                                                             bins protocol = {8'h00};
                                                        //  ignore_bins others = {[0:255]} with (item != 8'h00);  
                                                                                                      }

          MAX_PACKET : coverpoint usb_seq_item.bMax_packetsize {
                                                          bins packetsize = {8'h40};
                                                         // ignore_bins others = {[0:255]} with (item != 8'h40);
                                                            }
          VENDOR_ID : coverpoint usb_seq_item.idvendor {
                                                     bins vendor_781 = {16'h0781};
                                                         //ignore_bins others = {[0:65535]} with (item != 16'h0781); 
                                                                                                  }
          PRODUCT_ID : coverpoint usb_seq_item.idproduct {
                                                      bins product_5567 = {16'h5567};
                                                    // ignore_bins others = {[0:65535]} with (item != 16'h5567); 
                                                                                                 }

         DEVICE_BCD : coverpoint usb_seq_item.bcdDevice {
                                                        bins dev_ver = {16'h0126};
                                                         ignore_bins others = {[0:65535]} with (item != 16'h0126);                                                                                                 }

        MANUF_STR : coverpoint usb_seq_item.imanufacture {
                                                         bins mfg = {8'h01};
                                                     // ignore_bins others = {[0:255]} with (item != 8'h01);
                                                      }

         PROD_STR : coverpoint usb_seq_item.iproduct {
                                                 bins product = {8'h02};
                                               // ignore_bins others = {[0:255]} with (item != 8'h02);
                                                  }

	SERIAL_STR : coverpoint usb_seq_item.iserial_number {
                                                           bins serial = {8'h03};
                                                         // ignore_bins others = {[0:255]} with (item != 8'h03);   
                                                                                                  }

       NUM_CONFIG : coverpoint usb_seq_item.bNum_configuration {
                                                          bins cfg = {8'h01};
                                                        // ignore_bins others = {[0:255]} with (item != 8'h01);  
                                                                                                        }


       

    
          // DEVICE_CROSS : cross DESC_TYPE, BCD_USB, VENDOR_ID;

   
         TX_VALID  : coverpoint usb_seq_item.tx_valid;
         TX_VALIDH : coverpoint usb_seq_item.tx_validh;
  
         RX_VALID  : coverpoint usb_seq_item.rx_valid;
         RX_VALIDH : coverpoint usb_seq_item.rx_validh;
         WORD_IF   : coverpoint  usb_seq_item.word_if;

         OP_MODE : coverpoint usb_seq_item.op_mode {
                                                 bins hs_only = {2'b00};
                                                ignore_bins others = {[0:3]} with (item != 2'b00);
                                                   }
        TERM_SELECT : coverpoint usb_seq_item.term_select;
                                                          
        XCVR_SELECT : coverpoint usb_seq_item.xcvr_select;
    
        SUSPEND_N : coverpoint usb_seq_item.suspend_n;
    
       FSLS_SERIALMODE : coverpoint usb_seq_item.fsls_serialmode;
       FSLS_LOW_POWER : coverpoint usb_seq_item.fsls_low_power;
       OTG_DPPULLDOWN : coverpoint usb_seq_item.otg_dppulldown;
       OTG_DMPULLDOWN : coverpoint usb_seq_item.otg_dmpulldown;

       UTMI_VALID_CROSS : cross TX_VALID, RX_VALID;
       endgroup
  
  function new(string name="usb2p0_subscriber",uvm_component parent);
    super.new(name,parent); 
   usb_pid_cg = new();
   //brequest_cg=new();
   endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


virtual function void write(USB2p0_sequence_item t);

   usb_seq_item = t;
  `uvm_info("SUBSCRIBER_ENTERED_FUNCTION","SUBSCRIBER", UVM_LOW)
  `uvm_info("SUB_DEBUG",$sformatf("bRequest=%0h bmReq=%0h,wvalue=%h,windex=%h,wlength=%h", brequest_sample,bmRequestType_sample,wValue_sample,                            wIndex_sample,wLength_sample),UVM_LOW)

      brequest_sample      = t.bRequest;
      bmRequestType_sample = t.bmRequestType;
      wValue_sample        = t.wValue;
      wIndex_sample         =t.wIndex; 
      wLength_sample        =t.wLength;
    `uvm_info("SUB_DEBUG",$sformatf("bRequest=%0h bmReq=%0h,wvalue=%h,windex=%h,wlength=%h",brequest_sample,bmRequestType_sample,wValue_sample,                wIndex_sample,wLength_sample),UVM_LOW)

   case(usb_seq_item.mon_type)

     USB2p0_sequence_item::HOST_TX: begin

         foreach(usb_seq_item.utmi_txdata[i]) begin

            pids = usb_seq_item.utmi_txdata[i];

            `uvm_info("HOST_TX_PID",
               $sformatf("HOST_TX PID = %0h", pidsample_host_tx),
             UVM_LOW)

            usb_pid_cg.sample();
/*`ifdef UTMI_16BIT

   // LOW BYTE
   pidsample_host_tx = usb_seq_item.utmi_txdata[i][7:0];

   `uvm_info("SUBSCRIBER HOST_TX_DEBUG",
      $sformatf("SUBSCRIBER HS MODE i=%0d LOW_BYTE PID=%0h", i, pidsample_host_tx),
      UVM_LOW)

   usb_pid_cg.sample();

   // HIGH BYTE
   pidsample_host_tx = usb_seq_item.utmi_txdata[i][15:8];

   `uvm_info("SUBSCRIBER HOST_TX_DEBUG",
      $sformatf(" HS MODE i=%0d HIGH_BYTE PID=%0h", i, pidsample_host_tx),
      UVM_LOW)

   usb_pid_cg.sample();

`else

   pidsample_host_tx = usb_seq_item.utmi_txdata[i][7:0];

   `uvm_info("SUBSCRIBER HOST_TX_DEBUG",
      $sformatf("FS/LS MODE i=%0d BYTE PID=%0h", i, pidsample_host_tx),
      UVM_LOW)

   usb_pid_cg.sample();

`endif */    
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
 //brequest_cg.sample();
endfunction
  
   /* virtual function void write(USB2p0_sequence_item t);
       usb_seq_item = t;

 `uvm_info("PID_DEBUG",$sformatf("from coverage setup=%0h,data=%0h,ack=%0h",usb_seq_item.setup_token_pid,usb_seq_item.setup_data_pid,usb_seq_item.setup_handshake_pid), UVM_LOW)

foreach(usb_seq_item.utmi_txdata[i]) begin

   pid_sample = usb_seq_item.utmi_txdata[i];

`uvm_info("PID_DEBUG",$sformatf("from coverage pid_sample=%h",pid_sample), UVM_LOW)

   
    end
       usb_pid_cg.sample();

  foreach(usb_seq_item.rx_data[i]) begin

      pid_sample = usb_seq_item.rx_data[i];

      `uvm_info("DEVICE_PID",$sformatf("DEVICE PID=%h",pid_sample), UVM_LOW)

             end
     usb_pid_cg.sample();
     brequest_cg.sample();
         endfunction*/

         
    endclass

//     /* SETUP_TOKEN_PID:coverpoint usb_seq_item.setup_token_pid { 
  //                                                      bins setup = {8'hD};
    //                                                 ignore_bins tokenpid = {8'h69,8'hE1,8'h5A,8'h1E,8'hC3,8'h4B};
      //                                                 }*/

 
     /*  SETUP_TOKEN_PID_1:coverpoint usb_seq_item.utmi_txdata[0]{ 
                                                        bins utmi_txdata_1 = {8'hD2};
                                                       }*/


                                                   
        // BULK TRANSFER

    /*   BULK_PID_IN : coverpoint usb_seq_item.bulk_in_pid {
						           bins in_token  = {PID_IN};
                                                           ignore_bins  bulk_in_pid = {PID_ACK,PID_OUT,PID_SETUP,PID_NAK,PID_STALL};
                                                           }
                                                          
  							
       BULK_PID_OUT : coverpoint usb_seq_item.bulk_out_pid { 
                                                                bins out_token = {PID_OUT};
                                                                ignore_bins bulk_out_pid = {PID_ACK,PID_IN,PID_SETUP,PID_NAK,PID_STALL};
                                                                  }*/
                                                             
         /*SETUP_DATA:coverpoint usb_seq_item.setup_data_pid {
                                                          bins data0 = {8'h3C};
                                                     ignore_bins datapid = {8'h69,8'hE1,8'hD2,8'h2D,8'h5A,8'h1E,8'h4B};
                                                     }*/
                                                      
/*
       SETUP_HANDSHAKE:coverpoint usb_seq_item.setup_handshake_pid {
                                                                  bins handshake = {8'h2D};
                                                                 ignore_bins handshakepid = {8'h69,8'hE1,8'hD2,8'h5A,8'h1E,8'hC3,8'h4B};
                                                            }*/

    /* DATA_TOKEN: coverpoint usb_seq_item.data_token_pid {
                                                             bins in_out[] = {PID_IN, PID_OUT};
                                                             ignore_bins others = default;
                                                                     }*/
                                                              
    /* DATA_STAGE_PID_IN : coverpoint usb_seq_item.data_stage_pid_in {
                                                                   bins in_token  = {8'h96};
                                                                 ignore_bins data_pid = {8'h2D,8'hE1,8'hD2,8'h5A,8'h1E,8'hC3,8'h4B};
                                                                   } */
                                                                     

  /*   DATA_STAGE_PID_OUT : coverpoint usb_seq_item.data_stage_pid_out{
                                                                  bins out_token = {8'h1E};
                                                                 ignore_bins data_pid = {8'h96,8'hD2,8'h2D,8'h5A,8'hC3,8'h4B};
                                                                        }

                                                                     

     DATA_STAGE_DATA_PID : coverpoint usb_seq_item.data_data_pid {
                                                                   bins data0 = {PID_DATA0};
                                                                   bins data1 = {PID_DATA1};
                                                                   ignore_bins others = default;
                                                                    }

     DATA_STAGE_HANDSHAKE_PID : coverpoint usb_seq_item.data_handshake_pid {
                                                                          bins ack   = {PID_ACK};
                                                                         ignore_bins handshakepid = { PID_IN,PID_OUT,PID_SETUP,PID_NAK,PID_STALL};
                                                                           }

     // STATUS STAGE
    STATUS_STAGE_PID_IN : coverpoint usb_seq_item.status_stage_pid_in {
                                                                       bins in_token  = {PID_IN};
                                                                       ignore_bins  status_in_pid = {PID_ACK,PID_OUT,PID_SETUP,PID_NAK,PID_STALL};
                                                                       }
                                                                    
    STATUS_STAGE_PID_OUT : coverpoint usb_seq_item.status_stage_pid_out {
                                                                        bins out_token = {PID_OUT};
                                                                      ignore_bins status_out_pid = {PID_ACK,PID_IN,PID_SETUP,PID_NAK,PID_STALL};
                                                                    }
                                                                         
   STATUS_STAGE_DATA_PID : coverpoint usb_seq_item.status_stage_pid_out {
                                                                   bins data1 = {PID_DATA1};
                                                                   ignore_bins others = default;
                                                                      }
    STATUS_STAGE_HANDSHAKE_PID : coverpoint usb_seq_item.status_handshake_pid {
                                                                              bins ack = {PID_ACK};
                                                                         ignore_bins handshakepid = { PID_IN,PID_OUT,PID_SETUP,PID_NAK,PID_STALL};*/
                                                                             

 /* BULK_DATA_PID : coverpoint usb_seq_item.bulk_out_pid {
							      bins data0 = {PID_DATA0};
   							      bins data1 = {PID_DATA1};
							      ignore_bins others = default;
                                                             }

     BULK_HANDSHAKE_PID : coverpoint usb_seq_item.bulk_handshake_pid {
                                                                  bins ack   = {PID_ACK};
                                                                  // Enable below bins when error scenarios are implemented
                                                              //   bins nak   = {PID_NAK};
                                                              //   bins stall = {PID_STALL};
                                                                         ignore_bins handshakepid = { PID_IN,PID_OUT,PID_SETUP,PID_NAK,PID_STALL};
                                                                 }

      // INTERRUPT TRANSFER

     INTERRUPT_PID_IN : coverpoint usb_seq_item.interrupt_in_pid {
									bins in_token  = {PID_IN};
                                                                ignore_bins interrupt_in_pid = {PID_ACK,PID_OUT,PID_SETUP,PID_NAK,PID_STALL};
                                                              }
                                                                     

     INTERRUPT_PID_OUT : coverpoint usb_seq_item.interrupt_out_pid {
                                          	 			bins out_token = {PID_OUT};
                                                                 ignore_bins interrupt_out_pid = {PID_ACK,PID_IN,PID_SETUP,PID_NAK,PID_STALL};
                                                                       }
                                                                      
/*
     INTERRUPT_DATA_PID : coverpoint usb_seq_item.interrupt_out_pid {
								     bins data0 = {PID_DATA0};
  								     bins data1 = {PID_DATA1};
							            ignore_bins others = default;
                                                                      }

     INTERRUPT_HANDSHAKE_PID : coverpoint usb_seq_item.interrupt_handshake_pid {
										bins ack   = {PID_ACK};
                                                                         ignore_bins handshakepid = { PID_IN,PID_OUT,PID_SETUP,PID_NAK,PID_STALL};
										}
        // ISOCHRONOUS TRANSFER
             ISO_PID_IN : coverpoint usb_seq_item.iso_in_pid {
							        bins in_token  = {PID_IN};
                                                                ignore_bins iso_in_pid = {PID_ACK,PID_OUT,PID_SETUP,PID_NAK,PID_STALL};
                                                            }
                                                               
              ISO_PID_OUT : coverpoint usb_seq_item.iso_out_pid {
  
                                                                bins out_token = {PID_OUT};
                                                                 ignore_bins iso_out_pid = {PID_ACK,PID_IN,PID_SETUP,PID_NAK,PID_STALL};
                                                                  }
                    

             ISO_DATA_PID : coverpoint usb_seq_item.iso_out_pid {
                                                                  bins data0 = {PID_DATA0};
                                                                  bins data1 = {PID_DATA1};
                                                                  ignore_bins others = default;
                                                                              }*/

    /* ENDPOINT : coverpoint usb_seq_item.endp {

                     				 bins control_ep        = {0};
						 bins bulk_in_ep        = {1};
					         bins bulk_out_ep       = {2};
						 bins interrupt_in_ep   = {3};
						 bins interrupt_out_ep  = {5};
						 bins iso_in_ep         = {6};
						 bins iso_out_ep        = {7};
                                               ignore_bins others = {[8:15]};                                                                                                                                   }*/
                                                      
 
 /*    BREQUEST: coverpoint usb_seq_item.bRequest {
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
                                                              ignore_bins others = {[0:255]} with (!(item inside {
        8'h00,8'h01,8'h03,8'h05,8'h06,8'h07,8'h08,8'h09,8'h0A,8'h0B
    }));                                                            }*/

          /*BMREQUESTTYPE : coverpoint usb_seq_item.bmRequestType {
                                                                 bins std_out_device = {8'h00};
                                                                 bins std_device =     {8'h01};
                                                                 bins std_in_device  = {8'h80};
                                                                 bins std_in_if      = {8'h81};                                                                                                                           ignore_bins others = {[0:255]} with (!(item inside {8'h00,8'h01,8'h80,8'h81}));                                                                                                                             }*/

	 /* WVALUE : coverpoint usb_seq_item.wValue { 
                                                     bins zero = {16'h0000};
                                                     bins one  = {16'h0001};
                                                    ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0001}));                                                             
                                                               }*/

         /* WINDEX : coverpoint usb_seq_item.wIndex {
                                                    bins wzero = {16'h0000};
                                                    bins wone  = {16'h0001};
                                                    bins val_81 = {16'h0081};  
                                                   ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0001,16'h0081}));                                                   
                                                                   }*/

         /* WLENGTH : coverpoint usb_seq_item.wLength {
                                                      bins zero = {16'h0000};
                                                      bins one  = {16'h0001};
                                                      bins two  = {16'h0002};
                                                      bins desc = {16'h0012};
                                                      ignore_bins others = {[0:65535]} with (!(item inside {16'h0000,16'h0001,16'h0002,16'h0012}));                                                       
                                                      }*/


/*
           BLENGTH : coverpoint usb_seq_item.blength {
                                                        bins device_len = {8'h12};
                                                        ignore_bins others = {[0:255]} with (item != 8'h12);
                                                      }*/

          /* DESC_TYPE : coverpoint usb_seq_item.bdescriptors_type {
                                                               bins device_desc = {8'h01};
                                                                ignore_bins others = {[0:255]} with (item != 8'h01);                                                                                                 }*/

           /*BCD_USB : coverpoint usb_seq_item.bcd_usb {
                                                      bins usb_1 = {16'h0110};
                                                      ignore_bins others = {[0:65535]} with (item != 16'h0110);                                                                                                         }*/

          /* DEVICE_CLASS : coverpoint usb_seq_item.bDevice_class {
                                                               bins bdeviceclass = {8'h00};
                                                              ignore_bins others = {[0:255]} with (item != 8'h00);                                                                                                         }*/

         /* DEVICE_SUBCLASS : coverpoint usb_seq_item.bDevice_subclass {
                                                           bins subclass = {8'h00};
                                                         ignore_bins others = {[0:255]} with (item != 8'h00);                                                                                                         }*/

         
        /*  DEVICE_PROTOCOL : coverpoint usb_seq_item.bDevice_protocol {
                                                             bins protocol = {8'h00};
                                                          ignore_bins others = {[0:255]} with (item != 8'h00);                                                                                                        }*/

        /*  MAX_PACKET : coverpoint usb_seq_item.bMax_packetsize {
                                                          bins packetsize = {8'h40};
                                                          ignore_bins others = {[0:255]} with (item != 8'h40);
                                                            }*/

          /*VENDOR_ID : coverpoint usb_seq_item.idvendor {
                                                     bins vendor_781 = {16'h0781};
                                                         ignore_bins others = {[0:65535]} with (item != 16'h0781);                                                                                                   }*/
        /*  PRODUCT_ID : coverpoint usb_seq_item.idproduct {
                                                      bins product_5567 = {16'h5567};
                                                     ignore_bins others = {[0:65535]} with (item != 16'h5567);                                                                                                  }*/

        /*  DEVICE_BCD : coverpoint usb_seq_item.bcdDevice {
                                                        bins dev_ver = {16'h0126};
                                                         ignore_bins others = {[0:65535]} with (item != 16'h0126);                                                                                                 }*/
/*
         MANUF_STR : coverpoint usb_seq_item.imanufacture {
                                                         bins mfg = {8'h01};
                                                      ignore_bins others = {[0:255]} with (item != 8'h01);
                                                      }*/
/*
         PROD_STR : coverpoint usb_seq_item.iproduct {
                                                 bins product = {8'h02};
                                                ignore_bins others = {[0:255]} with (item != 8'h02);
                                                  }*/

	/* SERIAL_STR : coverpoint usb_seq_item.iserial_number {
                                                           bins serial = {8'h03};
                                                          ignore_bins others = {[0:255]} with (item != 8'h03);                                                                                                     }*/

     /*  NUM_CONFIG : coverpoint usb_seq_item.bNum_configuration {
                                                          bins cfg = {8'h01};
                                                         ignore_bins others = {[0:255]} with (item != 8'h01);                                                                                                          }*/






