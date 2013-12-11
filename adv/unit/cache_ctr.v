`include "wait_state_ctr.v"
module cache_ctr(
	clock,
	reset,

	PStrobe,
	PRw,
	PReady,
	SysStrobe,
	SysRW,

	tag_match,
	valid,
	write,

	select_CacheData,
	select_PData
);
	input clock;
	input reset;

	input  PStrobe;
	input  PRw;
	output PReady;
	output SysStrobe;
	output SysRW;

	input  tag_match;
	input  valid;
	output write;
	
	output select_CacheData;
	output select_PData;
	output open_SysData;
	output open_PData;

	wire PReady=(RW_hit_state&&tag_match&&valid) || (RW_ready);

	wire wsc_carry;
	wire [1:0] wsc_load_value=`WAITSTATE;

	reg  write;
	reg  wsc_load;
	reg  RW_hit_state;
	reg  RW_ready;
	reg  SysStrobe;
	reg  SysRW;
	reg  select_CacheData;
	reg  select_PData;
	reg  open_SysData;
	reg  open_PData;

	reg [3:0] state;
	reg [3:0] next_state;

	parameter STATE_IDLE	  =4'd0;
	parameter STATE_READ	  =4'd1;
	parameter STATE_READMISS  =4'd2;
	parameter STATE_READSYS	  =4'd3;
	parameter STATE_READDATA  =4'd4;
	parameter STATE_WRITE	  =4'd5;
	parameter STATE_WRITEHIT  =4'd6;
	parameter STATE_WRITEMISS =4'd7;
	parameter STATE_WRITESYS  =4'd8;
	parameter STATE_WRITEDATA =4'd9;

	wait_state_ctr WAIT_STATE_CTR(
		.clock(clock),
		.load(wsc_load),
		.load_value(wsc_load_value),
		.carry(wsc_carry)
	);

	always@(posedge clock)begin
		state<=(reset)? STATE_IDLE:next_state;
	end
	always@(*)begin
		case(state)
			STATE_IDLE:begin
				if( (PStrobe)&&(PRw==`RW_READ) )       next_state=STATE_READ;
				else if( (PStrobe)&&(PRw==`RW_WRITE) ) next_state=STATE_WRITE;
				else				       next_state=STATE_IDLE;
			end
			STATE_READ:begin
				if(tag_match&&valid) next_state=STATE_IDLE;
				else		     next_state=STATE_READMISS;
			end
			STATE_READMISS:begin
				next_state=STATE_READSYS;
			end
			STATE_READSYS:begin
				if(wsc_carry) next_state=STATE_READDATA;
				else	      next_state=STATE_READSYS;
			end
			STATE_READDATA:begin
				next_state=STATE_IDLE;
			end
			STATE_WRITE:begin
				if(tag_match&&valid) next_state=STATE_WRITEHIT;
				else		     next_state=STATE_WRITEMISS;
			end
			STATE_WRITEHIT:begin
				next_state=STATE_WRITESYS;
			end
			STATE_WRITEMISS:begin
				next_state=STATE_WRITESYS;
			end
			STATE_WRITESYS:begin
				if(wsc_carry) next_state=STATE_WRITEDATA;
				else          next_state=STATE_WRITESYS;
			end
			STATE_WRITEDATA:begin
				next_state=STATE_IDLE;
			end
			default:begin
				next_state=STATE_IDLE;
			end
		endcase
	end

	always@(*)begin
		case(state)
			STATE_IDLE:begin
				write           =1'b0;
				wsc_load        =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CacheData=`CDATA_UNK;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_CLOSE;
			end
			STATE_READ:begin
				write           =1'b0;
				wsc_load        =1'b0;
				RW_hit_state    =1'b1;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CacheData=`CDATA_UNK;
				select_PData    =`PDATA_CAC;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_OPEN;
			end
			STATE_READMISS:begin
				write           =1'b0;
				wsc_load        =1'b1;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b1;
				SysRW           =`RW_READ;
				select_CacheData=`CDATA_UNK;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_CLOSE;
			end
			STATE_READSYS:begin
				write           =1'b0;
				wsc_load        =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CacheData=`CDATA_UNK;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_CLOSE;
			end
			STATE_READDATA:begin
				write           =1'b1;
				wsc_load        =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b1;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CacheData=`CDATA_SYS;
				select_PData    =`PDATA_SYS;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_OPEN;
			end
			STATE_WRITE:begin
				write           =1'b0;
				wsc_load        =1'b0;
				RW_hit_state    =1'b1;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CacheData=`CDATA_UNK;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_CLOSE;
			end
			STATE_WRITEHIT:begin
				write           =1'b1;
				wsc_load        =1'b1;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b1;
				SysRW           =`RW_WRITE;
				select_CacheData=`CDATA_PRO;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_OPEN;
				open_PData      =`PDATA_CLOSE;
			end
			STATE_WRITEMISS:begin
				write           =1'b1;
				wsc_load        =1'b1;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b1;
				SysRW           =`RW_WRITE;
				select_CacheData=`CDATA_PRO;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_OPEN;
				open_PData      =`PDATA_CLOSE;
			end
			STATE_WRITESYS:begin
				write           =1'b0;
				wsc_load        =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CacheData=`CDATA_UNK;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_CLOSE;
			end
			STATE_WRITEDATA:begin
				write           =1'b0;
				wsc_load        =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b1;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CacheData=`CDATA_UNK;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_CLOSE;
			end
			default:begin
				write           =1'b0;
				wsc_load        =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CacheData=`CDATA_UNK;
				select_PData    =`PDATA_UNK;
				open_SysData    =`SDATA_CLOSE;
				open_PData      =`PDATA_CLOSE;
			end
		endcase
	end

endmodule
