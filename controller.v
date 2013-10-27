`include "def_op.v"

`define OPCODE ir[30:25]
`define SUBOP_BASE ir[4:0]
`define SUBOP_LS ir[7:0]
`define SV ir[9:8]

module controller(
	enable_execute,
	do_reg_fetch,
	enable_writeback,
	opcode,
	sub_op_base,
	sub_op_ls,
	sub_op_sv,
	mux4to1_select,
	write_reg_select,
	imm_reg_select,
	clock,
	reset,
	ir,

	imm_5bit,
	imm_15bit,
	imm_20bit,
	read_address1,
	read_address2,
	write_address,

	IM_enable,
	IM_read,
	IM_write,
	enable_pc,

	DM_enable,
	DM_read,
	DM_write,

	enable_reg_write,
);
	
	input clock;
	input reset;
	input [31:0] ir;
	
	output reg enable_execute;
	output reg do_reg_fetch;
	output reg enable_writeback;
	output [5:0] opcode;
	output [4:0] sub_op_base;
	output [7:0] sub_op_ls;
	output [1:0] sub_op_sv;
	output reg [1:0] mux4to1_select;
	output reg [1:0] write_reg_select;
	output reg [1:0] imm_reg_select;

	output [4:0] read_address1;
	output [4:0] read_address2;
	output [4:0] write_address;

	output [4:0] imm_5bit;
	output [14:0] imm_15bit;
	output [19:0] imm_20bit;
	
	output reg enable_pc;

	output reg IM_enable;
	output IM_read;
	output IM_write;

	output reg DM_enable;
	output reg DM_read;
	output reg DM_write;

	output reg enable_reg_write;

	reg [2:0] current_state;
	reg [2:0] next_state;
	reg [31:0] present_instruction;

	wire [5:0] opcode=ir[30:25];
	wire [4:0] sub_op_base=ir[4:0];
	wire [7:0] sub_op_ls=ir[7:0];
	wire [1:0] sub_op_sv=ir[9:8];
	wire [4:0] imm_5bit=ir[14:10];
	wire [14:0] imm_15bit=ir[14:0];
	wire [19:0] imm_20bit=ir[19:0];
	wire [4:0] read_address1=ir[19:15];
	wire [4:0] read_address2=ir[14:10];
	wire [4:0] write_address=ir[24:20];

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
			`TY_BASE: begin
				case(`SUBOP_BASE)
					//`NOP:begin
					//	imm_reg_select=2'b00;
					//	mux4to1_select=2'b00;
					//	write_reg_select=2'b00;
					//	DM_read=1'b0;
					//	DM_write=1'b0;
					//end
					`ADD:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					`SUB:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					`AND:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					`OR :begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					`XOR:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					//Immediate
					`SRLI:begin
						imm_reg_select=2'b01;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					`SLLI:begin
						imm_reg_select=2'b01;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					`ROTRI:begin
						imm_reg_select=2'b01;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					default:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b0;
					end
				endcase	
			end
			`ADDI:begin
				imm_reg_select=2'b01;
				mux4to1_select=2'b01;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				enable_reg_write=1'b1;
			end
			`ORI:begin
				imm_reg_select=2'b01;
				mux4to1_select=2'b10;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				enable_reg_write=1'b1;
			end
			`XORI:begin
				imm_reg_select=2'b01;
				mux4to1_select=2'b10;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				enable_reg_write=1'b1;
			end
			`MOVI:begin
				imm_reg_select=2'b01;
				mux4to1_select=2'b11;
				write_reg_select=2'b01;
				DM_read=1'b0;
				DM_write=1'b0;
				enable_reg_write=1'b1;
			end
			`LWI:begin
				imm_reg_select=2'b10;
				mux4to1_select=2'bxx;
				write_reg_select=2'b10;
				DM_read=1'b1;
				DM_write=1'b0;
				enable_reg_write=1'b1;
			end
			`SWI:begin
				imm_reg_select=2'b10;
				mux4to1_select=2'bxx;
				write_reg_select=2'bxx;
				DM_read=1'b0;
				DM_write=1'b1;
				enable_reg_write=1'b0;
			end
			`TY_LS:begin
				case(`SUBOP_LS)
					`LW:begin
						imm_reg_select=2'b11;
						mux4to1_select=2'bxx;
						write_reg_select=2'b10;
						DM_read=1'b1;
						DM_write=1'b0;
						enable_reg_write=1'b1;
					end
					`SW:begin
						imm_reg_select=2'b11;
						mux4to1_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b1;
						enable_reg_write=1'b0;
					end
					default:begin
						imm_reg_select=2'bxx;
						mux4to1_select=2'bxx;
						write_reg_select=2'bxx;
						DM_read=1'b0;
						DM_write=1'b0;
						enable_reg_write=1'b0;
					end
				endcase
			end
			default:begin
				imm_reg_select=2'b00;
				mux4to1_select=2'b00;
				write_reg_select=2'b00;
				DM_read=1'b0;
				DM_write=1'b0;
				enable_reg_write=1'b0;
			end
		endcase
	end

	always@(current_state) begin
		case(current_state)
			S0: begin
				next_state=S1;
				do_reg_fetch=1'b0;
				enable_execute=1'b0;
				enable_writeback=1'b0;

				enable_pc=1'b1;
				IM_enable=1'b1;
				DM_enable=1'b0;
			end
			S1: begin
				next_state=S2;
				do_reg_fetch=1'b1;
				enable_execute=1'b0;
				enable_writeback=1'b0;

				enable_pc=1'b0;
				IM_enable=1'b0;
				DM_enable=1'b0;
			end
			S2: begin
				next_state=S3;
				do_reg_fetch=1'b0;
				enable_execute=1'b1;
				enable_writeback=1'b0;

				enable_pc=1'b0;
				IM_enable=1'b0;
				DM_enable=1'b0;
			end
			S3: begin
				next_state=S4;
				do_reg_fetch=1'b0;
				enable_execute=1'b0;
				enable_writeback=1'b0;

				enable_pc=1'b0;
				IM_enable=1'b0;
				DM_enable=1'b1;
			end
			S4: begin
				next_state=S0;
				do_reg_fetch=1'b0;
				enable_execute=1'b0;
				enable_writeback=1'b1;

				enable_pc=1'b0;
				IM_enable=1'b0;
				DM_enable=1'b0;
			end
			default: begin
				next_state=S0;
				do_reg_fetch=1'b0;
				enable_execute=1'b0;
				enable_writeback=1'b0;

				enable_pc=1'b0;
				IM_enable=1'b0;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset) begin
		if(reset) present_instruction<=0;
		else	  present_instruction<=ir;
	end
endmodule

