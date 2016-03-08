`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:47:08 05/18/2015 
// Design Name: 
// Module Name:    dff32 
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
module dff32(d,clk,clrn,q);
	input clk,clrn;
	input [31:0] d;
	output reg [31:0] q;
	always @ (posedge clk or posedge clrn) begin
		if (clrn == 1) q=0;
		else				q=d;
	end
endmodule
