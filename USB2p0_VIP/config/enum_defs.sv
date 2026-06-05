enum bit [3:0] { PID_ACK   = 4'b0010,
      		 PID_NAK   = 4'b1010,
      		 PID_STALL = 4'b1110,
                 PID_SETUP = 4'b1101,
                 PID_DATA0 = 4'b0011,
                 PID_DATA1 = 4'b1011,
                 PID_DATA2 = 4'b0111,
                 PID_IN    = 4'b1001,
                 PID_OUT   = 	4'b0001,
                 MDATA     = 4'b1111 } pid_enum;


     typedef enum{
                  CONTROL_TRANSFER,
                  INTERRUPT_TRANSFER,
                  BULK_TRANSFER,
                  ISO_CHRONOUS_TRANSFER
                  } transfers;

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
 
   typedef enum {
                HOST_TX,
		HOST_RX,
		DEVICE_TX,
		DEVICE_RX
       } mon_type_e;


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

