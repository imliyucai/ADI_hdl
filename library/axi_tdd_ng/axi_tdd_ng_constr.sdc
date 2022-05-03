set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_burst_count[*]}] \
  -to [get_registers {*|i_counter|tdd_burst_counter[*]}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_startup_delay[*]}] \
  -to [get_registers {*|i_counter|tdd_delay_done}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_frame_length[*]}] \
  -to [get_registers {*|i_counter|tdd_endof_frame}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_sync_period_low[*]}] \
  -to [get_registers {*|i_sync_gen|tdd_sync_trigger}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_sync_period_high[*]}] \
  -to [get_registers {*|i_sync_gen|tdd_sync_trigger}]

set_false_path \
  -from [get_registers {*|i_regmap|up_tdd_channel_pol[*]}] \
  -to [get_registers {*|[*].i_channel|out}]

set_false_path \
  -from [get_registers {*|i_regmap|*up_tdd_channel_on[*][*]}] \
  -to [get_registers {*|[*].i_channel|tdd_ch_set}]

set_false_path \
  -from [get_registers {*|i_regmap|*up_tdd_channel_off[*][*]}] \
  -to [get_registers {*|[*].i_channel|tdd_ch_rst}]

util_cdc_sync_bits_constr {*|axi_tdd_ng_regmap:i_regmap|sync_bits:i_tdd_control_sync}

util_cdc_sync_bits_constr {*|axi_tdd_ng_regmap:i_regmap|sync_bits:i_tdd_ch_en_sync}

util_cdc_sync_data_constr {*|axi_tdd_ng_regmap:i_regmap|sync_data:i_tdd_cstate_sync}

util_cdc_sync_event_constr {*|axi_tdd_ng_regmap:i_regmap|sync_event:i_tdd_soft_sync}

