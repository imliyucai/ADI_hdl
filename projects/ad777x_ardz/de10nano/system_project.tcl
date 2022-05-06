set REQUIRED_QUARTUS_VERSION 20.1.1
set QUARTUS_PRO_ISUSED 0
source ../../scripts/adi_env.tcl
source ../../scripts/adi_project_intel.tcl

adi_project ad777x_ardz_de10nano

source $ad_hdl_dir/projects/common/de10nano/de10nano_system_assign.tcl

# ad777x interface

set_location_assignment PIN_AH12 -to adc_clk_in     ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to spi_csn        ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to spi_mosi       ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to spi_miso       ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to spi_clk        ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to sdp_mclk       ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to adc_ready_in   ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to adc_data_in[0] ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to adc_data_in[1] ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to adc_data_in[2] ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to adc_data_in[3] ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to start_n        ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to reset_n        ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to sdp_convst     ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to start_n        ; ##   Arduino_IO13              
set_location_assignment PIN_AH12 -to reset_n        ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to sdp_convst     ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to alert          ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to sync_adc_miso  ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to sync_adc_mosi  ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to gpio0          ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to gpio1          ; ##   Arduino_IO13
set_location_assignment PIN_AH12 -to gpio2          ; ##   Arduino_IO13

set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to adc_clk_in   
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_csn      
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_mosi     
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_miso     
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to spi_clk      
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdp_mclk     
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to adc_ready_in 
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to adc_data_in[0
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to adc_data_in[1
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to adc_data_in[2
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to adc_data_in[3
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to start_n      
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset_n      
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdp_convst   
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to start_n      
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to reset_n      
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sdp_convst   
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to alert        
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sync_adc_miso
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to sync_adc_mosi
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio0        
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio1        
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to gpio2        

execute_flow -compile

