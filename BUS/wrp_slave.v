module wrp_slaver(
	HCLK,
	HRESETn,

	MRead,
	MWrite,
	MEnable,
	MAddress,
	MWriteData,
	MReadData,
	MReady,

	HSEL,
	HTRANS,
	HWRITE,
	HSIZE,
	HBURST,
	HADDR,
	HWDATA,
	HMASTER,
	HMASTERLOCK,
	HREADY,
	HRESP,
	HSPLIT,
	HRDATA
);
	input HCLK;
	input HRESETn;

	output MRead;
	output MWrite;
	output MEnable;
	output [31:0] MAddress;
	output [31:0] MWriteData;
	input  [31:0] MReadData;
	input  MReady;
	
	input HSEL;
	input [ 1:0] HTRANS;
	input        HWRITE;
	input [ 2:0] HSIZE;
	input [ 2:0] HBURST;
	input [31:0] HADDR;
	input [31:0] HWDATA;
	input [2:0] HMASTER;
	input HMASTERLOCK;

	output        HREADY;
	output [ 1:0] HRESP;
	output [15:0] HSPLIT;
	output [31:0] HRDATA;

	wire MRead=!HWRITE;
	wire MWrite=HWRITE;
	wire MEnable=HSEL;
	wire [31:0] MAddress=HADDR;
	wire [31:0] MWriteData=HWDATA;
	wire        HREADY=MReady;
	wire [ 1:0] HRESP=`RSP_OKAY;
	wire [31:0] HRDATA=MReadData;
endmodule
