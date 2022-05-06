
# cn0577

set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports ref_clk_p]; #G02  FMC_LPC_CLK1_M2C_P
set_property -dict {PACKAGE_PIN C19 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports ref_clk_n]; #G03  FMC_LPC_CLK1_M2C_N
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports dco_p]; #H04  FMC_LPC_CLK0_M2C_P
set_property -dict {PACKAGE_PIN L19 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports dco_n]; #H05  FMC_LPC_CLK0_M2C_N
set_property -dict {PACKAGE_PIN P17 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports da_p]; #H07  FMC_LPC_LA02_P
set_property -dict {PACKAGE_PIN P18 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports da_n]; #H08  FMC_LPC_LA02_N
set_property -dict {PACKAGE_PIN M21 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports db_p]; #H10  FMC_LPC_LA04_P
set_property -dict {PACKAGE_PIN M22 IOSTANDARD LVDS_25 DIFF_TERM 1} [get_ports db_n]; #H11  FMC_LPC_LA04_N
set_property -dict {PACKAGE_PIN M19 IOSTANDARD LVDS_25} [get_ports clk_p]; #G06  FMC_LPC_LA00_CC_P
set_property -dict {PACKAGE_PIN M20 IOSTANDARD LVDS_25} [get_ports clk_n]; #G07  FMC_LPC_LA00_CC_N
set_property -dict {PACKAGE_PIN N19 IOSTANDARD LVDS_25} [get_ports cnv_p]; #D08  FMC_LPC_LA01_CC_P
set_property -dict {PACKAGE_PIN N20 IOSTANDARD LVDS_25} [get_ports cnv_n]; #D09  FMC_LPC_LA01_CC_N
set_property -dict {PACKAGE_PIN P22 IOSTANDARD LVCMOS25} [get_ports cnv_en]; #G10  FMC_LPC_LA03_N
set_property -dict {PACKAGE_PIN J20 IOSTANDARD LVCMOS25} [get_ports pd_cntrl]; #G18  FMC_LPC_LA16_P
set_property -dict {PACKAGE_PIN G20 IOSTANDARD LVCMOS25} [get_ports testpat_cntrl]; #G21  FMC_LPC_LA20_P
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS25} [get_ports twolanes_cntrl]; #G24  FMC_LPC_LA22_P

# clocks

create_clock -period 8.333 -name dco [get_ports dco_p]
create_clock -period 8.333 -name ref_clk [get_ports ref_clk_p]
create_clock -period 8.333 -name virtual_clk -waveform {0.225 4.392}

set_clock_latency -source -early 0.3 [get_clocks ref_clk]
set_clock_latency -source -late  1.5 [get_clocks ref_clk]

############ MUST be cnv_en, but then the timing fails with slack of -4.979ns
set_output_delay -clock dco -max 1.4 [get_ports cnv]
set_output_delay -clock dco -min 0.3 [get_ports cnv]

set_multicycle_path 2 -setup -end   -from dco -to ref_clk
set_multicycle_path 1 -hold  -start -from dco -to ref_clk

set_input_delay -clock dco -max 0.2 [get_ports da_p];
set_input_delay -clock dco -min -0.2 [get_ports da_p];
set_input_delay -clock dco -max 0.2 [get_ports da_p] -clock_fall -add_delay;
set_input_delay -clock dco -min -0.2 [get_ports da_p] -clock_fall -add_delay;

set_input_delay -clock dco -max 0.2 [get_ports db_p];
set_input_delay -clock dco -min -0.2 [get_ports db_p];
set_input_delay -clock dco -max 0.2 [get_ports db_p] -clock_fall -add_delay;
set_input_delay -clock dco -min -0.2 [get_ports db_p] -clock_fall -add_delay;

set_property IDELAY_VALUE 27 [get_cells i_system_wrapper/system_i/axi_ltc2387/inst/i_if/i_rx_db/i_rx_data_idelay]
set_property IDELAY_VALUE 27 [get_cells i_system_wrapper/system_i/axi_ltc2387/inst/i_if/i_rx_da/i_rx_data_idelay]
