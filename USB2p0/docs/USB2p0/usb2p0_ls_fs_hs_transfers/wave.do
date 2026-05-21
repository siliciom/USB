onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_clk
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_suspend_n
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_termselect
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_xcvrselect
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_word_if
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_fsls_low_power
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_fslsserialmode
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmiotg_dppulldown
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmiotg_dmpulldown
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_linestate
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_host_disconnect
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmisrp_bvalid
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmiotg_vbusvalid
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_txvalid
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_txvalidh
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_txdata
add wave -noupdate /USB2p0_top/usb_utmi_intf_tx/utmi_opmode
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_clk
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_rxvalid
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_rxvalidh
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_rxdata
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_txready
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_rxactive
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_rxerror
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_word_if
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_fsls_low_power
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmi_fslsserialmode
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmiotg_dppulldown
add wave -noupdate /USB2p0_top/usb_utmi_intf_rx/utmiotg_dmpulldown
add wave -noupdate /USB2p0_top/usb_phy_intf/phy_clk
add wave -noupdate /USB2p0_top/usb_phy_intf/Dp
add wave -noupdate /USB2p0_top/usb_phy_intf/Dm
add wave -noupdate /USB2p0_top/usb_phy_intf/Vbus
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 450
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 10014374
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {2000129995 ns} {2000136310 ns}
