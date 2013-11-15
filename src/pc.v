`include "def_opcode.v"
`include "def_muxs.v"
module pc(
	clock,
	reset,
	enable_pc,
	next_pc,
	current_pc,

	opcode,
	sub_op_b,
	alu_zero,
	select_pc
);
	input clock;
	input reset;
	input enable_pc;
	input [9:0] next_pc;
	output [9:0] current_pc;

	input [5:0] opcode;
	input sub_op_b;
	input alu_zero;
	output [1:0] select_pc;

	reg [9:0] current_pc;
	reg [1:0] select_pc;

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
endmodule
