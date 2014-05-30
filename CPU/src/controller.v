`include "def_opcode.v"
`include "def_muxs.v"

module controller(
	clock,
	reset,

	opcode,
	sub_op_base,
	sub_op_ls,
	sub_op_j,
	sub_op_jr,
	sub_op_misc,

	select_alu_src2,
	select_imm_extend,
	select_mem_addr,
	select_write_reg_addr,
	select_write_reg,
	select_misc,

	do_misc,
	do_im_read,
	do_im_write,
	do_dm_read,
	do_dm_write,
	do_reg_write,
	do_ra_write,

	reg_rt_data,
	reg_ra_data,
	reg_rt_ra_equal,
	reg_rt_zero,
	reg_rt_negative
);
	
	input clock;
	input reset;
	
	input [5:0] opcode;
	input [4:0] sub_op_base;
	input [7:0] sub_op_ls;
	input sub_op_j;
	input [4:0] sub_op_jr;
	input [4:0] sub_op_misc;

	output [2:0] select_alu_src2;
	output [2:0] select_imm_extend;
	output select_mem_addr;
	output select_write_reg_addr;
	output [2:0] select_write_reg;
	output [1:0] select_misc;

	output do_misc;
	output do_im_read;
	output do_im_write;
	output do_dm_read;
	output do_dm_write;
	output do_reg_write;
	output do_ra_write;

	input [31:0] reg_rt_data;
	input [31:0] reg_ra_data;
	output reg_rt_ra_equal;
	output reg_rt_zero;
	output reg_rt_negative;

	reg [2:0] select_alu_src2;
	reg [2:0] select_imm_extend;
	reg select_mem_addr;
	reg select_write_reg_addr;
	reg [2:0] select_write_reg;
	reg [1:0] select_misc;

	reg do_misc;
	reg do_dm_read;
	reg do_dm_write;
	reg do_reg_write;
	reg do_ra_write;

	assign do_im_read  = (reset)?1'b0:1'b1;
	assign do_im_write = (reset)?1'b0:1'b0;

	assign reg_rt_ra_equal=(reg_rt_data==reg_ra_data)?1'b1:1'b0;
	assign reg_rt_zero=!(|reg_rt_data);//*
	assign reg_rt_negative=reg_rt_data[31];

	always@(opcode or sub_op_base or sub_op_ls or sub_op_j or sub_op_jr or sub_op_misc) begin
		case(opcode)
			`TY_BASE: begin
				case(sub_op_base)
					//`NOP:begin
					//	select_alu_src2=`ALUSRC2_RBDATA;
					//	select_imm_extend=`IMM_UNKOWN;
					//	select_mem_addr=`MADDR_UNKOWN;
					//	select_write_reg_addr=`WRADDR_UNKOWN;
					//	select_write_reg=`WRREG_ALURESULT;
					//	select_misc=`MISC_UNKNOW;
					//	do_misc=1'b0;
					//	do_dm_read=1'b0;
					//	do_dm_write=1'b0;
					//end
					`ADD:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`SUB:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`AND:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`OR :begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`XOR:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`SLT:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`SLTS:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`SRL:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`SLL:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					//Immediate
					`SRLI:begin
						select_alu_src2=`ALUSRC2_IMM;
						select_imm_extend=`IMM_5BIT_ZE;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`SLLI:begin
						select_alu_src2=`ALUSRC2_IMM;
						select_imm_extend=`IMM_5BIT_ZE;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`ROTRI:begin
						select_alu_src2=`ALUSRC2_IMM;
						select_imm_extend=`IMM_5BIT_ZE;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_ALURESULT;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					default:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
				endcase	
			end
			`ADDI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_SE;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_ALURESULT;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`SUBRI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_SE;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_ALURESULT;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`ANDI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_ZE;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_ALURESULT;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`ORI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_ZE;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_ALURESULT;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`XORI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_ZE;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_ALURESULT;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`SLTI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_SE;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_ALURESULT;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`SLTSI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_SE;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_ALURESULT;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`MOVI:begin
				select_alu_src2=`ALUSRC2_UNKNOWN;
				select_imm_extend=`IMM_20BIT_SE;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_IMMDATA;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`SETHI:begin
				select_alu_src2=`ALUSRC2_UNKNOWN;
				select_imm_extend=`IMM_20BIT_HI;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_IMMDATA;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`LWI:begin
				select_alu_src2=`ALUSRC2_LSWI;
				select_imm_extend=`IMM_UNKOWN;
				select_mem_addr=`MADDR_ALURESULT;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_MEM;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b1;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b0;
			end
			`SWI:begin
				select_alu_src2=`ALUSRC2_LSWI;
				select_imm_extend=`IMM_UNKOWN;
				select_mem_addr=`MADDR_ALURESULT;
				select_write_reg_addr=`WRADDR_UNKOWN;
				select_write_reg=`WRREG_UNKOWN;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b1;
				do_reg_write=1'b0;
				do_ra_write=1'b0;
			end
			`LWIBI:begin
				select_alu_src2=`ALUSRC2_LSWI;
				select_imm_extend=`IMM_UNKOWN;
				select_mem_addr=`MADDR_RADATA;
				select_write_reg_addr=`WRADDR_RT;
				select_write_reg=`WRREG_MEM;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b1;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
				do_ra_write=1'b1;
			end
			`SWIBI:begin
				select_alu_src2=`ALUSRC2_LSWI;
				select_imm_extend=`IMM_UNKOWN;
				select_mem_addr=`MADDR_RADATA;
				select_write_reg_addr=`WRADDR_UNKOWN;
				select_write_reg=`WRREG_UNKOWN;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b1;
				do_reg_write=1'b0;
				do_ra_write=1'b1;
			end
			`TY_LS:begin
				case(sub_op_ls)
					`LW:begin
						select_alu_src2=`ALUSRC2_LSW;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_ALURESULT;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_MEM;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b1;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`SW:begin
						select_alu_src2=`ALUSRC2_LSW;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_ALURESULT;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b1;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
					default:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
				endcase
			end
			`TY_B:begin
				select_alu_src2=`ALUSRC2_BENX;
				select_imm_extend=`IMM_UNKOWN;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_UNKOWN;
				select_write_reg=`WRREG_UNKOWN;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b0;
				do_ra_write=1'b0;
			end
			`TY_J:begin
				case(sub_op_j)
					`JAL:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_LP;
						select_write_reg=`WRREG_PC;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					default:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
				endcase
			end
			`TY_JR:begin
				case(sub_op_jr)
					`JRAL:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_PC;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					default:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
				endcase
			end
			`TY_MISC:begin
				case(sub_op_misc)
					`MTSR:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_RTDATA;
						select_misc=`MISC_MTSR;
						do_misc=1'b1;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
					`MFSR:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_RT;
						select_write_reg=`WRREG_SYSREG;
						select_misc=`MISC_MFSR;
						do_misc=1'b1;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
						do_ra_write=1'b0;
					end
					`SYSCALL:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						select_misc=`MISC_SYSCALL;
						do_misc=1'b1;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
					`IRET:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						select_misc=`MISC_IRET;
						do_misc=1'b1;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
					default:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_mem_addr=`MADDR_UNKOWN;
						select_write_reg_addr=`WRADDR_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						select_misc=`MISC_UNKNOW;
						do_misc=1'b0;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
						do_ra_write=1'b0;
					end
				endcase
			end
			default:begin
				select_alu_src2=`ALUSRC2_UNKNOWN;
				select_imm_extend=`IMM_UNKOWN;
				select_mem_addr=`MADDR_UNKOWN;
				select_write_reg_addr=`WRADDR_UNKOWN;
				select_write_reg=`WRREG_UNKOWN;
				select_misc=`MISC_UNKNOW;
				do_misc=1'b0;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b0;
				do_ra_write=1'b0;
			end
		endcase
	end
endmodule

