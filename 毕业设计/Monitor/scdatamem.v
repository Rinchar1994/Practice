`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:45:16 05/18/2015 
// Design Name: 
// Module Name:    scdatamem 
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
module scdatamem#(parameter DEPTH = 1024)(
    input clk,
    input wmem,
	 input m2reg,
    input [31:0] addr,
    input [31:0] wdata,
    output[31:0] rdata,
	 input [31:0] pc,
	 output[31:0] inst
    );
reg [31:0] RAM[DEPTH-1:0];
assign rdata = RAM[addr[31:2]];
assign inst = RAM[pc[31:2]];

always@(posedge clk)
	   if(wmem)
		  begin
	     RAM[addr[31:2]] <= wdata;
		  end
endmodule 
