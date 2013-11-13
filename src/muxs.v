module muxs(

	current_pc,
	sub_op_sv,
	reg_rb_data,
	reg_rt_data,
	mem_read_data,
	alu_output,
	imm_5bit,
	imm_14bit,
	imm_15bit,
	imm_20bit,
	imm_24bit,

	select_pc,
	select_alu_src2,
	select_imm_extend,
	select_write_reg,

	next_pc,
	alu_src2,
	write_reg_data
);

	parameter DataSize = 32;

	input [9:0] current_pc;
	input [1:0] sub_op_sv;
	input [DataSize-1:0] reg_rb_data;
	input [DataSize-1:0] reg_rt_data;
	input [DataSize-1:0] mem_read_data;
	input [DataSize-1:0] alu_output;
	input [4:0] imm_5bit;
	input [13:0] imm_14bit;
	input [14:0] imm_15bit;
	input [19:0] imm_20bit;
	input [23:0] imm_24bit;

	input [1:0] select_pc;
	input [2:0] select_alu_src2;
	input [1:0] select_imm_extend;
	input [1:0] select_write_reg;

	output [9:0] next_pc;
	output [DataSize-1:0] alu_src2;
	output [DataSize-1:0] write_reg_data;
	
	reg [9:0] next_pc;
	reg [DataSize-1:0] alu_src2;
	reg [DataSize-1:0] write_reg_data;

	reg [DataSize-1:0] imm;

	always @(select_pc or current_pc or imm_14bit or imm_24bit) begin
		case(select_pc)
			2'b00:begin
				next_pc=current_pc+4;
			end
			2'b01:begin
				next_pc=current_pc+({imm_14bit[13],imm_14bit[7:0],1'b0});//*
			end
			2'b10:begin
				next_pc=current_pc+({imm_24bit[23],imm_24bit[7:0],1'b0});//*
			end
			default:begin
				next_pc=10'bxxxx_xxxx_xx;
			end
		endcase
	end

	always @(select_imm_extend or imm_5bit or imm_15bit or imm_20bit) begin
		case(select_imm_extend)
			2'b00: begin //5bit ZE
				imm={ {27{1'b0}}, imm_5bit };
			end
			2'b01: begin //15bit SE
				imm={ {17{imm_15bit[14]}}, {imm_15bit} };
			end
			2'b10: begin //15bit ZE
				imm={ {17{1'b0}}, {imm_15bit} };
			end
			2'b11: begin //20bit SE
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

