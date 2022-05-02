# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create axi_tdd_ng
adi_ip_files axi_tdd_ng [list \
  "$ad_hdl_dir/library/common/up_axi.v" \
  "$ad_hdl_dir/library/util_cdc/sync_bits.v" \
  "$ad_hdl_dir/library/util_cdc/sync_data.v" \
  "$ad_hdl_dir/library/util_cdc/sync_event.v" \
  "axi_tdd_ng_pkg.sv" \
  "axi_tdd_ng_channel.sv" \
  "axi_tdd_ng_counter.sv" \
  "axi_tdd_ng_regmap.sv" \
  "axi_tdd_ng_sync_gen.sv" \
  "axi_tdd_ng.sv" \
  "axi_tdd_ng_constr.xdc" ]

adi_ip_properties axi_tdd_ng
set_property display_name "ADI AXI TDD Controller" [ipx::current_core]
set_property description "ADI AXI TDD Controller" [ipx::current_core]
set_property company_url {https://wiki.analog.com/resources/fpga/docs/axi_tdd} [ipx::current_core]

adi_init_bd_tcl

proc add_reset {name polarity} {
  set reset_intf [ipx::infer_bus_interface $name xilinx.com:signal:reset_rtl:1.0 [ipx::current_core]]
  set reset_polarity [ipx::add_bus_parameter "POLARITY" $reset_intf]
  set_property value $polarity $reset_polarity
}

ipx::infer_bus_interface clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface s_axi_aclk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

add_reset rst ACTIVE_HIGH
add_reset s_axi_aresetn ACTIVE_LOW

ipx::add_bus_parameter ASSOCIATED_BUSIF [ipx::get_bus_interfaces s_axi_aclk -of_objects [ipx::current_core]]
set_property value s_axi [ipx::get_bus_parameters ASSOCIATED_BUSIF -of_objects [ipx::get_bus_interfaces s_axi_aclk -of_objects [ipx::current_core]]]

ipx::create_xgui_files [ipx::current_core]

ipx::save_core [ipx::current_core]

