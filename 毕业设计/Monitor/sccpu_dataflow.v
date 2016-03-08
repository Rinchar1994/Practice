`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:43:35 05/18/2015 
// Design Name: 
// Module Name:    sccpu_dataflow 
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
module sccpu_dataflow (clock,resetn,inst,mem,pc,wmem,m2reg,alu,data);

input [31:0] inst,mem;
input clock,resetn;
output [31:0] pc,alu,data;
output wmem,m2reg;
wire [31:0] p4,p8,bpc,npc,adr,ra,alua,alub,res,alu_mem;
wire [3:0] aluc;
wire [4:0] reg_dest,wn;
wire [1:0] pcsourse;
wire 		  zero,overflow,wmem,wreg01,wreg02,regrt,m2reg,shift,aluimm,jal,sext;
wire [31:0] sa={27'b0,inst[10:6]};
wire			e=sext & inst[15];
wire [15:0] imm = {16{e}};
wire [31:0] offset = {imm[13:0],inst[15:0],2'b00};
sccu_dataflow cu (inst[31:26],inst[5:0],zero,wmem,wreg01,regrt,
						m2reg,aluc,shift,aluimm,pcsourse,jal,sext);


wire [31:0] immediate = {imm,inst[15:0]};
dff32	ip(npc,clock,resetn,pc);


assign p4=pc+4;
assign adr=pc+offset;
assign  p8=p4+4;
assign  wreg02=wreg01 & ~overflow;


wire [31:0] jpc = {p4[31:28],inst[25:0],2'b00};
mux2x32 alu_b (data,immediate,aluimm,alub);
mux2x32 alu_a (ra,sa,shift,alua);
mux2x32 result (alu,mem,m2reg,alu_mem);
mux2x32 link (alu_mem,p8,jal,res);
mux2x5 reg_wn(inst[15:11],inst[20:16],regrt,reg_dest);
assign wn = reg_dest | {5{jal}} ;
mux4x32 nextpc (p4,adr,ra,jpc,pcsourse,npc);
regfile rf (inst[25:21],inst[20:16],res,wn,wreg02,clock,resetn,ra,data);
alu al_unit (alua,alub,aluc,alu,zero,overflow);

endmodule
