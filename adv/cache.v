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

`define SDATA_OPEN  1'b1
`define SDATA_CLOSE 1'b0
`define PDATA_OPEN  1'b1
`define PDATA_CLOSE 1'b0

`include "cache_ctr.v"
`include "ram_tag.v"
`include "ram_valid.v"
`include "ram_data.v"
`include "mux2to1.v"

module cache(
	clock,
	reset,

	PStrobe,
	PRw,
	PAddress,
	PReady,
	PData,

	SysStrobe,
	SysRW,
	SysAddress,
	SysData
);
	input clock;
	input reset;

	input  PStrobe;
	input  PRw;
	input  [31:0] PAddress;
	output PReady;
	inout  [31:0] PData;

	output SysStrobe;
	output SysRW;
	output [31:0] SysAddress;
	inout  [31:0] SysData;

	wire open_SysData;
	wire open_PData;

	wire [31:0] PDataOut;
	wire PData  =(open_PData)? PDataOut:32'bz;
	wire SysData=(open_SysData)? PData:32'bz;

	wire [31:0] SysAddress=PAddress;

	wire tag_match;
	wire valid;
	wire write;
	wire select_CData;
	wire select_PData;

	wire [`IDX-1:0] index;
	wire [`TAG-1:0] tag_in;
	wire valid_in=1'b1;
	wire [31:0] cache_data_in;
	wire [31:0] cache_data_out;

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
		.data_in(cache_data_in),
		.data_out(cache_data_out),
		.write(write)
	);

	mux2to1 CDATA_MUX(
		.s(select_CData),
		.in0(PData),
		.in1(SysData),
		.out(cache_data_in)
	);

	mux2to1 PDATA_MUX(
		.s(select_PData),
		.in0(cache_data_out),
		.in1(SysData),
		.out(PDataOut)
	);
endmodule

