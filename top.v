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

	pc,

	IM_read,
	IM_write,
	IM_enable,

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

	output [9:0] pc;

	output IM_read;
	output IM_write;
	output IM_enable;

	output DM_read;
	output DM_write;
	output DM_enable;

	output [11:0] DM_address;
	output [31:0] DM_in;
	input [31:0] DM_out;

	//controller to regfile
	wire do_reg_fetch;
	wire do_reg_write;
	wire enable_reg_write;
	wire [4:0] read_reg_addr1;
	wire [4:0] read_reg_addr2;
	wire [4:0] write_address;

	//controller to muxs
	wire [1:0] imm_extend_select;
	wire [1:0] write_reg_select;
	wire [1:0] imm_reg_select;

	//controller to alu
	wire [5:0] opcode;
	wire [4:0] sub_op_base;
	wire [7:0] sub_op_ls;
	wire [1:0] sub_op_sv;
	wire enable_execute;

	//controller to pc
	wire enable_pc;

	// regfile to alu
	wire [31:0] read_data1;

	//alu to muxs
	wire [31:0] alu_result;

	//regfile to muxs
	wire [31:0] read_data2;
	wire [4:0] imm_5bit;
	wire [14:0] imm_15bit;
	wire [19:0] imm_20bit;

	//muxs to regfile
	wire [31:0] write_data;
	
	//muxs to alu
	wire [31:0] alu_src2;

	wire [11:0] DM_address=alu_result[11:0];

	alu ALU(
		.alu_result(alu_result),
		.alu_overflow(alu_overflow),
		.src1(read_data1),
		.src2(alu_src2),
		.opcode(opcode),
		.sub_op_base(sub_op_base),
		.sub_op_ls(sub_op_ls),
		.enable_execute(enable_execute),
		.reset(rst)
	);
	
	regfile REGFILE(
		.mem_write_data(DM_in),
		.read_data1(read_data1),
		.read_data2(read_data2),
		.read_reg_addr1(read_reg_addr1),
		.read_reg_addr2(read_reg_addr2),
		.write_address(write_address),
		.write_data(write_data),
		.clock(clk),
		.reset(rst),
		.do_reg_fetch(do_reg_fetch),
		.do_reg_write(do_reg_write),
		.enable_reg_write(enable_reg_write)
	);

	muxs MUXS(
		.imm_5bit(imm_5bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),
		.read_data2(read_data2),
		.mem_read_data(DM_out),
		.ir_sv(sub_op_sv),
		.imm_extend_select(imm_extend_select),
		.write_reg_select(write_reg_select),
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
		.do_reg_fetch(do_reg_fetch),
		.do_reg_write(do_reg_write),
		.opcode(opcode),
		.sub_op_base(sub_op_base),
		.sub_op_ls(sub_op_ls),
		.sub_op_sv(sub_op_sv),
		.imm_extend_select(imm_extend_select),
		.write_reg_select(write_reg_select),
		.imm_reg_select(imm_reg_select),
		.enable_pc(enable_pc),
		.IM_enable(IM_enable),
		.IM_read(IM_read),
		.IM_write(IM_write),
		.DM_enable(DM_enable),
		.DM_read(DM_read),
		.DM_write(DM_write),
		.enable_reg_write(enable_reg_write),
		.imm_5bit(imm_5bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),
		.read_reg_addr1(read_reg_addr1),
		.read_reg_addr2(read_reg_addr2),
		.write_address(write_address)
	);
	pc PC(
		.clock(clk),
		.reset(rst),
		.enable_pc(enable_pc),
		.pc(pc)
	);
endmodule
