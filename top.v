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
	wire [1:0] select_pc;
	wire [2:0] select_alu_src2;
	wire [1:0] select_imm_extend;
	wire [1:0] select_write_reg;

	//controller to alu
	wire [5:0] opcode;
	wire [4:0] sub_op_base;
	wire [7:0] sub_op_ls;
	wire [1:0] sub_op_sv;
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

	//pc to muxs
	wire [9:0] current_pc;

	//muxs to pc
	wire [9:0] next_pc;

	//mem to muxs
	wire [31:0] mem_read_data;

	//alu to reg
	wire tmp_alu_overflow;

	reg [31:0] reg_alu_result; //*
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

	wire [13:0] iREG2_imm_14bit;
	wire [23:0] iREG2_imm_24bit;
	wire [ 1:0] iREG2_select_pc;
	wire [ 1:0] iREG2_select_write_reg;
	wire [13:0] oREG2_imm_14bit;
	wire [23:0] oREG2_imm_24bit;
	wire [ 1:0] oREG2_select_pc;
	wire [ 1:0] oREG2_select_write_reg;

	wire iREG2_do_im_read;
	wire iREG2_do_im_write;
	wire iREG2_do_dm_read;
	wire iREG2_do_dm_write;
	wire iREG2_do_reg_write;
	wire oREG2_do_im_read;
	wire oREG2_do_im_write;
	wire oREG2_do_dm_read;
	wire oREG2_do_dm_write;
	wire oREG2_do_reg_write;

	wire [31:0] iREG2_alu_src2;
	wire [31:0] oREG2_alu_src2;

	//top input output
	assign iREG1_instruction=instruction;
	assign alu_overflow=reg_alu_overflow;

	assign IM_read =oREG2_do_im_read;
	assign IM_write=oREG2_do_im_write;
	assign IM_enable=enable_fetch;
	assign IM_address=current_pc;

	assign DM_read =oREG2_do_dm_read;
	assign DM_write=oREG2_do_dm_write;
	assign DM_enable=enable_memaccess;
	assign DM_address=reg_alu_result[11:0];
	assign DM_in=oREG2_reg_rt_data;//*
	assign mem_read_data=DM_out;

	always@(posedge enable_memaccess) begin
		reg_alu_result<=alu_result;
		reg_alu_overflow<=tmp_alu_overflow;
	end

	alu ALU(
		.reset(rst),
		.enable_execute(enable_execute),
		.alu_src1(oREG2_reg_ra_data),
		.alu_src2(oREG2_alu_src2),
		.opcode(oREG2_opcode),
		.sub_op_base(oREG2_sub_op_base),
		.sub_op_ls(oREG2_sub_op_ls),

		.alu_result(alu_result),
		.alu_overflow(tmp_alu_overflow),
		.alu_zero(alu_zero)
	);
	
	regfile REGFILE(
		.clock(clk),
		.reset(rst),
		.enable_reg_fetch(enable_decode),
		.enable_reg_write(enable_writeback),
		.reg_ra_addr(reg_ra_addr),
		.reg_rb_addr(reg_rb_addr),
		.reg_rt_addr(reg_rt_addr),
		.write_reg_data(write_reg_data),
		.do_reg_write(oREG2_do_reg_write),

		.reg_ra_data(iREG2_reg_ra_data),
		.reg_rb_data(reg_rb_data),
		.reg_rt_data(iREG2_reg_rt_data)
	);

	muxs MUXS(
		.sub_op_sv(sub_op_sv),
		.reg_rb_data(reg_rb_data),
		.reg_rt_data(oREG2_reg_rt_data),
		.mem_read_data(mem_read_data),
		.alu_output(reg_alu_result),
		.imm_5bit(imm_5bit),
		.imm_14bit(oREG2_imm_14bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),
		.imm_24bit(oREG2_imm_24bit),

		.select_pc(select_pc),
		.select_alu_src2(select_alu_src2),
		.select_imm_extend(select_imm_extend),
		.select_write_reg(select_write_reg),

		.alu_src2(iREG2_alu_src2),
		.write_reg_data(write_reg_data),
		.current_pc(current_pc),
		.next_pc(next_pc)
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

		.reg_ra_addr(reg_ra_addr),
		.reg_rb_addr(reg_rb_addr),
		.reg_rt_addr(reg_rt_addr),

		.imm_5bit(imm_5bit),
		.imm_14bit(iREG2_imm_14bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),
		.imm_24bit(iREG2_imm_24bit),
		.select_pc(select_pc),
		.select_alu_src2(select_alu_src2),
		.select_imm_extend(select_imm_extend),
		.select_write_reg(select_write_reg),

		.do_im_read(iREG2_do_im_read),
		.do_im_write(iREG2_do_im_write),
		.do_dm_read(iREG2_do_dm_read),
		.do_dm_write(iREG2_do_dm_write),
		.do_reg_write(iREG2_do_reg_write),

		.alu_zero(alu_zero)
	);
	pc PC(
		.clock(clk),
		.reset(rst),
		.enable_pc(enable_execute),
		.next_pc(next_pc),
		.current_pc(current_pc)
	);
	regwalls REGWALLS(
		.clock(clk),
		.iREG1_instruction(iREG1_instruction),
		.oREG1_instruction(oREG1_instruction),
		.iREG2_reg_ra_data(iREG2_reg_ra_data),
		.iREG2_reg_rt_data(iREG2_reg_rt_data),
		.oREG2_reg_ra_data(oREG2_reg_ra_data),
		.oREG2_reg_rt_data(oREG2_reg_rt_data),

		.iREG2_opcode(iREG2_opcode),
		.iREG2_sub_op_base(iREG2_sub_op_base),
		.iREG2_sub_op_ls(iREG2_sub_op_ls),
		.oREG2_opcode(oREG2_opcode),
		.oREG2_sub_op_base(oREG2_sub_op_base),
		.oREG2_sub_op_ls(oREG2_sub_op_ls),

		.iREG2_imm_14bit(iREG2_imm_14bit),
		.iREG2_imm_24bit(iREG2_imm_24bit),
		.iREG2_select_pc(iREG2_select_pc),
		.iREG2_select_write_reg(iREG2_select_write_reg),
		.oREG2_imm_14bit(oREG2_imm_14bit),
		.oREG2_imm_24bit(oREG2_imm_24bit),
		.oREG2_select_pc(oREG2_select_pc),
		.oREG2_select_write_reg(oREG2_select_write_reg),

		.iREG2_do_im_read(iREG2_do_im_read),
		.iREG2_do_im_write(iREG2_do_im_write),
		.iREG2_do_dm_read(iREG2_do_dm_read),
		.iREG2_do_dm_write(iREG2_do_dm_write),
		.iREG2_do_reg_write(iREG2_do_reg_write),
		.oREG2_do_im_read(oREG2_do_im_read),
		.oREG2_do_im_write(oREG2_do_im_write),
		.oREG2_do_dm_read(oREG2_do_dm_read),
		.oREG2_do_dm_write(oREG2_do_dm_write),
		.oREG2_do_reg_write(oREG2_do_reg_write),

		.iREG2_alu_src2(iREG2_alu_src2),
		.oREG2_alu_src2(oREG2_alu_src2)
	);
endmodule
