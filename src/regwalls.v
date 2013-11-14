module regwalls(
	clock,
	iREG1_instruction,
	oREG1_instruction,

	iREG2_reg_ra_data,
	iREG2_reg_rb_data,
	iREG2_reg_rt_data,
	oREG2_reg_ra_data,
	oREG2_reg_rb_data,
	oREG2_reg_rt_data,

	iREG2_opcode,
	iREG2_sub_op_base,
	iREG2_sub_op_ls,
	oREG2_opcode,
	oREG2_sub_op_base,
	oREG2_sub_op_ls
);
	input  clock;

	input  [31:0] iREG1_instruction;
	output [31:0] oREG1_instruction;
	reg    [31:0] oREG1_instruction;

	//regfile
	input  [31:0] iREG2_reg_ra_data;
	input  [31:0] iREG2_reg_rb_data;
	input  [31:0] iREG2_reg_rt_data;
	output [31:0] oREG2_reg_ra_data;
	output [31:0] oREG2_reg_rb_data;
	output [31:0] oREG2_reg_rt_data;
	reg    [31:0] oREG2_reg_ra_data;
	reg    [31:0] oREG2_reg_rb_data;
	reg    [31:0] oREG2_reg_rt_data;

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

	always@(negedge clock)begin
		oREG1_instruction<=iREG1_instruction;

		oREG2_reg_ra_data<=iREG2_reg_ra_data;
		oREG2_reg_rb_data<=iREG2_reg_rb_data;
		oREG2_reg_rt_data<=iREG2_reg_rt_data;
		oREG2_opcode     <=iREG2_opcode;
		oREG2_sub_op_base<=iREG2_sub_op_base;
		oREG2_sub_op_ls  <=iREG2_sub_op_ls;
	end
endmodule
