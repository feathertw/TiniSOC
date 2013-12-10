module cache_control(
	clock,
	reset,

	PStrobe,
	PRw,
	PReady,

	SysStrobe,
	SysRW,

	tag_match,
	valid,
	write,

	select_CacheData,
	select_PData
);
	input clock;
	input reset;

	input  PStrobe;
	input  PRw;
	output PReady;

	output SysStrobe;
	output SysRW;

	input  tag_match;
	input  valid;
	output write;
	
	output select_CacheData;
	output select_PData;

endmodule
