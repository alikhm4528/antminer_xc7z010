set_property PACKAGE_PIN F16 [get_ports {led_o[0]}]
set_property PACKAGE_PIN M19 [get_ports {led_o[1]}]
set_property PACKAGE_PIN M17 [get_ports {led_o[2]}]
set_property PACKAGE_PIN L19 [get_ports {led_o[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {led_o[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led_o[0]}]

set_property PULLUP true [get_ports {led_o[0]}]
set_property PULLUP true [get_ports {led_o[1]}]
set_property PULLUP true [get_ports {led_o[2]}]
set_property PULLUP true [get_ports {led_o[3]}]
