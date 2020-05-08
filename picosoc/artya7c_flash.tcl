# ------------------------------------------------------------------------------
# Connect to FPGA board
# ------------------------------------------------------------------------------

# Open the hardware tool
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
    -file artya7c_flash_readback.bin [current_hw_cfgmem]

# ------------------------------------------------------------------------------
# Update contents of flash memory device
# ------------------------------------------------------------------------------

# Program FPGA using current bitstream
program_hw_devices [current_hw_device]

# Refreshes the in-memory view of the current device
refresh_hw_device -update_hw_probes false [current_hw_device]

# Create memory configuration file
write_cfgmem -format HEX -force -size 16 -interface SPIx4 -verbose \
    -loadbit "up 0x0 artya7c.bit" \
    -loaddata "up 0x100000 artya7c_fw.bin" \
    artya7c_flash.hex

# Set the address range used for erasing to the size of the programming file
set_property PROGRAM.ADDRESS_RANGE {use_file} [current_hw_cfgmem]

# Set the programming file to program into the SPI flash
set_property PROGRAM.FILES artya7c_flash.hex [current_hw_cfgmem]

# Set the termination of unused pins when programming the SPI flash
set_property PROGRAM.UNUSED_PIN_TERMINATION {pull-none} [current_hw_cfgmem]

# Set programming options
# Do not perform a blank check, but erase, program and verify
set_property PROGRAM.BLANK_CHECK 0 [current_hw_cfgmem]
set_property PROGRAM.ERASE 1 [current_hw_cfgmem]
set_property PROGRAM.CFG_PROGRAM 1 [current_hw_cfgmem]
set_property PROGRAM.VERIFY 1 [current_hw_cfgmem]

# Write contents to flash
program_hw_cfgmem -hw_cfgmem [current_hw_cfgmem]
