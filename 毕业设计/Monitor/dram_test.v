`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:35:33 11/30/2015
// Design Name:   dram
// Module Name:   C:/study/Monitor/dram_test.v
// Project Name:  Monitor
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: dram
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module dram_test;

	// Inputs
	reg clka;
	reg [0:0] wea;
	reg [7:0] addra;
	reg [31:0] dina;

	// Outputs
	wire [31:0] douta;

	// Instantiate the Unit Under Test (UUT)
	dram uut (
		.clka(clka), 
		.wea(wea), 
		.addra(addra), 
		.dina(dina), 
		.douta(douta)
	);

	initial begin
		// Initialize Inputs
		clka = 0;
		wea = 0;
		addra = 0;
		dina = 0;

		// Wait 100 ns for global reset to finish

	end
	always #10 begin clka = ~clka;  end
	always #20 begin
	    dina <= dina + 2; 
		 addra <= addra + 1; 
		 end
      
endmodule

