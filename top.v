`include "src/alu.v"
`include "src/regfile.v"
`include "src/muxs.v"
`include "src/controller.v"
`include "src/pc.v"
`include "src/regwalls.v"
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
	DM_out
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

	//controller to top
	wire do_im_read;
	wire do_im_write;
	wire do_dm_read;
	wire do_dm_write;

	//controller to regfile
	wire enable_decode;
	wire enable_writeback;
	wire do_reg_write;
	wire [4:0] reg_ra_addr;
	wire [4:0] reg_rb_addr;
	wire [4:0] reg_rt_addr;

	//controller to muxs
	wire [2:0] select_alu_src2;
	wire [1:0] select_imm_extend;
	wire [1:0] select_write_reg;

	//controller to alu
	wire [5:0] opcode;
	wire [4:0] sub_op_base;
	wire [7:0] sub_op_ls;
	wire [1:0] sub_op_sv;
	wire sub_op_b;
	wire enable_execute;

	//controller to im
	wire enable_fetch;

	//controller to dm
	wire enable_memaccess;

	// regfile to alu
	wire [31:0] reg_ra_data;

	//alu to muxs
	wire [31:0] alu_result;

	//regfile to muxs
	wire [31:0] reg_rb_data;
	wire [31:0] reg_rt_data;
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

	//regfile to pc
	wire reg_rt_ra_equal;

	//pc to muxs
	wire [9:0] current_pc;

	//mem to muxs
	wire [31:0] mem_read_data;

	//alu to reg
	wire tmp_alu_overflow;

	reg reg_alu_overflow; //*

	//REGWALL
	wire [31:0] iREG1_instruction;
	wire [31:0] oREG1_instruction;

	wire [31:0] iREG2_reg_ra_data;
	wire [31:0] iREG2_reg_rt_data;
	wire [31:0] oREG2_reg_ra_data;
	wire [31:0] oREG2_reg_rt_data;

	wire [ 5:0] iREG2_opcode;
	wire [ 4:0] iREG2_sub_op_base;
	wire [ 7:0] iREG2_sub_op_ls;
	wire [ 5:0] oREG2_opcode;
	wire [ 4:0] oREG2_sub_op_base;
	wire [ 7:0] oREG2_sub_op_ls;

	wire [ 1:0] iREG2_select_write_reg;
	wire [ 1:0] oREG3_select_write_reg;

	wire iREG2_do_dm_read;
	wire iREG2_do_dm_write;
	wire iREG2_do_reg_write;
	wire oREG3_do_dm_read;
	wire oREG3_do_dm_write;
	wire oREG4_do_reg_write;

	wire [31:0] iREG2_alu_src2;
	wire [31:0] oREG2_alu_src2;
	wire [31:0] iREG2_imm_extend;
	wire [31:0] oREG3_imm_extend;

	wire [31:0] iREG3_alu_result;
	wire [31:0] oREG3_alu_result;

	wire iREG3_alu_overflow;
	wire oREG3_alu_overflow;

	wire [ 4:0] iREG2_write_reg_addr;
	wire [ 4:0] oREG4_write_reg_addr;
	wire [31:0] iREG4_write_reg_data;
	wire [31:0] oREG4_write_reg_data;

	//
	assign iREG2_write_reg_addr=reg_rt_addr;

	//
	wire do_flush_REG1;
	wire do_flush_REG2;
	wire do_flush_REG3;
	wire do_flush_REG4;

	//top input output
	assign iREG1_instruction=instruction;
	assign alu_overflow=reg_alu_overflow;

	assign IM_read =do_im_read;
	assign IM_write=do_im_write;
	assign IM_enable=enable_system;
	assign IM_address=current_pc;

	assign DM_read =oREG3_do_dm_read;
	assign DM_write=oREG3_do_dm_write;
	assign DM_enable=enable_system;
	assign DM_address=oREG3_alu_result[11:0];
	assign DM_in=oREG2_reg_rt_data;//*
	assign mem_read_data=DM_out;

	wire enable_system;
	assign enable_system=1'b1;

	assign do_flush_REG2=1'b0;
	assign do_flush_REG3=1'b0;
	assign do_flush_REG4=1'b0;

`ifdef BUGMODE
	wire [ 9:0] iREG1_current_pc;
	assign iREG1_current_pc=current_pc;
`endif
	alu ALU(
		.reset(rst),
		.enable_execute(enable_system),
		.alu_src1(oREG2_reg_ra_data),
		.alu_src2(oREG2_alu_src2),
		.opcode(oREG2_opcode),
		.sub_op_base(oREG2_sub_op_base),
		.sub_op_ls(oREG2_sub_op_ls),

		.alu_result(iREG3_alu_result),
		.alu_overflow(tmp_alu_overflow),
		.alu_zero(alu_zero)
	);
	
	regfile REGFILE(
		.clock(clk),
		.reset(rst),
		.enable_reg_fetch(enable_system),
		.enable_reg_write(enable_system),
		.reg_ra_addr(reg_ra_addr),
		.reg_rb_addr(reg_rb_addr),
		.reg_rt_addr(reg_rt_addr),
		.write_reg_addr(oREG4_write_reg_addr),
		.write_reg_data(oREG4_write_reg_data),
		.do_reg_write(oREG4_do_reg_write),

		.reg_ra_data(iREG2_reg_ra_data),
		.reg_rb_data(reg_rb_data),
		.reg_rt_data(iREG2_reg_rt_data)
	);

	muxs MUXS(
		.sub_op_sv(sub_op_sv),
		.reg_rb_data(reg_rb_data),
		.reg_rt_data(oREG2_reg_rt_data),

		.alu_result(oREG3_alu_result),//*
		.r_imm_extend(oREG3_imm_extend),
		.mem_read_data(mem_read_data),

		.imm_5bit(imm_5bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),

		.select_alu_src2(select_alu_src2),
		.select_imm_extend(select_imm_extend),
		.select_write_reg(oREG3_select_write_reg),

		.imm_extend(iREG2_imm_extend),
		.alu_src2(iREG2_alu_src2),
		.write_reg_data(iREG4_write_reg_data)
	);
	
	controller CONTROLLER(
		.clock(clk),
		.reset(rst),
		.instruction(oREG1_instruction),

		.enable_fetch(enable_fetch),
		.enable_execute(enable_execute),
		.enable_decode(enable_decode),
		.enable_memaccess(enable_memaccess),
		.enable_writeback(enable_writeback),

		.opcode(iREG2_opcode),
		.sub_op_base(iREG2_sub_op_base),
		.sub_op_ls(iREG2_sub_op_ls),
		.sub_op_sv(sub_op_sv),
		.sub_op_b(sub_op_b),

		.reg_ra_addr(reg_ra_addr),
		.reg_rb_addr(reg_rb_addr),
		.reg_rt_addr(reg_rt_addr),

		.imm_5bit(imm_5bit),
		.imm_14bit(imm_14bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),
		.imm_24bit(imm_24bit),
		.select_alu_src2(select_alu_src2),
		.select_imm_extend(select_imm_extend),
		.select_write_reg(iREG2_select_write_reg),

		.do_im_read(do_im_read),
		.do_im_write(do_im_write),
		.do_dm_read(iREG2_do_dm_read),
		.do_dm_write(iREG2_do_dm_write),
		.do_reg_write(iREG2_do_reg_write),

		.reg_rt_data(iREG2_reg_rt_data),
		.reg_ra_data(iREG2_reg_ra_data),
		.reg_rt_ra_equal(reg_rt_ra_equal)
	);
	pc PC(
		.clock(clk),
		.reset(rst),
		.enable_pc(enable_system),
		.current_pc(current_pc),

		.opcode(iREG2_opcode),
		.sub_op_b(sub_op_b),
		.reg_rt_ra_equal(reg_rt_ra_equal),

		.imm_14bit(imm_14bit),
		.imm_24bit(imm_24bit),

		.do_flush_REG1(do_flush_REG1)
	);
	regwalls REGWALLS(
`ifdef BUGMODE
		.iREG1_current_pc(iREG1_current_pc),
`endif
		.clock(clk),
		.iREG1_instruction(iREG1_instruction),
		.oREG1_instruction(oREG1_instruction),
		.iREG2_reg_ra_data(iREG2_reg_ra_data),
		.iREG2_reg_rt_data(iREG2_reg_rt_data),
		.oREG2_reg_ra_data(oREG2_reg_ra_data),
		.oREG2_reg_rt_data(oREG2_reg_rt_data),
		.iREG2_write_reg_addr(iREG2_write_reg_addr),
		.oREG4_write_reg_addr(oREG4_write_reg_addr),

		.iREG2_opcode(iREG2_opcode),
		.iREG2_sub_op_base(iREG2_sub_op_base),
		.iREG2_sub_op_ls(iREG2_sub_op_ls),
		.oREG2_opcode(oREG2_opcode),
		.oREG2_sub_op_base(oREG2_sub_op_base),
		.oREG2_sub_op_ls(oREG2_sub_op_ls),

		.iREG2_select_write_reg(iREG2_select_write_reg),
		.oREG3_select_write_reg(oREG3_select_write_reg),

		.iREG2_do_dm_read(iREG2_do_dm_read),
		.iREG2_do_dm_write(iREG2_do_dm_write),
		.iREG2_do_reg_write(iREG2_do_reg_write),
		.oREG3_do_dm_read(oREG3_do_dm_read),
		.oREG3_do_dm_write(oREG3_do_dm_write),
		.oREG4_do_reg_write(oREG4_do_reg_write),

		.iREG2_alu_src2(iREG2_alu_src2),
		.oREG2_alu_src2(oREG2_alu_src2),
		.iREG2_imm_extend(iREG2_imm_extend),
		.oREG3_imm_extend(oREG3_imm_extend),

		.iREG3_alu_result(iREG3_alu_result),
		.oREG3_alu_result(oREG3_alu_result),

		.iREG3_alu_overflow(iREG3_alu_overflow),
		.oREG3_alu_overflow(oREG3_alu_overflow),

		.iREG4_write_reg_data(iREG4_write_reg_data),
		.oREG4_write_reg_data(oREG4_write_reg_data),

		.do_flush_REG1(do_flush_REG1),
		.do_flush_REG2(do_flush_REG2),
		.do_flush_REG3(do_flush_REG3),
		.do_flush_REG4(do_flush_REG4)
	);
endmodule
