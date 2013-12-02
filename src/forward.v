`include "def_muxs.v"
`define CHOOSE_DATA xREG4_write_reg_data or write_reg_data or xREG2_imm_extend or alu_result
`define CHOOSE_REG4(REG_ADDR) (xREG4_do_reg_write && (REG_ADDR==xREG4_write_reg_addr) )
`define CHOOSE_REG3(REG_ADDR) (xREG3_do_reg_write && (REG_ADDR==xREG3_write_reg_addr) )
`define CHOOSE_REG2(REG_ADDR) (xREG2_do_reg_write && (REG_ADDR==xREG2_write_reg_addr) &&(!xREG2_do_dm_read) )
`define CHOOSE_REG2_IMM (xREG2_select_write_reg==`WRREG_IMMDATA)
`define CHOOSE_REG2_ALU (xREG2_select_write_reg==`WRREG_ALURESULT)
`define CHOOSE xREG4_do_reg_write or xREG4_write_reg_addr or xREG3_do_reg_write or xREG3_write_reg_addr \
		or xREG2_do_reg_write or xREG2_write_reg_addr or xREG2_do_dm_read or xREG2_select_write_reg

module forward(
	reg_ra_addr,
	reg_rb_addr,
	reg_rt_addr,

	reg_ra_data,
	reg_rb_data,
	reg_rt_data,

	xREG2_do_dm_read,
	xREG2_do_reg_write,
	xREG2_select_write_reg,
	xREG2_write_reg_addr,
	xREG2_imm_extend,
	alu_result,

	xREG3_do_reg_write,
	xREG3_write_reg_addr,
	write_reg_data,

	xREG4_do_reg_write,
	xREG4_write_reg_addr,
	xREG4_write_reg_data,

	f_reg_ra_data,
	f_reg_rb_data,
	f_reg_rt_data,

	do_hazard
);
	input [ 4:0] reg_ra_addr;
	input [ 4:0] reg_rb_addr;
	input [ 4:0] reg_rt_addr;
	input [31:0] reg_ra_data;
	input [31:0] reg_rb_data;
	input [31:0] reg_rt_data;

	input xREG2_do_dm_read;
	input xREG2_do_reg_write;
	input [ 1:0] xREG2_select_write_reg;
	input [ 4:0] xREG2_write_reg_addr;
	input [31:0] xREG2_imm_extend;
	input [31:0] alu_result;

	input xREG3_do_reg_write;
	input [ 4:0] xREG3_write_reg_addr;
	input [31:0] write_reg_data;

	input xREG4_do_reg_write;
	input [ 4:0] xREG4_write_reg_addr;
	input [31:0] xREG4_write_reg_data;

	output [31:0] f_reg_rt_data;
	output [31:0] f_reg_ra_data;
	output [31:0] f_reg_rb_data;
	reg    [31:0] f_reg_rt_data;
	reg    [31:0] f_reg_ra_data;
	reg    [31:0] f_reg_rb_data;

	output do_hazard;
	reg    do_hazard;

	reg [2:0] select_f_reg_rt_data;

	always @(`CHOOSE or reg_rt_addr ) begin
		select_f_reg_rt_data=`FOR_RG_ORI;
		if(`CHOOSE_REG4(reg_rt_addr) ) select_f_reg_rt_data=`FOR_RG_REG4;
		if(`CHOOSE_REG3(reg_rt_addr) ) select_f_reg_rt_data=`FOR_RG_REG3;
		if(`CHOOSE_REG2(reg_rt_addr) ) begin
			if(`CHOOSE_REG2_IMM) select_f_reg_rt_data=`FOR_RG_REG2_IMM;
			if(`CHOOSE_REG2_ALU) select_f_reg_rt_data=`FOR_RG_REG2_ALU;
		end
	end
	always @( `CHOOSE_DATA or reg_rt_data or select_f_reg_rt_data)begin
		case(select_f_reg_rt_data)
			`FOR_RG_ORI:	 f_reg_rt_data=reg_rt_data;
			`FOR_RG_REG4:	 f_reg_rt_data=xREG4_write_reg_data;
			`FOR_RG_REG3:	 f_reg_rt_data=write_reg_data;
			`FOR_RG_REG2_IMM:f_reg_rt_data=xREG2_imm_extend;
			`FOR_RG_REG2_ALU:f_reg_rt_data=alu_result;
			default:	 f_reg_rt_data='bx;
		endcase
	end


	always @(*) begin

		f_reg_ra_data=reg_ra_data;
		f_reg_rb_data=reg_rb_data;
		if(xREG4_do_reg_write)begin
			if(reg_ra_addr==xREG4_write_reg_addr) f_reg_ra_data=xREG4_write_reg_data;
			if(reg_rb_addr==xREG4_write_reg_addr) f_reg_rb_data=xREG4_write_reg_data;
		end
		if(xREG3_do_reg_write)begin
			if(reg_ra_addr==xREG3_write_reg_addr) f_reg_ra_data=write_reg_data;
			if(reg_rb_addr==xREG3_write_reg_addr) f_reg_rb_data=write_reg_data;
		end
		if(xREG2_do_reg_write&&(!xREG2_do_dm_read) )begin
			if(xREG2_select_write_reg==`WRREG_IMMDATA)begin
				if(reg_ra_addr==xREG2_write_reg_addr) f_reg_ra_data=xREG2_imm_extend;
				if(reg_rb_addr==xREG2_write_reg_addr) f_reg_rb_data=xREG2_imm_extend;
			end
			else if(xREG2_select_write_reg==`WRREG_ALURESULT)begin
				if(reg_ra_addr==xREG2_write_reg_addr) f_reg_ra_data=alu_result;
				if(reg_rb_addr==xREG2_write_reg_addr) f_reg_rb_data=alu_result;
			end
		end
	end

	always @(xREG2_do_dm_read or reg_rt_addr or reg_ra_addr or reg_rb_addr or xREG2_write_reg_addr) begin
		if(xREG2_do_dm_read)begin
			if(	   reg_rt_addr==xREG2_write_reg_addr
				|| reg_ra_addr==xREG2_write_reg_addr
				|| reg_rb_addr==xREG2_write_reg_addr)begin
				do_hazard=1'b1;
			end
			else begin
				do_hazard=1'b0;
			end
		end
		else
			do_hazard=1'b0;
	end
endmodule
