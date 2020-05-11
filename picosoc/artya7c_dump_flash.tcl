# ------------------------------------------------------------------------------
# Connect to FPGA board
# ------------------------------------------------------------------------------

# Open Vivado's Hardware Manager tool
open_hw_manager

# Open a connection to a hardware server
connect_hw_server

# Open a connection to a hardware target on the hardware server
open_hw_target

# ------------------------------------------------------------------------------
# Configure FPGA with Xilinx's JTAG / SPI bridge
# ------------------------------------------------------------------------------

# Create a device-specific hw_cfgmem object
create_hw_cfgmem -hw_device [current_hw_device] {mt25ql128-spi-x1_x2_x4}

# Read bitstream file into memory
create_hw_bitstream -hw_device [current_hw_device] \
    [get_property PROGRAM.HW_CFGMEM_BITFILE [current_hw_device]]

# ------------------------------------------------------------------------------
# Readback contents of flash memory device
# ------------------------------------------------------------------------------

# Program FPGA using current bitstream
program_hw_devices [current_hw_device]

# Refreshes the in-memory view of the current device
refresh_hw_device -update_hw_probes false [current_hw_device]

# Dump previous flash contents
readback_hw_cfgmem -force -verbose -all -format bin \
    -file artya7c_flash_dump.bin [current_hw_cfgmem]

# ------------------------------------------------------------------------------
# Disconnect from FPGA board
# ------------------------------------------------------------------------------

# Close the connection to the current hardware target
close_hw_target -verbose

# Disconnect the current Vivado tools hardware server
disconnect_hw_server -verbose

# Close Vivado's Hardware Manager tool
close_hw_manager

