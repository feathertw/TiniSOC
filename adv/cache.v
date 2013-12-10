// tag:20 index:6 offset:4 word:2
`define TAG  20
`define IDX   6
`define OFS   4
`define BLK 512
`define DEP  64
`define WOR  32

`define RW_READ  1'b1
`define RW_WRITE 1'b0
`define RW_UNK   1'bx
`define PDATA_CAC 1'b0
`define PDATA_SYS 1'b1
`define PDATA_UNK 1'bx
`define CDATA_PRO 1'b0
`define CDATA_SYS 1'b1
`define CDATA_UNK 1'bx
`define SDATA_OPEN  1'b1
`define SDATA_CLOSE 1'b0
`define PDATA_OPEN  1'b1
`define PDATA_CLOSE 1'b0

`include "ram_tag.v"
`include "ram_valid.v"
`include "ram_data.v"

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
	input  [31:0] SysData;

endmodule

