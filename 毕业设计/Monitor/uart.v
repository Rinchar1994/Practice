module uart_receiver(
  input clk,
  input bit_in,
  output reg received,
  output reg [7:0] data_out
);
  reg last_bit;
  reg receiving = 0;
  reg [7:0] count;
  always@(posedge clk) begin
    if (~receiving & last_bit & ~bit_in) begin
	   receiving <= 1;
		received <= 0;
		count <= 0;
	 end
	 last_bit <= bit_in;
	 if (receiving)
	   count <= count + 1'b1;
	 else
	   count <= 0;
    case (count)
	   8'd24: data_out[0] <= bit_in;
		8'd40: data_out[1] <= bit_in;
		8'd56: data_out[2] <= bit_in;
		8'd72: data_out[3] <= bit_in;
		8'd88: data_out[4] <= bit_in;
		8'd104: data_out[5] <= bit_in;
		8'd120: data_out[6] <= bit_in;
		8'd136: data_out[7] <= bit_in;
		8'd152: begin
		  received <= 1;
		  receiving <= 0;
		end
	 endcase
  end
endmodule

module uart_transmitter(
  input clk,
  input [7:0] data_transmit,
  input ena,
  output reg sent,
  output reg bit_out
);
  reg last_ena;
  reg sending = 0;
  reg[7:0] count;
  reg[7:0] temp;
  always@(posedge clk) begin
    if (~sending & ~last_ena & ena) begin
	   temp <= data_transmit;
		sending <= 1;
		sent <= 0;
		count <= 0;
	 end
	 last_ena <= ena;
	 if (sending)
	   count <= count+1;
	 else begin
	   count <= 0;
		bit_out <= 1'b1;
	 end
	 case (count)
	   8'd8: bit_out <= 1'b0;
	   8'd24: bit_out <= temp[0];
		8'd40: bit_out <= temp[1];
		8'd56: bit_out <= temp[2];
		8'd72: bit_out <= temp[3];
		8'd88: bit_out <= temp[4];
		8'd104: bit_out <= temp[5];
		8'd120: bit_out <= temp[6];
		8'd136: bit_out <= temp[7];
		8'd152: begin
		  sent <= 1'b1;
		  sending <= 0;
		end
	  endcase
  end
endmodule

module uart(
	input clk,
	input bit_in,
	output bit_out,
	input [7:0] data_in,
	output [7:0] data_out,
	output sent,
	output received,
	input ena
);
  uart_receiver receiver(clk, bit_in, received, data_out);
  uart_transmitter transmitter(clk, data_in, ena, sent, bit_out);
endmodule
