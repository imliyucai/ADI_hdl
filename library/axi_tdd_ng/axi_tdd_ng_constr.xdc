
set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_burst_count_reg[*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_counter/tdd_burst_counter_reg[*]}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_startup_delay_reg[*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_counter/tdd_delay_done_reg}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_frame_length_reg[*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_counter/tdd_endof_frame_reg}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_sync_period_low_reg[*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_sync_gen/tdd_sync_trigger_reg}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_sync_period_high_reg[*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_sync_gen/tdd_sync_trigger_reg}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/*up_tdd_channel_on_reg[*][*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_channel/tdd_ch_set_reg}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/*up_tdd_channel_off_reg[*][*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_channel/tdd_ch_rst_reg}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_enable_reg}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_regmap/i_tdd_control_sync/cdc_sync_stage1_reg[0]}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_sync_rst_reg}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_regmap/i_tdd_control_sync/cdc_sync_stage1_reg[1]}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_sync_int_reg}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_regmap/i_tdd_control_sync/cdc_sync_stage1_reg[2]}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_sync_ext_reg}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_regmap/i_tdd_control_sync/cdc_sync_stage1_reg[3]}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_channel_en_reg[*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_regmap/i_tdd_ch_en_sync/cdc_sync_stage1_reg[*]}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_regmap/up_tdd_channel_pol_reg[*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_regmap/i_tdd_ch_pol_sync/cdc_sync_stage1_reg[*]}]

set_false_path \
  -from [get_cells -hierarchical * -filter {NAME=~*i_counter/*tdd_cstate_reg[*]}] \
  -to [get_cells -hierarchical * -filter {NAME=~*i_regmap/i_tdd_cstate_sync/cdc_sync_stage1_reg[*]}]

set_false_path \
  -from [get_pins -hierarchical * -filter {NAME=~*/i_tdd_soft_sync/in_toggle_d1_reg/C}] \
  -to [get_pins -hierarchical * -filter {NAME=~*/i_tdd_soft_sync/i_sync_out/cdc_sync_stage1_reg[*]/D}]

set_false_path \
  -from [get_pins -hierarchical * -filter {NAME=~*/i_tdd_soft_sync/out_toggle_d1_reg/C}] \
  -to [get_pins -hierarchical * -filter {NAME=~*/i_tdd_soft_sync/i_sync_in/cdc_sync_stage1_reg[*]/D}]


