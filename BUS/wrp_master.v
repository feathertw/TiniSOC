`define ADDR_OFS 32'hffff_ffc0

`include "hcounter.v"
module wrp_master(
	HCLK,
	HRESETn,

	MRead,
	MWrite,
	MEnable,
	MAddress,
	MReadData,
	MWriteData,
	MReady,

	HBUSREQ,
	HLOCK,
	HGRANT,

	HTRANS,
	HWRITE,
	HSIZE,
	HBURST,
	HPROT,
	HADDR,
	HWDATA,

	HREADY,
	HRESP,
	HRDATA
);
	input  HCLK;
	input  HRESETn;

	input  MRead;
	input  MWrite;
	input  MEnable;
	input  [31:0] MAddress;
	output [31:0] MReadData;
	input  [31:0] MWriteData;
	output MReady;

	output HBUSREQ;
	output HLOCK;
	input  HGRANT;

	output [ 1:0] HTRANS;
	output HWRITE;
	output [ 2:0] HSIZE;
	output [ 2:0] HBURST;
	output [ 3:0] HPROT;
	output [31:0] HADDR;
	output [31:0] HWDATA;

	input  HREADY;
	input  [ 1:0] HRESP;
	input  [31:0] HRDATA;

	reg    HBUSREQ;
	reg    HLOCK;

	reg    [ 1:0] HTRANS;
	reg    HWRITE;
	reg    [ 2:0] HSIZE;
	reg    [ 2:0] HBURST;
	reg    [ 3:0] HPROT;
	reg    [31:0] HADDR;
	reg    [31:0] HWDATA;

	reg    [31:0] HADDR_BASE;
	reg    do_counter_flush;
	reg    do_counter_start;
	wire   counter_up;
	wire   [3:0] counter_value;

	reg [2:0] state;
	reg [2:0] next_state;
	parameter STATE_IDLE	=3'd0;
	parameter STATE_RADDR   =3'd1;
	parameter STATE_RDATA_C =3'd2;
	parameter STATE_RDATA_F =3'd3;
	parameter STATE_WADDR	=3'd4;
	parameter STATE_WDATA	=3'd5;

	wire [31:0] MReadData=HRDATA;
	wire counter_signal= do_counter_start&&(!counter_up)&&HREADY;

	wire MReady=HREADY&&(state==STATE_RDATA_C||state==STATE_WADDR);

	hcounter HCOUNTER(
		.HCLK(HCLK),
		.flush(do_counter_flush),
		.signal(counter_signal),
		.value(counter_value),
		.readup(counter_up)
	);

	always@(posedge MEnable)begin
		if(MEnable)begin
			HBUSREQ<=1'b1;
		end
	end

	always@(posedge HCLK)begin
		if(!HRESETn)begin
			do_counter_flush<=1'b1;
			do_counter_start<=1'b0;
			HBUSREQ<=1'b0;
			HLOCK<=1'b0;
		end
		else begin
			if(MEnable&&MRead)begin
				HLOCK<=1'b1;
				HADDR_BASE<=MAddress&`ADDR_OFS;
			end
			if(counter_value==4'b1111)begin
				HBUSREQ<=1'b0;
				HLOCK<=1'b0;
			end
			if(HGRANT&&HREADY&&MWrite)begin
				HBUSREQ<=1'b0;
			end
		end
	end

	always@(posedge HCLK)begin
		state<=(!HRESETn)? STATE_IDLE:next_state;
	end
	always@(*)begin
		case(state)
			STATE_IDLE:begin
				if(HGRANT&&HREADY)begin
					if(MRead)  next_state=STATE_RADDR;
					else	   next_state=STATE_WADDR;
				end
				else		   next_state=STATE_IDLE;
			end
			STATE_RADDR:begin
				if(HREADY) next_state=STATE_RDATA_C;
				else	   next_state=STATE_RADDR;
			end
			STATE_RDATA_C:begin
				if(HREADY&&counter_up) next_state=STATE_RDATA_F;
				else		       next_state=STATE_RDATA_C;
			end
			STATE_RDATA_F:begin
				if(HREADY) next_state=STATE_IDLE;
				else	   next_state=STATE_RDATA_F;
			end
			STATE_WADDR:begin
				if(HREADY) next_state=STATE_WDATA;
				else	   next_state=STATE_WADDR;
			end
			STATE_WDATA:begin
				if(HREADY) next_state=STATE_IDLE;
				else	   next_state=STATE_WDATA;
			end
			default: next_state=STATE_IDLE;
		endcase
	end
	always@(*)begin
		case(state)
			STATE_IDLE:begin
				HTRANS='bx;
				HWRITE='bx;
				HSIZE ='bx;
				HBURST='bx;
				HPROT ='bx;
				HADDR ='bx;
				HWDATA='bx;
				do_counter_flush<=1'b1;
				do_counter_start<=1'b0;
			end
			STATE_RADDR:begin
				HTRANS=`TRN_NONSEQ;
				HWRITE=1'b0;
				HSIZE =`SIZ_32BIT;
				HBURST=`BUR_INCR16;
				HPROT ='bx;
				HADDR =HADDR_BASE;
				HWDATA='bx;
				do_counter_flush<=1'b0;
				do_counter_start<=1'b1;
			end
			STATE_RDATA_C:begin
				HTRANS=`TRN_SEQ;
				HWRITE=1'b0;
				HSIZE =`SIZ_32BIT;
				HBURST=`BUR_INCR16;
				HPROT ='bx;
				HADDR =HADDR_BASE+4*counter_value;
				HWDATA='bx;
				do_counter_flush<=1'b0;
				do_counter_start<=1'b1;
			end
			STATE_RDATA_F:begin
				HTRANS=`TRN_IDLE;
				HWRITE='bx;
				HSIZE ='bx;
				HBURST='bx;
				HPROT ='bx;
				HADDR ='bx;
				HWDATA='bx;
				do_counter_flush<=1'b0;
				do_counter_start<=1'b0;
			end
			STATE_WADDR:begin
				HTRANS=`TRN_NONSEQ;
				HWRITE=1'b1;
				HSIZE =`SIZ_32BIT;
				HBURST=`BUR_SINGLE;
				HPROT ='bx;
				HADDR =MAddress;
				HWDATA='bx;
				do_counter_flush<=1'b0;
				do_counter_start<=1'b0;
			end
			STATE_WDATA:begin
				HTRANS=`TRN_IDLE;
				HWRITE='bx;
				HSIZE ='bx;
				HBURST='bx;
				HPROT ='bx;
				HADDR ='bx;
				HWDATA=MWriteData;
				do_counter_flush<=1'b0;
				do_counter_start<=1'b0;
			end
			default:begin
				HTRANS='bx;
				HWRITE='bx;
				HSIZE ='bx;
				HBURST='bx;
				HPROT ='bx;
				HADDR ='bx;
				HWDATA='bx;
				do_counter_flush<=1'b1;
				do_counter_start<=1'b0;
			end
		endcase
	end
endmodule
