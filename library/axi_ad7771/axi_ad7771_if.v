// ***************************************************************************
// ***************************************************************************
// Copyright 2014 - 2017 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module axi_ad7771_if (

  // device-interface

  input                   clk_in,
  input                   ready_in,
  output                  sync_in_n,
  input                   sync_out_n,
  input       [ 3:0]      data_in,

  // data path interface

  output                  adc_clk,
  output                  adc_valid,

  output   [ 31:0]       adc_data_0,
  output   [ 31:0]       adc_data_1,
  output   [ 31:0]       adc_data_2,
  output   [ 31:0]       adc_data_3,
  output   [ 31:0]       adc_data_4,
  output   [ 31:0]       adc_data_5,
  output   [ 31:0]       adc_data_6,
  output   [ 31:0]       adc_data_7);

  // internal registers


  reg     [ 31:0]   adc_ch_data_0 = 'd0;
  reg     [ 31:0]   adc_ch_data_1 = 'd0;
  reg     [ 31:0]   adc_ch_data_2 = 'd0;
  reg     [ 31:0]   adc_ch_data_3 = 'd0;
  reg     [ 31:0]   adc_ch_data_4 = 'd0;
  reg     [ 31:0]   adc_ch_data_5 = 'd0;
  reg     [ 31:0]   adc_ch_data_6 = 'd0;
  reg     [ 31:0]   adc_ch_data_7 = 'd0;
 
  reg     [  8:0]   adc_cnt_p = 'd0;
  reg               adc_valid_p = 'd0;
  reg     [255:0]   adc_data_p = 'd0;

  reg    [ 31:0]   adc_data_0_s; 
  reg    [ 31:0]   adc_data_1_s;
  reg    [ 31:0]   adc_data_2_s;
  reg    [ 31:0]   adc_data_3_s;
  reg    [ 31:0]   adc_data_4_s;
  reg    [ 31:0]   adc_data_5_s;
  reg    [ 31:0]   adc_data_6_s;
  reg    [ 31:0]   adc_data_7_s; 

  reg    [ 3:0]    adc_data_valid='b0;
  


 
  // internal signals

  wire              adc_cnt_enable_s;
  wire              adc_ready_in_s;

  reg              adc_valid_s;



  assign adc_valid = adc_valid_s;
  assign adc_ready_in_s = ready_in;
  assign adc_data_0 = adc_data_0_s;
  assign adc_data_1 = adc_data_1_s;
  assign adc_data_2 = adc_data_2_s;
  assign adc_data_3 = adc_data_3_s;
  assign adc_data_4 = adc_data_4_s;
  assign adc_data_5 = adc_data_5_s;
  assign adc_data_6 = adc_data_6_s;
  assign adc_data_7 = adc_data_7_s;
  assign sync_in_n  = sync_out_n;
  assign adc_clk  = clk_in;
 
  // data & status

  always @(posedge adc_clk) begin
  
    if (adc_valid_p == 1'b1) begin
    
      adc_data_0_s <= adc_data_p[((32*1)+31):(32*1)];
      adc_data_1_s <= adc_data_p[((32*0)+31):(32*0)];
      adc_data_2_s <= adc_data_p[((32*3)+31):(32*3)];
      adc_data_3_s <= adc_data_p[((32*2)+31):(32*2)];
      adc_data_4_s <= adc_data_p[((32*5)+31):(32*5)];
      adc_data_5_s <= adc_data_p[((32*4)+31):(32*4)];
      adc_data_6_s <= adc_data_p[((32*7)+31):(32*7)];
      adc_data_7_s <= adc_data_p[((32*6)+31):(32*6)];
      adc_valid_s   <= adc_valid_p;
    end else begin
      adc_data_0_s <= 32'b0;
      adc_data_1_s <= 32'b0;
      adc_data_2_s <= 32'b0;
      adc_data_3_s <= 32'b0;
      adc_data_4_s <= 32'b0;
      adc_data_5_s <= 32'b0;
      adc_data_6_s <= 32'b0;
      adc_data_7_s <= 32'b0;
	  adc_valid_s  <=  1'b0;
    end 
  end



  assign adc_cnt_enable_s = (adc_cnt_p < 'h03f) ? 1'b1 : 1'b0;

  always @(negedge adc_clk) begin
    if (adc_ready_in_s == 1'b1) begin
      adc_cnt_p <= 'h000;
    end else if (adc_cnt_enable_s == 1'b1) begin
      adc_cnt_p <= adc_cnt_p + 1'b1;
    end
     if (adc_cnt_p == 'h03f) begin
      adc_valid_p <= 1'b1;
    end else begin
      adc_valid_p <= 1'b0;
    end
  end
 
  // data (individual lanes)

  genvar n;
  generate
    for (n = 0; n < 4; n = n + 1) begin: g_data
      always @(negedge adc_clk) begin
        if (adc_cnt_p == 'h000 ) begin
          adc_data_p[((64*n)+63):(64*n)] <= {63'd0, data_in[n]};
        end else begin
          adc_data_p[((64*n)+63):(64*n)] <= {adc_data_p[((64*n)+62):(64*n)], data_in[n]};
        end
      end
    end
  endgenerate

endmodule
