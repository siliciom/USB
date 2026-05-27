interface USB2p0_host_utmi_interface(input utmi_clk);
   `ifdef UTMI_16BIT
     parameter DATA_WIDTH = 16;
   `else
     parameter DATA_WIDTH = 8;
   `endif
  logic reset;
  //------------------------------------------------
  //input signals
  //------------------------------------------------
  logic 		utmi_rxvalid;
  logic 		utmi_rxvalidh;
  logic  [DATA_WIDTH-1:0]         utmi_rxdata;
  logic 		utmi_txready=1;
  logic 		utmi_rxactive;
  logic 		utmi_rxerror;
  logic [1:0] 		utmi_linestate;
  logic 		utmi_host_disconnect;
  logic 		utmisrp_bvalid;
  logic 		utmiotg_vbusvalid;
  //------------------------------------------------
  //output signals
  //------------------------------------------------
  logic 		utmi_txvalid;
  logic 		utmi_txvalidh;
  logic  [DATA_WIDTH-1:0]         utmi_txdata;
  logic 		utmi_opmode;
  logic 		utmi_suspend_n;
  logic 		utmi_termselect;
  logic 		utmi_xcvrselect;
  logic 		utmi_word_if;
  logic 		utmi_fsls_low_power;
  logic 		utmi_fslsserialmode;
  logic 		utmiotg_dppulldown;
  logic 		utmiotg_dmpulldown;

  //------------------------------------------------
  //host clocking block
  //------------------------------------------------
   
  clocking cb_utmi_host_controller_driver @(posedge utmi_clk);
    default input #1 output #1;
    input  utmi_rxvalid, 
     	   utmi_rxvalidh, 
    	   utmi_rxdata, 
           utmi_txready, 
           utmi_rxactive, 
           utmi_rxerror, 
           utmi_linestate, 
           utmi_host_disconnect, 
           utmisrp_bvalid, 
           utmiotg_vbusvalid;
    output utmi_txvalid,
           utmi_txvalidh, 
           utmi_txdata, 
           utmi_opmode,  
           utmi_suspend_n,
           utmi_termselect, 
           utmi_xcvrselect, 
           utmi_word_if, 
           utmi_fsls_low_power, 
           utmi_fslsserialmode, 
           utmiotg_dppulldown, 
           utmiotg_dmpulldown;
  endclocking

   clocking cb_utmi_host_controller_monitor @(negedge utmi_clk);
        default input #1 output #1;
        input  utmi_rxvalid, 
               utmi_rxvalidh, 
               utmi_rxdata, 
               utmi_txready, 
               utmi_rxactive, 
               utmi_rxerror, 
               utmi_linestate, 
               utmi_host_disconnect, 
               utmisrp_bvalid, 
               utmiotg_vbusvalid;
        input utmi_txvalid,
               utmi_txvalidh, 
               utmi_txdata, 
               utmi_opmode,  
               utmi_suspend_n,
               utmi_termselect, 
               utmi_xcvrselect, 
               utmi_word_if, 
               utmi_fsls_low_power, 
               utmi_fslsserialmode, 
               utmiotg_dppulldown, 
               utmiotg_dmpulldown;
  endclocking

 
  //------------------------------------------------------
  //Modports
  //------------------------------------------------------
  modport mp_utmi_host_controller_driver    ( clocking cb_utmi_host_controller_driver, input utmi_clk, output reset);
  modport mp_utmi_host_controller_monitor   ( clocking cb_utmi_host_controller_monitor, input utmi_clk, output reset);

    /*input  reset,
           utmi_rxvalid, 
     	   utmi_rxvalidh, 
    	   utmi_rxdata, 
           utmi_txready, 
           utmi_rxactive, 
           utmi_rxerror, 
           utmi_linestate, 
           utmi_host_disconnect, 
           utmisrp_bvalid, 
           utmiotg_vbusvalid,
    output utmi_txvalid,
           utmi_txvalidh, 
           utmi_txdata, 
           utmi_opmode,  
           utmi_suspend_n,
           utmi_termselect, 
           utmi_xcvrselect, 
           utmi_word_if, 
           utmi_fsls_low_power, 
           utmi_fslsserialmode, 
           utmiotg_dppulldown, 
           utmiotg_dmpulldown
                      );
 
 
modport mp_utmi_host_controller_monitor ( clocking cb_utmi_host_controller_monitor,
    input  reset,
           utmi_rxvalid, 
     	   utmi_rxvalidh, 
    	   utmi_rxdata, 
           utmi_txready, 
           utmi_rxactive, 
           utmi_rxerror, 
           utmi_linestate, 
           utmi_host_disconnect, 
           utmisrp_bvalid, 
           utmiotg_vbusvalid,
    input utmi_txvalid,
           utmi_txvalidh, 
           utmi_txdata, 
           utmi_opmode,  
           utmi_suspend_n,
           utmi_termselect, 
           utmi_xcvrselect, 
           utmi_word_if, 
           utmi_fsls_low_power, 
           utmi_fslsserialmode, 
           utmiotg_dppulldown, 
           utmiotg_dmpulldown
                      );*/

 
endinterface






interface USB2p0_device_utmi_interface(input utmi_clk);
   `ifdef UTMI_16BIT
     parameter DATA_WIDTH = 16;
   `else
     parameter DATA_WIDTH = 8;
   `endif
  logic reset;
  //------------------------------------------------
  //input signals
  //------------------------------------------------
  logic 		utmi_rxvalid;
  logic 		utmi_rxvalidh;
  logic  [DATA_WIDTH-1:0]         utmi_rxdata;
  logic 		utmi_txready=1;
  logic 		utmi_rxactive;
  logic 		utmi_rxerror;
  logic [1:0] 		utmi_linestate;
  logic 		utmi_host_disconnect;
  logic 		utmisrp_bvalid;
  logic 		utmiotg_vbusvalid;
  //------------------------------------------------
  //output signals
  //------------------------------------------------
  logic 		utmi_txvalid;
  logic 		utmi_txvalidh;
  logic  [DATA_WIDTH-1:0]         utmi_txdata;
  logic 		utmi_opmode;
  logic 		utmi_suspend_n;
  logic 		utmi_termselect;
  logic 		utmi_xcvrselect;
  logic 		utmi_word_if;
  logic 		utmi_fsls_low_power;
  logic 		utmi_fslsserialmode;
  logic 		utmiotg_dppulldown;
  logic 		utmiotg_dmpulldown;


  //------------------------------------------------
  //device clocking block
  //------------------------------------------------
  clocking cb_utmi_device_controller_driver @(posedge utmi_clk);
        default input #1 output #1;
        input  utmi_rxvalid, 
               utmi_rxvalidh, 
               utmi_rxdata, 
               utmi_txready, 
               utmi_rxactive, 
               utmi_rxerror, 
               utmi_linestate, 
               utmi_host_disconnect, 
               utmisrp_bvalid, 
               utmiotg_vbusvalid;
        output utmi_txvalid,
               utmi_txvalidh, 
               utmi_txdata, 
               utmi_opmode,  
               utmi_suspend_n,
               utmi_termselect, 
               utmi_xcvrselect, 
               utmi_word_if, 
               utmi_fsls_low_power, 
               utmi_fslsserialmode, 
               utmiotg_dppulldown, 
               utmiotg_dmpulldown;
  endclocking

  clocking cb_utmi_device_controller_monitor @(negedge utmi_clk);
        default input #1 output #0;
        input  utmi_rxvalid, 
               utmi_rxvalidh, 
               utmi_rxdata, 
               utmi_txready, 
               utmi_rxactive, 
               utmi_rxerror, 
               utmi_linestate, 
               utmi_host_disconnect, 
               utmisrp_bvalid, 
               utmiotg_vbusvalid;
        input utmi_txvalid,
               utmi_txvalidh, 
               utmi_txdata, 
               utmi_opmode,  
               utmi_suspend_n,
               utmi_termselect, 
               utmi_xcvrselect, 
               utmi_word_if, 
               utmi_fsls_low_power, 
               utmi_fslsserialmode, 
               utmiotg_dppulldown, 
               utmiotg_dmpulldown;
  endclocking

 
  //------------------------------------------------------
  //Modports
  //------------------------------------------------------
  modport mp_utmi_device_controller_driver  ( clocking cb_utmi_device_controller_driver, input utmi_clk, output reset);
  modport mp_utmi_device_controller_monitor ( clocking cb_utmi_device_controller_monitor, input utmi_clk, output reset);

  /*modport mp_utmi_device_controller_driver ( clocking cb_utmi_device_controller_driver,
    input  reset,
           utmi_rxvalid, 
     	   utmi_rxvalidh, 
    	   utmi_rxdata, 
           utmi_txready, 
           utmi_rxactive, 
           utmi_rxerror, 
           utmi_linestate, 
           utmi_host_disconnect, 
           utmisrp_bvalid, 
           utmiotg_vbusvalid,
    output utmi_txvalid,
           utmi_txvalidh, 
           utmi_txdata, 
           utmi_opmode,  
           utmi_suspend_n,
           utmi_termselect, 
           utmi_xcvrselect, 
           utmi_word_if, 
           utmi_fsls_low_power, 
           utmi_fslsserialmode, 
           utmiotg_dppulldown, 
           utmiotg_dmpulldown
                      );
 
modport mp_utmi_device_controller_monitor (clocking cb_utmi_device_controller_monitor,
    input  reset,
           utmi_rxvalid, 
     	   utmi_rxvalidh, 
    	   utmi_rxdata, 
           utmi_txready, 
           utmi_rxactive, 
           utmi_rxerror, 
           utmi_linestate, 
           utmi_host_disconnect, 
           utmisrp_bvalid, 
           utmiotg_vbusvalid,
    input utmi_txvalid,
           utmi_txvalidh, 
           utmi_txdata, 
           utmi_opmode,  
           utmi_suspend_n,
           utmi_termselect, 
           utmi_xcvrselect, 
           utmi_word_if, 
           utmi_fsls_low_power, 
           utmi_fslsserialmode, 
           utmiotg_dppulldown, 
           utmiotg_dmpulldown
                      );
*/
 
endinterface

