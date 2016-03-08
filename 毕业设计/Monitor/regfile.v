`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:47:37 05/18/2015 
// Design Name: 
// Module Name:    regfile 
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
module regfile (rna,rnb,d,wn,we,clk,clrn,qa,qb);
input [4:0] rna,rnb,wn;
input [31:0] d;
input			 we,clk,clrn;
output [31:0] qa,qb;
reg	[31:0] register [0:31];
assign qa = (rna == 0)? 0 : register[rna];
assign qb = (rnb == 0)? 0 : register[rnb];
integer i;
always @ (posedge clk or posedge clrn)

	if(clrn == 1)begin
	
	   for (i=0; i<32 ; i=i+1)
		     register[i] =0;
	end 
	
	else if((wn != 0) && we)
		 register[wn] =d;
endmodule 
