`include "def_opcode.v"
`include "def_muxs.v"

module controller(
	clock,
	reset,

	opcode,
	sub_op_base,
	sub_op_ls,

	select_alu_src2,
	select_imm_extend,
	select_write_reg,

	do_im_read,
	do_im_write,
	do_dm_read,
	do_dm_write,
	do_reg_write,

	reg_rt_data,
	reg_ra_data,
	reg_rt_ra_equal
);
	
	input clock;
	input reset;
	
	input [5:0] opcode;
	input [4:0] sub_op_base;
	input [7:0] sub_op_ls;

	output [2:0] select_alu_src2;
	output [1:0] select_imm_extend;
	output [1:0] select_write_reg;

	output do_im_read;
	output do_im_write;
	output do_dm_read;
	output do_dm_write;
	output do_reg_write;

	input [31:0] reg_rt_data;
	input [31:0] reg_ra_data;
	output reg_rt_ra_equal;

	reg [2:0] select_alu_src2;
	reg [1:0] select_imm_extend;
	reg [1:0] select_write_reg;

	reg do_dm_read;
	reg do_dm_write;
	reg do_reg_write;

	assign do_im_read  = (reset)?1'b0:1'b1;
	assign do_im_write = (reset)?1'b0:1'b0;

	assign reg_rt_ra_equal=(reg_rt_data==reg_ra_data)?1'b1:1'b0;

	always@(opcode or sub_op_base or sub_op_ls) begin
		case(opcode)
			`TY_BASE: begin
				case(sub_op_base)
					//`NOP:begin
					//	select_alu_src2=`ALUSRC2_RBDATA;
					//	select_imm_extend=`IMM_UNKOWN;
					//	select_write_reg=`WRREG_ALURESULT;
					//	do_dm_read=1'b0;
					//	do_dm_write=1'b0;
					//end
					`ADD:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_ALURESULT;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					`SUB:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_ALURESULT;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					`AND:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_ALURESULT;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					`OR :begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_ALURESULT;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					`XOR:begin
						select_alu_src2=`ALUSRC2_RBDATA;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_ALURESULT;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					//Immediate
					`SRLI:begin
						select_alu_src2=`ALUSRC2_IMM;
						select_imm_extend=`IMM_5BIT_ZE;
						select_write_reg=`WRREG_ALURESULT;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					`SLLI:begin
						select_alu_src2=`ALUSRC2_IMM;
						select_imm_extend=`IMM_5BIT_ZE;
						select_write_reg=`WRREG_ALURESULT;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					`ROTRI:begin
						select_alu_src2=`ALUSRC2_IMM;
						select_imm_extend=`IMM_5BIT_ZE;
						select_write_reg=`WRREG_ALURESULT;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					default:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
					end
				endcase	
			end
			`ADDI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_SE;
				select_write_reg=`WRREG_ALURESULT;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
			end
			`ORI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_ZE;
				select_write_reg=`WRREG_ALURESULT;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
			end
			`XORI:begin
				select_alu_src2=`ALUSRC2_IMM;
				select_imm_extend=`IMM_15BIT_ZE;
				select_write_reg=`WRREG_ALURESULT;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
			end
			`MOVI:begin
				select_alu_src2=`ALUSRC2_UNKNOWN;
				select_imm_extend=`IMM_20BIT_SE;
				select_write_reg=`WRREG_IMMDATA;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
			end
			`LWI:begin
				select_alu_src2=`ALUSRC2_LSWI;
				select_imm_extend=`IMM_UNKOWN;
				select_write_reg=`WRREG_MEM;
				do_dm_read=1'b1;
				do_dm_write=1'b0;
				do_reg_write=1'b1;
			end
			`SWI:begin
				select_alu_src2=`ALUSRC2_LSWI;
				select_imm_extend=`IMM_UNKOWN;
				select_write_reg=`WRREG_UNKOWN;
				do_dm_read=1'b0;
				do_dm_write=1'b1;
				do_reg_write=1'b0;
			end
			`TY_LS:begin
				case(sub_op_ls)
					`LW:begin
						select_alu_src2=`ALUSRC2_LSW;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_MEM;
						do_dm_read=1'b1;
						do_dm_write=1'b0;
						do_reg_write=1'b1;
					end
					`SW:begin
						select_alu_src2=`ALUSRC2_LSW;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						do_dm_read=1'b0;
						do_dm_write=1'b1;
						do_reg_write=1'b0;
					end
					default:begin
						select_alu_src2=`ALUSRC2_UNKNOWN;
						select_imm_extend=`IMM_UNKOWN;
						select_write_reg=`WRREG_UNKOWN;
						do_dm_read=1'b0;
						do_dm_write=1'b0;
						do_reg_write=1'b0;
					end
				endcase
			end
			`TY_B:begin
				select_alu_src2=`ALUSRC2_BENX;
				select_imm_extend=`IMM_UNKOWN;
				select_write_reg=`WRREG_UNKOWN;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b0;
			end
			`TY_J:begin
				select_alu_src2=`ALUSRC2_UNKNOWN;
				select_imm_extend=`IMM_UNKOWN;
				select_write_reg=`WRREG_UNKOWN;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b0;
			end
			default:begin
				select_alu_src2=`ALUSRC2_UNKNOWN;
				select_imm_extend=`IMM_UNKOWN;
				select_write_reg=`WRREG_UNKOWN;
				do_dm_read=1'b0;
				do_dm_write=1'b0;
				do_reg_write=1'b0;
			end
		endcase
	end
endmodule

