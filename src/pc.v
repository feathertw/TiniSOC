`include "def_opcode.v"
`include "def_muxs.v"
module pc(
	clock,
	reset,
	enable_pc,
	current_pc,

	opcode,
	sub_op_b,
	sub_op_j,
	reg_rt_ra_equal,

	imm_14bit,
	imm_24bit,
	reg_rb_data,

	do_jump_link,
	do_flush_REG1,
	do_hazard
);
	input clock;
	input reset;
	input enable_pc;
	output [9:0] current_pc;

	input [5:0] opcode;
	input sub_op_b;
	input sub_op_j;
	input reg_rt_ra_equal;

	input [13:0] imm_14bit;
	input [23:0] imm_24bit;
	input [31:0] reg_rb_data;

	output do_jump_link;
	output do_flush_REG1;
	input  do_hazard;

	reg [9:0] current_pc;
	reg [9:0] next_pc;
	reg [1:0] select_pc;

	reg do_jump_link;
	reg do_jump_reg;
	reg do_flush_REG1;

	always@(negedge clock) begin
		if(reset) 	   current_pc<=0;
		else if(do_hazard) current_pc<=current_pc;
		else if(enable_pc) current_pc<=next_pc;
	end

	always@(opcode or sub_op_b or reg_rt_ra_equal) begin
		case(opcode)
			`TY_B:begin
				if(      (sub_op_b==`BEQ)&&( reg_rt_ra_equal) ) select_pc=`PC_14BIT;
				else if( (sub_op_b==`BNE)&&(!reg_rt_ra_equal) ) select_pc=`PC_14BIT;
				else					 	select_pc=`PC_4;
				do_jump_link=1'b0;
			end
			`TY_J:begin
				select_pc=`PC_24BIT;
				if(     sub_op_j==`JJ ) do_jump_link=1'b0;
				else if(sub_op_j==`JAL) do_jump_link=1'b1;
				else			do_jump_link=1'b0;
			end
			`JR:begin
				select_pc=`PC_REGISTER;
				do_jump_link=1'b0;
			end
			default:begin
				select_pc=`PC_4;
				do_jump_link=1'b0;
			end
		endcase
	end

	always @(select_pc or current_pc or imm_14bit or imm_24bit or reg_rb_data) begin
		case(select_pc)
			`PC_4:begin
				next_pc=current_pc+4;
				do_flush_REG1=1'b0;
				do_jump_reg  =1'b0;
			end
			`PC_14BIT:begin
				next_pc=(current_pc-4)+({imm_14bit[13],imm_14bit[7:0],1'b0});//*
				do_flush_REG1=1'b1;
				do_jump_reg  =1'b0;
			end
			`PC_24BIT:begin
				next_pc=(current_pc-4)+({imm_24bit[23],imm_24bit[7:0],1'b0});//*
				do_flush_REG1=1'b1;
				do_jump_reg  =1'b0;
			end
			`PC_REGISTER:begin
				next_pc=reg_rb_data[9:0];
				do_flush_REG1=1'b1;
				do_jump_reg  =1'b1;
			end
			default:begin
				next_pc=10'bxxxx_xxxx_xx;
				do_flush_REG1=1'b0;
				do_jump_reg  =1'b0;
			end
		endcase
	end

endmodule
