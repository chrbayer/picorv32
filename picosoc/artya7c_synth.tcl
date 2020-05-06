read_verilog artya7c.v
read_verilog picosoc.v
read_verilog ../picorv32.v
read_verilog spimemio.v
read_verilog simpleuart.v
read_xdc artya7c.xdc

synth_design -top artya7c -part xc7a35t-csg324-1 -flatten_hierarchy none -verbose
opt_design -directive ExploreSequentialArea -verbose
place_design -verbose
phys_opt_design -directive AggressiveExplore -verbose
route_design -directive Explore -tns_cleanup -verbose
phys_opt_design -directive AggressiveExplore -verbose

report_utilization
report_timing
write_verilog -force artya7c_syn.v

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force -file artya7c.bit -verbose
