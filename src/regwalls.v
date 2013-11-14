module regwalls(
	clock,
	iREG1_instruction,
	oREG1_instruction,

	iREG2_reg_ra_data,
	iREG2_reg_rb_data,
	iREG2_reg_rt_data,
	oREG2_reg_ra_data,
	oREG2_reg_rb_data,
	oREG2_reg_rt_data
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

	always@(negedge clock)begin
		oREG1_instruction<=iREG1_instruction;
		oREG2_reg_ra_data<=iREG2_reg_ra_data;
		oREG2_reg_rb_data<=iREG2_reg_rb_data;
		oREG2_reg_rt_data<=iREG2_reg_rt_data;
	end
endmodule
