
create_bd_intf_port -mode Master -vlnv analog.com:interface:spi_master_rtl:1.0 ad4134_di
create_bd_port -dir O ad4134_odr

create_bd_cell -type hier ad4134_spi
current_bd_instance /ad4134_spi

  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type clk spi_clk
  create_bd_pin -dir I -type rst resetn
  create_bd_pin -dir I odr
  create_bd_pin -dir O irq
  create_bd_intf_pin -mode Master -vlnv analog.com:interface:spi_master_rtl:1.0 m_spi
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_SAMPLE

  set data_width 32

  ad_ip_instance spi_engine_execution execution
  ad_ip_parameter execution CONFIG.DATA_WIDTH $data_width
  ad_ip_parameter execution CONFIG.NUM_OF_CS 1
  ad_ip_parameter execution CONFIG.NUM_OF_SDI $adc_num_of_channels

  ad_ip_instance axi_spi_engine axi
  ad_ip_parameter axi CONFIG.DATA_WIDTH $data_width
  ad_ip_parameter axi CONFIG.NUM_OF_SDI $adc_num_of_channels
  ad_ip_parameter axi CONFIG.NUM_OFFLOAD 1
  ad_ip_parameter axi CONFIG.ASYNC_SPI_CLK 1

  ad_ip_instance spi_engine_offload offload
  ad_ip_parameter offload CONFIG.DATA_WIDTH $data_width
  ad_ip_parameter offload CONFIG.NUM_OF_SDI $adc_num_of_channels
  ad_ip_parameter offload CONFIG.ASYNC_TRIG 1
  ad_ip_parameter offload CONFIG.ASYNC_SPI_CLK 1

  ad_ip_instance spi_engine_interconnect interconnect
  ad_ip_parameter interconnect CONFIG.DATA_WIDTH $data_width
  ad_ip_parameter interconnect CONFIG.NUM_OF_SDI $adc_num_of_channels

  ad_connect axi/spi_engine_offload_ctrl0 offload/spi_engine_offload_ctrl
  ad_connect offload/spi_engine_ctrl interconnect/s0_ctrl
  ad_connect axi/spi_engine_ctrl interconnect/s1_ctrl
  ad_connect interconnect/m_ctrl execution/ctrl

  ad_connect offload/offload_sdi M_AXIS_SAMPLE

  ad_connect execution/spi m_spi

  ad_connect spi_clk offload/spi_clk
  ad_connect spi_clk offload/ctrl_clk
  ad_connect spi_clk execution/clk
  ad_connect clk axi/s_axi_aclk
  ad_connect spi_clk axi/spi_clk
  ad_connect spi_clk interconnect/clk

  ad_connect axi/spi_resetn offload/spi_resetn
  ad_connect axi/spi_resetn execution/resetn
  ad_connect axi/spi_resetn interconnect/resetn

  ad_connect odr offload/trigger

  ad_connect resetn axi/s_axi_aresetn
  ad_connect irq axi/irq

current_bd_instance /

# clkgen

ad_ip_instance axi_clkgen axi_ad4134_clkgen
ad_ip_parameter axi_ad4134_clkgen CONFIG.VCO_DIV 5
ad_ip_parameter axi_ad4134_clkgen CONFIG.VCO_MUL 48
ad_ip_parameter axi_ad4134_clkgen CONFIG.CLK0_DIV 10

# dma to receive data stream

ad_ip_instance axi_dmac axi_ad4134_dma
ad_ip_parameter axi_ad4134_dma CONFIG.DMA_TYPE_SRC 1
ad_ip_parameter axi_ad4134_dma CONFIG.DMA_TYPE_DEST 0
ad_ip_parameter axi_ad4134_dma CONFIG.CYCLIC 0
ad_ip_parameter axi_ad4134_dma CONFIG.SYNC_TRANSFER_START 0
ad_ip_parameter axi_ad4134_dma CONFIG.DMA_2D_TRANSFER 0
ad_ip_parameter axi_ad4134_dma CONFIG.DMA_DATA_WIDTH_SRC [expr $data_width * $adc_num_of_channels]
ad_ip_parameter axi_ad4134_dma CONFIG.DMA_DATA_WIDTH_DEST 64

# odr generator

ad_ip_instance axi_pwm_gen odr_generator
ad_ip_parameter odr_generator CONFIG.N_PWMS 1
ad_ip_parameter odr_generator CONFIG.PULSE_0_PERIOD 10000
ad_ip_parameter odr_generator CONFIG.PULSE_0_WIDTH 4
ad_ip_parameter odr_generator CONFIG.ASYNC_CLK_EN 0

create_bd_cell -type module -reference sync_bits busy_sync
create_bd_cell -type module -reference ad_edge_detect busy_capture
set_property -dict [list CONFIG.EDGE 1] [get_bd_cells busy_capture]

ad_connect odr_generator/pwm_0 ad4134_odr

ad_connect axi_ad4134_clkgen/clk_0 busy_capture/clk
ad_connect axi_ad4134_clkgen/clk_0 busy_sync/out_clk
ad_connect busy_capture/rst GND
ad_connect ad4134_spi/axi/spi_resetn busy_sync/out_resetn

ad_connect ad4134_odr busy_sync/in_bits
ad_connect busy_sync/out_bits busy_capture/signal_in
ad_connect busy_capture/signal_out ad4134_spi/odr

ad_connect  axi_ad4134_clkgen/clk_0 ad4134_spi/spi_clk
ad_connect  sys_cpu_clk axi_ad4134_clkgen/clk
ad_connect  sys_cpu_clk ad4134_spi/clk
ad_connect  axi_ad4134_clkgen/clk_0 axi_ad4134_dma/s_axis_aclk
ad_connect  sys_cpu_resetn ad4134_spi/resetn
ad_connect  sys_cpu_resetn axi_ad4134_dma/m_dest_axi_aresetn

ad_connect  ad4134_spi/m_spi ad4134_di
ad_connect  axi_ad4134_dma/s_axis ad4134_spi/M_AXIS_SAMPLE

ad_cpu_interconnect 0x44a00000 ad4134_spi/axi
ad_cpu_interconnect 0x44a30000 axi_ad4134_dma
ad_cpu_interconnect 0x44b00000 odr_generator
ad_cpu_interconnect 0x44b10000 axi_ad4134_clkgen

ad_cpu_interrupt "ps-13" "mb-13" axi_ad4134_dma/irq
ad_cpu_interrupt "ps-12" "mb-12" ad4134_spi/irq

ad_mem_hp0_interconnect sys_cpu_clk axi_ad4134_dma/m_dest_axi

