`include "ram_pc.v"
module jcache(
	clock,
	reset,
	enable_jcache,
	current_pc,
	next_pc,
	opcode,
	sub_op_j,
	xREG1_do_jcache,
	jcache_pc,
	do_jcache_link,
	do_jcache
);
	input  clock;
	input  reset;
	input  enable_jcache;
	input  [31:0] current_pc;
	input  [31:0] next_pc;
	input  [ 5:0] opcode;
	input  sub_op_j;
	input xREG1_do_jcache;

	output [31:0] jcache_pc;
	output do_jcache_link;
	output do_jcache;

	wire [31:0] hit_target;
	wire hit_link;
	wire hit;

	wire [31:0] jcache_pc=hit_target;
	wire do_jcache_link=(hit)? hit_link:1'b0;
	wire do_jcache=hit;

	reg  do_write;

	ram_pc RAM_PC(
		.clock(clock),
		.reset(reset),
		.enable_ram(enable_jcache),
		.do_write(do_write),
		.current_pc(current_pc),
		.next_pc(next_pc),
		.sub_op_j(sub_op_j),
		.hit_target(hit_target),
		.hit_link(hit_link),
		.hit(hit)
	);

	always@(posedge clock)begin
		if(reset)begin
			do_write<=1'b0;
		end
		else if( (opcode==`TY_J)&&(!xREG1_do_jcache) )begin
			do_write<=1'b1;
		end
		else begin
			do_write<=1'b0;
		end
	end

endmodule
