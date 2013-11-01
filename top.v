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
	IM_address,

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
	output [9:0] IM_address;

	output DM_read;
	output DM_write;
	output DM_enable;
	output [11:0] DM_address;
	output [31:0] DM_in;
	input [31:0] DM_out;

	//controller to regfile
	wire enable_decode;
	wire enable_writeback;
	wire do_reg_write;
	wire [4:0] read_reg_addr1;
	wire [4:0] read_reg_addr2;
	wire [4:0] write_addr;

	//controller to muxs
	wire [1:0] pc_select;
	wire [1:0] imm_reg_select;
	wire [1:0] imm_extend_select;
	wire [1:0] write_reg_select;

	//controller to alu
	wire [5:0] opcode;
	wire [4:0] sub_op_base;
	wire [7:0] sub_op_ls;
	wire [1:0] sub_op_sv;
	wire enable_execute;

	//controller to pc
	wire enable_fetch;

	// regfile to alu
	wire [31:0] reag_reg_data1;

	//alu to muxs
	wire [31:0] alu_result;

	//regfile to muxs
	wire [31:0] read_reg_data2;
	wire [4:0] imm_5bit;
	wire [13:0] imm_14bit;
	wire [14:0] imm_15bit;
	wire [19:0] imm_20bit;
	wire [23:0] imm_24bit;

	//muxs to regfile
	wire [31:0] write_reg_data;
	
	//muxs to alu
	wire [31:0] alu_src2;

	//alu to controller
	wire alu_zero;

	//pc to muxs
	wire [9:0] pc_out;

	//muxs to pc
	wire [9:0] pc_in;

	wire IM_enable=enable_fetch;
	wire [11:0] DM_address=alu_result[11:0];
	wire [9:0] IM_address=pc_out[9:0];

	alu ALU(
		.reset(rst),
		.enable_execute(enable_execute),
		.src1(reag_reg_data1),
		.src2(alu_src2),
		.opcode(opcode),
		.sub_op_base(sub_op_base),
		.sub_op_ls(sub_op_ls),

		.alu_result(alu_result),
		.alu_overflow(alu_overflow),
		.alu_zero(alu_zero)
	);
	
	regfile REGFILE(
		.clock(clk),
		.reset(rst),
		.enable_reg_fetch(enable_decode),
		.enable_reg_write(enable_writeback),
		.read_reg_addr1(read_reg_addr1),
		.read_reg_addr2(read_reg_addr2),
		.write_addr(write_addr),
		.write_reg_data(write_reg_data),
		.do_reg_write(do_reg_write),

		.reag_reg_data1(reag_reg_data1),
		.read_reg_data2(read_reg_data2),
		.mem_write_data(DM_in)
	);

	muxs MUXS(
		.sub_op_sv(sub_op_sv),
		.read_reg_data2(read_reg_data2),
		.mem_read_data(DM_out),
		.alu_output(alu_result),
		.imm_5bit(imm_5bit),
		.imm_14bit(imm_14bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),
		.imm_24bit(imm_24bit),

		.pc_select(pc_select),
		.imm_reg_select(imm_reg_select),
		.imm_extend_select(imm_extend_select),
		.write_reg_select(write_reg_select),

		.output_imm_reg_mux(alu_src2),
		.write_reg_data(write_reg_data),
		.pc_from(pc_out),
		.pc_to(pc_in)
	);
	
	controller CONTROLLER(
		.clock(clk),
		.reset(rst),
		.instruction(instruction),

		.enable_fetch(enable_fetch),
		.enable_execute(enable_execute),
		.enable_decode(enable_decode),
		.enable_memaccess(DM_enable),
		.enable_writeback(enable_writeback),

		.opcode(opcode),
		.sub_op_base(sub_op_base),
		.sub_op_ls(sub_op_ls),
		.sub_op_sv(sub_op_sv),

		.read_reg_addr1(read_reg_addr1),
		.read_reg_addr2(read_reg_addr2),
		.write_addr(write_addr),

		.imm_5bit(imm_5bit),
		.imm_14bit(imm_14bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),
		.imm_24bit(imm_24bit),
		.pc_select(pc_select),
		.imm_reg_select(imm_reg_select),
		.imm_extend_select(imm_extend_select),
		.write_reg_select(write_reg_select),

		.IM_read(IM_read),
		.IM_write(IM_write),
		.DM_read(DM_read),
		.DM_write(DM_write),
		.do_reg_write(do_reg_write),

		.alu_zero(alu_zero)
	);
	pc PC(
		.clock(clk),
		.reset(rst),
		.enable_pc(enable_fetch),
		.pc_in(pc_in),
		.pc_out(pc_out)
	);
endmodule
