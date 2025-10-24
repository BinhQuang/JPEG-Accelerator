create_clock -name CLK_I -period 5.4 [get_ports {CLK_I}]
set_input_delay -clock CLK_I 0 [get_ports {*}]
set_output_delay -clock CLK_I 0 [get_ports {*}]
# 120 MHz clock constraint