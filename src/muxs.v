`include "def_muxs.v"
module muxs(

	sub_op_sv,
	reg_rb_data,
	reg_rt_data,

	alu_result,
	xREG3_imm_extend,
	mem_read_data,

	imm_5bit,
	imm_15bit,
	imm_20bit,

	select_alu_src2,
	select_imm_extend,
	select_write_reg,

	imm_extend,
	alu_src2,
	write_reg_data
);

	parameter DataSize = 32;

	input [1:0] sub_op_sv;
	input [DataSize-1:0] reg_rb_data;
	input [DataSize-1:0] reg_rt_data;

	input [DataSize-1:0] alu_result;
	input [DataSize-1:0] xREG3_imm_extend;
	input [DataSize-1:0] mem_read_data;

	input [4:0] imm_5bit;
	input [14:0] imm_15bit;
	input [19:0] imm_20bit;

	input [2:0] select_alu_src2;
	input [1:0] select_imm_extend;
	input [1:0] select_write_reg;

	output [DataSize-1:0] imm_extend;
	output [DataSize-1:0] alu_src2;
	output [DataSize-1:0] write_reg_data;
	
	reg [DataSize-1:0] alu_src2;
	reg [DataSize-1:0] write_reg_data;

	reg [DataSize-1:0] imm_extend;

	always @(select_imm_extend or imm_5bit or imm_15bit or imm_20bit) begin
		case(select_imm_extend)
			`IMM_5BIT_ZE: begin
				imm_extend={ {27{1'b0}}, imm_5bit };
			end
			`IMM_15BIT_SE: begin
				imm_extend={ {17{imm_15bit[14]}}, {imm_15bit} };
			end
			`IMM_15BIT_ZE: begin
				imm_extend={ {17{1'b0}}, {imm_15bit} };
			end
			`IMM_20BIT_SE: begin
				imm_extend={ {12{imm_20bit[19]}}, {imm_20bit} };
			end
			default: begin
				imm_extend=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			end
		endcase
	end

	always @(select_alu_src2 or reg_rb_data or imm_extend or imm_15bit or sub_op_sv or reg_rt_data) begin
		case(select_alu_src2)
			`ALUSRC2_RBDATA: begin
				alu_src2 = reg_rb_data;
			end
			`ALUSRC2_IMM: begin
				alu_src2 = imm_extend;
			end
			`ALUSRC2_LSWI: begin
				alu_src2 = { {15{imm_15bit[14]}},imm_15bit,2'b00}; //*
			end
			`ALUSRC2_LSW: begin
				alu_src2 = reg_rb_data<<sub_op_sv;
			end
			`ALUSRC2_BENX: begin
				alu_src2 = reg_rt_data;
			end
			default: begin
				alu_src2 = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			end
		endcase
	end

	always @(select_write_reg or alu_result or xREG3_imm_extend or mem_read_data) begin
		case(select_write_reg)
			`WRREG_ALURESULT: begin
				write_reg_data = alu_result;
			end
			`WRREG_IMMDATA: begin
				write_reg_data = xREG3_imm_extend;
			end
			`WRREG_MEM: begin
				write_reg_data = mem_read_data;
			end
			default: begin
				write_reg_data = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			end
		endcase
	end
endmodule

