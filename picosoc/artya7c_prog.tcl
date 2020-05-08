set bit_file "[lindex $argv 0]"

open_hw_manager
connect_hw_server
open_hw_target
set_property PROGRAM.FILE ${bit_file} [lindex [get_hw_devices] 0]
program_hw_devices [lindex [get_hw_devices] 0]
close_hw_target
disconnect_hw_server
close_hw_manager
