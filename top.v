`include "alu.v"
`include "regfile.v" 
`include "muxs.v"
`include "controller.v"
`include "pc.v"
module top(
	clk,
	rst,
	instruction,
	alu_overflow,

	IM_read,
	IM_write,
	IM_enable,
	pc,

	DM_read,
	DM_write,
	DM_enable,
	DM_address,
	DM_in,
	DM_out,
);
	input clk;
	input rst;
	input [31:0] instruction;
	output alu_overflow;

	output IM_read;
	output IM_write;
	output IM_enable;
	output [9:0] pc;

	output DM_read;
	output DM_write;
	output DM_enable;

	output [11:0] DM_address;
	output [31:0] DM_in;
	input [31:0] DM_out;

	//controller to regfile
	wire enable_fetch;
	wire enable_writeback;

	//controller to muxs
	wire [1:0] mux4to1_select;
	wire mux2to1_select;
	wire [1:0] imm_reg_select;

	//controller to alu
	wire [5:0] opcode;
	wire [4:0] sub_opcode;
	wire enable_execute;

	//controller to pc
	wire enable_pc;

	// regfile to alu
	wire [31:0] read_data1;

	//alu to muxs
	wire [31:0] alu_result;

	//regfile to muxs
	wire [31:0] read_data2;

	//muxs to regfile
	wire [31:0] write_data;
	
	//muxs to alu
	wire [31:0] alu_src2;

	alu ALU(
		.alu_result(alu_result),
		.alu_overflow(alu_overflow),
		.src1(read_data1),
		.src2(alu_src2),
		.opcode(opcode),
		.sub_opcode(sub_opcode),
		.sub_op_ls(instruction[7:0]),
		.enable_execute(enable_execute),
		.reset(rst)
	);
	
	regfile REGFILE(
		.read_data1(read_data1),
		.read_data2(read_data2),
		.read_address1(instruction[19:15]),
		.read_address2(instruction[14:10]),
		.write_address(instruction[24:20]),
		.write_data(write_data),
		.clock(clk),
		.reset(rst),
		.enable_fetch(enable_fetch),
		.enable_writeback(enable_writeback)
	);

	muxs MUXS(
		.imm_5bit(instruction[14:10]),
		.imm_15bit(instruction[14:0]),
		.imm_20bit(instruction[19:0]),
		.read_data2(read_data2),
		.ir_imm_15bit(instruction[14:0]),
		.ir_rb(instruction[14:10]),
		.ir_sv(instruction[9:8]),
		.mux4to1_select(mux4to1_select),
		.mux2to1_select(mux2to1_select),
		.imm_reg_select(imm_reg_select),
		.output_imm_reg_mux(alu_src2),
		.write_data(write_data),
		.alu_output(alu_result)
	);
	
	controller CONTROLLER(
		.clock(clk),
		.reset(rst),
		.ir(instruction),
		.enable_execute(enable_execute),
		.enable_fetch(enable_fetch),
		.enable_writeback(enable_writeback),
		.opcode(opcode),
		.sub_opcode(sub_opcode),
		.mux4to1_select(mux4to1_select),
		.mux2to1_select(mux2to1_select),
		.imm_reg_select(imm_reg_select),
		.enable_pc(enable_pc),
		.IM_enable(IM_enable),
		.IM_read(IM_read),
		.IM_write(IM_write),
		.DM_enable(DM_enable),
		.DM_read(DM_read),
		.DM_write(DM_write),
		.DM_address(DM_address),
		.DM_in(DM_in),
		.DM_out(DM_out)
	);
	pc PC(
		.clock(clk),
		.reset(rst),
		.enable_pc(enable_pc),
		.pc(pc)
	);
endmodule
