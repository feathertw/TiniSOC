module cache_control(
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

	wire wait_state_ctr_carry;

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

	always@(posedge clock)begin
		state<=(reset)? STATE_IDLE:next_state;
	end
	always@(*)begin
		case(state)
			STATE_IDLE:begin
				if( (PStrobe)&&(PRw==`READ) )	    next_state=STATE_READ;
				else if( (PStrobe)&&(PRw==`WRITE) ) next_state=STATE_WRITE;
				else				    next_state=STATE_IDLE;
			end
			STATE_READ:begin
				if(tag_match&&valid) next_state=STATE_IDLE;
				else		     next_state=STATE_READMISS;
			end
			STATE_READMISS:begin
				next_state=STATE_READSYS;
			end
			STATE_READSYS:begin
				if(wait_state_ctr_carry) next_state=STATE_READDATA;
				else			 next_state=STATE_READSYS;
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
				if(wait_state_ctr_carry) next_state=STATE_WRITEDATA;
				else			 next_state=STATE_WRITESYS;
			end
			STATE_WRITEDATA:begin
				next_state=STATE_IDLE;
			end
			default:begin
				next_state=STATE_IDLE;
			end
		endcase
	end

endmodule
