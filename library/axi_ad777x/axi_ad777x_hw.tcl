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

ad_interface clock  adc_clk             output 1
ad_interface reset  adc_reset           output 1 
ad_interface signal adc_valid           output 1
ad_interface signal adc_crc_ch_mismatch output 8 

for {set i 0} {$i < 4} {incr i} {
  add_interface adc_ch_$i conduit end
  add_interface_port adc_enable_$i adc_enable_$i enable Output 1
  add_interface_port adc_data_$i dac_valid_$i data Input 32
  set_interface_property adc_ch_$i associatedClock clk_in
  set_interface_property adc_ch_$i associatedReset none
}

set_interface_property if_rst associatedResetSinks s_axi_reset





