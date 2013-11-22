module regwalls(
	clock,
	iREG1_instruction,
	oREG1_instruction,

	iREG2_reg_ra_data,
	iREG2_reg_rt_data,
	oREG2_reg_ra_data,
	oREG2_reg_rt_data,

	iREG2_write_reg_addr,
	oREG4_write_reg_addr,

	iREG2_opcode,
	iREG2_sub_op_base,
	iREG2_sub_op_ls,
	oREG2_opcode,
	oREG2_sub_op_base,
	oREG2_sub_op_ls,

	iREG2_imm_14bit,
	iREG2_imm_24bit,
	iREG2_select_write_reg,
	oREG2_imm_14bit,
	oREG2_imm_24bit,
	oREG2_select_write_reg,

	iREG2_do_dm_read,
	iREG2_do_dm_write,
	iREG2_do_reg_write,
	oREG3_do_dm_read,
	oREG3_do_dm_write,
	oREG4_do_reg_write,

	iREG2_alu_src2,
	oREG2_alu_src2,

	iREG3_alu_result,
	oREG3_alu_result,

	iREG3_alu_overflow,
	oREG3_alu_overflow,

	iREG4_write_reg_data,
	oREG4_write_reg_data
);
	input  clock;

	input  [31:0] iREG1_instruction;
	output [31:0] oREG1_instruction;
	reg    [31:0] oREG1_instruction;

	//regfile
	input  [31:0] iREG2_reg_ra_data;
	input  [31:0] iREG2_reg_rt_data;
	output [31:0] oREG2_reg_ra_data;
	output [31:0] oREG2_reg_rt_data;
	reg    [31:0] oREG2_reg_ra_data;
	reg    [31:0] oREG2_reg_rt_data;

	input  [ 4:0] iREG2_write_reg_addr;
	output [ 4:0] oREG4_write_reg_addr;
	reg    [ 4:0] mREG2_write_reg_addr;
	reg    [ 4:0] mREG3_write_reg_addr;
	reg    [ 4:0] oREG4_write_reg_addr;

	//controller
	input  [ 5:0] iREG2_opcode;
	input  [ 4:0] iREG2_sub_op_base;
	input  [ 7:0] iREG2_sub_op_ls;
	output [ 5:0] oREG2_opcode;
	output [ 4:0] oREG2_sub_op_base;
	output [ 7:0] oREG2_sub_op_ls;
	reg    [ 5:0] oREG2_opcode;
	reg    [ 4:0] oREG2_sub_op_base;
	reg    [ 7:0] oREG2_sub_op_ls;

	input  [13:0] iREG2_imm_14bit;
	input  [23:0] iREG2_imm_24bit;
	input  [ 1:0] iREG2_select_write_reg;
	output [13:0] oREG2_imm_14bit;
	output [23:0] oREG2_imm_24bit;
	output [ 1:0] oREG2_select_write_reg;
	reg    [13:0] oREG2_imm_14bit;
	reg    [23:0] oREG2_imm_24bit;
	reg    [ 1:0] oREG2_select_write_reg;

	input  iREG2_do_dm_read;
	input  iREG2_do_dm_write;
	input  iREG2_do_reg_write;
	output oREG3_do_dm_read;
	output oREG3_do_dm_write;
	output oREG4_do_reg_write;
	reg    mREG2_do_dm_read;
	reg    mREG2_do_dm_write;
	reg    mREG2_do_reg_write;
	reg    oREG3_do_dm_read;
	reg    oREG3_do_dm_write;
	reg    mREG3_do_reg_write;
	reg    oREG4_do_reg_write;

	//muxs
	input  [31:0] iREG2_alu_src2;
	output [31:0] oREG2_alu_src2;
	reg    [31:0] oREG2_alu_src2;

	//alu
	input  [31:0] iREG3_alu_result;
	output [31:0] oREG3_alu_result;
	reg    [31:0] oREG3_alu_result;

	input  iREG3_alu_overflow;
	output oREG3_alu_overflow;
	reg    oREG3_alu_overflow;

	//muxs
	input  [31:0] iREG4_write_reg_data;
	output [31:0] oREG4_write_reg_data;
	reg    [31:0] oREG4_write_reg_data;

	always@(negedge clock)begin
		oREG1_instruction<=iREG1_instruction;

		oREG2_reg_ra_data<=iREG2_reg_ra_data;
		oREG2_reg_rt_data<=iREG2_reg_rt_data;

		mREG2_write_reg_addr<=iREG2_write_reg_addr;
		mREG3_write_reg_addr<=mREG2_write_reg_addr;
		oREG4_write_reg_addr<=mREG3_write_reg_addr;

		oREG2_opcode     <=iREG2_opcode;
		oREG2_sub_op_base<=iREG2_sub_op_base;
		oREG2_sub_op_ls  <=iREG2_sub_op_ls;

		oREG2_imm_14bit       <=iREG2_imm_14bit;
		oREG2_imm_24bit       <=iREG2_imm_24bit;
		oREG2_select_write_reg<=iREG2_select_write_reg;

		mREG2_do_dm_read      <=iREG2_do_dm_read;
		mREG2_do_dm_write     <=iREG2_do_dm_write;
		mREG2_do_reg_write    <=iREG2_do_reg_write;
		oREG3_do_dm_read      <=mREG2_do_dm_read;
		oREG3_do_dm_write     <=mREG2_do_dm_write;
		mREG3_do_reg_write    <=mREG2_do_reg_write;
		oREG4_do_reg_write    <=mREG3_do_reg_write;

		oREG2_alu_src2        <=iREG2_alu_src2;

		oREG3_alu_result  <=iREG3_alu_result;
		oREG3_alu_overflow<=iREG3_alu_overflow;

		oREG4_write_reg_data<=iREG4_write_reg_data;
	end
endmodule
