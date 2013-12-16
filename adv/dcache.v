// tag:20 index: 6 offset:4 word:2 block:512 deep:  32
// tag:20 index:10 offset:0 word:2 block: 32 deep:1024
`define TAG    20
`define IDX    10
`define OFS     0
`define BLK    32
`define DEP  1024
`define WOR    32
`define WAITSTATE 2'd2

`define RW_READ  1'b1
`define RW_WRITE 1'b0
`define RW_UNK   1'bx

`define CDATA_PRO 1'b0
`define CDATA_SYS 1'b1
`define CDATA_UNK 1'bx
`define PDATA_CAC 1'b0
`define PDATA_SYS 1'b1
`define PDATA_UNK 1'bx

`include "cache_ctr.v"
`include "ram_tag.v"
`include "ram_valid.v"
`include "ram_data.v"

module dcache(
	clock,
	reset,

	PStrobe,
	PRw,
	PAddress,
	PReady,
	PData_in,
	PData_out,

	SysStrobe,
	SysRW,
	SysAddress,
	SysData_in,
	SysData_out
);
	input clock;
	input reset;

	input  PStrobe;
	input  PRw;
	input  [31:0] PAddress;
	output PReady;
	output [31:0] PData_in;
	input  [31:0] PData_out;

	output SysStrobe;
	output SysRW;
	output [31:0] SysAddress;
	output [31:0] SysData_in;
	input  [31:0] SysData_out;

	wire tag_match;
	wire valid;
	wire write;
	wire select_CData;
	wire select_PData;

	wire [`IDX-1:0] index=PAddress[11:2];
	wire [`TAG-1:0] tag_in=PAddress[31:12];
	wire valid_in=1'b1;

	wire [31:0] CData_out;
	wire [31:0] CData_in=(select_CData)? SysData_out:PData_out;
	wire [31:0] PData_in=(select_PData)? SysData_out:CData_out;
	wire [31:0] SysData_in=PData_out;
	wire [31:0] SysAddress=PAddress;


	cache_ctr CACHE_CTR(
		.clock(clock),
		.reset(reset),
		.PStrobe(PStrobe),
		.PRw(PRw),
		.PReady(PReady),
		.SysStrobe(SysStrobe),
		.SysRW(SysRW),
		.tag_match(tag_match),
		.valid(valid),
		.write(write),
		.select_CData(select_CData),
		.select_PData(select_PData)
	);

	ram_tag RAM_TAG(
		.clock(clock),
		.index(index),
		.tag_in(tag_in),
		.tag_match(tag_match),
		.write(write)
	);

	ram_valid RAM_VALID(
		.clock(clock),
		.reset(reset),
		.index(index),
		.valid_in(valid_in),
		.valid_out(valid),
		.write(write)
	);

	ram_data RAM_DATA(
		.clock(clock),
		.index(index),
		.offset(),
		.data_in(CData_in),
		.data_out(CData_out),
		.write(write)
	);

endmodule

