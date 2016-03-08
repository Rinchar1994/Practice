`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:37:35 11/30/2015
// Design Name:   scimem
// Module Name:   C:/study/Monitor/scimem_tb.v
// Project Name:  Monitor
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: scimem
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module scimem_tb;

	// Inputs
	reg [11:0] addra;

	// Outputs
	wire [31:0] douta;

	// Instantiate the Unit Under Test (UUT)
	scimem uut ( 
		.addra(addra),  
		.douta(douta)
	);

	initial begin
		// Initialize Inputs
		addra = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		

	end
	always #20 addra = addra +1;
      
endmodule

