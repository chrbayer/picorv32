read_verilog artya7c.v
read_verilog picosoc.v
read_verilog ../picorv32.v
read_verilog spimemio.v
read_verilog simpleuart.v
read_xdc artya7c.xdc

create_ip -name vio -vendor xilinx.com -library ip -module_name vio
set_property -dict [list \
	CONFIG.C_PROBE_IN0_WIDTH 8 \
	CONFIG.C_PROBE_OUT0_WIDTH 8 \
	CONFIG.C_NUM_PROBE_IN 1 \
	CONFIG.C_NUM_PROBE_OUT 1 \
] [get_ips vio]
synth_ip [get_ips vio]

create_ip -name ila -vendor xilinx.com -library ip -module_name ila
set_property -dict [list \
	CONFIG.C_PROBE0_WIDTH  32 \
	CONFIG.C_DATA_DEPTH 4096 \
	CONFIG.C_NUM_OF_PROBES 1 \
] [get_ips ila]
synth_ip [get_ips ila]

synth_design -top artya7c -part xc7a35t-csg324-1 -flatten_hierarchy none -verilog_define synthesis -verbose
opt_design -directive ExploreSequentialArea -verbose
place_design -verbose
phys_opt_design -directive AggressiveExplore -verbose
route_design -directive Explore -tns_cleanup -verbose
phys_opt_design -directive AggressiveExplore -verbose

report_utilization
report_timing
write_verilog -force artya7c_syn.v

set_property BITSTREAM.CONFIG.USERID 0xCAFEDECA [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
write_bitstream -force -file artya7c.bit -verbose
write_debug_probes artya7c.ltx
write_cfgmem -force -format BIN -size 16 -interface SPIx4 -loadbit "up 0x0 artya7c.bit" -verbose artya7c_bit.bin

# write_cfgmem -format mcs -interface [dict get $board iface] -size [dict get $board size] \
# 	-loadbit "up [dict get $board bitaddr] $bitfile" \
# 	-loaddata [expr {$datafile ne "" ? "up 0x400000 $datafile" : ""}] \
# 	-file $mcsfile -force