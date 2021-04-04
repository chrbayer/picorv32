
# XDC File for KCU1500
###########################

set_property PACKAGE_PIN BA34 [get_ports clk_300mhz_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk_300mhz_p]
set_property PACKAGE_PIN BB34 [get_ports clk_300mhz_n]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk_300mhz_n]
create_clock -period 3.3333 [get_ports clk_300mhz_p]

# User LED[7:0]
set_property PACKAGE_PIN AW25 [get_ports {out_byte[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte[0]}]
set_property PACKAGE_PIN AY25 [get_ports {out_byte[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte[1]}]
set_property PACKAGE_PIN BA27 [get_ports {out_byte[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte[2]}]
set_property PACKAGE_PIN BA28 [get_ports {out_byte[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte[3]}]
set_property PACKAGE_PIN BB26 [get_ports {out_byte[4]}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte[4]}]
set_property PACKAGE_PIN BB27 [get_ports {out_byte[5]}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte[5]}]
set_property PACKAGE_PIN BA25 [get_ports {out_byte[6]}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte[6]}]
set_property PACKAGE_PIN BB25 [get_ports {out_byte[7]}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte[7]}]

# Reset button & user switches
set_property PACKAGE_PIN BE26 [get_ports {resetn}]
set_property IOSTANDARD LVCMOS18 [get_ports {resetn}]
set_property PACKAGE_PIN BC26 [get_ports {trap}]
set_property IOSTANDARD LVCMOS18 [get_ports {trap}]
set_property PACKAGE_PIN BC27 [get_ports {out_byte_en}]
set_property IOSTANDARD LVCMOS18 [get_ports {out_byte_en}]

