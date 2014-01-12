`include "CPU/cpu.v"
`include "BUS/ahb.v"
`include "MEM/mem.v"
`include "PER/uart.v"
`include "WRP/wrp_master.v"
`include "WRP/wrp_master_io.v"
`include "WRP/wrp_slave.v"
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
	wire IOM_read;
	wire IOM_write;
	wire IOM_enable;
	wire [31:0] IOM_address;
	wire [31:0] IOM_in;
	wire [31:0] IOM_out;
	wire IOM_ready;

	wire HBUSREQ_M1;
	wire HBUSREQ_M2;
	wire HBUSREQ_M3;
	wire HLOCK_M1;
	wire HLOCK_M2;
	wire HLOCK_M3;
	wire HGRANT_M1;
	wire HGRANT_M2;
	wire HGRANT_M3;

	wire HSEL_S1;
	wire HSEL_S2;
	wire HSEL_S3;

	wire [ 1:0] HTRANS_M1;
	wire [ 1:0] HTRANS_M2;
	wire [ 1:0] HTRANS_M3;
	wire        HWRITE_M1;
	wire        HWRITE_M2;
	wire        HWRITE_M3;
	wire [ 2:0] HSIZE_M1;
	wire [ 2:0] HSIZE_M2;
	wire [ 2:0] HSIZE_M3;
	wire [ 2:0] HBURST_M1;
	wire [ 2:0] HBURST_M2;
	wire [ 2:0] HBURST_M3;
	wire [ 3:0] HPROT_M1;
	wire [ 3:0] HPROT_M2;
	wire [ 3:0] HPROT_M3;
	wire [31:0] HADDR_M1;
	wire [31:0] HADDR_M2;
	wire [31:0] HADDR_M3;
	wire [31:0] HWDATA_M1;
	wire [31:0] HWDATA_M2;
	wire [31:0] HWDATA_M3;
	wire [ 1:0] HTRANS;
	wire        HWRITE;
	wire [ 2:0] HSIZE;
	wire [ 2:0] HBURST;
	wire [ 3:0] HPROT;
	wire [31:0] HADDR;
	wire [31:0] HWDATA;

	wire        HREADY_S1;
	wire        HREADY_S2;
	wire        HREADY_S3;
	wire [ 1:0] HRESP_S1;
	wire [ 1:0] HRESP_S2;
	wire [ 1:0] HRESP_S3;
	wire [15:0] HSPLIT_S1;
	wire [15:0] HSPLIT_S2;
	wire [15:0] HSPLIT_S3;
	wire [31:0] HRDATA_S1;
	wire [31:0] HRDATA_S2;
	wire [31:0] HRDATA_S3;
	wire        HREADY;
	wire [ 1:0] HRESP;
	wire [15:0] HSPLIT;
	wire [31:0] HRDATA;

	wire IOMRead;
	wire IOMWrite;
	wire IOMEnable;
	wire [31:0] IOMAddress;
	wire [31:0] IOMWriteData;
	wire [31:0] IOMReadData;
	wire IOMReady;

	wire DMRead;
	wire DMWrite;
	wire DMEnable;
	wire [31:0] DMAddress;
	wire [31:0] DMWriteData;
	wire [31:0] DMReadData;
	wire DMReady;

	wire IMRead;
	wire IMWrite;
	wire IMEnable;
	wire [31:0] IMAddress;
	wire [31:0] IMWriteData;
	wire [31:0] IMReadData;
	wire IMReady;

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
		.IOM_read(IOM_read),
		.IOM_write(IOM_write),
		.IOM_enable(IOM_enable),
		.IOM_address(IOM_address),
		.IOM_in(IOM_in),
		.IOM_out(IOM_out),
		.IOM_ready(IOM_ready),
		.do_system(do_system)
	);
	ahb AHB(
		.HCLK(clock),
		.HRESETn(!reset),
		.HBUSREQ_M1(HBUSREQ_M1),
		.HBUSREQ_M2(HBUSREQ_M2),
		.HBUSREQ_M3(HBUSREQ_M3),
		.HLOCK_M1(HLOCK_M1),
		.HLOCK_M2(HLOCK_M2),
		.HLOCK_M3(HLOCK_M3),
		.HGRANT_M1(HGRANT_M1),
		.HGRANT_M2(HGRANT_M2),
		.HGRANT_M3(HGRANT_M3),
		.HSEL_S1(HSEL_S1),
		.HSEL_S2(HSEL_S2),
		.HSEL_S3(HSEL_S3),
		.HTRANS_M1(HTRANS_M1),
		.HTRANS_M2(HTRANS_M2),
		.HTRANS_M3(HTRANS_M3),
		.HWRITE_M1(HWRITE_M1),
		.HWRITE_M2(HWRITE_M2),
		.HWRITE_M3(HWRITE_M3),
		.HSIZE_M1(HSIZE_M1),
		.HSIZE_M2(HSIZE_M2),
		.HSIZE_M3(HSIZE_M3),
		.HBURST_M1(HBURST_M1),
		.HBURST_M2(HBURST_M2),
		.HBURST_M3(HBURST_M3),
		.HPROT_M1(HPROT_M1),
		.HPROT_M2(HPROT_M2),
		.HPROT_M3(HPROT_M3),
		.HADDR_M1(HADDR_M1),
		.HADDR_M2(HADDR_M2),
		.HADDR_M3(HADDR_M3),
		.HWDATA_M1(HWDATA_M1),
		.HWDATA_M2(HWDATA_M2),
		.HWDATA_M3(HWDATA_M3),
		.HTRANS(HTRANS),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HPROT(HPROT),
		.HADDR(HADDR),
		.HWDATA(HWDATA),
		.HREADY_S1(HREADY_S1),
		.HREADY_S2(HREADY_S2),
		.HREADY_S3(HREADY_S3),
		.HRESP_S1(HRESP_S1),
		.HRESP_S2(HRESP_S2),
		.HRESP_S3(HRESP_S3),
		.HSPLIT_S1(HSPLIT_S1),
		.HSPLIT_S2(HSPLIT_S2),
		.HSPLIT_S3(HSPLIT_S3),
		.HRDATA_S1(HRDATA_S1),
		.HRDATA_S2(HRDATA_S2),
		.HRDATA_S3(HRDATA_S3),
		.HREADY(HREADY),
		.HRESP(HRESP),
		.HSPLIT(HSPLIT),
		.HRDATA(HRDATA)
	);
	mem IM(
		.clock(clock),
		.reset(reset),
		.MRead(IMRead),
		.MWrite(IMWrite),
		.MEnable(IMEnable),
		.MAddress(IMAddress[15:0]),
		.MWriteData(IMWriteData),
		.MReadData(IMReadData),
		.MReady(IMReady)
	);
	mem DM(
		.clock(clock),
		.reset(reset),
		.MRead(DMRead),
		.MWrite(DMWrite),
		.MEnable(DMEnable),
		.MAddress(DMAddress[15:0]),
		.MWriteData(DMWriteData),
		.MReadData(DMReadData),
		.MReady(DMReady)
	);
	uart UART(
		.clock(clock),
		.reset(reset),
		.MRead(IOMRead),
		.MWrite(IOMWrite),
		.MEnable(IOMEnable),
		.MAddress(IOMAddress[23:0]),
		.MWriteData(IOMWriteData),
		.MReadData(IOMReadData),
		.MReady(IOMReady)
	);
	wrp_master WRP_MST_IM(
		.clock(clock),
		.reset(reset),
		.MRead(IM_read),
		.MWrite(IM_write),
		.MEnable(IM_enable),
		.MAddress(IM_address),
		.MReadData(IM_out),
		.MWriteData(),
		.MReady(IM_ready),
		.HBUSREQ(HBUSREQ_M1),
		.HLOCK(HLOCK_M1),
		.HGRANT(HGRANT_M1),
		.HTRANS(HTRANS_M1),
		.HWRITE(HWRITE_M1),
		.HSIZE(HSIZE_M1),
		.HBURST(HBURST_M1),
		.HPROT(HPROT_M1),
		.HADDR(HADDR_M1),
		.HWDATA(HWDATA_M1),
		.HREADY(HREADY),
		.HRESP(HRESP),
		.HRDATA(HRDATA)
	);
	wrp_master WRP_MST_DM(
		.clock(clock),
		.reset(reset),
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
	wrp_master_io WRP_MST_IOM(
		.clock(clock),
		.reset(reset),
		.MRead(IOM_read),
		.MWrite(IOM_write),
		.MEnable(IOM_enable),
		.MAddress(IOM_address),
		.MReadData(IOM_out),
		.MWriteData(IOM_in),
		.MReady(IOM_ready),
		.HBUSREQ(HBUSREQ_M3),
		.HLOCK(HLOCK_M3),
		.HGRANT(HGRANT_M3),
		.HTRANS(HTRANS_M3),
		.HWRITE(HWRITE_M3),
		.HSIZE(HSIZE_M3),
		.HBURST(HBURST_M3),
		.HPROT(HPROT_M3),
		.HADDR(HADDR_M3),
		.HWDATA(HWDATA_M3),
		.HREADY(HREADY),
		.HRESP(HRESP),
		.HRDATA(HRDATA)
	);
	wrp_slaver WRP_SLV_IM(
		.clock(clock),
		.reset(reset),
		.MRead(IMRead),
		.MWrite(IMWrite),
		.MEnable(IMEnable),
		.MAddress(IMAddress),
		.MWriteData(IMWriteData),
		.MReadData(IMReadData),
		.MReady(IMReady),
		.HSEL(HSEL_S1),
		.HTRANS(HTRANS),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HADDR(HADDR),
		.HWDATA(HWDATA),
		.HMASTER(),
		.HMASTERLOCK(),
		.HREADY(HREADY_S1),
		.HRESP(HRESP_S1),
		.HSPLIT(HSPLIT_S1),
		.HRDATA(HRDATA_S1)
	);
	wrp_slaver WRP_SLV_DM(
		.clock(clock),
		.reset(reset),
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
	wrp_slaver WRP_SLV_IOM(
		.clock(clock),
		.reset(reset),
		.MRead(IOMRead),
		.MWrite(IOMWrite),
		.MEnable(IOMEnable),
		.MAddress(IOMAddress),
		.MWriteData(IOMWriteData),
		.MReadData(IOMReadData),
		.MReady(IOMReady),
		.HSEL(HSEL_S3),
		.HTRANS(HTRANS),
		.HWRITE(HWRITE),
		.HSIZE(HSIZE),
		.HBURST(HBURST),
		.HADDR(HADDR),
		.HWDATA(HWDATA),
		.HMASTER(),
		.HMASTERLOCK(),
		.HREADY(HREADY_S3),
		.HRESP(HRESP_S3),
		.HSPLIT(HSPLIT_S3),
		.HRDATA(HRDATA_S3)
	);
endmodule
