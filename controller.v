`include "def_op.v"

`define OPCODE ir[30:25]
`define SUBOP_BASE ir[4:0]
`define SUBOP_LS ir[7:0]
`define SV ir[9:8]

module controller(
	enable_execute,
	enable_fetch,
	enable_writeback,
	opcode,
	sub_opcode,
	mux4to1_select,
	write_reg_select,
	imm_reg_select,
	clock,
	reset,
	ir,

	IM_enable,
	IM_read,
	IM_write,
	enable_pc,

	DM_enable,
	DM_read,
	DM_write,
	DM_address,
	DM_in,
	DM_out,
);
	
	input clock;
	input reset;
	input [31:0] ir;
	
	output reg enable_execute;
	output reg enable_fetch;
	output reg enable_writeback;
	output [5:0] opcode;
	output [4:0] sub_opcode;
	output reg [1:0] mux4to1_select;
	output reg [1:0] write_reg_select;
	output reg [1:0] imm_reg_select;
	
	output reg enable_pc;

	output reg IM_enable;
	output reg IM_read;
	output reg IM_write;

	output reg DM_enable;
	output reg DM_read;
	output reg DM_write;

	output reg [11:0] DM_address;
	output reg [31:0] DM_in;
	input [31:0] DM_out;

	wire [5:0] opcode = ir[30:25];
	wire [4:0] sub_opcode = ir[4:0];
	reg [1:0] current_state;
	reg [1:0] next_state;
	reg [31:0] present_instruction;

	parameter S0=2'b00;
	parameter S1=2'b01;
	parameter S2=2'b10;
	parameter S3=2'b11;

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
					//end
					`ADD:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
					`SUB:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
					`AND:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
					`OR :begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
					`XOR:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
					//Immediate
					`SRLI:begin
						imm_reg_select=2'b01;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
					`SLLI:begin
						imm_reg_select=2'b01;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
					`ROTRI:begin
						imm_reg_select=2'b01;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
					default:begin
						imm_reg_select=2'b00;
						mux4to1_select=2'b00;
						write_reg_select=2'b00;
					end
				endcase	
			end
			`ADDI:begin
				imm_reg_select=2'b01;
				mux4to1_select=2'b01;
				write_reg_select=2'b00;
			end
			`ORI:begin
				imm_reg_select=2'b01;
				mux4to1_select=2'b10;
				write_reg_select=2'b00;
			end
			`XORI:begin
				imm_reg_select=2'b01;
				mux4to1_select=2'b10;
				write_reg_select=2'b00;
			end
			`MOVI:begin
				imm_reg_select=2'b01;
				mux4to1_select=2'b11;
				write_reg_select=2'b01;
			end
			`LWI:begin
				imm_reg_select=2'b10;
				mux4to1_select=2'bxx;
				write_reg_select=2'b00;
			end
			`SWI:begin
				imm_reg_select=2'b10;
				mux4to1_select=2'bxx;
				write_reg_select=2'b00;
			end
			`TY_LS:begin
				case(`SUBOP_LS)
					`LW:begin
						imm_reg_select=2'b11;
						mux4to1_select=2'bxx;
						write_reg_select=2'b00;
					end
					`SW:begin
						imm_reg_select=2'b11;
						mux4to1_select=2'bxx;
						write_reg_select=2'b00;
					end
					default:begin
						imm_reg_select=2'bxx;
						mux4to1_select=2'bxx;
						write_reg_select=2'bxx;
					end
				endcase
			end
			default:begin
				imm_reg_select=2'b00;
				mux4to1_select=2'b00;
				write_reg_select=2'b00;
			end
		endcase
	end

	always@(current_state) begin
		case(current_state)
			S0: begin
				next_state=S1;
				enable_fetch=1'b0;
				enable_execute=1'b0;
				enable_writeback=1'b0;

				enable_pc=1'b0;
				IM_enable=1'b1;
				IM_read=1'b1;
				IM_write=1'b0;
			end
			S1: begin
				next_state=S2;
				enable_fetch=1'b1;
				enable_execute=1'b0;
				enable_writeback=1'b0;

				enable_pc=1'b1;
				IM_enable=1'b0;
				IM_read=1'b0;
				IM_write=1'b0;
			end
			S2: begin
				next_state=S3;
				enable_fetch=1'b0;
				enable_execute=1'b1;
				enable_writeback=1'b0;

				enable_pc=1'b0;
				IM_enable=1'b0;
				IM_read=1'b0;
				IM_write=1'b0;
			end
			S3: begin
				next_state=S0;
				enable_fetch=1'b0;
				enable_execute=1'b0;//**STRANGE**//
				//enable_execute=1'b1;//**STRANGE**//
				enable_writeback=1'b1;

				enable_pc=1'b0;
				IM_enable=1'b0;
				IM_read=1'b0;
				IM_write=1'b0;
			end
			default: begin
				next_state=S0;
				enable_fetch=1'b0;
				enable_execute=1'b0;
				enable_writeback=1'b0;

				enable_pc=1'b0;
				IM_enable=1'b0;
				IM_read=1'b0;
				IM_write=1'b0;
			end
		endcase
	end
	
	always@(posedge clock or posedge reset) begin
		if(reset) present_instruction<=0;
		else	  present_instruction<=ir;
	end
endmodule

