module wrp_master_io(
	clock,
	reset,

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
	input  clock;
	input  reset;

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

	reg    [ 1:0] HTRANS;
	reg    HWRITE;
	reg    [ 2:0] HSIZE;
	reg    [ 2:0] HBURST;
	reg    [ 3:0] HPROT;
	reg    [31:0] HADDR;
	reg    [31:0] HWDATA;

	reg    [31:0] MReadData;

	reg    REG_MReady;

	reg [2:0] state;
	reg [2:0] next_state;
	parameter STATE_IDLE	=3'd0;
	parameter STATE_RADDR	=3'd1;
	parameter STATE_RDATA	=3'd2;
	parameter STATE_WADDR	=3'd3;
	parameter STATE_WDATA	=3'd4;

	wire MReady=(state==STATE_IDLE);

	wire HBUSREQ=MEnable&&MReady&&REG_MReady;
	wire HLOCK=1'b0;

	always@(negedge clock)begin
		REG_MReady<=MReady;
	end

	always@(posedge clock)begin
		if(state==STATE_RDATA)begin
			MReadData<=HRDATA;
		end
	end

	always@(posedge clock)begin
		state<=(reset)? STATE_IDLE:next_state;
	end
	always@(*)begin
		case(state)
			STATE_IDLE:begin
				if(HGRANT&&HREADY&&MRead) 	next_state=STATE_RADDR;
				else if(HGRANT&&HREADY&&MWrite) next_state=STATE_WADDR;
				else		   		next_state=STATE_IDLE;
			end
			STATE_RADDR:begin
				if(HREADY) next_state=STATE_RDATA;
				else	   next_state=STATE_RADDR;
			end
			STATE_RDATA:begin
				if(HREADY) next_state=STATE_IDLE;
				else	   next_state=STATE_RDATA;
			end
			STATE_WADDR:begin
				if(HREADY) next_state=STATE_WDATA;
				else	   next_state=STATE_WADDR;
			end
			STATE_WDATA:begin
				if(HREADY) next_state=STATE_IDLE;
				else	   next_state=STATE_WDATA;
			end
			default:begin
				next_state=STATE_IDLE;
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
				HBURST=`BUR_SINGLE;
				HPROT ='bx;
				HADDR =MAddress;
				HWDATA='bx;
			end
			STATE_RDATA:begin
				HTRANS='bx;
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
				HTRANS='bx;
				HWRITE='bx;
				HSIZE ='bx;
				HBURST='bx;
				HPROT ='bx;
				HADDR ='bx;
				HWDATA=MWriteData;
			end
			default:begin
				HTRANS='bx;
				HWRITE='bx;
				HSIZE ='bx;
				HBURST='bx;
				HPROT ='bx;
				HADDR ='bx;
				HWDATA='bx;
			end
		endcase
	end
endmodule
