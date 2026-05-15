package USB2p0_pkg;

    `include "uvm_macros.svh"
     import uvm_pkg::*;
       
 `ifdef UTMI_16BIT
      parameter DATA_WIDTH = 16;
  `else
      parameter DATA_WIDTH = 8;
  `endif


      typedef enum {USB_LS,USB_FS,USB_HS} speed_state;

	`include "../config/enum_defs.sv"
	`include "../agents/USB2p0_sequence_item.sv"
	`include "../agents/USB2p0_phy_sequence_item.sv"
	`include "../config/USB2p0_env_config.sv"

	`include "../agents/host_controller_agent/USB2p0_HOST_controller_sequencer.sv"
	`include "../agents/device_controller_agent/USB2p0_DEVICE_controller_sequencer.sv"
	`include "../agents/phy_agent/USB2p0_PHY_sequencer.sv"

	`include "../agents/host_controller_agent/USB2p0_HOST_controller_driver.sv"
	`include "../agents/device_controller_agent/USB2p0_DEVICE_controller_driver.sv"
	`include "../agents/phy_agent/USB2p0_PHY_driver.sv"

	`include "../agents/host_controller_agent/USB2p0_HOST_controller_monitor.sv"
	`include "../agents/device_controller_agent/USB2p0_DEVICE_controller_monitor.sv"
	`include "../agents/phy_agent/USB2p0_PHY_monitor.sv"

        `include "../Regression/sequences/virtual_sequencer/USB2p0_base_virtual_sequencer.sv"
        `include "../sequences/virtual_sequence/USB2p0_base_virtual_sequence.sv"
	
        `include "../agents/host_controller_agent/USB2p0_HOST_controller_agent.sv"
	`include "../agents/phy_agent/USB2p0_PHY_agent.sv"
	`include "../agents/device_controller_agent/USB2p0_DEVICE_controller_agent.sv"

	//------------------------------ADDING_sequences----------------------------//

	`include "../Regression/sequences/host_sequences/USB2p0_HOST_sequence.sv"
	`include "../Regression/sequences/host_sequences/USB2p0_HOST_vbus_connect_sequence.sv"
	`include "../Regression/sequences/host_sequences/USB2p0_HOST_vbus_disconnect_sequence.sv"

	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_detect_sequence.sv"
        `include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_set_address_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_clear_feature_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_set_configuration_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_set_feature_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_set_interface_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_get_configuration_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_get_interface_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_get_status_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_CT_get_descriptor_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_interrupt_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/LS_sequences/USB2p0_HOST_LS_interrupt_out_sequence.sv"

	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_detect_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_set_configuration_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_set_interface_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_get_configuration_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_get_descriptor_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_get_interface_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_set_address_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_get_status_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_set_feature_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_CT_clear_feature_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_isochronous_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_isochronous_out_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_interrupt_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_interrupt_out_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_bulk_in_sequence.sv"
	`include "../Regression/sequences/host_sequences/FS_sequences/USB2p0_HOST_FS_bulk_out_sequence.sv"

	//`include "../Regression/sequences/host_sequences/HS_sequences/USB2p0_HOST_HS_detect_sequence.sv"
	//`include "../Regression/sequences/host_sequences/HS_sequences/USB2p0_host_hs_ct_set_configuration_in_sequence.sv"

	//----------/Regression-------- adding phy sequences ------------------------//
	`include "../Regression/sequences/phy_sequences/USB2p0_PHY_sequence.sv"
	`include "../Regression/sequences/phy_sequences/USB2p0_PHY_vbus_sequence.sv"
	`include "../Regression/sequences/phy_sequences/USB2p0_PHY_LS_detect_sequence.sv"
	`include "../Regression/sequences/phy_sequences/USB2p0_PHY_FS_detect_sequence.sv"
	`include "../Regression/sequences/phy_sequences/USB2p0_PHY_HS_detect_sequence.sv"
	`include "../Regression/sequences/phy_sequences/USB2p0_PHY_LS_data_stage_sequence.sv"

	//----------/Regression-------- adding device sequences ------------------------//
	`include "../Regression/sequences/device_sequences/USB2p0_DEVICE_sequence.sv"
	`include "../Regression/sequences/device_sequences/USB2p0_DEVICE_vbus_sequence.sv"
	`include "../Regression/sequences/device_sequences/LS_sequences/USB2p0_DEVICE_LS_detect_sequence.sv"
	`include "../Regression/sequences/device_sequences/FS_sequences/USB2p0_DEVICE_FS_detect_sequence.sv"
	`include "../Regression/sequences/device_sequences/HS_sequences/USB2p0_DEVICE_HS_detect_sequence.sv"

	`include "../Regression/sequences/device_sequences/LS_sequences/USB2p0_DEVICE_LS_setup_hs_sequence.sv"
	`include "../Regression/sequences/device_sequences/LS_sequences/USB2p0_DEVICE_LS_send_hs_sequence.sv"
	`include "../Regression/sequences/device_sequences/FS_sequences/USB2p0_DEVICE_FS_send_hs_sequence.sv"
	`include "../Regression/sequences/device_sequences/FS_sequences/USB2p0_DEVICE_FS_setup_sequence.sv"
//	`include "../Regression/sequences/device_sequences/HS_sequences/USB2p0_DEVICE_hs_send_hs_sequence.sv"
//	`include "../Regression/sequences/device_sequences/HS_sequences/USB2p0_DEVICE_hs_setup_sequence.sv"

	
	//----------/Regression-------- adding vsequences ------------------------//
        `include "../Regression/sequences/virtual_sequence/USB2p0_vbus_connect_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/USB2p0_vbus_disconnect_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_detect_vsequence.sv"
      //  `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_detect_vsequence.sv"
               
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_set_address_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_clear_feature_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_set_configuration_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_set_feature_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_set_interface_vsequence.sv"
        
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_get_configuration_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_get_interface_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_get_status_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_CT_get_descriptor_vsequence.sv"
        
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_set_configuration_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_set_interface_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_set_feature_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_set_address_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_clear_feature_vsequence.sv"

        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_get_configuration_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_get_descriptor_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_get_interface_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_CT_get_status_vsequence.sv"
        
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_interrupt_in_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/LS_vsequences/USB2p0_LS_interrupt_out_vsequence.sv"
        
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_isochronous_in_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_isochronous_out_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_interrupt_in_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_interrupt_out_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_bulk_in_vsequence.sv"
        `include "../Regression/sequences/virtual_sequence/FS_vsequences/USB2p0_FS_bulk_out_vsequence.sv"

      //  `include "../Regression/sequences/virtual_sequence/HS_sequences/USB2p0_hs_ct_set_configuration_vsequence.sv"

        `include "../env/USB2p0_scoreboard.sv"
        `include "../env/USB2p0_subscriber.sv"
        `include "../env/USB2p0_environment.sv"

	//----------/Regression-------- adding test ------------------------//
        `include "../Regression/tests/USB2p0_base_test.sv"
        `include "../Regression/tests/USB2p0_vbus_connect_test.sv"
        `include "../Regression/tests/USB2p0_vbus_disconnect_test.sv"
        
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_detect_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_set_address_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_clear_feature_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_set_configuration_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_set_feature_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_set_interface_test.sv"
        
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_get_configuration_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_get_interface_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_get_status_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_CT_get_descriptor_test.sv"
        
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_interrupt_in_test.sv"
        `include "../Regression/tests/LS_Transfers/USB2p0_LS_interrupt_out_test.sv"
        
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_detect_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_set_configuration_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_set_interface_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_get_configuration_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_get_descriptor_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_get_interface_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_set_feature_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_set_address_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_get_status_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_CT_clear_feature_test.sv"

        `include "../Regression/tests/FS_Transfers/USB2p0_FS_isochronous_in_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_isochronous_out_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_interrupt_in_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_interrupt_out_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_bulk_in_test.sv"
        `include "../Regression/tests/FS_Transfers/USB2p0_FS_bulk_out_test.sv"
        
        //`include "../Regression/tests/HS_Transfers/USB2p0_HS_detect_test.sv"
       // `include "../Regression/tests/HS_Transfers/USB2p0_HS_CT_set_configuration_test.sv"

endpackage
