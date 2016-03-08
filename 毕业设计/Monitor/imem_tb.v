`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   10:04:39 12/01/2015
// Design Name:   imem
// Module Name:   C:/study/Monitor/imem_tb.v
// Project Name:  Monitor
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: imem
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module imem_tb;

	// Inputs
	reg [11:0] a;

	// Outputs
	wire [31:0] spo;

	// Instantiate the Unit Under Test (UUT)
	imem uut (
		.a(a), 
		.spo(spo)
	);

	initial begin
		// Initialize Inputs
		a = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	always #20 a = a + 1;
      
endmodule

