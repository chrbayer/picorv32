open_hw_manager
connect_hw_server
open_hw_target

set_property PROBES.FILE artya7c.ltx [current_hw_device]
set_property FULL_PROBES.FILE artya7c.ltx [current_hw_device]
refresh_hw_device -update_hw_probes true [current_hw_device]

get_hw_vios
refresh_hw_vio [get_hw_vios]

refresh_hw_device [current_hw_device]
set vio_in_val [get_property INPUT_VALUE [get_hw_probes vio_in]]
puts $vio_in_val

close_hw_target
disconnect_hw_server
close_hw_manager
