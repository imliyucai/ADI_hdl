
source $ad_hdl_dir/library/jesd204/scripts/jesd204.tcl

# RX parameters
set RX_NUM_OF_LANES 1        ; # L
set RX_NUM_OF_CONVERTERS 32  ; # M
set RX_SAMPLES_PER_FRAME 1   ; # S
set RX_SAMPLE_WIDTH 16       ; # N/NP

set RX_OCTETS_PER_FRAME [expr $RX_NUM_OF_CONVERTERS * $RX_SAMPLES_PER_FRAME * $RX_SAMPLE_WIDTH / (8*$RX_NUM_OF_LANES)] ; # F = M * S * N' / (8 * L)
set DPW [expr max(4,$RX_OCTETS_PER_FRAME)] ;# max(4,F)

set RX_SAMPLES_PER_CHANNEL [expr $RX_NUM_OF_LANES * 8 * $DPW / ($RX_NUM_OF_CONVERTERS * $RX_SAMPLE_WIDTH)] ; # L * 8* DPW / (M * N')

# fifo size should provide 32ks/ch
# (512*2^15)/32[ch]/16[N/NP]=32ks

set adc_fifo_name axi_ad9083_fifo
set adc_data_width [expr $RX_NUM_OF_LANES * 8 * $DPW]
set adc_dma_data_width $adc_data_width
set adc_fifo_address_width 15

# adc peripherals
# rx_out_clk = ref_clk
# qpll0 selected

ad_ip_instance axi_adxcvr axi_ad9083_rx_xcvr [list \
  NUM_OF_LANES $RX_NUM_OF_LANES \
  QPLL_ENABLE 1 \
  TX_OR_RX_N 0 \
  SYS_CLK_SEL 3 \
  OUT_CLK_SEL 4 \
  ]

adi_axi_jesd204_rx_create axi_ad9083_rx_jesd $RX_NUM_OF_LANES
ad_ip_parameter axi_ad9083_rx_jesd/rx CONFIG.SYSREF_IOB false
ad_ip_parameter axi_ad9083_rx_jesd/rx CONFIG.TPL_DATA_PATH_WIDTH $DPW

ad_ip_instance util_cpack2 util_ad9083_rx_cpack [list \
  NUM_OF_CHANNELS $RX_NUM_OF_CONVERTERS \
  SAMPLES_PER_CHANNEL $RX_SAMPLES_PER_CHANNEL \
  SAMPLE_DATA_WIDTH $RX_SAMPLE_WIDTH \
  ]

adi_tpl_jesd204_rx_create rx_ad9083_tpl_core $RX_NUM_OF_LANES \
                                               $RX_NUM_OF_CONVERTERS \
                                               $RX_SAMPLES_PER_FRAME \
                                               $RX_SAMPLE_WIDTH

ad_adcfifo_create $adc_fifo_name $adc_data_width $adc_dma_data_width $adc_fifo_address_width

ad_ip_instance axi_dmac axi_ad9083_rx_dma [list \
  DMA_TYPE_SRC 1 \
  DMA_TYPE_DEST 0 \
  CYCLIC 0 \
  SYNC_TRANSFER_START 0 \
  DMA_2D_TRANSFER 0 \
  MAX_BYTES_PER_BURST 4096 \
  AXI_SLICE_DEST 1 \
  AXI_SLICE_SRC 1 \
  DMA_LENGTH_WIDTH 24 \
  DMA_DATA_WIDTH_DEST 128 \
  DMA_DATA_WIDTH_SRC $adc_dma_data_width \
]

# common cores
# fPLLClkin = 500 MHz => RX_CLK25_DIV = 20
# fPLLClkout = 5000 MHz
# VCO = 10000 MHz - qpll0

ad_ip_instance util_adxcvr util_ad9083_xcvr [list \
  RX_NUM_OF_LANES $RX_NUM_OF_LANES \
  TX_NUM_OF_LANES 0 \
  QPLL_FBDIV 40 \
  QPLL_REFCLK_DIV 2 \
  RX_OUT_DIV 1 \
  RX_CLK25_DIV 20 \
  POR_CFG 0x0 \
  QPLL_CFG0 0x391c \
  QPLL_CFG1 0x0000 \
  QPLL_CFG1_G3 0x0020 \
  QPLL_CFG2 0x0f80 \
  QPLL_CFG2_G3 0x0f80 \
  QPLL_CFG3 0x0120 \
  QPLL_CFG4 0x0002 \
  QPLL_CP 0x1f \
  QPLL_CP_G3 0x1f \
  QPLL_LPF 0x2ff \
  CH_HSPMUX 0x2424 \
  PREIQ_FREQ_BST 0 \
  RXPI_CFG0 0x0102 \
  RXPI_CFG1 0x15 \
  RXCDR_CFG0 0x3 \
  RXCDR_CFG2_GEN2 0x265 \
  RXCDR_CFG2_GEN4 0x164 \
  RXCDR_CFG3 0x12 \
  RXCDR_CFG3_GEN2 0x12 \
  RXCDR_CFG3_GEN3 0x12 \
  RXCDR_CFG3_GEN4 0x12 \
  RX_WIDEMODE_CDR 0x0 \
  ]

# spi instances

ad_ip_instance axi_quad_spi axi_spi_bus1
ad_ip_parameter axi_spi_bus1 CONFIG.C_USE_STARTUP 0
ad_ip_parameter axi_spi_bus1 CONFIG.C_NUM_SS_BITS 2
ad_ip_parameter axi_spi_bus1 CONFIG.C_SCK_RATIO 8

ad_ip_instance axi_quad_spi axi_spi_adl5960_1
ad_ip_parameter axi_spi_adl5960_1 CONFIG.C_USE_STARTUP 0
ad_ip_parameter axi_spi_adl5960_1 CONFIG.C_NUM_SS_BITS 4
ad_ip_parameter axi_spi_adl5960_1 CONFIG.C_SCK_RATIO 16
ad_ip_parameter axi_spi_adl5960_1 CONFIG.Multiples16 8

ad_ip_instance axi_quad_spi axi_spi_adl5960_2
ad_ip_parameter axi_spi_adl5960_2 CONFIG.C_USE_STARTUP 0
ad_ip_parameter axi_spi_adl5960_2 CONFIG.C_NUM_SS_BITS 4
ad_ip_parameter axi_spi_adl5960_2 CONFIG.C_SCK_RATIO 16
ad_ip_parameter axi_spi_adl5960_2 CONFIG.Multiples16 8

# xcvr interfaces

set rx_ref_clk     rx_ref_clk_0

create_bd_port -dir I $rx_ref_clk
create_bd_port -dir I rx_core_clk_0

ad_connect  $sys_cpu_resetn util_ad9083_xcvr/up_rstn
ad_connect  $sys_cpu_clk util_ad9083_xcvr/up_clk

# Rx
ad_connect ad9083_rx_device_clk rx_core_clk_0
ad_connect ad9083_rx_link_clk util_ad9083_xcvr/rx_out_clk_0

ad_xcvrcon  util_ad9083_xcvr axi_ad9083_rx_xcvr axi_ad9083_rx_jesd {} ad9083_rx_link_clk ad9083_rx_device_clk
ad_xcvrpll $rx_ref_clk util_ad9083_xcvr/qpll_ref_clk_0
for {set i 0} {$i < $RX_NUM_OF_LANES} {incr i} {
  set ch [expr $i]
  ad_xcvrpll  $rx_ref_clk util_ad9083_xcvr/cpll_ref_clk_$ch
  ad_xcvrpll  axi_ad9083_rx_xcvr/up_pll_rst util_ad9083_xcvr/up_cpll_rst_$ch
}

ad_xcvrpll  axi_ad9083_rx_xcvr/up_pll_rst util_ad9083_xcvr/up_qpll_rst_*

# spi interface

create_bd_port -dir O -from 1 -to 0 spi_bus1_csn_o
create_bd_port -dir I -from 1 -to 0 spi_bus1_csn_i
create_bd_port -dir I spi_bus1_clk_i
create_bd_port -dir O spi_bus1_clk_o
create_bd_port -dir I spi_bus1_sdo_i
create_bd_port -dir O spi_bus1_sdo_o
create_bd_port -dir I spi_bus1_sdi_i

ad_connect  sys_cpu_clk  axi_spi_bus1/ext_spi_clk
ad_connect  spi_bus1_csn_i  axi_spi_bus1/ss_i
ad_connect  spi_bus1_csn_o  axi_spi_bus1/ss_o
ad_connect  spi_bus1_clk_i  axi_spi_bus1/sck_i
ad_connect  spi_bus1_clk_o  axi_spi_bus1/sck_o
ad_connect  spi_bus1_sdo_i  axi_spi_bus1/io0_i
ad_connect  spi_bus1_sdo_o  axi_spi_bus1/io0_o
ad_connect  spi_bus1_sdi_i  axi_spi_bus1/io1_i

create_bd_port -dir O -from 1 -to 0 spi_adl5960_1_csn_o
create_bd_port -dir I -from 1 -to 0 spi_adl5960_1_csn_i
create_bd_port -dir I spi_adl5960_1_clk_i
create_bd_port -dir O spi_adl5960_1_clk_o
create_bd_port -dir I spi_adl5960_1_sdo_i
create_bd_port -dir O spi_adl5960_1_sdo_o
create_bd_port -dir I spi_adl5960_1_sdi_i

ad_connect  sys_cpu_clk  axi_spi_adl5960_1/ext_spi_clk
ad_connect  spi_adl5960_1_csn_i  axi_spi_adl5960_1/ss_i
ad_connect  spi_adl5960_1_csn_o  axi_spi_adl5960_1/ss_o
ad_connect  spi_adl5960_1_clk_i  axi_spi_adl5960_1/sck_i
ad_connect  spi_adl5960_1_clk_o  axi_spi_adl5960_1/sck_o
ad_connect  spi_adl5960_1_sdo_i  axi_spi_adl5960_1/io0_i
ad_connect  spi_adl5960_1_sdo_o  axi_spi_adl5960_1/io0_o
ad_connect  spi_adl5960_1_sdi_i  axi_spi_adl5960_1/io1_i

create_bd_port -dir O -from 5 -to 0 spi_adl5960_2_csn_o
create_bd_port -dir I -from 5 -to 0 spi_adl5960_2_csn_i
create_bd_port -dir I spi_adl5960_2_clk_i
create_bd_port -dir O spi_adl5960_2_clk_o
create_bd_port -dir I spi_adl5960_2_sdo_i
create_bd_port -dir O spi_adl5960_2_sdo_o
create_bd_port -dir I spi_adl5960_2_sdi_i

ad_connect  sys_cpu_clk  axi_spi_adl5960_2/ext_spi_clk
ad_connect  spi_adl5960_2_csn_i  axi_spi_adl5960_2/ss_i
ad_connect  spi_adl5960_2_csn_o  axi_spi_adl5960_2/ss_o
ad_connect  spi_adl5960_2_clk_i  axi_spi_adl5960_2/sck_i
ad_connect  spi_adl5960_2_clk_o  axi_spi_adl5960_2/sck_o
ad_connect  spi_adl5960_2_sdo_i  axi_spi_adl5960_2/io0_i
ad_connect  spi_adl5960_2_sdo_o  axi_spi_adl5960_2/io0_o
ad_connect  spi_adl5960_2_sdi_i  axi_spi_adl5960_2/io1_i

# connections (adc)

ad_connect $sys_dma_resetn axi_ad9083_rx_dma/m_dest_axi_aresetn
ad_connect ad9083_rx_device_clk_rstgen/peripheral_reset axi_ad9083_fifo/adc_rst
ad_connect ad9083_rx_device_clk axi_ad9083_fifo/adc_clk
ad_connect $sys_dma_clk axi_ad9083_fifo/dma_clk
ad_connect $sys_dma_clk axi_ad9083_rx_dma/s_axis_aclk

ad_connect util_ad9083_rx_cpack/packed_fifo_wr_data axi_ad9083_fifo/adc_wdata
ad_connect util_ad9083_rx_cpack/packed_fifo_wr_en axi_ad9083_fifo/adc_wr

ad_connect axi_ad9083_fifo/dma_wr axi_ad9083_rx_dma/s_axis_valid
ad_connect axi_ad9083_fifo/dma_wdata axi_ad9083_rx_dma/s_axis_data
ad_connect axi_ad9083_fifo/dma_wready axi_ad9083_rx_dma/s_axis_ready
ad_connect axi_ad9083_fifo/dma_xfer_req axi_ad9083_rx_dma/s_axis_xfer_req

ad_connect ad9083_rx_device_clk rx_ad9083_tpl_core/link_clk
ad_connect ad9083_rx_device_clk util_ad9083_rx_cpack/clk
ad_connect ad9083_rx_device_clk_rstgen/peripheral_reset util_ad9083_rx_cpack/reset

ad_connect axi_ad9083_rx_jesd/rx_sof rx_ad9083_tpl_core/link_sof
ad_connect axi_ad9083_rx_jesd/rx_data_tdata rx_ad9083_tpl_core/link_data
ad_connect axi_ad9083_rx_jesd/rx_data_tvalid rx_ad9083_tpl_core/link_valid

ad_connect rx_ad9083_tpl_core/adc_valid_0 util_ad9083_rx_cpack/fifo_wr_en
ad_connect rx_ad9083_tpl_core/adc_dovf util_ad9083_rx_cpack/fifo_wr_overflow

for {set i 0} {$i < $RX_NUM_OF_CONVERTERS} {incr i} {
  ad_connect  rx_ad9083_tpl_core/adc_enable_$i util_ad9083_rx_cpack/enable_$i
  ad_connect  rx_ad9083_tpl_core/adc_data_$i util_ad9083_rx_cpack/fifo_wr_data_$i
}

# interconnect (cpu)

ad_cpu_interconnect 0x44A00000 rx_ad9083_tpl_core
ad_cpu_interconnect 0x44A60000 axi_ad9083_rx_xcvr
ad_cpu_interconnect 0x44AA0000 axi_ad9083_rx_jesd
ad_cpu_interconnect 0x7c400000 axi_ad9083_rx_dma

ad_cpu_interconnect 0x48000000 axi_spi_bus1
ad_cpu_interconnect 0x48100000 axi_spi_adl5960_1
ad_cpu_interconnect 0x48200000 axi_spi_adl5960_2

ad_mem_hp1_interconnect $sys_cpu_clk sys_ps7/S_AXI_HP1
ad_mem_hp1_interconnect $sys_cpu_clk axi_ad9083_rx_xcvr/m_axi

# interconnect (mem/dac)

ad_mem_hp2_interconnect $sys_dma_clk sys_ps7/S_AXI_HP2
ad_mem_hp2_interconnect $sys_dma_clk axi_ad9083_rx_dma/m_dest_axi

# interrupts

ad_cpu_interrupt ps-9 mb-8   axi_spi_bus1/ip2intc_irpt
ad_cpu_interrupt ps-10 mb-15 axi_spi_adl5960_1/ip2intc_irpt
ad_cpu_interrupt ps-11 mb-14 axi_spi_adl5960_2/ip2intc_irpt
ad_cpu_interrupt ps-12 mb-13 axi_ad9083_rx_jesd/irq
ad_cpu_interrupt ps-13 mb-12 axi_ad9083_rx_dma/irq

# Create dummy outputs for unused Rx lanes
for {set i $RX_NUM_OF_LANES} {$i < 4} {incr i} {
  create_bd_port -dir I rx_data_${i}_n
  create_bd_port -dir I rx_data_${i}_p
}
