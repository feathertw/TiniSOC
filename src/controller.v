`include "def_opcode.v"

`define OPCODE instruction[30:25]
`define SUBOP_BASE instruction[4:0]
`define SUBOP_LS instruction[7:0]
`define SUBOP_B instruction[14]
`define SV instruction[9:8]

module controller(
	clock,
	reset,
	instruction,

	enable_fetch,
	enable_execute,
	enable_decode,
	enable_memaccess,
	enable_writeback,

	opcode,
	sub_op_base,
	sub_op_ls,
	sub_op_sv,

	reg_ra_addr,
	reg_rb_addr,
	reg_rt_addr,

	imm_5bit,
	imm_14bit,
	imm_15bit,
	imm_20bit,
	imm_24bit,
	pc_select,
	alu_src2_select,
	imm_extend_select,
	write_reg_select,

	IM_read,
	IM_write,
	DM_read,
	DM_write,
	do_reg_write,

	alu_zero
);
	
	input clock;
	input reset;
	input [31:0] instruction;
	
	output enable_fetch;
	output enable_execute;
	output enable_decode;
	output enable_memaccess;
	output enable_writeback;

	output [5:0] opcode;
	output [4:0] sub_op_base;
	output [7:0] sub_op_ls;
	output [1:0] sub_op_sv;

	output [4:0] reg_ra_addr;
	output [4:0] reg_rb_addr;
	output [4:0] reg_rt_addr;

	output [4:0] imm_5bit;
	output [13:0] imm_14bit;
	output [14:0] imm_15bit;
	output [19:0] imm_20bit;
	output [23:0] imm_24bit;
	output [1:0] pc_select;
	output [2:0] alu_src2_select;
	output [1:0] imm_extend_select;
	output [1:0] write_reg_select;

	output IM_read;
	output IM_write;
	output DM_read;
	output DM_write;
	output do_reg_write;

	input alu_zero;

	reg enable_fetch;
	reg enable_execute;
	reg enable_decode;
	reg enable_memaccess;
	reg enable_writeback;

	reg [1:0] pc_select;
	reg [2:0] alu_src2_select;
	reg [1:0] imm_extend_select;
	reg [1:0] write_reg_select;

	reg IM_read;
	reg IM_write;
	reg DM_read;
	reg DM_write;
	reg do_reg_write;

	reg [2:0] current_state;
	reg [2:0] next_state;
	reg [31:0] present_instruction;

	wire [5:0] opcode=instruction[30:25];
	wire [4:0] sub_op_base=instruction[4:0];
	wire [7:0] sub_op_ls=instruction[7:0];
	wire [1:0] sub_op_sv=instruction[9:8];

	wire [4:0] reg_ra_addr=instruction[19:15];
	wire [4:0] reg_rb_addr=instruction[14:10];
	wire [4:0] reg_rt_addr=instruction[24:20];

	wire [4:0] imm_5bit=instruction[14:10];
	wire [13:0] imm_14bit=instruction[13:0];
	wire [14:0] imm_15bit=instruction[14:0];
	wire [19:0] imm_20bit=instruction[19:0];
	wire [23:0] imm_24bit=instruction[23:0];

	parameter S0=3'b000;
	parameter S1=3'b001;
	parameter S2=3'b010;
	parameter S3=3'b011;
	parameter S4=3'b100;

	always@(posedge clock or posedge reset) begin
		if(reset) present_instruction<=0;
		else	  present_instruction<=instruction;
	end

	always@(posedge clock or posedge reset) begin
		if(reset)begin 
			current_state<= S0;
		end
		else begin
			current_state<= next_state;
		end
	end

	always@(current_state) begin
		case(current_state)
			S0: begin
				next_state=S1;
				enable_fetch=1'b1;
				enable_decode=1'b0;
				enable_execute=1'b0;
				enable_memaccess=1'b0;
				enable_writeback=1'b0;
			end
			S1: begin
				next_state=S2;
				enable_fetch=1'b0;
				enable_decode=1'b1;
				enable_execute=1'b0;
				enable_memaccess=1'b0;
				enable_writeback=1'b0;
			end
			S2: begin
				next_state=S3;
				enable_fetch=1'b0;
				enable_decode=1'b0;
				enable_execute=1'b1;
				enable_memaccess=1'b0;
				enable_writeback=1'b0;
			end
			S3: begin
				next_state=S4;
				enable_fetch=1'b0;
				enable_decode=1'b0;
				enable_execute=1'b0;
				enable_memaccess=1'b1;
				enable_writeback=1'b0;
			end
			S4: begin
				next_state=S0;
				enable_fetch=1'b0;
				enable_decode=1'b0;
				enable_execute=1'b0;
				enable_memaccess=1'b0;
				enable_writeback=1'b1;
			end
			default: begin
				next_state=S0;
				enable_fetch=1'b0;
				enable_decode=1'b0;
				enable_execute=1'b0;
				enable_memaccess=1'b0;
				enable_writeback=1'b0;
			end
		endcase
	end

	always@(reset) begin
		if(reset)begin
			IM_read=1'b0;
			IM_write=1'b0;
		end
		else begin
			IM_read=1'b1;
			IM_write=1'b0;
		end
	end

	always@(`OPCODE or `SUBOP_B or alu_zero) begin
		case(`OPCODE)
			`TY_B:begin
				if(      (`SUBOP_B==`BEQ)&&( alu_zero) ) pc_select=2'b01;
				else if( (`SUBOP_B==`BNE)&&(!alu_zero) ) pc_select=2'b01;
				else					 pc_select=2'b00;
			end
			`JJ:begin
				pc_select=2'b10;
			end
			default:begin
				pc_select=2'b00;
			end
		endcase
	end

	always@(`OPCODE or `SUBOP_BASE or `SUBOP_LS or `SUBOP_B) begin
		case(`OPCODE)
			`TY_BASE: begin
				case(`SUBOP_BASE)
					//`NOP:begin
					//	alu_src2_select=3'b000;
					//	imm_extend_select=2'b00;
					//	write_reg_select=2'b00;
					//	DM_read=1'b0;
					//	DM_write=1'b0;
					//end
					`ADD:begin
						alu_src2_select=3'b000;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`SUB:begin
						alu_src2_select=3'b000;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`AND:begin
						alu_src2_select=3'b000;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`OR :begin
						alu_src2_select=3'b000;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`XOR:begin
						alu_src2_select=3'b000;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					//Immediate
					`SRLI:begin
						alu_src2_select=3'b001;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`SLLI:begin
						alu_src2_select=3'b001;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`ROTRI:begin
						alu_src2_select=3'b001;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					default:begin
						alu_src2_select=3'b000;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
				endcase	
			end
			`ADDI:begin
				alu_src2_select=3'b001;
				imm_extend_select=2'b01;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`ORI:begin
				alu_src2_select=3'b001;
				imm_extend_select=2'b10;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`XORI:begin
				alu_src2_select=3'b001;
				imm_extend_select=2'b10;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`MOVI:begin
				alu_src2_select=3'b001;
				imm_extend_select=2'b11;
				write_reg_select=2'b01;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`LWI:begin
				alu_src2_select=3'b010;
				imm_extend_select=2'bxx;
				write_reg_select=2'b10;
				DM_read=1'b1;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`SWI:begin
				alu_src2_select=3'b010;
				imm_extend_select=2'bxx;
				write_reg_select=2'bxx;
				DM_read=1'b0;
				DM_write=1'b1;
				do_reg_write=1'b0;
			end
			`TY_LS:begin
				case(`SUBOP_LS)
					`LW:begin
						alu_src2_select=3'b011;
						imm_extend_select=2'bxx;
						write_reg_select=2'b10;
						DM_read=1'b1;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`SW:begin
						alu_src2_select=3'b011;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b1;
						do_reg_write=1'b0;
					end
					default:begin
						alu_src2_select=3'b0xx;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
				endcase
			end
			`TY_B:begin
				case(`SUBOP_B)
					`BEQ:begin
						alu_src2_select=3'b100;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
					`BNE:begin
						alu_src2_select=3'b100;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
					default:begin
						alu_src2_select=3'b0xx;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
				endcase
			end
			`JJ:begin
				alu_src2_select=3'b0xx;
				imm_extend_select=2'bxx;
				write_reg_select=2'bxx;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b0;
			end
			default:begin
				alu_src2_select=3'b000;
				imm_extend_select=2'b00;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b0;
			end
		endcase
	end
endmodule

