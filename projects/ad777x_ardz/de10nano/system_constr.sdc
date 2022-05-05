create_clock -period "20.000 ns"  -name sys_clk     [get_ports {sys_clk}]
create_clock -period "16.666 ns"  -name usb1_clk    [get_ports {usb1_clk}]
create_clock -period "488.00 ns"  -name adc_clk     [get_ports {adc_clk_in}]


derive_pll_clocks
derive_clock_uncertainty
