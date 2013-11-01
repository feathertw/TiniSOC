`include "def_op.v"

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

	read_reg_addr1,
	read_reg_addr2,
	write_addr,

	imm_5bit,
	imm_14bit,
	imm_15bit,
	imm_20bit,
	imm_24bit,
	pc_select,
	imm_reg_select,
	imm_extend_select,
	write_reg_select,

	IM_read,
	IM_write,
	DM_read,
	DM_write,
	do_reg_write,

	alu_zero,
);
	
	input clock;
	input reset;
	input [31:0] instruction;
	
	output reg enable_fetch;
	output reg enable_execute;
	output reg enable_decode;
	output reg enable_memaccess;
	output reg enable_writeback;

	output [5:0] opcode;
	output [4:0] sub_op_base;
	output [7:0] sub_op_ls;
	output [1:0] sub_op_sv;

	output [4:0] read_reg_addr1;
	output [4:0] read_reg_addr2;
	output [4:0] write_addr;

	output [4:0] imm_5bit;
	output [13:0] imm_14bit;
	output [14:0] imm_15bit;
	output [19:0] imm_20bit;
	output [23:0] imm_24bit;
	output reg [1:0] pc_select;
	output reg [1:0] imm_reg_select;
	output reg [1:0] imm_extend_select;
	output reg [1:0] write_reg_select;

	output IM_read;
	output IM_write;
	output reg DM_read;
	output reg DM_write;
	output reg do_reg_write;

	input alu_zero;

	reg [2:0] current_state;
	reg [2:0] next_state;
	reg [31:0] present_instruction;

	wire [5:0] opcode=instruction[30:25];
	wire [4:0] sub_op_base=instruction[4:0];
	wire [7:0] sub_op_ls=instruction[7:0];
	wire [1:0] sub_op_sv=instruction[9:8];

	wire [4:0] read_reg_addr1=instruction[19:15];
	wire [4:0] read_reg_addr2=instruction[14:10];
	wire [4:0] write_addr=instruction[24:20];

	wire [4:0] imm_5bit=instruction[14:10];
	wire [13:0] imm_14bit=instruction[13:0];
	wire [14:0] imm_15bit=instruction[14:0];
	wire [19:0] imm_20bit=instruction[19:0];
	wire [23:0] imm_24bit=instruction[23:0];

	assign IM_read=1'b1;
	assign IM_write=1'b0;

	parameter S0=3'b000;
	parameter S1=3'b001;
	parameter S2=3'b010;
	parameter S3=3'b011;
	parameter S4=3'b100;

	always@(posedge clock) begin
		if(reset)begin 
			current_state<= S0;
		end
		else begin
			current_state<= next_state;
		end
	end

	always@(*) begin
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

	always@(*) begin
		case(`OPCODE)
			`TY_BASE: begin
				case(`SUBOP_BASE)
					//`NOP:begin
					//	imm_reg_select=2'b00;
					//	imm_extend_select=2'b00;
					//	write_reg_select=2'b00;
					//	DM_read=1'b0;
					//	DM_write=1'b0;
					//end
					`ADD:begin
						imm_reg_select=2'b00;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`SUB:begin
						imm_reg_select=2'b00;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`AND:begin
						imm_reg_select=2'b00;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`OR :begin
						imm_reg_select=2'b00;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`XOR:begin
						imm_reg_select=2'b00;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					//Immediate
					`SRLI:begin
						imm_reg_select=2'b01;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`SLLI:begin
						imm_reg_select=2'b01;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`ROTRI:begin
						imm_reg_select=2'b01;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					default:begin
						imm_reg_select=2'b00;
						imm_extend_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
				endcase	
			end
			`ADDI:begin
				imm_reg_select=2'b01;
				imm_extend_select=2'b01;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`ORI:begin
				imm_reg_select=2'b01;
				imm_extend_select=2'b10;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`XORI:begin
				imm_reg_select=2'b01;
				imm_extend_select=2'b10;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`MOVI:begin
				imm_reg_select=2'b01;
				imm_extend_select=2'b11;
				write_reg_select=2'b01;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`LWI:begin
				imm_reg_select=2'b10;
				imm_extend_select=2'bxx;
				write_reg_select=2'b10;
				DM_read=1'b1;
				DM_write=1'b0;
				do_reg_write=1'b1;
			end
			`SWI:begin
				imm_reg_select=2'b10;
				imm_extend_select=2'bxx;
				write_reg_select=2'bxx;
				DM_read=1'b0;
				DM_write=1'b1;
				do_reg_write=1'b0;
			end
			`TY_LS:begin
				case(`SUBOP_LS)
					`LW:begin
						imm_reg_select=2'b11;
						imm_extend_select=2'bxx;
						write_reg_select=2'b10;
						DM_read=1'b1;
						DM_write=1'b0;
						do_reg_write=1'b1;
					end
					`SW:begin
						imm_reg_select=2'b11;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b1;
						do_reg_write=1'b0;
					end
					default:begin
						imm_reg_select=2'bxx;
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
						imm_reg_select=2'b00;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
					`BNE:begin
						imm_reg_select=2'b00;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
					default:begin
						imm_reg_select=2'bxx;
						imm_extend_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b0;
						do_reg_write=1'b0;
					end
				endcase
			end
			`JJ:begin
				imm_reg_select=2'bxx;
				imm_extend_select=2'bxx;
				write_reg_select=2'bxx;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b0;
			end
			default:begin
				imm_reg_select=2'b00;
				imm_extend_select=2'b00;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				do_reg_write=1'b0;
			end
		endcase
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
	
	always@(posedge clock or posedge reset) begin
		if(reset) present_instruction<=0;
		else	  present_instruction<=instruction;
	end
endmodule

