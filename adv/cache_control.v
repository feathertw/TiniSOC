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

	reg [3:0] state;
	reg [3:0] next_state;

	parameter STATE_IDLE		4'd0
	parameter STATE_READ		4'd1
	parameter STATE_READMISS	4'd2
	parameter STATE_READSYS		4'd3
	parameter STATE_READDATA	4'd4
	parameter STATE_WRITE		4'd5
	parameter STATE_WRITEHIT	4'd6
	parameter STATE_WRITEMISS	4'd7
	parameter STATE_WRITESYS	4'd8
	parameter STATE_WRITEDATA	4'd9

	always@(posedge clock)begin
		state<=(reset)? STATE_IDLE:next_state;
	end
	always@(*)begin
		case(state)
			STATE_IDLE:
			STATE_READ:
			STATE_READMISS:
			STATE_READSYS:
			STATE_READDATA:
			STATE_WRITE:
			STATE_WRITEHIT:
			STATE_WRITEMISS:
			STATE_WRITESYS:
			STATE_WRITEDATA:
			default:
		endcase
	end

endmodule
