//=====================scoreboard=======================================
`uvm_analysis_imp_decl(_host_tx)
`uvm_analysis_imp_decl(_host_rx)
`uvm_analysis_imp_decl(_device_tx)
`uvm_analysis_imp_decl(_device_rx)

class usb2p0_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(usb2p0_scoreboard)

  uvm_analysis_imp_host_tx   #(USB2p0_sequence_item,usb2p0_scoreboard) host_tx_imp;
  uvm_analysis_imp_host_rx   #(USB2p0_sequence_item,usb2p0_scoreboard) host_rx_imp;

  uvm_analysis_imp_device_tx #(USB2p0_sequence_item,usb2p0_scoreboard) device_tx_imp;
  uvm_analysis_imp_device_rx #(USB2p0_sequence_item,usb2p0_scoreboard) device_rx_imp;

  bit [DATA_WIDTH-1:0] host_tx_q[$][$];
  bit [DATA_WIDTH-1:0] host_rx_q[$][$];

  bit [DATA_WIDTH-1:0] device_tx_q[$][$];
  bit [DATA_WIDTH-1:0] device_rx_q[$][$];

  function new(string name="usb2p0_scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    host_tx_imp   = new("host_tx_imp",this);
    host_rx_imp   = new("host_rx_imp",this);
    device_tx_imp = new("device_tx_imp",this);
    device_rx_imp = new("device_rx_imp",this);
  endfunction


  //=================HOST TX================================
  function void write_host_tx(USB2p0_sequence_item pkt);
  `uvm_info("HOST_TX_SB",$sformatf("HOST_TX_DATA"),UVM_LOW)
   pkt.print();
    if(DATA_WIDTH == 8) begin
      if(pkt.tx_valid) begin
        host_tx_q.push_back(pkt.utmi_txdata);
        `uvm_info("HOST_TX_SB",$sformatf("8BIT_HOST_TX DATA=%0h 8_BIT_QUEUE=%P",pkt.utmi_txdata,host_tx_q),UVM_LOW)
      end
    end
    else if(DATA_WIDTH == 16) begin
      if(pkt.tx_valid) begin
        if(pkt.tx_validh) begin
          host_tx_q.push_back(pkt.utmi_txdata);
          `uvm_info("HOST_TX_SB",$sformatf("16BIT_HOST_TX DATA=%0h 16_BIT_QUEUE=%P VALIDH=%0b ",pkt.utmi_txdata,pkt.tx_validh,host_tx_q),UVM_LOW)
        end
        else begin
          host_tx_q.push_back(pkt.utmi_txdata);
          `uvm_info("HOST_TX_SB",$sformatf("LOW BYTE VALID DATA=%0h VALIDH=%0b",pkt.utmi_txdata,pkt.tx_validh),UVM_LOW)
        end
      end
    end
    compare_host_to_device();
  endfunction

  //=================DEVICE RX==============================
  function void write_device_rx(USB2p0_sequence_item pkt);
  `uvm_info("DEVICE_RX_SB",$sformatf("DEVICE_RX_DATA"),UVM_LOW)
   pkt.print();
    if(DATA_WIDTH == 8) begin
      if(pkt.rx_valid) begin
        device_rx_q.push_back(pkt.rx_data);
       `uvm_info("DEVICE_RX_SB",$sformatf("8BIT_DEVICE_RX DATA=%0h 8_BIT_QUEUE=%p",pkt.rx_data,device_rx_q),UVM_LOW)
      end
    end

    else if(DATA_WIDTH == 16) begin
      if(pkt.rx_valid) begin
        if(pkt.rx_validh) begin
          device_rx_q.push_back(pkt.rx_data);
          `uvm_info("DEVICE_RX_SB",$sformatf("16BIT_DEVICE_RX DATA=%0h 16_BIT_QUEUE",pkt.rx_data,device_rx_q),UVM_LOW)
        end
        else begin
          device_rx_q.push_back(pkt.rx_data[7:0]);
          `uvm_info("DEVICE_RX_SB",$sformatf("LOW BYTE VALID DATA=%0h VALIDH=%0b",pkt.utmi_txdata,pkt.tx_validh),UVM_LOW)
        end
      end
    end
    compare_host_to_device();
  endfunction

  //===================DEVICE TX============================
  function void write_device_tx(USB2p0_sequence_item pkt);
  `uvm_info("DEVICE_TX_SB",$sformatf("DEVICE_TX_DATA"),UVM_LOW)
   pkt.print();
    if(DATA_WIDTH == 8) begin
      if(pkt.tx_valid) begin
        device_tx_q.push_back(pkt.utmi_txdata);
        `uvm_info("DEVICE_TX_SB",$sformatf("8BIT_DEVICE_TX DATA=%0h 8_BIT_QUEUE=%P",pkt.utmi_txdata,device_tx_q),UVM_LOW)
      end
    end
    else if(DATA_WIDTH == 16) begin
      if(pkt.tx_valid) begin
        if(pkt.tx_validh) begin
          device_tx_q.push_back(pkt.utmi_txdata);
          `uvm_info("DEVICE_TX_SB",$sformatf("16BIT_DEVICE_TX DATA=%0h 16_BIT_QUEUE=%P VALIDH=%0b ",pkt.utmi_txdata,pkt.tx_validh,device_tx_q),UVM_LOW)
        end
        else begin
          device_tx_q.push_back(pkt.utmi_txdata[7:0]);
          `uvm_info("DEVICE_TX_SB",$sformatf("LOW BYTE VALID DATA=%0h VALIDH=%0b",pkt.utmi_txdata,pkt.tx_validh),UVM_LOW)
        end
      end
    end
    compare_device_to_host();
  endfunction


  //=======================HOST RX==========================
  function void write_host_rx(USB2p0_sequence_item pkt);
  `uvm_info("HOST_RX_SB",$sformatf("HOST_RX_DATA"),UVM_LOW)
   pkt.print();
    if(DATA_WIDTH == 8) begin
       if(pkt.rx_valid) begin
        host_rx_q.push_back(pkt.rx_data);
       `uvm_info("HOST_RX_SB",$sformatf("8BIT_HOST_RX DATA=%0h 8_BIT_QUEUE=%p",pkt.rx_data,host_rx_q),UVM_LOW)
      end
    end
    else if(DATA_WIDTH == 16) begin
      if(pkt.rx_valid) begin
        if(pkt.rx_validh) begin
          host_rx_q.push_back(pkt.rx_data);
          `uvm_info("HOST_RX_SB",$sformatf("16BIT_HOST_RX DATA=%0h 16_BIT_QUEUE=%P VALIDH=%0b ",pkt.utmi_txdata,pkt.tx_validh,host_rx_q),UVM_LOW)
        end
        else begin
          host_rx_q.push_back(pkt.rx_data[7:0]);
          `uvm_info("HOST_RX_SB",$sformatf("LOW BYTE VALID DATA=%0h VALIDH=%0b",pkt.utmi_txdata,pkt.tx_validh),UVM_LOW)
        end
      end
    end
    compare_device_to_host();
  endfunction

  //=============HOST TO DEVICE COMPARE====================
  function void compare_host_to_device();
    bit [DATA_WIDTH-1:0] exp_data[$];
    bit [DATA_WIDTH-1:0] act_data[$];
    if((host_tx_q.size() > 0) &&
       (device_rx_q.size() > 0)) begin
      act_data = host_tx_q.pop_front();
      exp_data = device_rx_q.pop_front();
      if(exp_data == act_data) begin
        `uvm_info("HOST_DEVICE_COMPARE",$sformatf("SB_DATA_MATCHED EXP=%p ACT=%p",exp_data,act_data),UVM_LOW)
      end
      else begin
        `uvm_warning("HOST_DEVICE_COMPARE",$sformatf("SB_DATA_MISMATCH EXP=%p ACT=%p",exp_data,act_data))
      end
    end
  endfunction


  //===============DEVICE TO HOST COMPARE====================
  function void compare_device_to_host();
    bit [DATA_WIDTH-1:0] exp_data[$];
    bit [DATA_WIDTH-1:0] act_data[$];
    //device_tx_q.delete();
    if((device_tx_q.size() > 0) &&
       (host_rx_q.size() > 0)) begin
      act_data = device_tx_q.pop_front();
      `uvm_info("DEVICE_HOST_COMPARE",$sformatf("DEVICE_HOST_ACT=%p",act_data),UVM_LOW)
      exp_data = host_rx_q.pop_front();
      `uvm_info("DEVICE_HOST_COMPARE",$sformatf("DEVICE_HOST_EXP=%p",exp_data),UVM_LOW)
      if(exp_data == act_data) begin
      `uvm_info("DEVICE_HOST_COMPARE",$sformatf("SB_DATA_MATCHED EXP=%p ACT=%p",exp_data,act_data),UVM_LOW)
      end
      else begin
      `uvm_warning("DEVICE_HOST_COMPARE",$sformatf("SB_DATA_MISMATCH EXP=%p ACT=%p",exp_data,act_data))
      end
    end
  endfunction

endclass



