`include "def_muxs.v"
module muxs(

	sub_op_sv,
	reg_rb_data,
	reg_rt_data,
	mem_read_data,
	alu_output,
	imm_5bit,
	imm_15bit,
	imm_20bit,

	select_alu_src2,
	select_imm_extend,
	select_write_reg,

	alu_src2,
	write_reg_data
);

	parameter DataSize = 32;

	input [1:0] sub_op_sv;
	input [DataSize-1:0] reg_rb_data;
	input [DataSize-1:0] reg_rt_data;
	input [DataSize-1:0] mem_read_data;
	input [DataSize-1:0] alu_output;
	input [4:0] imm_5bit;
	input [14:0] imm_15bit;
	input [19:0] imm_20bit;

	input [2:0] select_alu_src2;
	input [1:0] select_imm_extend;
	input [1:0] select_write_reg;

	output [DataSize-1:0] alu_src2;
	output [DataSize-1:0] write_reg_data;
	
	reg [DataSize-1:0] alu_src2;
	reg [DataSize-1:0] write_reg_data;

	reg [DataSize-1:0] imm;

	always @(select_imm_extend or imm_5bit or imm_15bit or imm_20bit) begin
		case(select_imm_extend)
			`IMM_5BIT_ZE: begin
				imm={ {27{1'b0}}, imm_5bit };
			end
			`IMM_15BIT_SE: begin
				imm={ {17{imm_15bit[14]}}, {imm_15bit} };
			end
			`IMM_15BIT_ZE: begin
				imm={ {17{1'b0}}, {imm_15bit} };
			end
			`IMM_20BIT_SE: begin
				imm={ {12{imm_20bit[19]}}, {imm_20bit} };
			end
			default: begin
				imm=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			end
		endcase
	end

	always @(select_alu_src2 or reg_rb_data or imm or imm_15bit or sub_op_sv or reg_rt_data) begin
		case(select_alu_src2)
			3'b000: begin
				alu_src2 = reg_rb_data;
			end
			3'b001: begin
				alu_src2 = imm;
			end
			3'b010: begin
				alu_src2 = { {15{imm_15bit[14]}},imm_15bit,2'b00}; //*
			end
			3'b011: begin
				alu_src2 = reg_rb_data<<sub_op_sv;
			end
			3'b100: begin
				alu_src2 = reg_rt_data;
			end
			default: begin
				alu_src2 = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			end
		endcase
	end

	always @(select_write_reg or alu_output or alu_src2 or mem_read_data) begin
		case(select_write_reg)
			2'b00: begin
				write_reg_data = alu_output;
			end
			2'b01: begin
				write_reg_data = alu_src2;
			end
			2'b10: begin
				write_reg_data = mem_read_data;
			end
			default: begin
				write_reg_data = 32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			end
		endcase
	end
endmodule

