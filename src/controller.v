`include "def_opcode.v"
`include "def_muxs.v"

module controller(
	clock,
	reset,
	instruction,

	opcode,
	sub_op_base,
	sub_op_ls,
	sub_op_sv,
	sub_op_b,
	sub_op_j,

	reg_ra_addr,
	reg_rb_addr,
	reg_rt_addr,

	imm_5bit,
	imm_14bit,
	imm_15bit,
	imm_20bit,
	imm_24bit,
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
	input [31:0] instruction;
	
	output [5:0] opcode;
	output [4:0] sub_op_base;
	output [7:0] sub_op_ls;
	output [1:0] sub_op_sv;
	output sub_op_b;
	output sub_op_j;

	output [4:0] reg_ra_addr;
	output [4:0] reg_rb_addr;
	output [4:0] reg_rt_addr;

	output [4:0] imm_5bit;
	output [13:0] imm_14bit;
	output [14:0] imm_15bit;
	output [19:0] imm_20bit;
	output [23:0] imm_24bit;
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

	reg [31:0] present_instruction;

	wire [5:0] opcode=instruction[30:25];
	wire [4:0] sub_op_base=instruction[4:0];
	wire [7:0] sub_op_ls=instruction[7:0];
	wire [1:0] sub_op_sv=instruction[9:8];
	wire sub_op_b=instruction[14];
	wire sub_op_j=instruction[24];

	wire [4:0] reg_ra_addr=instruction[19:15];
	wire [4:0] reg_rb_addr=instruction[14:10];
	wire [4:0] reg_rt_addr=instruction[24:20];

	wire [4:0] imm_5bit=instruction[14:10];
	wire [13:0] imm_14bit=instruction[13:0];
	wire [14:0] imm_15bit=instruction[14:0];
	wire [19:0] imm_20bit=instruction[19:0];
	wire [23:0] imm_24bit=instruction[23:0];

	assign do_im_read  = (reset)?1'b0:1'b1;
	assign do_im_write = (reset)?1'b0:1'b0;

	assign reg_rt_ra_equal=(reg_rt_data==reg_ra_data)?1'b1:1'b0;

	always@(posedge clock or posedge reset) begin
		if(reset) present_instruction<=0;
		else	  present_instruction<=instruction;
	end

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

