set bit_file "[lindex $argv 0]"

open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE ${bit_file} [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]

# Check User ID
refresh_hw_device -update_hw_probes false [current_hw_device]
set userid [get_property REGISTER.USERCODE [current_hw_device]]
puts $userid

close_hw_target
disconnect_hw_server
close_hw_manager
