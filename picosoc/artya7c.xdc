################################################################################
# 100 MHz Clock (Abracon ASEM1-100.000MHz-LC-T oscillator)

set_property PACKAGE_PIN E3 [get_ports clk100]
create_clock -period 10 [get_ports clk100]
set_input_jitter clk100 0.050

################################################################################
# USB-UART Interface

set_property PACKAGE_PIN D10 [get_ports ser_tx]
set_property PACKAGE_PIN A9 [get_ports ser_rx]

################################################################################
# Quad SPI Flash (N25Q128)

set_property PACKAGE_PIN L16 [get_ports flash_clk]
set_property PACKAGE_PIN L13 [get_ports flash_csb]
set_property PACKAGE_PIN K17 [get_ports flash_io[0]]
set_property PACKAGE_PIN K18 [get_ports flash_io[1]]
set_property PACKAGE_PIN L14 [get_ports flash_io[2]]
set_property PACKAGE_PIN M14 [get_ports flash_io[3]]

################################################################################
# LEDs

set_property PACKAGE_PIN F6 [get_ports leds[0]]
set_property PACKAGE_PIN J4 [get_ports leds[1]]
set_property PACKAGE_PIN J2 [get_ports leds[2]]
set_property PACKAGE_PIN H6 [get_ports leds[3]]
set_property PACKAGE_PIN H5 [get_ports leds[4]]
set_property PACKAGE_PIN J5 [get_ports leds[5]]
set_property PACKAGE_PIN T9 [get_ports leds[6]]
set_property PACKAGE_PIN T10 [get_ports leds[7]]

################################################################################
# Configuration Bank Voltage

set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

################################################################################
# Thermal Parameters

set_operating_conditions -airflow 0 -heatsink none

################################################################################
# Default IO Standard

set_property IOSTANDARD LVCMOS33 [get_ports -filter { LOC =~ IOB_* }]
