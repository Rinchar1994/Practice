`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:49:26 05/18/2015 
// Design Name: 
// Module Name:    inter 
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
module inter(
    input clk_cpu,
	input clk_uart,
	 input reset,
	 input wmem,
	 input m2reg,
    input [31:0] addr,
	input [31:0] data,
    output reg [31:0] interout,
	input RsRx,
	output RsTx,
	output [15:0] Led
    );
     integer i;
	 wire dataready, sent;
	 reg last_dataready, last_sent;
	 assign Led = inter_reg[0][15:0];
	 wire [7:0] datareceived;
	 reg [31:0] inter_reg [0:127];
	 

	 always @ (posedge clk_uart or posedge reset) begin
		 if(reset) begin
			 last_sent <= 1'b0;
			 last_dataready <= 1'b0;
		 end
		 else begin
		     last_sent <= sent;
		     last_dataready <= dataready;
	     end
	 end

	 always @ (negedge clk_cpu or posedge reset)
	 begin
	    if(reset)
		 begin
		    for(i=0; i<128; i=i+1)
			 begin
			    inter_reg[i] <= 32'd0;
			 end
			 interout <= 32'd0;
		 end
		 else begin
		 if(dataready && ~last_dataready)//dataready
		 begin
			 inter_reg[4] <= {24'd0, datareceived};
			 inter_reg[3] <= 32'd1;
		 end
		 if( ~dataready) begin
			 inter_reg[3] <= 32'd0;
		 end
		 if(~last_sent && sent) begin
			 inter_reg[5] <= 32'd2;
			 inter_reg[1] <= 32'd0;
		 end
		 if(~sent) begin
			 inter_reg[5] <= 32'b0;
		 end
		 if(addr==1024 && wmem) begin
			 inter_reg[0] <= data;
		 end
		 if(addr==1028 && wmem) begin
			 inter_reg[1] <= data;
		 end
		 if(addr==1032 && wmem) begin
			 inter_reg[2] <= data;
		 end
		 if(addr==1036 && m2reg) begin
			 interout <= inter_reg[3];
		 end
		 if(addr==1040 && m2reg) begin
			 interout <= inter_reg[4]; 
		 end
		 if(addr==1044 && m2reg) begin
			 interout <= inter_reg[5];
		 end

		 end
	 end
	 

	 rx_module uart_receive( clk_uart, reset, RsRx, dataready, datareceived);
     tx_module uart_transmit(clk_uart, reset, inter_reg[1][0], inter_reg[2][7:0],sent, RsTx);
endmodule
