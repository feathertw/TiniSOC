//`include "ram_pc.v"
module bcache(
	clock,
	reset,
	enable_bcache,
	current_pc,
	target_pc,
	do_branch,
	opcode,
	do_flush_REG1,
	xREG1_do_hit_bcache,
	bcache_opc,
	bcache_pc,
	do_hit_bcache,
	do_bcache
);
	input  clock;
	input  reset;
	input  enable_bcache;
	input  [31:0] current_pc;
	input  [31:0] target_pc;
	input  do_branch;
	input  [ 5:0] opcode;
	input  do_flush_REG1;
	input  xREG1_do_hit_bcache;
	output [31:0] bcache_opc;
	output [31:0] bcache_pc;
	output do_hit_bcache;
	output do_bcache;

	wire [31:0] hit_addr;
	wire [31:0] hit_target;
	wire hit_branch;
	wire hit;

	wire [31:0] bcache_opc=hit_addr[31:0];
	wire [31:0] bcache_pc =hit_target[31:0];
	wire do_hit_bcache=hit;
	wire do_bcache=(hit)? hit_branch:1'b0;

	reg do_write;

	ram_pc RAM_PC(
		.clock(clock),
		.reset(reset),
		.enable_ram(enable_bcache),
		.do_write(do_write),
		.current_pc(current_pc),
		.target_pc(target_pc),
		.do_branch(do_branch),
		.sub_op_j(),
		.do_flush_REG1(do_flush_REG1),
		.hit_addr(hit_addr),
		.hit_target(hit_target),
		.hit_branch(hit_branch),
		.hit_link(),
		.hit(hit)
	);
	always@(posedge clock)begin
		if(reset)begin
			do_write<=1'b0;
		end
		else if( (opcode==`TY_B||opcode==`TY_BZ)&&(!xREG1_do_hit_bcache) )begin
			do_write<=1'b1;
		end
		else begin
			do_write<=1'b0;
		end
	end
endmodule
