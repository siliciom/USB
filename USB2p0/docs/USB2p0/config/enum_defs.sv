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


