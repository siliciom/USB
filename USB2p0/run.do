#power_connection_testcases
#set testname "USB2p0_vbus_connect_test"
#set testname "USB2p0_vbus_disconnect_test"

#set_feature_testcases
#set testname "USB2p0_LS_CT_set_address_test"
#set testname "USB2p0_LS_CT_clear_feature_test"
#set testname "USB2p0_LS_CT_set_configuration_test"
#set testname "USB2p0_LS_CT_set_feature_test"
#set testname "USB2p0_LS_CT_set_interface_test"

#get_feature_testcases
#set testname "USB2p0_LS_CT_get_configuration_test"
#set testname "USB2p0_LS_CT_get_interface_test"
#set testname "USB2p0_LS_CT_get_status_test"
#set testname "USB2p0_LS_CT_get_descriptor_test"

#set testname "USB2p0_LS_interrupt_in_test"
#set testname "USB2p0_LS_interrupt_out_test"

#set_feature_testcases
#set testname "USB2p0_FS_CT_set_address_test"
#set testname "USB2p0_FS_CT_clear_feature_test"
#set testname "USB2p0_FS_CT_set_configuration_test"
#set testname "USB2p0_FS_CT_set_feature_test"
#set testname "USB2p0_FS_CT_set_interface_test"

#get_feature_testcases
#set testname "USB2p0_FS_CT_get_configuration_test"
#set testname "USB2p0_FS_CT_get_interface_test"
 set testname "USB2p0_FS_CT_get_status_test"
#set testname "USB2p0_FS_CT_get_descriptor_test"

#set testname "USB2p0_FS_isochronous_in_test"
#set testname "USB2p0_FS_isochronous_out_test"
#set testname "USB2p0_FS_interrupt_in_test"
#set testname "USB2p0_FS_interrupt_out_test"
#set testname "USB2p0_FS_bulk_in_test"
#set testname "USB2p0_FS_bulk_out_test"

vlib work
vmap work work

#updating HS transfers code
#vlog -work work -sv top/USB2p0_UTMI_interface.sv  top/USB2p0_PHY_interface.sv top/USB2p0_pkg.sv top/USB2p0_top.sv -l compile.log 
vlog -work work -sv top/USB2p0_UTMI_interface.sv  top/USB2p0_PHY_interface.sv top/USB2p0_pkg_regression.sv top/USB2p0_top.sv -l compile.log
set infile [open "${testname}_log.log" w+]

vsim USB2p0_top +UVM_TESTNAME=${testname} -l $infile


add log -r /*
add wave -r /USB2p0_top/*
run -all


