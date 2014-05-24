`include "systick.v"
`define SISTICK_RANGE 4'h1
module sysmem(
	clock,
	reset,
	do_mem_read,
	do_mem_write,
	mem_address,
	din,
	dout,
	do_enable,
	do_systick_it
);
	input  clock;
	input  reset;
	input  do_mem_read;
	input  do_mem_write;
	input  [31:0] mem_address;
	input  [31:0] din;
	output [31:0] dout;
	input  do_enable;
	output do_systick_it;

	wire do_systick = (mem_address[23:20]==`SISTICK_RANGE)? 1:0;

	systick SYSTICK(
		.clock(clock),
		.reset(reset),
		.do_mem_read(do_mem_read),
		.do_mem_write(do_mem_write),
		.mem_address(mem_address),
		.din(din),
		.dout(dout),
		.do_enable(do_systick),
		.do_systick_it(do_systick_it)
	);

endmodule
