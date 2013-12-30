`include "cpu.v"
`include "ahb.v"
`include "mem.v"
`include "wrp_master.v"
`include "wrp_slave.v"
module soc(
	clock,
	reset,
	do_system
);
	input clock;
	input reset;
	input do_system;

	wire IM_read;
	wire IM_write;
	wire IM_enable;
	wire [31:0] IM_address;
	wire [31:0] IM_out;
	wire IM_ready;
	wire DM_read;
	wire DM_write;
	wire DM_enable;
	wire [31:0] DM_address;
	wire [31:0] DM_in;
	wire [31:0] DM_out;
	wire DM_ready;

	wire HBUSREQ_M1;
	wire HBUSREQ_M2;
	wire HLOCK_M1;
	wire HLOCK_M2;
	wire HGRANT_M1;
	wire HGRANT_M2;

	wire HSEL_S1;
	wire HSEL_S2;

	wire [ 1:0] HTRANS_M1;
	wire [ 1:0] HTRANS_M2;
	wire        HWRITE_M1;
	wire        HWRITE_M2;
	wire [ 2:0] HSIZE_M1;
	wire [ 2:0] HSIZE_M2;
	wire [ 2:0] HBURST_M1;
	wire [ 2:0] HBURST_M2;
	wire [ 3:0] HPROT_M1;
	wire [ 3:0] HPROT_M2;
	wire [31:0] HADDR_M1;
	wire [31:0] HADDR_M2;
	wire [31:0] HWDATA_M1;
	wire [31:0] HWDATA_M2;
	wire [ 1:0] HTRANS;
	wire        HWRITE;
	wire [ 2:0] HSIZE;
	wire [ 2:0] HBURST;
	wire [ 3:0] HPROT;
	wire [31:0] HADDR;
	wire [31:0] HWDATA;

	wire        HREADY_S1;
	wire        HREADY_S2;
	wire [ 1:0] HRESP_S1;
	wire [ 1:0] HRESP_S2;
	wire [15:0] HSPLIT_S1;
	wire [15:0] HSPLIT_S2;
	wire [31:0] HRDATA_S1;
	wire [31:0] HRDATA_S2;
	wire        HREADY;
	wire [ 1:0] HRESP;
	wire [15:0] HSPLIT;
	wire [31:0] HRDATA;

	wire DMRead;
	wire DMWrite;
	wire DMEnable;
	wire [31:0] DMAddress;
	wire [31:0] DMWriteData;
	wire [31:0] DMReadData;
	wire DMReady;

	cpu CPU(
		.clock(clock),
		.reset(reset),
		.alu_overflow(),
		.IM_read(IM_read),
		.IM_write(IM_write),
		.IM_enable(IM_enable),
		.IM_address(IM_address),
		.IM_out(IM_out),
		.IM_ready(IM_ready),
		.DM_read(DM_read),
		.DM_write(DM_write),
		.DM_enable(DM_enable),
		.DM_address(DM_address),
		.DM_in(DM_in),
		.DM_out(DM_out),
		.DM_ready(DM_ready),
		.do_system(do_system)
	);
	ahb AHB(
		.HCLK(clock),
		.HRESETn(!reset),
		.HBUSREQ_M1(HBUSREQ_M1),
		.HBUSREQ_M2(HBUSREQ_M2),
		.HLOCK_M1(HLOCK_M1),
		.HLOCK_M2(HLOCK_M2),
		.HGRANT_M1(HGRANT_M1),
		.HGRANT_M2(HGRANT_M2),
		.HSEL_S1(HSEL_S1),
		.HSEL_S2(HSEL_S2),
		.HTRANS_M1(HTRANS_M1),
		.HTRANS_M2(HTRANS_M2),
		.HWRITE_M1(HWRITE_M1),
		.HWRITE_M2(HWRITE_M2),
		.HSIZE_M1(HSIZE_M1),
		.HSIZE_M2(HSIZE_M2),
		.HBURST_M1(HBURST_M1),
		.HBURST_M2(HBURST_M2),
		.HPROT_M1(HPROT_M1),
		.HPROT_M2(HPROT_M2),
		.HADDR_M1(HADDR_M1),
		.HADDR_M2(HADDR_M2),
		.HWDATA_M1(HWDATA_M1),
		.HWDATA_M2(HWDATA_M2),
		.HTRANS(HTRANS),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HPROT(HPROT),
		.HADDR(HADDR),
		.HWDATA(HWDATA),
		.HREADY_S1(HREADY_S1),
		.HREADY_S2(HREADY_S2),
		.HRESP_S1(HRESP_S1),
		.HRESP_S2(HRESP_S2),
		.HSPLIT_S1(HSPLIT_S1),
		.HSPLIT_S2(HSPLIT_S2),
		.HRDATA_S1(HRDATA_S1),
		.HRDATA_S2(HRDATA_S2),
		.HREADY(HREADY),
		.HRESP(HRESP),
		.HSPLIT(HSPLIT),
		.HRDATA(HRDATA)
	);
	mem IM(
		.clock(clock),
		.reset(reset),
		.MRead(IM_read),
		.MWrite(IM_write),
		.MEnable(IM_enable),
		.MAddress(IM_address[11:0]),
		.MWriteData(),
		.MReadData(IM_out),
		.MReady(IM_ready)
	);
	mem DM(
		.clock(clock),
		.reset(reset),
		.MRead(DMRead),
		.MWrite(DMWrite),
		.MEnable(DMEnable),
		.MAddress(DMAddress[11:0]),
		.MWriteData(DMWriteData),
		.MReadData(DMReadData),
		.MReady(DMReady)
	);
	wrp_master WRP_MST_DM(
		.HCLK(clock),
		.HRESETn(!reset),
		.MRead(DM_read),
		.MWrite(DM_write),
		.MEnable(DM_enable),
		.MAddress(DM_address),
		.MReadData(DM_out),
		.MWriteData(DM_in),
		.MReady(DM_ready),
		.HBUSREQ(HBUSREQ_M2),
		.HLOCK(HLOCK_M2),
		.HGRANT(HGRANT_M2),
		.HTRANS(HTRANS_M2),
		.HWRITE(HWRITE_M2),
		.HSIZE(HSIZE_M2),
		.HBURST(HBURST_M2),
		.HPROT(HPROT_M2),
		.HADDR(HADDR_M2),
		.HWDATA(HWDATA_M2),
		.HREADY(HREADY),
		.HRESP(HRESP),
		.HRDATA(HRDATA)
	);
	wrp_slaver WRP_SLV_DM(
		.HCLK(clock),
		.HRESETn(!reset),
		.MRead(DMRead),
		.MWrite(DMWrite),
		.MEnable(DMEnable),
		.MAddress(DMAddress),
		.MWriteData(DMWriteData),
		.MReadData(DMReadData),
		.MReady(DMReady),
		.HSEL(HSEL_S2),
		.HTRANS(HTRANS),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HADDR(HADDR),
		.HWDATA(HWDATA),
		.HMASTER(),
		.HMASTERLOCK(),
		.HREADY(HREADY_S2),
		.HRESP(HRESP_S2),
		.HSPLIT(HSPLIT_S2),
		.HRDATA(HRDATA_S2)
	);
endmodule
