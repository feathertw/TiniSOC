`include "def_muxs.v"
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

	always @(*) begin

		f_reg_rt_data=reg_rt_data;
		f_reg_ra_data=reg_ra_data;
		f_reg_rb_data=reg_rb_data;
		if(xREG4_do_reg_write)begin
			if(reg_rt_addr==xREG4_write_reg_addr) f_reg_rt_data=xREG4_write_reg_data;
			if(reg_ra_addr==xREG4_write_reg_addr) f_reg_ra_data=xREG4_write_reg_data;
			if(reg_rb_addr==xREG4_write_reg_addr) f_reg_rb_data=xREG4_write_reg_data;
		end
		if(xREG3_do_reg_write)begin
			if(reg_rt_addr==xREG3_write_reg_addr) f_reg_rt_data=write_reg_data;
			if(reg_ra_addr==xREG3_write_reg_addr) f_reg_ra_data=write_reg_data;
			if(reg_rb_addr==xREG3_write_reg_addr) f_reg_rb_data=write_reg_data;
		end
		if(xREG2_do_reg_write&&(!xREG2_do_dm_read) )begin
			if(xREG2_select_write_reg==`WRREG_IMMDATA)begin
				if(reg_rt_addr==xREG2_write_reg_addr) f_reg_rt_data=xREG2_imm_extend;
				if(reg_ra_addr==xREG2_write_reg_addr) f_reg_ra_data=xREG2_imm_extend;
				if(reg_rb_addr==xREG2_write_reg_addr) f_reg_rb_data=xREG2_imm_extend;
			end
			else if(xREG2_select_write_reg==`WRREG_ALURESULT)begin
				if(reg_rt_addr==xREG2_write_reg_addr) f_reg_rt_data=alu_result;
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
