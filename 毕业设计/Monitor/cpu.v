module cpu(clk,resetn,RsRx,RsTx,Led);
input clk,resetn,RsRx;
output RsTx;
output [15:0] Led;

wire [31:0] inst,pc,aluout,memout,mem,interout;
wire [31:0] data;
wire wmem,m2reg,clk_cpu,clk_uart,clk_1;

//fenpin clock(clk,clk_cpu,clk_vga,clk_1,clk_half);
fenpin clock(clk,clk_cpu,clk_1);

fenpin_uart clock_uart(clk_1,clk_uart);
wire select_inst = pc[31:11]==0;
wire [31:0] inst_choose, inst_ram;
assign inst_choose = select_inst?inst:inst_ram;
sccpu_dataflow s (clk_cpu,resetn,inst_choose,mem,pc,wmem,m2reg,aluout,data);
imem iram(pc[10:2], inst);
//scimem iram(~clk_cpu, 1'b0, pc[13:2], 32'd0, inst);
wire select_mem = aluout<1024 || aluout>=2048;
//dram dram (~clk_cpu,select_mem & wmem,aluout[9:2],data,memout);
scdatamem dram(clk_cpu, select_mem&wmem, m2reg, aluout, data, memout, pc, inst_ram);
inter device(clk_cpu,clk_uart,resetn,wmem,m2reg,aluout,data,interout,RsRx,RsTx,Led);
assign mem = (aluout>=1024 && aluout<2048)?interout:memout;
endmodule