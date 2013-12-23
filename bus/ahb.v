`include "def_ahb.v"

`include "arbiter.v"
`include "decoder.v"
`include "mux_m2s.v"
`include "mux_s2m.v"
module ahb(
	HCLK,
	HRESETn,

	HBUSREQ_M1,
	HBUSREQ_M2,
	HLOCK_M1,
	HLOCK_M2,
	HGRANT_M1,
	HGRANT_M2,
	HTRANS,
	HWRITE,
	HSIZE,
	HADDR,
	HWDATA,

	HSEL_S1,
	HSEL_S2,

	HTRANS_M1,
	HTRANS_M2,
	HWRITE_M1,
	HWRITE_M2,
	HSIZE_M1,
	HSIZE_M2,
	HADDR_M1,
	HADDR_M2,
	HWDATA_M1,
	HWDATA_M2,

	HREADY_S1,
	HREADY_S2,
	HRESP_S1,
	HRESP_S2,
	HRDATA_S1,
	HRDATA_S2,
	HREADY,
	HRESP,
	HRDATA
);
	input HCLK;
	input HRESETn;

	input  HBUSREQ_M1;
	input  HBUSREQ_M2;
	input  HLOCK_M1;
	input  HLOCK_M2;
	output HGRANT_M1;
	output HGRANT_M2;

	output HSEL_S1;
	output HSEL_S2;

	input  [ 1:0] HTRANS_M1;
	input  [ 1:0] HTRANS_M2;
	input         HWRITE_M1;
	input         HWRITE_M2;
	input  [ 2:0] HSIZE_M1;
	input  [ 2:0] HSIZE_M2;
	input  [31:0] HADDR_M1;
	input  [31:0] HADDR_M2;
	input  [31:0] HWDATA_M1;
	input  [31:0] HWDATA_M2;
	output [ 1:0] HTRANS;
	output        HWRITE;
	output [ 2:0] HSIZE;
	output [31:0] HADDR;
	output [31:0] HWDATA;

	input         HREADY_S1;
	input         HREADY_S2;
	input  [ 1:0] HRESP_S1;
	input  [ 1:0] HRESP_S2;
	input  [31:0] HRDATA_S1;
	input  [31:0] HRDATA_S2;
	output        HREADY;
	output [ 1:0] HRESP;
	output [31:0] HRDATA;

	wire [2:0] HMASTER;

	arbiter ARBITER(
		.HCLK(HCLK),
		.HRESETn(HRESETn),
		.HTRANS(HTRANS),
		.HREADY(HREADY),
		.HRESP(HRESP),
	
		.HBUSREQ_M0(),
		.HBUSREQ_M1(HBUSREQ_M1),
		.HBUSREQ_M2(HBUSREQ_M2),
		.HLOCK_M0(),
		.HLOCK_M1(HLOCK_M1),
		.HLOCK_M2(HLOCK_M2),
	
		.HGRANT_M0(),
		.HGRANT_M1(HGRANT_M1),
		.HGRANT_M2(HGRANT_M2),
		.HMASTER(HMASTER)
	);

	decoder DECODER(
		.HRESETn(HRESETn),
		.HADDR(HADDR),
		.HSEL_Default(),
		.HSEL_S1(HSEL_S1),
		.HSEL_S2(HSEL_S2)
	);

	mux_m2s MUX_M2S(
		.HCLK(HCLK),
		.HRESETn(HRESETn),
		.HMASTER(HMASTER),
		.HREADY(HREADY),
		
		.HTRANS_M1(HTRANS_M1),
		.HTRANS_M2(HTRANS_M2),
		.HWRITE_M1(HWRITE_M1),
		.HWRITE_M2(HWRITE_M2),
		.HSIZE_M1(HSIZE_M1),
		.HSIZE_M2(HSIZE_M2),
		.HADDR_M1(HADDR_M1),
		.HADDR_M2(HADDR_M2),
		.HWDATA_M1(HWDATA_M1),
		.HWDATA_M2(HWDATA_M2),
	
		.HTRANS(HTRANS),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HADDR(HADDR),
		.HWDATA(HWDATA)
	);

	mux_s2m MUX_S2M(
		.HCLK(HCLK),
		.HRESETn(HRESETn),
	
		.HSEL_Default(),
		.HSEL_S1(HSEL_S1),
		.HSEL_S2(HSEL_S2),
		.HREADY_S1(HREADY_S1),
		.HREADY_S2(HREADY_S2),
		.HRESP_S1(HRESP_S1),
		.HRESP_S2(HRESP_S2),
		.HRDATA_S1(HRDATA_S1),
		.HRDATA_S2(HRDATA_S2),
	
		.HREADY(HREADY),
		.HRESP(HRESP),
		.HRDATA(HRDATA)
	);
endmodule
