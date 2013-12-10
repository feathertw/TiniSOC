// tag:20 index:6 offset:4 word:2
`define TAG  20
`define IDX   6
`define OFS   4
`define BLK 512
`define DEP  64
`define WOR  32

`define READ  1'b1
`define WRITE 1'b0

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
endmodule

