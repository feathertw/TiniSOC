`include "def_muxs.v"

`define CHOOSE_DATA xREG4_write_reg_data or write_reg_data or xREG2_imm_extend or alu_result
`define CHOOSE_REG4 (xREG4_do_reg_write && (reg_rx_addr==xREG4_write_reg_addr) )
`define CHOOSE_REG3 (xREG3_do_reg_write && (reg_rx_addr==xREG3_write_reg_addr) )
`define CHOOSE_REG2 (xREG2_do_reg_write && (reg_rx_addr==xREG2_write_reg_addr) &&(!xREG2_do_dm_read) )
`define CHOOSE_REG2_IMM (xREG2_select_write_reg==`WRREG_IMMDATA)
`define CHOOSE_REG2_ALU (xREG2_select_write_reg==`WRREG_ALURESULT)
`define CHOOSE xREG4_do_reg_write or xREG4_write_reg_addr or xREG3_do_reg_write or xREG3_write_reg_addr \
		or xREG2_do_reg_write or xREG2_write_reg_addr or xREG2_do_dm_read or xREG2_select_write_reg

`define HAZARD_EVENT reg_rt_addr or reg_ra_addr or reg_rb_addr or xREG2_write_reg_addr
`define HAZARD_ADDR_CONDITION ( ( (reg_rt_addr==xREG2_write_reg_addr)&&(!do_reg_write) ) \
		|| reg_ra_addr==xREG2_write_reg_addr || reg_rb_addr==xREG2_write_reg_addr)

module forw(
	reg_rx_addr,
	reg_rx_data,

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

	f_reg_rx_data
);
	input [ 4:0] reg_rx_addr;
	input [31:0] reg_rx_data;

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

	output [31:0] f_reg_rx_data;
	reg    [31:0] f_reg_rx_data;
	reg    [ 2:0] select_f_reg_rx_data;

	always @(`CHOOSE or reg_rx_addr ) begin
		select_f_reg_rx_data=`FOR_RG_ORI;
		if(`CHOOSE_REG4) select_f_reg_rx_data=`FOR_RG_REG4;
		if(`CHOOSE_REG3) select_f_reg_rx_data=`FOR_RG_REG3;
		if(`CHOOSE_REG2) begin
			if(`CHOOSE_REG2_IMM) select_f_reg_rx_data=`FOR_RG_REG2_IMM;
			if(`CHOOSE_REG2_ALU) select_f_reg_rx_data=`FOR_RG_REG2_ALU;
		end
	end
	always @( `CHOOSE_DATA or reg_rx_data or select_f_reg_rx_data)begin
		case(select_f_reg_rx_data)
			`FOR_RG_ORI:	 f_reg_rx_data=reg_rx_data;
			`FOR_RG_REG4:	 f_reg_rx_data=xREG4_write_reg_data;
			`FOR_RG_REG3:	 f_reg_rx_data=write_reg_data;
			`FOR_RG_REG2_IMM:f_reg_rx_data=xREG2_imm_extend;
			`FOR_RG_REG2_ALU:f_reg_rx_data=alu_result;
			default:	 f_reg_rx_data='bx;
		endcase
	end
endmodule
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

	do_reg_write,
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

	input  do_reg_write;
	output do_hazard;
	reg    do_hazard;

	forw FORW_RT(
		.reg_rx_addr(reg_rt_addr),
		.reg_rx_data(reg_rt_data),

		.xREG2_do_dm_read(xREG2_do_dm_read),
		.xREG2_do_reg_write(xREG2_do_reg_write),
		.xREG2_select_write_reg(xREG2_select_write_reg),
		.xREG2_write_reg_addr(xREG2_write_reg_addr),
		.xREG2_imm_extend(xREG2_imm_extend),
		.alu_result(alu_result),

		.xREG3_do_reg_write(xREG3_do_reg_write),
		.xREG3_write_reg_addr(xREG3_write_reg_addr),
		.write_reg_data(write_reg_data),

		.xREG4_do_reg_write(xREG4_do_reg_write),
		.xREG4_write_reg_addr(xREG4_write_reg_addr),
		.xREG4_write_reg_data(xREG4_write_reg_data),

		.f_reg_rx_data(f_reg_rt_data)
	);

	forw FORW_RA(
		.reg_rx_addr(reg_ra_addr),
		.reg_rx_data(reg_ra_data),

		.xREG2_do_dm_read(xREG2_do_dm_read),
		.xREG2_do_reg_write(xREG2_do_reg_write),
		.xREG2_select_write_reg(xREG2_select_write_reg),
		.xREG2_write_reg_addr(xREG2_write_reg_addr),
		.xREG2_imm_extend(xREG2_imm_extend),
		.alu_result(alu_result),

		.xREG3_do_reg_write(xREG3_do_reg_write),
		.xREG3_write_reg_addr(xREG3_write_reg_addr),
		.write_reg_data(write_reg_data),

		.xREG4_do_reg_write(xREG4_do_reg_write),
		.xREG4_write_reg_addr(xREG4_write_reg_addr),
		.xREG4_write_reg_data(xREG4_write_reg_data),

		.f_reg_rx_data(f_reg_ra_data)
	);

	forw FORW_RB(
		.reg_rx_addr(reg_rb_addr),
		.reg_rx_data(reg_rb_data),

		.xREG2_do_dm_read(xREG2_do_dm_read),
		.xREG2_do_reg_write(xREG2_do_reg_write),
		.xREG2_select_write_reg(xREG2_select_write_reg),
		.xREG2_write_reg_addr(xREG2_write_reg_addr),
		.xREG2_imm_extend(xREG2_imm_extend),
		.alu_result(alu_result),

		.xREG3_do_reg_write(xREG3_do_reg_write),
		.xREG3_write_reg_addr(xREG3_write_reg_addr),
		.write_reg_data(write_reg_data),

		.xREG4_do_reg_write(xREG4_do_reg_write),
		.xREG4_write_reg_addr(xREG4_write_reg_addr),
		.xREG4_write_reg_data(xREG4_write_reg_data),

		.f_reg_rx_data(f_reg_rb_data)
	);

	always @(`HAZARD_EVENT or xREG2_do_dm_read) begin
		if(xREG2_do_dm_read)begin
			if(`HAZARD_ADDR_CONDITION) do_hazard=1'b1;
			else			   do_hazard=1'b0;
		end
		else				   do_hazard=1'b0;
	end
endmodule
