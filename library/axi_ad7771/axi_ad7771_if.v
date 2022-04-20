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
  input       [ 4:0]      adc_num_lanes,

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
  reg              adc_valid_s;


 
  // internal signals

  wire              adc_cnt_enable_s;
  wire              adc_ready_in_s;
  wire   [  8:0]    adc_cnt_value;
 
  
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

 

 // function (crc)

  function  [ 7:0]  crc8;
    input   [23:0]  din;
    input   [ 7:0]  cin;
    reg     [ 7:0]  cout;
    begin
      cout[ 7] =  cin[ 1] ^ cin[ 2] ^ cin[ 4] ^ cin[ 6] ^ din[ 5] ^ din[ 6] ^ din[ 7] ^ din[11] ^
                  din[13] ^ din[15] ^ din[17] ^ din[18] ^ din[20] ^ din[22];
      cout[ 6] =  cin[ 0] ^ cin[ 1] ^ cin[ 3] ^ cin[ 5] ^ din[ 4] ^ din[ 5] ^ din[ 6] ^ din[10] ^
                  din[12] ^ din[14] ^ din[16] ^ din[17] ^ din[19] ^ din[21];
      cout[ 5] =  cin[ 0] ^ cin[ 2] ^ cin[ 4] ^ din[ 3] ^ din[ 4] ^ din[ 5] ^ din[ 9] ^ din[11] ^
                  din[13] ^ din[15] ^ din[16] ^ din[18] ^ din[20];
      cout[ 4] =  cin[ 1] ^ cin[ 3] ^ din[ 2] ^ din[ 3] ^ din[ 4] ^ din[ 8] ^ din[10] ^ din[12] ^
                  din[14] ^ din[15] ^ din[17] ^ din[19];
      cout[ 3] =  cin[ 0] ^ cin[ 2] ^ cin[ 7] ^ din[ 1] ^ din[ 2] ^ din[ 3] ^ din[ 7] ^ din[ 9] ^
                  din[11] ^ din[13] ^ din[14] ^ din[16] ^ din[18] ^ din[23];
      cout[ 2] =  cin[ 1] ^ cin[ 6] ^ din[ 0] ^ din[ 1] ^ din[ 2] ^ din[ 6] ^ din[ 8] ^ din[10] ^
                  din[12] ^ din[13] ^ din[15] ^ din[17] ^ din[22];
      cout[ 1] =  cin[ 0] ^ cin[ 1] ^ cin[ 2] ^ cin[ 4] ^ cin[ 5] ^ cin[ 6] ^ cin[ 7] ^ din[ 0] ^
                  din[ 1] ^ din[ 6] ^ din[ 9] ^ din[12] ^ din[13] ^ din[14] ^ din[15] ^ din[16] ^
                  din[17] ^ din[18] ^ din[20] ^ din[21] ^ din[22] ^ din[23];
      cout[ 0] =  cin[ 0] ^ cin[ 2] ^ cin[ 3] ^ cin[ 5] ^ cin[ 7] ^ din[ 0] ^ din[ 6] ^ din[ 7] ^
                  din[ 8] ^ din[12] ^ din[14] ^ din[16] ^ din[18] ^ din[19] ^ din[21] ^ din[23];
      crc8 = cout;
    end
  endfunction




 
  // data & status

  always @(posedge adc_clk) begin
  
    if (adc_valid_p == 1'b1) begin


      if( adc_num_lanes == 'h1) begin
        adc_data_0_s <= adc_data_p[((32*7)+31):(32*7)];
        adc_data_1_s <= adc_data_p[((32*6)+31):(32*6)];
        adc_data_2_s <= adc_data_p[((32*5)+31):(32*5)];
        adc_data_3_s <= adc_data_p[((32*4)+31):(32*4)];
        adc_data_4_s <= adc_data_p[((32*3)+31):(32*3)];
        adc_data_5_s <= adc_data_p[((32*2)+31):(32*2)];
        adc_data_6_s <= adc_data_p[((32*1)+31):(32*1)];
        adc_data_7_s <= adc_data_p[((32*0)+31):(32*0)];
      end else if( adc_num_lanes == 'h2) begin
        adc_data_0_s <= adc_data_p[((32*3)+31):(32*3)];
        adc_data_1_s <= adc_data_p[((32*2)+31):(32*2)];
        adc_data_2_s <= adc_data_p[((32*1)+31):(32*1)];
        adc_data_3_s <= adc_data_p[((32*0)+31):(32*0)];
        adc_data_4_s <= adc_data_p[((32*7)+31):(32*7)];
        adc_data_5_s <= adc_data_p[((32*6)+31):(32*6)];
        adc_data_6_s <= adc_data_p[((32*5)+31):(32*5)];
        adc_data_7_s <= adc_data_p[((32*4)+31):(32*4)];
      end else begin
        adc_data_0_s <= adc_data_p[((32*1)+31):(32*1)];
        adc_data_1_s <= adc_data_p[((32*0)+31):(32*0)];
        adc_data_2_s <= adc_data_p[((32*3)+31):(32*3)];
        adc_data_3_s <= adc_data_p[((32*2)+31):(32*2)];
        adc_data_4_s <= adc_data_p[((32*5)+31):(32*5)];
        adc_data_5_s <= adc_data_p[((32*4)+31):(32*4)];
        adc_data_6_s <= adc_data_p[((32*7)+31):(32*7)];
        adc_data_7_s <= adc_data_p[((32*6)+31):(32*6)];
      end
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

 assign adc_cnt_value = (adc_num_lanes == 'h1) ? 'hff :  
                       ((adc_num_lanes == 'h2)? 'h7f : 'h3f);

 assign adc_cnt_enable_s = (adc_cnt_p < adc_cnt_value) ? 1'b1 : 1'b0;

  always @(negedge adc_clk) begin
    
    if (adc_ready_in_s == 1'b1) begin
      adc_cnt_p <= 'h000;
    end else if (adc_cnt_enable_s == 1'b1) begin
      adc_cnt_p <= adc_cnt_p + 1'b1;
    end
     if (adc_cnt_p == adc_cnt_value) begin
      adc_valid_p <= 1'b1;
    end else begin
      adc_valid_p <= 1'b0;
    end
  end
 
  // data (individual lanes)

 

        always @(negedge adc_clk) begin


        if( adc_num_lanes == 'h1) begin 
          if (adc_cnt_p == 'h000 ) begin
            adc_data_p[((256*0)+255):(256*0)] <= {255'd0, data_in[0]};
          end else begin
            adc_data_p[((256*0)+255):(255*0)] <= {adc_data_p[((256*0)+254):(256*0)], data_in[0]};
          end

        end else if( adc_num_lanes == 'h2) begin 
         if (adc_cnt_p == 'h000 ) begin
            adc_data_p[((128*0)+127):(128*0)] <= {127'd0, data_in[0]};
            adc_data_p[((128*1)+127):(128*1)] <= {127'd0, data_in[1]};
          end else begin
            adc_data_p[((128*0)+127):(128*0)] <= {adc_data_p[((128*0)+126):(128*0)], data_in[0]};
            adc_data_p[((128*1)+127):(128*1)] <= {adc_data_p[((128*1)+126):(128*1)], data_in[1]};
          end

        end else begin
         if (adc_cnt_p == 'h000 ) begin
            adc_data_p[((64*0)+63):(64*0)] <= {63'd0, data_in[0]};
            adc_data_p[((64*1)+63):(64*1)] <= {63'd0, data_in[1]};
            adc_data_p[((64*2)+63):(64*2)] <= {63'd0, data_in[2]};
            adc_data_p[((64*3)+63):(64*3)] <= {63'd0, data_in[3]};
          end else begin
            adc_data_p[((64*0)+63):(64*0)] <= {adc_data_p[((64*0)+62):(64*0)], data_in[0]};
            adc_data_p[((64*1)+63):(64*1)] <= {adc_data_p[((64*1)+62):(64*1)], data_in[1]};
            adc_data_p[((64*2)+63):(64*2)] <= {adc_data_p[((64*2)+62):(64*2)], data_in[2]};
            adc_data_p[((64*3)+63):(64*3)] <= {adc_data_p[((64*3)+62):(64*3)], data_in[3]};
          end
        end

    end

endmodule
