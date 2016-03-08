`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:44:42 11/17/2015 
// Design Name: 
// Module Name:    fenpin 
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
module fenpin(clk, clk_cpu, clk_1
    );
	 input clk;
	 output reg clk_cpu, clk_1;
	 integer i;
	 always @ ( posedge clk )
	 begin
	     i = i + 1;
		  if( i >= 9 )
		  begin
		      clk_cpu = ~clk_cpu;
				i = 0;
		  end
	 end
	 
	 assign clk_1 = clk;


endmodule
