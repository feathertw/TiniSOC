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
	reg    count_start;
	reg    count_up;
	reg    do_flush_count;
	reg    [3:0] count_value;
	reg    MReady;

	reg [2:0] state;
	reg [2:0] next_state;
	parameter STATE_IDLE	=3'd0;
	parameter STATE_RADDR   =3'd1;
	parameter STATE_RDATA_C =3'd2;
	parameter STATE_RDATA_F =3'd4;
	parameter STATE_WADDR	=3'd5;
	parameter STATE_WDATA	=3'd6;

	//wire HBUSREQ=(MEnable^xMEnable)||REG_HBUSREQ;

	wire [31:0] MReadData=HRDATA;

	always@(posedge MEnable)begin
		if(MEnable)begin
			HBUSREQ<=1'b1;
			MReady<=1'b0;
		end
	end
	always@(posedge MReady)begin
		if(MReady) HBUSREQ<=1'b0;
	end

	always@(posedge HCLK)begin
		if(!HRESETn)begin
			count_start<=0;
			count_up<=0;
			do_flush_count<=0;
			count_value<=4'b0;
			MReady<=1'b0;
		end
		else begin
			if(MEnable&&MRead)begin
				HLOCK=1'b1;
				HADDR_BASE<=MAddress&32'hffff_ffc0;
			end
			if(MEnable&&MWrite)begin
				if(HREADY)begin
					HLOCK=1'b0;
				end
				else begin
					HLOCK=1'b0;
				end
			end

			if(count_start&&HREADY)begin
				count_value<=count_value+1;
			end
			if(count_value==4'b1111)begin
				count_start<=0;
				count_up<=1'b1;
				HLOCK=1'b0;
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
				if(HREADY)begin
					next_state=STATE_RDATA_C;
					MReady=1'b0;
				end
				else begin
					next_state=STATE_RADDR;
					MReady=1'b0;
				end
			end
			STATE_RDATA_C:begin
				if(HREADY&&count_up)begin
					next_state=STATE_RDATA_F;
					MReady=1'b1;
				end
				else if(HREADY)begin
					next_state=STATE_RDATA_C;
					MReady=1'b1;
				end
				else begin
					next_state=STATE_RDATA_C;
					MReady=1'b0;
				end
			end
			STATE_RDATA_F:begin
				if(HREADY)begin
					next_state=STATE_IDLE;
					MReady=1'b1;
				end
				else begin
					next_state=STATE_RDATA_F;
					MReady=1'b0;
				end
			end
			STATE_WADDR:begin
				HBUSREQ=1'b0;
				if(HREADY)begin
					next_state=STATE_WDATA;
					MReady=1'b1;
				end
				else begin
					next_state=STATE_WADDR;
					MReady=1'b0;
				end
			end
			STATE_WDATA:begin
				if(HREADY)begin
					next_state=STATE_IDLE;
					MReady=1'b1;
				end
				else begin
					next_state=STATE_WDATA;
					MReady=1'b0;
				end
			end
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
			end
			STATE_RADDR:begin
				HTRANS=`TRN_NONSEQ;
				HWRITE=1'b0;
				HSIZE =`SIZ_32BIT;
				HBURST=`BUR_INCR16;
				HPROT ='bx;
				HADDR =HADDR_BASE;
				HWDATA='bx;
				count_start=1'b1;
				count_up=1'b0;
			end
			STATE_RDATA_C:begin
				HTRANS=`TRN_SEQ;
				HWRITE=1'b0;
				HSIZE =`SIZ_32BIT;
				HBURST=`BUR_INCR16;
				HPROT ='bx;
				HADDR =HADDR_BASE+4*count_value;
				HWDATA='bx;
			end
			STATE_RDATA_F:begin
				HTRANS=`TRN_IDLE;
				HWRITE='bx;
				HSIZE ='bx;
				HBURST='bx;
				HPROT ='bx;
				HADDR ='bx;
				HWDATA='bx;
			end
			STATE_WADDR:begin
				HTRANS=`TRN_NONSEQ;
				HWRITE=1'b1;
				HSIZE =`SIZ_32BIT;
				HBURST=`BUR_SINGLE;
				HPROT ='bx;
				HADDR =MAddress;
				HWDATA='bx;
			end
			STATE_WDATA:begin
				HTRANS=`TRN_IDLE;
				HWRITE='bx;
				HSIZE ='bx;
				HBURST='bx;
				HPROT ='bx;
				HADDR ='bx;
				HWDATA=MWriteData;
			end
		endcase
	end
endmodule
