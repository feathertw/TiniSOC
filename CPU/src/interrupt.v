`define VECTOR_RESET	32'h0000_0000
`define VECTOR_SYSCALL	32'h0000_0004
module interrupt(
	clock,
	reset,
	enable_system,
	do_syscall_it,
	do_it_return,

	do_halt_pc,
	do_flush_REG1,
	do_interrupt,
	interrupt_pc,

	it_opcode,
	it_reg_rt_addr,
	it_reg_ra_addr,
	it_reg_rb_addr,
	it_imm_15bit,
	do_it_store_pc,
	do_it_load_pc,
	do_it_state
);
	input  clock;
	input  reset;
	input  enable_system;
	input  do_syscall_it;
	input  do_it_return;

	output do_halt_pc;
	output do_flush_REG1;
	output do_interrupt;
	output [31:0] interrupt_pc;
	reg    do_halt_pc;
	reg    do_interrupt;
	reg    [31:0] interrupt_pc;

	output [ 5:0] it_opcode;
	output [ 4:0] it_reg_rt_addr;
	output [ 4:0] it_reg_ra_addr;
	output [ 4:0] it_reg_rb_addr;
	output [14:0] it_imm_15bit;
	output do_it_store_pc;
	output do_it_load_pc;
	output do_it_state;

	reg    [ 5:0] it_opcode;
	reg    [ 4:0] it_reg_rt_addr;
	reg    [ 4:0] it_reg_ra_addr;
	reg    [ 4:0] it_reg_rb_addr;
	reg    [14:0] it_imm_15bit;
	reg    do_it_store_pc;
	reg    do_it_load_pc;

	reg [4:0] state;
	reg [4:0] next_state;
	parameter STATE_IDLE	  =5'd0;
	parameter STATE_STORE_PC  =5'd1;
	parameter STATE_STORE_LP  =5'd2;
	parameter STATE_STORE_GP  =5'd3;
	parameter STATE_STORE_FP  =5'd4;
	parameter STATE_STORE_R3  =5'd5;
	parameter STATE_STORE_R2  =5'd6;
	parameter STATE_STORE_R1  =5'd7;
	parameter STATE_STORE_R0  =5'd8;
	parameter STATE_STORE_FSP =5'd9;
	parameter STATE_STORE_W1  =5'd10;
	parameter STATE_STORE_W2  =5'd11;
	parameter STATE_STORE_W3  =5'd12;
	parameter STATE_LOAD_R0	  =5'd13;
	parameter STATE_LOAD_R1	  =5'd14;
	parameter STATE_LOAD_R2	  =5'd15;
	parameter STATE_LOAD_R3	  =5'd16;
	parameter STATE_LOAD_FP	  =5'd17;
	parameter STATE_LOAD_GP	  =5'd18;
	parameter STATE_LOAD_LP	  =5'd19;
	parameter STATE_LOAD_PC	  =5'd20;
	parameter STATE_LOAD_FSP  =5'd21;
	parameter STATE_LOAD_W1	  =5'd22;
	parameter STATE_LOAD_W2	  =5'd23;
	parameter STATE_LOAD_W3	  =5'd24;

	wire do_flush_REG1=do_halt_pc||do_interrupt;
	wire do_it_state=(state!=STATE_IDLE
		&&state!=STATE_STORE_W1&&state!=STATE_STORE_W2&&state!=STATE_STORE_W3
		&&state!=STATE_LOAD_W3 &&state!=STATE_LOAD_W2 &&state!=STATE_LOAD_W3);

	always@(negedge clock)begin
		if(reset) state<=STATE_IDLE;
		else if(enable_system) state<=next_state;
	end
	always@(*)begin
		case(state)
			STATE_IDLE:begin
				if(do_syscall_it)     next_state=STATE_STORE_PC;
				else if(do_it_return) next_state=STATE_LOAD_R0;
				else		      next_state=STATE_IDLE;
			end
			STATE_STORE_W3:begin
				next_state=STATE_IDLE;
			end
			STATE_LOAD_W3:begin
				next_state=STATE_IDLE;
			end
			default:begin
				next_state=state+5'd1;
			end
		endcase
	end
	always@(*)begin
		case(state)
			STATE_IDLE:begin
				it_opcode	='bx;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	='bx;
				it_reg_rb_addr	='bx;
				it_imm_15bit	='bx;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_PC:begin
				it_opcode	=`SWI;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FFF;
				do_it_store_pc	=1'b1;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_LP:begin
				it_opcode	=`SWI;
				it_reg_rt_addr	=5'b11110;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FFE;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_GP:begin
				it_opcode	=`SWI;
				it_reg_rt_addr	=5'b11101;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FFD;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_FP:begin
				it_opcode	=`SWI;
				it_reg_rt_addr	=5'b11100;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FFC;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_R3:begin
				it_opcode	=`SWI;
				it_reg_rt_addr	=5'b00011;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FFB;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_R2:begin
				it_opcode	=`SWI;
				it_reg_rt_addr	=5'b00010;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FFA;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_R1:begin
				it_opcode	=`SWI;
				it_reg_rt_addr	=5'b00001;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FF9;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_R0:begin
				it_opcode	=`SWI;
				it_reg_rt_addr	=5'b00000;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FF8;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_FSP:begin
				it_opcode	=`ADDI;
				it_reg_rt_addr	=5'b11111;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7FE0;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_W1:begin
				it_opcode	='bx;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	='bx;
				it_reg_rb_addr	='bx;
				it_imm_15bit	='bx;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_W2:begin
				it_opcode	='bx;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	='bx;
				it_reg_rb_addr	='bx;
				it_imm_15bit	='bx;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_STORE_W3:begin
				it_opcode	='bx;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	='bx;
				it_reg_rb_addr	='bx;
				it_imm_15bit	='bx;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_R0:begin
				it_opcode	=`LWI;
				it_reg_rt_addr	=5'b00000;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h0;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_R1:begin
				it_opcode	=`LWI;
				it_reg_rt_addr	=5'b00001;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h1;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_R2:begin
				it_opcode	=`LWI;
				it_reg_rt_addr	=5'b00010;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h2;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_R3:begin
				it_opcode	=`LWI;
				it_reg_rt_addr	=5'b00011;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h3;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_FP:begin
				it_opcode	=`LWI;
				it_reg_rt_addr	=5'b11100;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h4;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_GP:begin
				it_opcode	=`LWI;
				it_reg_rt_addr	=5'b11101;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h5;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_LP:begin
				it_opcode	=`LWI;
				it_reg_rt_addr	=5'b11110;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h6;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_PC:begin
				it_opcode	=`LWI;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h7;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_FSP:begin
				it_opcode	=`ADDI;
				it_reg_rt_addr	=5'b11111;
				it_reg_ra_addr	=5'b11111;
				it_reg_rb_addr	='bx;
				it_imm_15bit	=15'h100;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_W1:begin
				it_opcode	='bx;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	='bx;
				it_reg_rb_addr	='bx;
				it_imm_15bit	='bx;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			STATE_LOAD_W2:begin
				it_opcode	='bx;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	='bx;
				it_reg_rb_addr	='bx;
				it_imm_15bit	='bx;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b1;
			end
			STATE_LOAD_W3:begin
				it_opcode	='bx;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	='bx;
				it_reg_rb_addr	='bx;
				it_imm_15bit	='bx;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
			default:begin
				it_opcode	='bx;
				it_reg_rt_addr	='bx;
				it_reg_ra_addr	='bx;
				it_reg_rb_addr	='bx;
				it_imm_15bit	='bx;
				do_it_store_pc	=1'b0;
				do_it_load_pc	=1'b0;
			end
		endcase
	end

	always@(posedge clock)begin
		if(reset)begin
			do_halt_pc<=1'b0;
			do_interrupt<=1'b0;
			interrupt_pc<=32'b0;
		end
		else begin
			if(do_syscall_it)begin
				do_halt_pc<=1'b1;
				interrupt_pc<=`VECTOR_SYSCALL;
			end
			if(do_it_return)begin
				do_halt_pc<=1'b1;
			end
			if(state==STATE_STORE_W3)begin
				do_halt_pc<=1'b0;
				do_interrupt<=1'b1;
			end
			else begin
				do_interrupt<=1'b0;
			end
			if(state==STATE_LOAD_W3)begin
				do_halt_pc<=1'b0;
			end
		end
	end
endmodule
