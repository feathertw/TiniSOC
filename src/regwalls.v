module regwalls(
`ifdef BUGMODE
	iREG1_current_pc,
`endif
	clock,
	iREG1_instruction,
	oREG1_instruction,

	iREG2_reg_ra_data,
	iREG2_reg_rt_data,
	oREG2_reg_ra_data,
	oREG3_reg_rt_data,

	iREG2_write_reg_addr,
	mREG2_write_reg_addr,
	oREG4_write_reg_addr,

	iREG2_opcode,
	iREG2_sub_op_base,
	iREG2_sub_op_ls,
	oREG2_opcode,
	oREG2_sub_op_base,
	oREG2_sub_op_ls,

	iREG2_imm_14bit,
	oREG2_imm_14bit,

	iREG2_select_write_reg,
	mREG2_select_write_reg,
	oREG3_select_write_reg,

	iREG2_do_dm_read,
	iREG2_do_dm_write,
	iREG2_do_reg_write,
	mREG2_do_dm_read,
	mREG2_do_reg_write,
	oREG3_do_dm_read,
	oREG3_do_dm_write,
	oREG4_do_reg_write,

	iREG2_alu_src2,
	oREG2_alu_src2,
	iREG2_imm_extend,
	mREG2_imm_extend,
	oREG3_imm_extend,

	iREG3_alu_result,
	oREG3_alu_result,

	iREG3_alu_overflow,
	oREG3_alu_overflow,

	iREG4_write_reg_data,
	oREG4_write_reg_data,

	do_flush_REG1,
	do_flush_REG2,
	do_flush_REG3,
	do_flush_REG4
);
`ifdef BUGMODE
	input  [ 9:0] iREG1_current_pc;
	reg    [ 9:0] mREG1_current_pc;
	reg    [ 9:0] mREG2_current_pc;
	reg    [ 9:0] mREG3_current_pc;
	reg    [ 9:0] mREG4_current_pc;
`endif
	input  clock;

	input  [31:0] iREG1_instruction;
	output [31:0] oREG1_instruction;
	reg    [31:0] oREG1_instruction;

	//regfile
	input  [31:0] iREG2_reg_ra_data;
	output [31:0] oREG2_reg_ra_data;
	reg    [31:0] oREG2_reg_ra_data;

	input  [31:0] iREG2_reg_rt_data;
	output [31:0] oREG3_reg_rt_data;
	reg    [31:0] mREG2_reg_rt_data;
	reg    [31:0] oREG3_reg_rt_data;

	input  [ 4:0] iREG2_write_reg_addr;
	output [ 4:0] mREG2_write_reg_addr;
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
	output [13:0] oREG2_imm_14bit;
	reg    [13:0] oREG2_imm_14bit;

	input  [ 1:0] iREG2_select_write_reg;
	output [ 1:0] mREG2_select_write_reg;
	output [ 1:0] oREG3_select_write_reg;
	reg    [ 1:0] mREG2_select_write_reg;
	reg    [ 1:0] oREG3_select_write_reg;

	input  iREG2_do_dm_read;
	input  iREG2_do_dm_write;
	input  iREG2_do_reg_write;
	output mREG2_do_dm_read;
	output mREG2_do_reg_write;
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

	input  [31:0] iREG2_imm_extend;
	output [31:0] mREG2_imm_extend;
	output [31:0] oREG3_imm_extend;
	reg    [31:0] mREG2_imm_extend;
	reg    [31:0] oREG3_imm_extend;

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

	input do_flush_REG1;
	input do_flush_REG2;
	input do_flush_REG3;
	input do_flush_REG4;

	reg r_do_flush_REG1;
	reg r_do_flush_REG2;
	reg r_do_flush_REG3;
	reg r_do_flush_REG4;

	always@(posedge clock)begin
		r_do_flush_REG1<=do_flush_REG1;
		r_do_flush_REG2<=do_flush_REG2;
		r_do_flush_REG3<=do_flush_REG3;
		r_do_flush_REG4<=do_flush_REG4;
	end

	always@(negedge clock)begin
`ifdef BUGMODE
		mREG1_current_pc <=iREG1_current_pc;
		mREG2_current_pc <=mREG1_current_pc;
		mREG3_current_pc <=mREG2_current_pc;
		mREG4_current_pc <=mREG3_current_pc;
`endif
		if(r_do_flush_REG1)begin
			oREG1_instruction<=32'b0;
		end
		else begin
			oREG1_instruction<=iREG1_instruction;
		end

		if(r_do_flush_REG2)begin
			oREG2_reg_ra_data<=32'b0;
			mREG2_reg_rt_data<=32'b0;

			oREG2_opcode     <=6'b0;
			oREG2_sub_op_base<=5'b0;
			oREG2_sub_op_ls  <=8'b0;

			oREG2_alu_src2   <=32'b0;
			oREG2_imm_14bit  <=14'b0;
			mREG2_imm_extend <=32'b0;

			mREG2_do_dm_read      <=1'b0;
			mREG2_do_dm_write     <=1'b0;
			mREG2_do_reg_write    <=1'b0;
			mREG2_write_reg_addr  <=5'b0;
			mREG2_select_write_reg<=2'b0;
		end
		else begin
			oREG2_reg_ra_data<=iREG2_reg_ra_data;
			mREG2_reg_rt_data<=iREG2_reg_rt_data;

			oREG2_opcode     <=iREG2_opcode;
			oREG2_sub_op_base<=iREG2_sub_op_base;
			oREG2_sub_op_ls  <=iREG2_sub_op_ls;

			oREG2_alu_src2        <=iREG2_alu_src2;
			oREG2_imm_14bit       <=iREG2_imm_14bit;
			mREG2_imm_extend      <=iREG2_imm_extend;

			mREG2_do_dm_read      <=iREG2_do_dm_read;
			mREG2_do_dm_write     <=iREG2_do_dm_write;
			mREG2_do_reg_write    <=iREG2_do_reg_write;
			mREG2_write_reg_addr  <=iREG2_write_reg_addr;
			mREG2_select_write_reg<=iREG2_select_write_reg;
		end

		if(r_do_flush_REG3)begin
			oREG3_reg_rt_data     <=32'b0;
			oREG3_alu_result      <=32'b0;
			oREG3_alu_overflow    <= 1'b0;
			oREG3_imm_extend      <=32'b0;

			oREG3_do_dm_read      <=1'b0;
			oREG3_do_dm_write     <=1'b0;
			mREG3_do_reg_write    <=1'b0;
			mREG3_write_reg_addr  <=5'b0;
			oREG3_select_write_reg<=2'b0;
		end
		else begin
			oREG3_reg_rt_data     <=mREG2_reg_rt_data;
			oREG3_alu_result      <=iREG3_alu_result;
			oREG3_alu_overflow    <=iREG3_alu_overflow;
			oREG3_imm_extend      <=mREG2_imm_extend;

			oREG3_do_dm_read      <=mREG2_do_dm_read;
			oREG3_do_dm_write     <=mREG2_do_dm_write;
			mREG3_do_reg_write    <=mREG2_do_reg_write;
			mREG3_write_reg_addr  <=mREG2_write_reg_addr;
			oREG3_select_write_reg<=mREG2_select_write_reg;
		end

		if(r_do_flush_REG4)begin
			oREG4_do_reg_write  <= 1'b0;
			oREG4_write_reg_addr<= 5'b0;
			oREG4_write_reg_data<=32'b0;
		end
		else begin
			oREG4_do_reg_write  <=mREG3_do_reg_write;
			oREG4_write_reg_addr<=mREG3_write_reg_addr;
			oREG4_write_reg_data<=iREG4_write_reg_data;
		end
	end
endmodule
