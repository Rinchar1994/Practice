`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:42:18 05/18/2015 
// Design Name: 
// Module Name:    fenpin_uart 
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
module fenpin_uart(
    input clk,
	 output reg clk_1
    );
	 integer i = 0;
	 always @ ( posedge clk )
	 begin
	     i = i + 1;
		  if( i >= 333 )
		  begin
		      clk_1 = ~clk_1;
				i = 0;
		  end
	 end
endmodule
