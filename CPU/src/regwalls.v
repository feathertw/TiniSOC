module regwalls(
	clock,
	reset,
	enable_regwalls,
	iREG1_instruction,
	oREG1_instruction,
	iREG1_current_pc,
	oREG1_current_pc,
	iREG1_do_jcache_link,
	oREG1_do_jcache_link,
	iREG1_do_jcache,
	oREG1_do_jcache,

	iREG2_reg_ra_data,
	mREG2_reg_ra_data,
	oREG3_reg_ra_data,
	iREG2_reg_rt_data,
	oREG3_reg_rt_data,

	iREG2_write_reg_addr,
	mREG2_write_reg_addr,
	mREG3_write_reg_addr,
	oREG4_write_reg_addr,
	iREG2_write_ra_addr,
	mREG2_write_ra_addr,
	mREG3_write_ra_addr,
	oREG4_write_ra_addr,

	iREG2_opcode,
	iREG2_sub_op_base,
	oREG2_opcode,
	oREG2_sub_op_base,

	iREG2_select_mem_addr,
	oREG3_select_mem_addr,
	iREG2_select_write_reg,
	mREG2_select_write_reg,
	oREG3_select_write_reg,

	iREG2_do_dm_read,
	iREG2_do_dm_write,
	iREG2_do_reg_write,
	iREG2_do_ra_write,
	mREG2_do_dm_read,
	mREG2_do_reg_write,
	mREG3_do_reg_write,
	mREG2_do_ra_write,
	mREG3_do_ra_write,
	oREG3_do_dm_read,
	oREG3_do_dm_write,
	oREG4_do_reg_write,
	oREG4_do_ra_write,

	iREG2_alu_src2,
	oREG2_alu_src2,
	iREG2_imm_extend,
	mREG2_imm_extend,
	oREG3_imm_extend,

	iREG3_alu_result,
	oREG3_alu_result,

	iREG4_write_reg_data,
	oREG4_write_reg_data,
	iREG3_write_ra_data,
	mREG3_write_ra_data,
	oREG4_write_ra_data,

	iREG2_write_reg_pc,
	oREG3_write_reg_pc,

	do_flush_REG1,
	do_hazard
);
	input  clock;
	input  reset;
	input  enable_regwalls;

	input  [31:0] iREG1_instruction;
	output [31:0] oREG1_instruction;
	reg    [31:0] oREG1_instruction;
	input  [31:0] iREG1_current_pc;
	output [31:0] oREG1_current_pc;
	reg    [31:0] oREG1_current_pc;
	input  iREG1_do_jcache_link;
	output oREG1_do_jcache_link;
	reg    oREG1_do_jcache_link;
	input  iREG1_do_jcache;
	output oREG1_do_jcache;
	reg    oREG1_do_jcache;

	//regfile
	input  [31:0] iREG2_reg_ra_data;
	output [31:0] mREG2_reg_ra_data;
	output [31:0] oREG3_reg_ra_data;
	reg    [31:0] mREG2_reg_ra_data;
	reg    [31:0] oREG3_reg_ra_data;

	input  [31:0] iREG2_reg_rt_data;
	output [31:0] oREG3_reg_rt_data;
	reg    [31:0] mREG2_reg_rt_data;
	reg    [31:0] oREG3_reg_rt_data;

	input  [ 4:0] iREG2_write_reg_addr;
	output [ 4:0] mREG2_write_reg_addr;
	output [ 4:0] mREG3_write_reg_addr;
	output [ 4:0] oREG4_write_reg_addr;
	reg    [ 4:0] mREG2_write_reg_addr;
	reg    [ 4:0] mREG3_write_reg_addr;
	reg    [ 4:0] oREG4_write_reg_addr;
	input  [ 4:0] iREG2_write_ra_addr;
	output [ 4:0] mREG2_write_ra_addr;
	output [ 4:0] mREG3_write_ra_addr;
	output [ 4:0] oREG4_write_ra_addr;
	reg    [ 4:0] mREG2_write_ra_addr;
	reg    [ 4:0] mREG3_write_ra_addr;
	reg    [ 4:0] oREG4_write_ra_addr;

	//controller
	input  [ 5:0] iREG2_opcode;
	input  [ 4:0] iREG2_sub_op_base;
	output [ 5:0] oREG2_opcode;
	output [ 4:0] oREG2_sub_op_base;
	reg    [ 5:0] oREG2_opcode;
	reg    [ 4:0] oREG2_sub_op_base;

	input  iREG2_select_mem_addr;
	output oREG3_select_mem_addr;
	reg    mREG2_select_mem_addr;
	reg    oREG3_select_mem_addr;
	input  [ 1:0] iREG2_select_write_reg;
	output [ 1:0] mREG2_select_write_reg;
	output [ 1:0] oREG3_select_write_reg;
	reg    [ 1:0] mREG2_select_write_reg;
	reg    [ 1:0] oREG3_select_write_reg;

	input  iREG2_do_dm_read;
	input  iREG2_do_dm_write;
	input  iREG2_do_reg_write;
	input  iREG2_do_ra_write;
	output mREG2_do_dm_read;
	output mREG2_do_reg_write;
	output mREG3_do_reg_write;
	output mREG2_do_ra_write;
	output mREG3_do_ra_write;
	output oREG3_do_dm_read;
	output oREG3_do_dm_write;
	output oREG4_do_reg_write;
	output oREG4_do_ra_write;
	reg    mREG2_do_dm_read;
	reg    mREG2_do_dm_write;
	reg    mREG2_do_reg_write;
	reg    mREG2_do_ra_write;
	reg    oREG3_do_dm_read;
	reg    oREG3_do_dm_write;
	reg    mREG3_do_reg_write;
	reg    mREG3_do_ra_write;
	reg    oREG4_do_reg_write;
	reg    oREG4_do_ra_write;

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
	input  [31:0] iREG3_write_ra_data;
	output [31:0] mREG3_write_ra_data;
	output [31:0] oREG4_write_ra_data;
	reg    [31:0] mREG3_write_ra_data;
	reg    [31:0] oREG4_write_ra_data;

	//muxs
	input  [31:0] iREG4_write_reg_data;
	output [31:0] oREG4_write_reg_data;
	reg    [31:0] oREG4_write_reg_data;

	//pc
	input  [31:0] iREG2_write_reg_pc;
	output [31:0] oREG3_write_reg_pc;
	reg    [31:0] mREG2_write_reg_pc;
	reg    [31:0] oREG3_write_reg_pc;

	input do_flush_REG1;
	input do_hazard;

	always@(negedge clock)begin
		if(reset)begin
			oREG1_instruction   <=32'b0;
			oREG1_current_pc    <=32'b0;
			oREG1_do_jcache_link<= 1'b0;
			oREG1_do_jcache     <= 1'b0;

			mREG2_reg_ra_data<=32'b0;
			oREG3_reg_ra_data<=32'b0;
			mREG2_reg_rt_data<=32'b0;

			oREG2_opcode     <=6'b0;
			oREG2_sub_op_base<=5'b0;

			oREG2_alu_src2   <=32'b0;
			mREG2_imm_extend <=32'b0;

			mREG2_do_dm_read      <=1'b0;
			mREG2_do_dm_write     <=1'b0;
			mREG2_do_reg_write    <=1'b0;
			mREG2_do_ra_write     <=1'b0;
			mREG2_write_reg_addr  <=5'b0;
			mREG2_write_ra_addr   <=5'b0;
			mREG2_select_mem_addr <=1'b0;
			mREG2_select_write_reg<=2'b0;

			oREG3_reg_rt_data     <=32'b0;
			oREG3_alu_result      <=32'b0;
			oREG3_imm_extend      <=32'b0;

			oREG3_do_dm_read      <=1'b0;
			oREG3_do_dm_write     <=1'b0;
			mREG3_do_reg_write    <=1'b0;
			mREG3_do_ra_write     <=1'b0;
			mREG3_write_reg_addr  <=5'b0;
			mREG3_write_ra_addr   <=5'b0;
			mREG3_write_ra_data   <=32'b0;
			oREG3_select_mem_addr <=1'b0;
			oREG3_select_write_reg<=2'b0;

			oREG4_do_reg_write  <=1'b0;
			oREG4_do_ra_write   <=1'b0;
			oREG4_write_reg_addr<=5'b0;
			oREG4_write_ra_addr <=5'b0;
			oREG4_write_reg_data<=32'b0;
			oREG4_write_ra_data <=32'b0;

			mREG2_write_reg_pc <= 32'b0;
			oREG3_write_reg_pc <= 32'b0;
		end
		else if(enable_regwalls)begin
			if(do_hazard)begin
				oREG1_instruction   <=oREG1_instruction;
				oREG1_current_pc    <=oREG1_current_pc;
				oREG1_do_jcache_link<=oREG1_do_jcache_link;
				oREG1_do_jcache     <=oREG1_do_jcache;
			end
			else if(do_flush_REG1)begin
				oREG1_instruction   <=32'b0;
				oREG1_current_pc    <=32'b0;
				oREG1_do_jcache_link<= 1'b0;
				oREG1_do_jcache     <= 1'b0;
			end
			else begin
				oREG1_instruction   <=iREG1_instruction;
				oREG1_current_pc    <=iREG1_current_pc;
				oREG1_do_jcache_link<=iREG1_do_jcache_link;
				oREG1_do_jcache     <=iREG1_do_jcache;
			end

			if(do_hazard)begin
				mREG2_reg_ra_data<=32'b0;
				mREG2_reg_rt_data<=32'b0;

				oREG2_opcode     <=6'b0;
				oREG2_sub_op_base<=5'b0;

				oREG2_alu_src2   <=32'b0;
				mREG2_imm_extend <=32'b0;

				mREG2_do_dm_read      <=1'b0;
				mREG2_do_dm_write     <=1'b0;
				mREG2_do_reg_write    <=1'b0;
				mREG2_do_ra_write     <=1'b0;
				mREG2_write_reg_addr  <=5'b0;
				mREG2_write_ra_addr   <=5'b0;
				mREG2_select_mem_addr <=1'b0;
				mREG2_select_write_reg<=2'b0;

				mREG2_write_reg_pc <= 32'b0;
			end
			else begin
				mREG2_reg_ra_data<=iREG2_reg_ra_data;
				mREG2_reg_rt_data<=iREG2_reg_rt_data;

				oREG2_opcode     <=iREG2_opcode;
				oREG2_sub_op_base<=iREG2_sub_op_base;

				oREG2_alu_src2        <=iREG2_alu_src2;
				mREG2_imm_extend      <=iREG2_imm_extend;

				mREG2_do_dm_read      <=iREG2_do_dm_read;
				mREG2_do_dm_write     <=iREG2_do_dm_write;
				mREG2_do_reg_write    <=iREG2_do_reg_write;
				mREG2_do_ra_write     <=iREG2_do_ra_write;
				mREG2_write_reg_addr  <=iREG2_write_reg_addr;
				mREG2_write_ra_addr   <=iREG2_write_ra_addr;
				mREG2_select_mem_addr <=iREG2_select_mem_addr;
				mREG2_select_write_reg<=iREG2_select_write_reg;

				mREG2_write_reg_pc <= iREG2_write_reg_pc;
			end

			oREG3_reg_ra_data     <=mREG2_reg_ra_data;
			oREG3_reg_rt_data     <=mREG2_reg_rt_data;
			oREG3_alu_result      <=iREG3_alu_result;
			oREG3_imm_extend      <=mREG2_imm_extend;

			oREG3_do_dm_read      <=mREG2_do_dm_read;
			oREG3_do_dm_write     <=mREG2_do_dm_write;
			mREG3_do_reg_write    <=mREG2_do_reg_write;
			mREG3_do_ra_write     <=mREG2_do_ra_write;
			mREG3_write_reg_addr  <=mREG2_write_reg_addr;
			mREG3_write_ra_addr   <=mREG2_write_ra_addr;
			mREG3_write_ra_data   <=iREG3_write_ra_data;
			oREG3_select_mem_addr <=mREG2_select_mem_addr;
			oREG3_select_write_reg<=mREG2_select_write_reg;

			oREG3_write_reg_pc <= mREG2_write_reg_pc;

			oREG4_do_reg_write  <=mREG3_do_reg_write;
			oREG4_do_ra_write   <=mREG3_do_ra_write;
			oREG4_write_reg_addr<=mREG3_write_reg_addr;
			oREG4_write_ra_addr <=mREG3_write_ra_addr;
			oREG4_write_reg_data<=iREG4_write_reg_data;
			oREG4_write_ra_data <=mREG3_write_ra_data;
		end
	end
endmodule
