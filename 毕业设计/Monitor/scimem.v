`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:35:51 11/17/2015 
// Design Name: 
// Module Name:    scimem 
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
module scimem(
     input [11:0] addr,
	  output [31:0] inst
     );
	 reg [31:0] data_temp;
	 assign inst = data_temp;
	 reg [31:0] my_men [0:2047];
	 initial $readmemh("inst.txt", my_men);
	 always @ ( * ) begin
	      data_temp = my_men[addr>>>2];
	 end

endmodule
