`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:19:33 12/01/2015
// Design Name:   cpu
// Module Name:   C:/study/Monitor/cpu_tb.v
// Project Name:  Monitor
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cpu
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cpu_tb;

	// Inputs
	reg clk;
	reg resetn;
	reg RsRx;

	// Outputs
	wire RsTx;
	wire [15:0] Led;

	// Instantiate the Unit Under Test (UUT)
	cpu uut (
		.clk(clk), 
		.resetn(resetn), 
		.RsRx(RsRx), 
		.RsTx(RsTx), 
		.Led(Led)
	);
	integer file_output;
	integer coun = 0;

	initial begin
		// Initialize Inputs
		file_output = $fopen("result.txt");
		clk = 0;
		resetn = 1;
		RsRx = 0;

		// Wait 100 ns for global reset to finish
		#10;
		resetn = 0;
        
		// Add stimulus here

	end
	always #10 clk = ~clk;
	
	always @ (posedge clk) begin
		for(; coun < 10; coun = coun + 1) begin
			$display(file_output, "inst = %h", uut.inst);
			$display(file_output, "pc   = %h", uut.s.pc);
		end
	end
      
endmodule

