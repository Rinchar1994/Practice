`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:11:47 04/28/2015 
// Design Name: 
// Module Name:    vga_display 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module VGA(
    input clk_cpu,
    input clk_vga,
    input reset,
	 input [7:0] datain,
	 input [31:0] addr,
	 input DM_W,
    output  reg [2:0] vgaRed,
    output  reg [2:0] vgaGreen,
    output  reg [1:0] vgaBlue,
    output reg Hsync,
    output reg Vsync,
	 output reg [3:0] dir
    );
	 reg [9:0] x_cnt, y_cnt;
	 //行扫描参数设定
    parameter H_sync = 96;
    parameter H_back_porch = 45;
	 parameter H_active_video_time = 646;
	 parameter H_front_porch = 13;
	 parameter H_Scanline_time = 800;
	 
    //场扫描参数设定
	 parameter V_sync = 2;
	 parameter V_back_porch = 30;
	 parameter V_active_video_time = 484;
	 parameter V_front_porch = 9;
	 parameter V_total_frame_time = 525;
	 
	 //x_cnt
	 always@(posedge clk_vga or posedge reset)
	 begin
	    if(reset)
		    x_cnt <= 10'd1;
		 else if(x_cnt == H_Scanline_time)
		    x_cnt <= 10'd1;
		 else
		    x_cnt <= x_cnt + 10'd1;
	 end
	 
	 //Hsync在0-96时间内为低电平
	 always@(posedge clk_vga or posedge reset)
	 begin
	    if(reset)
		    Hsync <= 1'b1;
		 else if(x_cnt==1)
		    Hsync <= 1'b0;
		 else if(x_cnt==H_sync+1)
		    Hsync <= 1'b1;
	 end
	 
	 //y_cnt
	 always@(posedge clk_vga or posedge reset)
	 begin
	    if(reset)
		    y_cnt <= 10'd1;
		 else if(y_cnt == V_total_frame_time)
		    y_cnt <= 10'd1;
		 else if(x_cnt == H_Scanline_time)
		    y_cnt <= y_cnt + 10'd1;
	 end
	 
	 //Vsync在0-2时间内为低电平
	 always@(posedge clk_vga or posedge reset)
	 begin
	    if(reset)
		    Vsync <= 1'b1;
		 else if(y_cnt==1)
		    Vsync <= 1'b0;
		 else if(y_cnt==V_sync+1)
		    Vsync <= 1'b1;
	 end
	 
	 //有效显示位
	 wire valid;
	 assign valid = (x_cnt > (H_sync+H_back_porch) &&
	                x_cnt <= (H_sync+H_back_porch+H_active_video_time) &&
						 y_cnt > (V_sync+V_back_porch) &&
						 y_cnt <= (V_sync+V_back_porch+V_active_video_time));
						 //划分色块,并往色块寄存器中存入数据,dir四位分别是上下左右
	 reg [7:0] RGB [0:99];
    integer i;
	 always@(posedge clk_cpu or posedge reset)
	 begin
	    if(reset)
		 begin
		    for( i=0; i<100; i=i+1 )
			 begin
			    RGB[i] <= 8'd0;
			 end
			 dir <= 4'b1111;
		 end
		 else if(DM_W==1 && addr[31:11]!= 0)
		 begin
		    RGB[(addr-32'd2048)>>2] <= datain;
			 if(addr == 32'd2048 && datain != 0)
			     dir <= 4'b0101;
			 else if(addr == 32'd2084 && datain != 0)
			     dir <= 4'b0110;
			 else if(addr == 32'd2408 && datain != 0)
			     dir <= 4'b1001;
			 else if(addr == 32'd2444 && datain != 0)
			     dir <= 4'b1010;
			 else if(addr>32'd2048 && addr<32'd2084 && datain != 0)
			     dir <= 4'b0111;
			 else if(addr>32'd2408 && addr<32'd2444 && datain != 0)
			     dir <= 4'b1011;
			 else if((addr==32'd2088 || addr==32'd2128 || addr==32'd2168 || addr==32'd2208 || addr==32'd2248
			         || addr==32'd2288 || addr==32'd2328 || addr==32'd2368) && datain != 0)
			     dir <= 4'b1101;
			 else if((addr==32'd2124 || addr==32'd2164 || addr==32'd2204 || addr==32'd2244 || addr==32'd2284
			         || addr==32'd2324 || addr==32'd2364 || addr==32'd2404) && datain != 0)
			     dir <= 4'b1110;
			 else
			     dir <= 4'b1111;
		 end
	 end


	 
	 //显示色块
	 integer num_h;
	 integer num_v;
	 parameter length_h = 65;
	 parameter length_v = 49;
	 always@(posedge clk_vga or posedge reset)
	 begin
	    if(reset)
		 begin
		    vgaRed<=valid?3'd0:3'd0;
			 vgaGreen<=valid?3'd0:3'd0;
			 vgaBlue<=valid?2'd0:2'd0;
		 end
		 else
		 begin
			    for( num_h=0; num_h < 10; num_h=num_h+1)
				    for( num_v=1; num_v < 10; num_v=num_v+1)
					 begin
						 if( x_cnt > (H_sync+H_back_porch+num_h*length_h) &&
						     x_cnt <= (H_sync+H_back_porch+(num_h+1)*length_h) &&
						     y_cnt > (V_sync+V_back_porch+num_v*length_v) &&
						     y_cnt <= (V_sync+V_back_porch+(num_v+1)*length_v))
						 begin
						    vgaRed <= valid?RGB[num_h+10*num_v][7:5]:3'd0;
						    vgaGreen <= valid?RGB[num_h+10*num_v][4:2]:3'd0;
						    vgaBlue <= valid?RGB[num_h+10*num_v][1:0]:2'd0;
						 end
					 end
				if( y_cnt>=V_sync+V_back_porch && y_cnt<=V_sync+V_back_porch+49 )
            begin
				    if(x_cnt>H_sync+H_back_porch && x_cnt<=H_sync+H_back_porch+24 || 
					    x_cnt>H_sync+H_back_porch+32 && x_cnt<=H_sync+H_back_porch+41 ||
						 x_cnt>H_sync+H_back_porch+41 && x_cnt<=H_sync+H_back_porch+57 && y_cnt>V_sync+V_back_porch+12 && y_cnt<=V_sync+V_back_porch+24 ||
						 x_cnt>H_sync+H_back_porch+49 && x_cnt<=H_sync+H_back_porch+65 && y_cnt>V_sync+V_back_porch+30 && y_cnt<=V_sync+V_back_porch+42 ||
						 x_cnt>H_sync+H_back_porch+65 && x_cnt<=H_sync+H_back_porch+73 ||
						 x_cnt>H_sync+H_back_porch+73 && x_cnt<=H_sync+H_back_porch+89 && y_cnt>V_sync+V_back_porch+30 && y_cnt<=V_sync+V_back_porch+42 ||
						 x_cnt>H_sync+H_back_porch+81 && x_cnt<=H_sync+H_back_porch+97 && y_cnt>V_sync+V_back_porch+12 && y_cnt<=V_sync+V_back_porch+24 ||
						 x_cnt>H_sync+H_back_porch+97 && x_cnt<=H_sync+H_back_porch+106 ||
						 x_cnt>H_sync+H_back_porch+106 && x_cnt<=H_sync+H_back_porch+122 && y_cnt>V_sync+V_back_porch+12 && y_cnt<=V_sync+V_back_porch+24 ||
						 x_cnt>H_sync+H_back_porch+114 && x_cnt<=H_sync+H_back_porch+130 && y_cnt>V_sync+V_back_porch+30 && y_cnt<=V_sync+V_back_porch+42 ||
						 x_cnt>H_sync+H_back_porch+130 && x_cnt<=H_sync+H_back_porch+138 ||
						 x_cnt>H_sync+H_back_porch+138 && x_cnt<=H_sync+H_back_porch+154 && y_cnt>V_sync+V_back_porch+12 && y_cnt<=V_sync+V_back_porch+24 ||
						 x_cnt>H_sync+H_back_porch+138 && x_cnt<=H_sync+H_back_porch+154 && y_cnt>V_sync+V_back_porch+30 && y_cnt<=V_sync+V_back_porch+42 ||
						 x_cnt>H_sync+H_back_porch+162 && x_cnt<=H_sync+H_back_porch+171 ||
						 x_cnt>H_sync+H_back_porch+179 && x_cnt<=H_sync+H_back_porch+195 && y_cnt>V_sync+V_back_porch+12 && y_cnt<=V_sync+V_back_porch+24 ||
						 x_cnt>H_sync+H_back_porch+179 && x_cnt<=H_sync+H_back_porch+187 && y_cnt>V_sync+V_back_porch+30 && y_cnt<=V_sync+V_back_porch+42 ||
						 x_cnt>H_sync+H_back_porch+195 && x_cnt<=H_sync+H_back_porch+203 ||
						 x_cnt>H_sync+H_back_porch+211 && x_cnt<=H_sync+H_back_porch+227 && y_cnt>V_sync+V_back_porch+12 && y_cnt<=V_sync+V_back_porch+24 ||
						 x_cnt>H_sync+H_back_porch+211 && x_cnt<=H_sync+H_back_porch+219 && y_cnt>V_sync+V_back_porch+30 && y_cnt<=V_sync+V_back_porch+42 ||
						 x_cnt>H_sync+H_back_porch+227 && x_cnt<=H_sync+H_back_porch+236 ||
						 x_cnt>H_sync+H_back_porch+236 && x_cnt<=H_sync+H_back_porch+252 && y_cnt>V_sync+V_back_porch && y_cnt<=V_sync+V_back_porch+42 ||
						 x_cnt>H_sync+H_back_porch+260 && x_cnt<=H_sync+H_back_porch+268 ||
						 x_cnt>H_sync+H_back_porch+276 && x_cnt<=H_sync+H_back_porch+292 && y_cnt>V_sync+V_back_porch && y_cnt<=V_sync+V_back_porch+42 ||
						 x_cnt>H_sync+H_back_porch+292 && x_cnt<=H_sync+H_back_porch+301 ||
						 x_cnt>H_sync+H_back_porch+309 && x_cnt<=H_sync+H_back_porch+325 && y_cnt>V_sync+V_back_porch+12 && y_cnt<=V_sync+V_back_porch+42)
						 begin
						    vgaRed <= valid?3'd0:3'd0;
						    vgaGreen <= valid?3'd0:3'd0;
						    vgaBlue <= valid?2'd0:2'd0;
						 end
						 else if(x_cnt>H_sync+H_back_porch+325 && x_cnt<=H_sync+H_back_porch+650)
						 begin
						     for(num_h=0; num_h<5; num_h=num_h+1)
							  begin
							      if(x_cnt > (H_sync+H_back_porch+num_h*length_h+325) &&
						            x_cnt <= (H_sync+H_back_porch+(num_h+1)*length_h+325))
                           begin
									    vgaRed <= valid?RGB[num_h+5][7:5]:3'd0;
						             vgaGreen <= valid?RGB[num_h+5][4:2]:3'd0;
						             vgaBlue <= valid?RGB[num_h+5][1:0]:2'd0;
                           end									
							  end
                   end
                   else
                   begin
						    vgaRed <= valid?RGB[0][7:5]:3'd0;
						    vgaGreen <= valid?RGB[0][4:2]:3'd0;
						    vgaBlue <= valid?RGB[0][1:0]:2'd0;
                   end						 
            end			
		 end
	 end

endmodule
