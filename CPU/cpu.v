`include "src/alu.v"
`include "src/regfile.v"
`include "src/muxs.v"
`include "src/controller.v"
`include "src/pc.v"
`include "src/regwalls.v"
`include "src/forward.v"
`include "src/memctr.v"
`include "adv/cache.v"
module cpu(
	clock,
	reset,
	alu_overflow,

	IM_read,
	IM_write,
	IM_enable,
	IM_address,
	IM_out,
	IM_ready,

	DM_read,
	DM_write,
	DM_enable,
	DM_address,
	DM_in,
	DM_out,
	DM_ready,

	IOM_read,
	IOM_write,
	IOM_enable,
	IOM_address,
	IOM_in,
	IOM_out,
	IOM_ready,

	do_system
);
	input clock;
	input reset;
	output alu_overflow;

	output IM_read;
	output IM_write;
	output IM_enable;
	output [31:0] IM_address;
	input [31:0] IM_out;
	input  IM_ready;

	output DM_read;
	output DM_write;
	output DM_enable;
	output [31:0] DM_address;
	output [31:0] DM_in;
	input  [31:0] DM_out;
	input  DM_ready;

	output IOM_read;
	output IOM_write;
	output IOM_enable;
	output [31:0] IOM_address;
	output [31:0] IOM_in;
	input  [31:0] IOM_out;
	input  IOM_ready;

	input do_system;

	//controller
	wire do_im_read;
	wire do_im_write;
	wire do_dm_read;
	wire do_dm_write;
	wire do_reg_write;
	wire [2:0] select_alu_src2;
	wire [1:0] select_imm_extend;
	wire [1:0] select_write_reg;
	wire reg_rt_ra_equal;
	wire reg_rt_zero;
	wire reg_rt_negative;

	//regfile
	wire [31:0] reg_rt_data;
	wire [31:0] reg_ra_data;
	wire [31:0] reg_rb_data;

	//alu
	wire [31:0] alu_result;

	//muxs
	wire [31:0] alu_src2;
	wire [31:0] imm_extend;
	wire [31:0] write_reg_data;

	//pc
	wire [31:0] current_pc;
	wire do_jump_link;

	//mem
	wire [31:0] mem_read_data;

	//forward
	wire [31:0] f_reg_rt_data;
	wire [31:0] f_reg_ra_data;
	wire [31:0] f_reg_rb_data;
	wire do_hazard;

	//REGWALL
	wire [31:0] xREG1_instruction;

	wire [31:0] xREG3_reg_rt_data;
	wire [31:0] xREG2_reg_ra_data;

	wire [ 5:0] xREG2_opcode;
	wire [ 4:0] xREG2_sub_op_base;
	wire [ 1:0] xREG2_select_write_reg;
	wire [ 1:0] xREG3_select_write_reg;
	wire xREG2_do_dm_read;
	wire xREG2_do_reg_write;
	wire xREG3_do_dm_read;
	wire xREG3_do_dm_write;
	wire xREG3_do_reg_write;
	wire xREG4_do_reg_write;

	wire [31:0] xREG2_alu_src2;
	wire [31:0] xREG2_imm_extend;
	wire [31:0] xREG3_imm_extend;

	wire [31:0] xREG3_alu_result;

	wire [ 4:0] xREG2_write_reg_addr;
	wire [ 4:0] xREG3_write_reg_addr;
	wire [ 4:0] xREG4_write_reg_addr;
	wire [31:0] xREG4_write_reg_data;

	wire do_flush_REG1;
	wire do_flush_REG2;
	wire do_flush_REG3;
	wire do_flush_REG4;

	//top
	wire [5:0] opcode	=xREG1_instruction[30:25];
	wire [4:0] sub_op_base	=xREG1_instruction[4:0];
	wire [7:0] sub_op_ls	=xREG1_instruction[7:0];
	wire [1:0] sub_op_sv	=xREG1_instruction[9:8];
	wire sub_op_b		=xREG1_instruction[14];
	wire [3:0] sub_op_bz	=xREG1_instruction[19:16];
	wire sub_op_j		=xREG1_instruction[24];

	wire [4:0] reg_ra_addr  =xREG1_instruction[19:15];
	wire [4:0] reg_rb_addr  =xREG1_instruction[14:10];
	wire [4:0] reg_rt_addr  =xREG1_instruction[24:20];

	wire [ 4:0] imm_5bit    =xREG1_instruction[14:10];
	wire [13:0] imm_14bit   =xREG1_instruction[13:0];
	wire [14:0] imm_15bit   =xREG1_instruction[14:0];
	wire [15:0] imm_16bit   =xREG1_instruction[15:0];
	wire [19:0] imm_20bit   =xREG1_instruction[19:0];
	wire [23:0] imm_24bit   =xREG1_instruction[23:0];

	wire do_dmem_enable;
	wire do_iomem_enable;

	wire iPStrobe=do_im_read||do_im_write;
	wire iPRw=(do_im_read)? 1'b1:1'b0;
	wire [31:0] iPAddress=current_pc;
	wire [31:0] iPData_in;
	wire iSysStrobe;
	wire iSysRW;
	wire [31:0] iSysAddress;
	wire [31:0] iSysData_out=IM_out;
	wire iSysReady=IM_ready;

	wire dPStrobe=do_dmem_enable;
	wire dPRw=(xREG3_do_dm_read)? 1'b1:1'b0;
	wire [31:0] dPAddress=xREG3_alu_result;
	wire iCReady;
	wire dCReady;
	wire [31:0] dPData_in;
	wire [31:0] dPData_out;

	wire dSysStrobe;
	wire dSysRW;
	wire [31:0] dSysAddress;
	wire [31:0] dSysData_in;
	wire [31:0] dSysData_out;
	wire dSysReady=DM_ready;

	wire enable_system=do_system && iCReady && dCReady && IOM_ready;

	//wire enable_system;
	//assign enable_system=(reset)? 1'b0:1'b1;

	assign IM_read =(iSysRW)? 1'b1:1'b0;
	assign IM_write=(iSysRW)? 1'b0:1'b1;
	assign IM_enable=iSysStrobe;
	assign IM_address=iSysAddress[31:0];

	assign DM_read =(dSysRW)? 1'b1:1'b0;
	assign DM_write=(dSysRW)? 1'b0:1'b1;
	assign DM_enable=dSysStrobe;
	assign DM_address=dSysAddress[31:0];
	assign DM_in=dSysData_in;//*
	assign dSysData_out=DM_out;
	assign mem_read_data=(do_dmem_enable)? dPData_in:IOM_out;
	assign dPData_out=xREG3_reg_rt_data;

	wire IOM_read=xREG3_do_dm_read;
	wire IOM_write=xREG3_do_dm_write;
	wire IOM_enable=do_iomem_enable;
	wire [31:0] IOM_address=xREG3_alu_result;
	wire [31:0] IOM_in=xREG3_reg_rt_data;
	wire [31:0] IOM_out;
	wire IOM_ready;

	alu ALU(
		.reset(reset),
		.enable_execute(enable_system),
		.alu_src1(xREG2_reg_ra_data),
		.alu_src2(xREG2_alu_src2),
		.opcode(xREG2_opcode),
		.sub_op_base(xREG2_sub_op_base),

		.alu_result(alu_result),
		.alu_overflow(alu_overflow)
	);
	
	regfile REGFILE(
		.clock(clock),
		.reset(reset),
		.enable_reg_fetch(enable_system),
		.enable_reg_write(enable_system),
		.reg_ra_addr(reg_ra_addr),
		.reg_rb_addr(reg_rb_addr),
		.reg_rt_addr(reg_rt_addr),
		.write_reg_addr(xREG4_write_reg_addr),
		.write_reg_data(xREG4_write_reg_data),
		.do_reg_write(xREG4_do_reg_write),

		.current_pc(current_pc),
		.do_jump_link(do_jump_link),

		.reg_ra_data(reg_ra_data),
		.reg_rb_data(reg_rb_data),
		.reg_rt_data(reg_rt_data)
	);

	muxs MUXS(
		.sub_op_sv(sub_op_sv),
		.reg_rb_data(f_reg_rb_data),
		.reg_rt_data(f_reg_rt_data),

		.alu_result(xREG3_alu_result),//*
		.xREG3_imm_extend(xREG3_imm_extend),
		.mem_read_data(mem_read_data),

		.imm_5bit(imm_5bit),
		.imm_15bit(imm_15bit),
		.imm_20bit(imm_20bit),

		.select_alu_src2(select_alu_src2),
		.select_imm_extend(select_imm_extend),
		.select_write_reg(xREG3_select_write_reg),

		.imm_extend(imm_extend),
		.alu_src2(alu_src2),
		.write_reg_data(write_reg_data)
	);
	
	controller CONTROLLER(
		.clock(clock),
		.reset(reset),

		.opcode(opcode),
		.sub_op_base(sub_op_base),
		.sub_op_ls(sub_op_ls),

		.select_alu_src2(select_alu_src2),
		.select_imm_extend(select_imm_extend),
		.select_write_reg(select_write_reg),

		.do_im_read(do_im_read),
		.do_im_write(do_im_write),
		.do_dm_read(do_dm_read),
		.do_dm_write(do_dm_write),
		.do_reg_write(do_reg_write),

		.reg_rt_data(f_reg_rt_data),
		.reg_ra_data(f_reg_ra_data),
		.reg_rt_ra_equal(reg_rt_ra_equal),
		.reg_rt_zero(reg_rt_zero),
		.reg_rt_negative(reg_rt_negative)
	);
	pc PC(
		.clock(clock),
		.reset(reset),
		.enable_pc(enable_system),
		.current_pc(current_pc),

		.opcode(opcode),
		.sub_op_b(sub_op_b),
		.sub_op_bz(sub_op_bz),
		.sub_op_j(sub_op_j),
		.reg_rt_ra_equal(reg_rt_ra_equal),
		.reg_rt_zero(reg_rt_zero),
		.reg_rt_negative(reg_rt_negative),

		.imm_14bit(imm_14bit),
		.imm_16bit(imm_16bit),
		.imm_24bit(imm_24bit),
		.reg_rb_data(f_reg_rb_data),

		.do_jump_link(do_jump_link),
		.do_flush_REG1(do_flush_REG1),
		.do_hazard(do_hazard)
	);
	regwalls REGWALLS(
		.clock(clock),
		.reset(reset),
		.enable_regwalls(enable_system),
		.iREG1_instruction(iPData_in),
		.oREG1_instruction(xREG1_instruction),
		.iREG2_reg_ra_data(f_reg_ra_data),
		.iREG2_reg_rt_data(f_reg_rt_data),
		.oREG2_reg_ra_data(xREG2_reg_ra_data),
		.oREG3_reg_rt_data(xREG3_reg_rt_data),
		.iREG2_write_reg_addr(reg_rt_addr),
		.mREG2_write_reg_addr(xREG2_write_reg_addr),
		.mREG3_write_reg_addr(xREG3_write_reg_addr),
		.oREG4_write_reg_addr(xREG4_write_reg_addr),

		.iREG2_opcode(opcode),
		.iREG2_sub_op_base(sub_op_base),
		.oREG2_opcode(xREG2_opcode),
		.oREG2_sub_op_base(xREG2_sub_op_base),

		.iREG2_select_write_reg(select_write_reg),
		.mREG2_select_write_reg(xREG2_select_write_reg),
		.oREG3_select_write_reg(xREG3_select_write_reg),

		.iREG2_do_dm_read(do_dm_read),
		.iREG2_do_dm_write(do_dm_write),
		.iREG2_do_reg_write(do_reg_write),
		.mREG2_do_dm_read(xREG2_do_dm_read),
		.mREG2_do_reg_write(xREG2_do_reg_write),
		.oREG3_do_dm_read(xREG3_do_dm_read),
		.oREG3_do_dm_write(xREG3_do_dm_write),
		.mREG3_do_reg_write(xREG3_do_reg_write),
		.oREG4_do_reg_write(xREG4_do_reg_write),

		.iREG2_alu_src2(alu_src2),
		.oREG2_alu_src2(xREG2_alu_src2),
		.iREG2_imm_extend(imm_extend),
		.mREG2_imm_extend(xREG2_imm_extend),
		.oREG3_imm_extend(xREG3_imm_extend),

		.iREG3_alu_result(alu_result),
		.oREG3_alu_result(xREG3_alu_result),

		.iREG4_write_reg_data(write_reg_data),
		.oREG4_write_reg_data(xREG4_write_reg_data),

		.do_flush_REG1(do_flush_REG1),
		.do_hazard(do_hazard)
	);
	forward FORWARD(
		.alu_result(alu_result),
		.xREG2_imm_extend(xREG2_imm_extend),

		.reg_ra_addr(reg_ra_addr),
		.reg_rb_addr(reg_rb_addr),
		.reg_rt_addr(reg_rt_addr),

		.xREG2_do_dm_read(xREG2_do_dm_read),
		.xREG2_do_reg_write(xREG2_do_reg_write),
		.xREG2_select_write_reg(xREG2_select_write_reg),
		.xREG2_write_reg_addr(xREG2_write_reg_addr),

		.xREG3_do_reg_write(xREG3_do_reg_write),
		.xREG3_write_reg_addr(xREG3_write_reg_addr),
		.write_reg_data(write_reg_data),

		.xREG4_do_reg_write(xREG4_do_reg_write),
		.xREG4_write_reg_addr(xREG4_write_reg_addr),
		.xREG4_write_reg_data(xREG4_write_reg_data),

		.reg_ra_data(reg_ra_data),
		.reg_rb_data(reg_rb_data),
		.reg_rt_data(reg_rt_data),

		.f_reg_ra_data(f_reg_ra_data),
		.f_reg_rb_data(f_reg_rb_data),
		.f_reg_rt_data(f_reg_rt_data),

		.do_reg_write(do_reg_write),
		.do_hazard(do_hazard)
	);
	memctr MEMCTR(
		.do_mem_read(xREG3_do_dm_read),
		.do_mem_write(xREG3_do_dm_write),
		.mem_address(xREG3_alu_result),
		.do_dmem_enable(do_dmem_enable),
		.do_iomem_enable(do_iomem_enable)
	);

	cache ICACHE(
		.clock(clock),
		.reset(reset),
		.CReady(iCReady),
		.PStrobe(iPStrobe),
		.PRw(iPRw),
		.PAddress(iPAddress),
		.PData_in(iPData_in),
		.PData_out(),
		.SysStrobe(iSysStrobe),
		.SysRW(iSysRW),
		.SysAddress(iSysAddress),
		.SysData_in(),
		.SysData_out(iSysData_out),
		.SysReady(iSysReady)
	);
	cache DCACHE(
		.clock(clock),
		.reset(reset),
		.CReady(dCReady),
		.PStrobe(dPStrobe),
		.PRw(dPRw),
		.PAddress(dPAddress),
		.PData_in(dPData_in),
		.PData_out(dPData_out),
		.SysStrobe(dSysStrobe),
		.SysRW(dSysRW),
		.SysAddress(dSysAddress),
		.SysData_in(dSysData_in),
		.SysData_out(dSysData_out),
		.SysReady(dSysReady)
	);
endmodule
