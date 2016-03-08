`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:48:03 05/18/2015 
// Design Name: 
// Module Name:    alu 
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
module alu (a,b,aluc,r,zero,overflow);
reg [4:0] temp;
input [31:0] a;
input [31:0] b;
input [3:0] aluc;
output reg[31:0] r;
output reg zero;
reg carry; 
reg negative; 
output reg overflow;
always @(a or b or aluc) begin
casex(aluc)
	4'b0000 : begin r=a+b;if  (r<a||r<b)carry=1; else carry=0; negative=0; zero=(r==0)? 1:0; overflow=0;end
	4'b0010 : begin r = a + b;if (a[31]&&!b[31]) overflow = 0;else if (!a[31]&&b[31] )  overflow = 0; else if (a[31]&&b[31]&&r[31]) overflow = 0;else if  (!a[31]&&!b[31]&&!r[31]) overflow = 0;else begin overflow = 1;r= 0;end zero=(r==0)? 1:0;carry=0;negative=(r[31]==1)? 1:0;end
	4'b0001 : begin r=a-b; negative=(r[31]==1)? 1:0; if (a<b)carry=1; else carry=0;  zero=(r==0)? 1:0; carry=0;end
	4'b0011 : begin r=a-b;if ((a[31]!=b[31]&&b[31]==r[31])) begin overflow = 1;temp = 0;end else overflow = 0;if (r ==0) zero =1 ; else zero = 0;if (r[31])negative = 1 ;else negative = 0;carry = 0;end
	4'b0100 : begin r=a & b; negative=(r[31]==1)? 1:0; zero=(r==0)? 1:0; carry=0;overflow=0;end
	4'b0101 : begin r=a | b; negative=(r[31]==1)? 1:0; zero=(r==0)? 1:0; carry=0;overflow=0;end
	4'b0110 : begin r=a ^ b; negative=(r[31]==1)? 1:0; zero=(r==0)? 1:0; carry=0;overflow=0;end
	4'b0111 : begin r=~(a|b); negative=(r[31]==1)? 1:0; zero=(r==0)? 1:0; carry=0;overflow=0;end
	4'b100x : begin r={b[15:0],16'b0} ; negative=(r[31]==1)? 1:0; zero=(r==0)? 1:0; carry=0;overflow=0;end
	4'b1011 : begin r=($signed(a)<$signed(b))?1:0; negative=0; zero=(r==0)? 1:0;carry=0;overflow=0;end
	4'b1010 : begin r=(a<b)?1:0; negative=0; zero=(r==0)? 1:0; if(a<b) carry=1;else carry=0;overflow=0;end
	4'b1100 : begin temp=a[4:0]; r=$signed(b)>>>a;if(temp==0)carry=0;else carry=b[a-1]; negative=(r[31]==1)? 1:0; zero=(r==0)? 1:0; overflow=0; end
	4'b111x : begin temp = a[4:0]; r=(b<<temp); if(temp==0)carry=0;else carry=b[32-a]; negative=(r[31]==1)? 1:0; zero=(r==0)? 1:0;overflow=0;end
	4'b1101 : begin temp = a[4:0]; r=(b>>temp); if(temp==0)carry=0;else carry=b[a-1]; negative=(r[31]==1)? 1:0; zero=(r==0)? 1:0; overflow=0;end	
endcase
end
endmodule
