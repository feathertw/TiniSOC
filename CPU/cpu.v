`include "src/alu.v"
`include "src/regfile.v"
`include "src/muxs.v"
`include "src/controller.v"
`include "src/pc.v"
`include "src/regwalls.v"
`include "src/forward.v"
`include "src/memctr.v"
`include "src/cache.v"
`include "src/jcache.v"
`include "src/bcache.v"
`include "src/interrupt.v"
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
	wire do_syscall_it;
	wire do_it_return;
	wire do_im_read;
	wire do_im_write;
	wire do_dm_read;
	wire do_dm_write;
	wire do_reg_write;
	wire do_ra_write;
	wire [2:0] select_alu_src2;
	wire [2:0] select_imm_extend;
	wire  select_mem_addr;
	wire  select_write_reg_addr;
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
	wire [31:0] write_ra_data = alu_result[31:0];

	//muxs
	wire [31:0] alu_src2;
	wire [31:0] imm_extend;
	wire [ 4:0] write_reg_addr;
	wire [31:0] write_reg_data;

	//mem
	wire [31:0] mem_address;
	wire [31:0] mem_read_data;

	//forward
	wire [31:0] f_reg_rt_data;
	wire [31:0] f_reg_ra_data;
	wire [31:0] f_reg_rb_data;
	wire do_hazard;

	//REGWALL
	wire [31:0] xREG1_instruction;
	wire [31:0] xREG1_current_pc;
	wire xREG1_do_jcache_link;
	wire xREG1_do_jcache;
	wire [31:0] xREG1_bcache_opc;
	wire xREG1_do_hit_bcache;
	wire xREG1_do_bcache;

	wire [31:0] xREG3_reg_rt_data;
	wire [31:0] xREG2_reg_ra_data;
	wire [31:0] xREG3_reg_ra_data;

	wire [ 5:0] xREG2_opcode;
	wire [ 4:0] xREG2_sub_op_base;
	wire xREG3_select_mem_addr;
	wire [ 1:0] xREG2_select_write_reg;
	wire [ 1:0] xREG3_select_write_reg;
	wire xREG2_do_dm_read;
	wire xREG2_do_reg_write;
	wire xREG3_do_dm_read;
	wire xREG3_do_dm_write;
	wire xREG3_do_reg_write;
	wire xREG4_do_reg_write;
	wire xREG2_do_ra_write;
	wire xREG3_do_ra_write;
	wire xREG4_do_ra_write;

	wire [31:0] xREG2_alu_src2;
	wire [31:0] xREG2_imm_extend;
	wire [31:0] xREG3_imm_extend;

	wire [31:0] xREG3_alu_result;

	wire [ 4:0] xREG2_write_reg_addr;
	wire [ 4:0] xREG3_write_reg_addr;
	wire [ 4:0] xREG4_write_reg_addr;
	wire [ 4:0] xREG2_write_ra_addr;
	wire [ 4:0] xREG3_write_ra_addr;
	wire [ 4:0] xREG4_write_ra_addr;
	wire [31:0] xREG4_write_reg_data;
	wire [31:0] xREG3_write_ra_data;
	wire [31:0] xREG4_write_ra_data;

	wire [31:0] xREG3_write_reg_pc;

	wire do_flush_REG1_pc;
	wire do_flush_REG1_interrupt;
	wire do_flush_REG1=do_flush_REG1_pc||do_flush_REG1_interrupt;
	wire do_flush_REG2;
	wire do_flush_REG3;
	wire do_flush_REG4;

	//pc
	wire [31:0] current_pc;
	wire [31:0] target_pc;
	wire [31:0] write_reg_pc=(xREG1_do_jcache_link)? xREG1_current_pc+4:current_pc;
	wire do_branch;

	//jcache
	wire [31:0] jcache_pc;
	wire do_jcache_link;
	wire do_jcache;

	//bcache
	wire [31:0] bcache_opc;
	wire [31:0] bcache_pc;
	wire do_hit_bcache;
	wire do_bcache;

	//top
	wire [5:0] opcode	=xREG1_instruction[30:25];
	wire [4:0] sub_op_base	=xREG1_instruction[4:0];
	wire [7:0] sub_op_ls	=xREG1_instruction[7:0];
	wire [1:0] sub_op_sv	=xREG1_instruction[9:8];
	wire sub_op_b		=xREG1_instruction[14];
	wire [3:0] sub_op_bz	=xREG1_instruction[19:16];
	wire sub_op_j		=xREG1_instruction[24];
	wire [4:0] sub_op_jr	=xREG1_instruction[4:0];
	wire [4:0] sub_op_misc	=xREG1_instruction[4:0];

	wire [4:0] reg_ra_addr  =xREG1_instruction[19:15];
	wire [4:0] reg_rb_addr  =xREG1_instruction[14:10];
	wire [4:0] reg_rt_addr  =xREG1_instruction[24:20];

	wire [ 4:0] imm_5bit    =xREG1_instruction[14:10];
	wire [13:0] imm_14bit   =xREG1_instruction[13:0];
	wire [14:0] imm_15bit   =xREG1_instruction[14:0];
	wire [15:0] imm_16bit   =xREG1_instruction[15:0];
	wire [19:0] imm_20bit   =xREG1_instruction[19:0];
	wire [23:0] imm_24bit   =xREG1_instruction[23:0];

	//interrupt
	wire do_halt_pc;
	wire do_interrupt;
	wire [31:0] interrupt_pc;
	wire [ 5:0] it_opcode;
	wire [ 4:0] it_reg_rt_addr;
	wire [ 4:0] it_reg_ra_addr;
	wire [ 4:0] it_reg_rb_addr;
	wire [14:0] it_imm_15bit;
	wire do_it_store_pc;
	wire do_it_load_pc;
	wire do_it_state;
	wire [31:0] it_return_pc=xREG4_write_reg_data;

	wire [ 5:0] final_opcode	=(do_it_state)? it_opcode:opcode;
	wire [ 4:0] final_reg_rt_addr	=(do_it_state)? it_reg_rt_addr:reg_rt_addr;
	wire [ 4:0] final_reg_ra_addr	=(do_it_state)? it_reg_ra_addr:reg_ra_addr;
	wire [ 4:0] final_reg_rb_addr	=(do_it_state)? it_reg_rb_addr:reg_rb_addr;
	wire [14:0] final_imm_15bit	=(do_it_state)? it_imm_15bit:imm_15bit;
	wire [31:0] final_reg_rt_data	=(do_it_state&&do_it_store_pc)? current_pc:f_reg_rt_data;

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
	wire [31:0] dPAddress=mem_address;
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
	wire [31:0] IOM_address=mem_address;
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
		.reg_ra_addr(final_reg_ra_addr),
		.reg_rb_addr(final_reg_rb_addr),
		.reg_rt_addr(final_reg_rt_addr),
		.write_reg_addr(xREG4_write_reg_addr),
		.write_reg_data(xREG4_write_reg_data),
		.write_ra_addr(xREG4_write_ra_addr),
		.write_ra_data(xREG4_write_ra_data),
		.do_reg_write(xREG4_do_reg_write),
		.do_ra_write(xREG4_do_ra_write),

		.reg_ra_data(reg_ra_data),
		.reg_rb_data(reg_rb_data),
		.reg_rt_data(reg_rt_data)
	);

	muxs MUXS(
		.sub_op_sv(sub_op_sv),
		.reg_rb_data(f_reg_rb_data),
		.reg_rt_data(final_reg_rt_data),

		.reg_rt_addr(final_reg_rt_addr),

		.xREG3_alu_result(xREG3_alu_result),//*
		.xREG3_imm_extend(xREG3_imm_extend),
		.mem_read_data(mem_read_data),
		.xREG3_write_reg_pc(xREG3_write_reg_pc),
		.xREG3_reg_ra_data(xREG3_reg_ra_data),

		.imm_5bit(imm_5bit),
		.imm_15bit(final_imm_15bit),
		.imm_20bit(imm_20bit),

		.select_alu_src2(select_alu_src2),
		.select_imm_extend(select_imm_extend),
		.select_mem_addr(xREG3_select_mem_addr),
		.select_write_reg_addr(select_write_reg_addr),
		.select_write_reg(xREG3_select_write_reg),

		.alu_src2(alu_src2),
		.imm_extend(imm_extend),
		.mem_address(mem_address),
		.write_reg_addr(write_reg_addr),
		.write_reg_data(write_reg_data)
	);
	
	controller CONTROLLER(
		.clock(clock),
		.reset(reset),

		.opcode(final_opcode),
		.sub_op_base(sub_op_base),
		.sub_op_ls(sub_op_ls),
		.sub_op_j(sub_op_j),
		.sub_op_jr(sub_op_jr),
		.sub_op_misc(sub_op_misc),

		.select_alu_src2(select_alu_src2),
		.select_imm_extend(select_imm_extend),
		.select_mem_addr(select_mem_addr),
		.select_write_reg_addr(select_write_reg_addr),
		.select_write_reg(select_write_reg),

		.do_syscall_it(do_syscall_it),
		.do_it_return(do_it_return),
		.do_im_read(do_im_read),
		.do_im_write(do_im_write),
		.do_dm_read(do_dm_read),
		.do_dm_write(do_dm_write),
		.do_reg_write(do_reg_write),
		.do_ra_write(do_ra_write),

		.reg_rt_data(final_reg_rt_data),
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
		.target_pc(target_pc),
		.do_branch(do_branch),

		.opcode(final_opcode),
		.sub_op_b(sub_op_b),
		.sub_op_bz(sub_op_bz),
		.reg_rt_ra_equal(reg_rt_ra_equal),
		.reg_rt_zero(reg_rt_zero),
		.reg_rt_negative(reg_rt_negative),

		.imm_14bit(imm_14bit),
		.imm_16bit(imm_16bit),
		.imm_24bit(imm_24bit),
		.reg_rb_data(f_reg_rb_data),

		.do_flush_REG1(do_flush_REG1_pc),
		.do_hazard(do_hazard),

		.xREG1_do_jcache(xREG1_do_jcache),
		.jcache_pc(jcache_pc),
		.do_jcache(do_jcache),
		.xREG1_bcache_opc(xREG1_bcache_opc),
		.xREG1_do_bcache(xREG1_do_bcache),
		.bcache_pc(bcache_pc),
		.do_bcache(do_bcache),

		.do_halt_pc(do_halt_pc),
		.do_interrupt(do_interrupt),
		.interrupt_pc(interrupt_pc),
		.do_it_load_pc(do_it_load_pc),
		.it_return_pc(it_return_pc)
	);
	regwalls REGWALLS(
		.clock(clock),
		.reset(reset),
		.enable_regwalls(enable_system),
		.iREG1_instruction(iPData_in),
		.oREG1_instruction(xREG1_instruction),
		.iREG1_current_pc(current_pc),
		.oREG1_current_pc(xREG1_current_pc),
		.iREG1_do_jcache_link(do_jcache_link),
		.oREG1_do_jcache_link(xREG1_do_jcache_link),
		.iREG1_do_jcache(do_jcache),
		.oREG1_do_jcache(xREG1_do_jcache),
		.iREG1_bcache_opc(bcache_opc),
		.oREG1_bcache_opc(xREG1_bcache_opc),
		.iREG1_do_hit_bcache(do_hit_bcache),
		.oREG1_do_hit_bcache(xREG1_do_hit_bcache),
		.iREG1_do_bcache(do_bcache),
		.oREG1_do_bcache(xREG1_do_bcache),
		.iREG2_reg_ra_data(f_reg_ra_data),
		.mREG2_reg_ra_data(xREG2_reg_ra_data),
		.oREG3_reg_ra_data(xREG3_reg_ra_data),
		.iREG2_reg_rt_data(final_reg_rt_data),
		.oREG3_reg_rt_data(xREG3_reg_rt_data),
		.iREG2_write_reg_addr(write_reg_addr),
		.mREG2_write_reg_addr(xREG2_write_reg_addr),
		.mREG3_write_reg_addr(xREG3_write_reg_addr),
		.oREG4_write_reg_addr(xREG4_write_reg_addr),
		.iREG2_write_ra_addr(final_reg_ra_addr),
		.mREG2_write_ra_addr(xREG2_write_ra_addr),
		.mREG3_write_ra_addr(xREG3_write_ra_addr),
		.oREG4_write_ra_addr(xREG4_write_ra_addr),

		.iREG2_opcode(final_opcode),
		.iREG2_sub_op_base(sub_op_base),
		.oREG2_opcode(xREG2_opcode),
		.oREG2_sub_op_base(xREG2_sub_op_base),

		.iREG2_select_mem_addr(select_mem_addr),
		.oREG3_select_mem_addr(xREG3_select_mem_addr),
		.iREG2_select_write_reg(select_write_reg),
		.mREG2_select_write_reg(xREG2_select_write_reg),
		.oREG3_select_write_reg(xREG3_select_write_reg),

		.iREG2_do_dm_read(do_dm_read),
		.iREG2_do_dm_write(do_dm_write),
		.iREG2_do_reg_write(do_reg_write),
		.iREG2_do_ra_write(do_ra_write),
		.mREG2_do_dm_read(xREG2_do_dm_read),
		.mREG2_do_reg_write(xREG2_do_reg_write),
		.mREG3_do_reg_write(xREG3_do_reg_write),
		.mREG2_do_ra_write(xREG2_do_ra_write),
		.mREG3_do_ra_write(xREG3_do_ra_write),
		.oREG3_do_dm_read(xREG3_do_dm_read),
		.oREG3_do_dm_write(xREG3_do_dm_write),
		.oREG4_do_reg_write(xREG4_do_reg_write),
		.oREG4_do_ra_write(xREG4_do_ra_write),

		.iREG2_alu_src2(alu_src2),
		.oREG2_alu_src2(xREG2_alu_src2),
		.iREG2_imm_extend(imm_extend),
		.mREG2_imm_extend(xREG2_imm_extend),
		.oREG3_imm_extend(xREG3_imm_extend),

		.iREG3_alu_result(alu_result),
		.oREG3_alu_result(xREG3_alu_result),

		.iREG4_write_reg_data(write_reg_data),
		.oREG4_write_reg_data(xREG4_write_reg_data),
		.iREG3_write_ra_data(write_ra_data),
		.mREG3_write_ra_data(xREG3_write_ra_data),
		.oREG4_write_ra_data(xREG4_write_ra_data),

		.iREG2_write_reg_pc(write_reg_pc),
		.oREG3_write_reg_pc(xREG3_write_reg_pc),

		.do_flush_REG1(do_flush_REG1),
		.do_hazard(do_hazard)
	);
	forward FORWARD(
		.reg_ra_addr(final_reg_ra_addr),
		.reg_rb_addr(final_reg_rb_addr),
		.reg_rt_addr(final_reg_rt_addr),
		.reg_ra_data(reg_ra_data),
		.reg_rb_data(reg_rb_data),
		.reg_rt_data(reg_rt_data),

		.xREG2_do_dm_read(xREG2_do_dm_read),
		.xREG2_select_write_reg(xREG2_select_write_reg),

		.xREG2_do_reg_write(xREG2_do_reg_write),
		.xREG3_do_reg_write(xREG3_do_reg_write),
		.xREG4_do_reg_write(xREG4_do_reg_write),
		.xREG2_write_reg_addr(xREG2_write_reg_addr),
		.xREG3_write_reg_addr(xREG3_write_reg_addr),
		.xREG4_write_reg_addr(xREG4_write_reg_addr),
		.xREG2_imm_extend(xREG2_imm_extend),
		.alu_result(alu_result),
		.write_reg_data(write_reg_data),
		.xREG4_write_reg_data(xREG4_write_reg_data),

		.xREG2_do_ra_write(xREG2_do_ra_write),
		.xREG3_do_ra_write(xREG3_do_ra_write),
		.xREG4_do_ra_write(xREG4_do_ra_write),
		.xREG2_write_ra_addr(xREG2_write_ra_addr),
		.xREG3_write_ra_addr(xREG3_write_ra_addr),
		.xREG4_write_ra_addr(xREG4_write_ra_addr),
		.write_ra_data(write_ra_data),
		.xREG3_write_ra_data(xREG3_write_ra_data),
		.xREG4_write_ra_data(xREG4_write_ra_data),

		.f_reg_ra_data(f_reg_ra_data),
		.f_reg_rb_data(f_reg_rb_data),
		.f_reg_rt_data(f_reg_rt_data),

		.do_reg_write(do_reg_write),
		.do_hazard(do_hazard)
	);
	memctr MEMCTR(
		.do_mem_read(xREG3_do_dm_read),
		.do_mem_write(xREG3_do_dm_write),
		.mem_address(mem_address),
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
	jcache JCACHE(
		.clock(clock),
		.reset(reset),
		.enable_jcache(enable_system),
		.current_pc(current_pc),
		.target_pc(target_pc),
		.opcode(final_opcode),
		.sub_op_j(sub_op_j),
		.do_flush_REG1(do_flush_REG1),
		.xREG1_do_jcache(xREG1_do_jcache),
		.jcache_pc(jcache_pc),
		.do_jcache_link(do_jcache_link),
		.do_jcache(do_jcache)
	);
	bcache BCACHE(
		.clock(clock),
		.reset(reset),
		.enable_bcache(enable_system),
		.current_pc(current_pc),
		.target_pc(target_pc),
		.do_branch(do_branch),
		.opcode(final_opcode),
		.do_flush_REG1(do_flush_REG1),
		.xREG1_do_hit_bcache(xREG1_do_hit_bcache),
		.bcache_opc(bcache_opc),
		.bcache_pc(bcache_pc),
		.do_hit_bcache(do_hit_bcache),
		.do_bcache(do_bcache)
	);
	interrupt INTERRUPT(
		.clock(clock),
		.reset(reset),
		.enable_system(enable_system),
		.do_syscall_it(do_syscall_it),
		.do_it_return(do_it_return),
		.do_halt_pc(do_halt_pc),
		.do_flush_REG1(do_flush_REG1_interrupt),
		.do_interrupt(do_interrupt),
		.interrupt_pc(interrupt_pc),
		.it_opcode(it_opcode),
		.it_reg_rt_addr(it_reg_rt_addr),
		.it_reg_ra_addr(it_reg_ra_addr),
		.it_reg_rb_addr(it_reg_rb_addr),
		.it_imm_15bit(it_imm_15bit),
		.do_it_store_pc(do_it_store_pc),
		.do_it_load_pc(do_it_load_pc),
		.do_it_state(do_it_state)
	);
endmodule
