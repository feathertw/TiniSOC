`include "def_opcode.v"
`include "def_muxs.v"
module pc(
	clock,
	reset,
	enable_pc,
	current_pc,

	opcode,
	sub_op_b,
	alu_zero,

	imm_14bit,
	imm_24bit,

	do_flush_REG1
);
	input clock;
	input reset;
	input enable_pc;
	output [9:0] current_pc;

	input [5:0] opcode;
	input sub_op_b;
	input alu_zero;

	input [13:0] imm_14bit;
	input [23:0] imm_24bit;

	output do_flush_REG1;

	reg [9:0] current_pc;
	reg [9:0] next_pc;
	reg [1:0] select_pc;

	reg do_flush_REG1;

	always@(posedge clock) begin
		if(reset) 	   current_pc<=0;
		else if(enable_pc) current_pc<=next_pc;
	end

	always@(opcode or sub_op_b or alu_zero) begin
		case(opcode)
			`TY_B:begin
				if(      (sub_op_b==`BEQ)&&( alu_zero) ) select_pc=`PC_14BIT;
				else if( (sub_op_b==`BNE)&&(!alu_zero) ) select_pc=`PC_14BIT;
				else					 select_pc=`PC_4;
			end
			`JJ:begin
				select_pc=`PC_24BIT;
			end
			default:begin
				select_pc=`PC_4;
			end
		endcase
	end

	always @(select_pc or current_pc or imm_14bit or imm_24bit) begin
		case(select_pc)
			`PC_4:begin
				next_pc=current_pc+4;
				do_flush_REG1=1'b0;
			end
			`PC_14BIT:begin
				next_pc=current_pc+({imm_14bit[13],imm_14bit[7:0],1'b0});//*
				do_flush_REG1=1'b0;
			end
			`PC_24BIT:begin
				next_pc=(current_pc-4)+({imm_24bit[23],imm_24bit[7:0],1'b0});//*
				do_flush_REG1=1'b1;
			end
			default:begin
				next_pc=10'bxxxx_xxxx_xx;
				do_flush_REG1=1'b0;
			end
		endcase
	end

endmodule
