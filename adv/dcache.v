// tag:20 index: 6 offset:4 word:2 block:512 deep:  32
// tag:20 index:10 offset:0 word:2 block: 32 deep:1024
`define TAG    20
`define IDX     6
`define OFS     4
`define BLK   512
`define DEP    32
`define WOR    32
`define WAITSTATE 2'd2

`define RW_READ  1'b1
`define RW_WRITE 1'b0
`define RW_UNK   1'bx

`define CDATA_PRO 1'b0
`define CDATA_SYS 1'b1
`define CDATA_UNK 1'bx
`define CWOFS_PRO 1'b0
`define CWOFS_SYS 1'b1
`define CWOFS_UNK 1'bx

`include "cache_ctr.v"
`include "ram_tag.v"
`include "ram_valid.v"
`include "ram_data.v"
`include "counter.v"

module dcache(
	clock,
	reset,
	CReady,

	PStrobe,
	PRw,
	PAddress,
	PData_in,
	PData_out,

	SysStrobe,
	SysRW,
	SysAddress,
	SysData_in,
	SysData_out,
	SysAck,
	SysReady
);
	input clock;
	input reset;
	output CReady;

	input  PStrobe;
	input  PRw;
	input  [31:0] PAddress;
	output [31:0] PData_in;
	input  [31:0] PData_out;

	output SysStrobe;
	output SysRW;
	output [31:0] SysAddress;
	output [31:0] SysData_in;
	input  [31:0] SysData_out;
	input  SysAck;
	input  SysReady;

	wire tag_match;
	wire valid;
	wire do_write;
	wire select_CData;
	wire do_buffer_flush;

	wire [`IDX-1:0] index=PAddress[11:6];
	wire [`TAG-1:0] tag_in=PAddress[31:12];
	wire [`OFS-1:0] offset_pro=PAddress[5:2];
	wire valid_in=1'b1;

	wire [`OFS-1:0] offset_sys;
	wire [31:0] CData_out;
	wire [`OFS-1:0] offset_write=(select_CWOffset==`CWOFS_PRO)? offset_pro:offset_sys;
	wire [31:0] CData_in=(select_CData==`CDATA_SYS)? SysData_out:PData_out;
	wire [31:0] PData_in=CData_out;
	wire [31:0] SysData_in=PData_out;
	wire [31:0] SysAddress=PAddress;


	cache_ctr CACHE_CTR(
		.clock(clock),
		.reset(reset),
		.PStrobe(PStrobe),
		.PRw(PRw),
		.CReady(CReady),
		.SysStrobe(SysStrobe),
		.SysRW(SysRW),
		.SysReady(SysReady),
		.tag_match(tag_match),
		.valid(valid),
		.do_write(do_write),
		.select_CData(select_CData),
		.select_CWOffset(select_CWOffset),
		.do_buffer_flush(do_buffer_flush)
	);

	ram_tag RAM_TAG(
		.clock(clock),
		.index(index),
		.tag_in(tag_in),
		.tag_match(tag_match),
		.do_write(do_write)
	);

	ram_valid RAM_VALID(
		.clock(clock),
		.reset(reset),
		.index(index),
		.valid_in(valid_in),
		.valid_out(valid),
		.do_write(do_write)
	);

	ram_data RAM_DATA(
		.clock(clock),
		.index(index),
		.offset_write(offset_write),
		.offset_read(offset_pro),
		.data_in(CData_in),
		.data_out(CData_out),
		.do_write(do_write)
	);

	counter COUNTER(
		.clock(clock),
		.flush(do_buffer_flush),
		.signal(SysAck),
		.value(offset_sys)
	);
endmodule

