`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:49:47 04/27/2015 
// Design Name: 
// Module Name:    tx_transena 
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
module tx_transena(
    input clk,
    input reset,
    input [31:0] addr,
    input DM_W,
    output reg trans_ena
    );
	 reg state;
	 always@( posedge clk or posedge reset )
	 begin
	     if( reset )
		  begin
		      trans_ena <= 0;
				state <= 0;
		  end
		  else if( addr==32'd1044 && DM_W==1 )
		  begin
		      if(state)
				    trans_ena <= 0;
				else
				begin
				    trans_ena <= 1;
					 state <= 1;
				end
		  end
		  else
		  begin
		      trans_ena <= 0;
				state <= 0;
		  end
	 end


endmodule
