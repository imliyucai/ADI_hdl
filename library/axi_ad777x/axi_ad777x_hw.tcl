package require qsys 14.0
package require quartus::device

source ../scripts/adi_env.tcl
source ../scripts/adi_ip_intel.tcl

ad_ip_create axi_ad777x {AXI AD777x Interface} 

ad_ip_files axi_ad777x [list\
  $ad_hdl_dir/library/intel/common/up_xfer_cntrl_constr.sdc \
  $ad_hdl_dir/library/intel/common/up_xfer_status_constr.sdc \
  $ad_hdl_dir/library/intel/common/up_clock_mon_constr.sdc \
  $ad_hdl_dir/library/intel/common/up_rst_constr.sdc \
  $ad_hdl_dir/library/intel/common/ad_dcfilter.v \
  $ad_hdl_dir/library/common/ad_rst.v \
  $ad_hdl_dir/library/common/up_axi.v \
  $ad_hdl_dir/library/common/ad_datafmt.v \
  $ad_hdl_dir/library/common/up_xfer_cntrl.v \
  $ad_hdl_dir/library/common/up_xfer_status.v \
  $ad_hdl_dir/library/common/up_clock_mon.v \
  $ad_hdl_dir/library/common/up_delay_cntrl.v \
  $ad_hdl_dir/library/common/up_adc_channel.v \
  $ad_hdl_dir/library/common/up_adc_common.v \
  axi_ad777x_if.v \
  axi_ad777x.v ]

  #parameters 

  adi_add_auto_fpga_spec_params

  ad_ip_intf_s_axi s_axi_aclk s_axi_aresetn

  # adc clock  interface

add_interface clk_in clock end
add_interface_port clk_in clk_in adc_clk_in Input 1

add_interface adc_if conduit end
set_interface_property adc_if associatedClock clk_in
add_interface_port adc_if  ready_in        adc_ready       Input  1
add_interface_port adc_if  data_in         adc_data_in     Input  4
add_interface_port adc_if  sync_adc_miso   sync_adc_miso   Input  1
add_interface_port adc_if  sync_adc_mosi   sync_adc_mosi   Output 1

ad_interface signal adc_enable_0        output 1
ad_interface signal adc_enable_1        output 1
ad_interface signal adc_enable_2        output 1
ad_interface signal adc_enable_3        output 1
ad_interface signal adc_enable_4        output 1
ad_interface signal adc_enable_5        output 1
ad_interface signal adc_enable_6        output 1
ad_interface signal adc_enable_7        output 1
ad_interface signal adc_data_0          output 32   
ad_interface signal adc_data_1          output 32
ad_interface signal adc_data_2          output 32
ad_interface signal adc_data_3          output 32
ad_interface signal adc_data_4          output 32
ad_interface signal adc_data_5          output 32
ad_interface signal adc_data_6          output 32
ad_interface signal adc_data_7          output 32
ad_interface clock  adc_clk             output 1
ad_interface reset  adc_reset           output 1 
ad_interface signal adc_valid           output 1
ad_interface signal adc_crc_ch_mismatch output 8 

set_interface_property if_rst associatedResetSinks s_axi_reset





