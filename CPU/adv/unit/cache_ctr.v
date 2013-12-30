module cache_ctr(
	clock,
	reset,
	CReady,

	PStrobe,
	PRw,
	SysStrobe,
	SysRW,
	SysReady,

	tag_match,
	valid,
	readup,
	do_write,

	select_CData,
	select_CWOffset,
	do_buffer_flush
);
	input clock;
	input reset;
	output CReady;

	input  PStrobe;
	input  PRw;
	output SysStrobe;
	output SysRW;
	input  SysReady;

	input  tag_match;
	input  valid;
	input  readup;
	output do_write;
	
	output select_CData;
	output select_CWOffset;
	output do_buffer_flush;

	reg  write;
	reg  RW_hit_state;
	reg  RW_ready;
	reg  SysStrobe;
	reg  SysRW;
	reg  select_CData;
	reg  select_CWOffset;
	reg  do_buffer_flush;

	reg [3:0] state;
	reg [3:0] next_state;

	parameter STATE_IDLE	  =4'd0;
	parameter STATE_READ	  =4'd1;
	parameter STATE_READMISS  =4'd2;
	parameter STATE_READSYS	  =4'd3;
	parameter STATE_READDATA  =4'd4;
	parameter STATE_WRITE	  =4'd5;
	parameter STATE_WRITEDATA =4'd6;

	wire CReady=(RW_hit_state&&tag_match&&valid) || (RW_ready);

	wire do_write=write||(state==STATE_WRITE&&tag_match&&valid);

	always@(posedge clock)begin
		state<=(reset)? STATE_IDLE:next_state;
	end
	always@(state or PStrobe or PRw or tag_match or valid or readup or SysReady)begin
		case(state)
			STATE_IDLE:begin
				if( (PStrobe)&&(PRw==`RW_READ) )       next_state=STATE_READ;
				else if( (PStrobe)&&(PRw==`RW_WRITE) ) next_state=STATE_WRITE;
				else			      	       next_state=STATE_IDLE;
			end
			STATE_READ:begin
				if(tag_match&&valid) begin
					if( (PStrobe)&&(PRw==`RW_READ) )       next_state=STATE_READ;
					else if( (PStrobe)&&(PRw==`RW_WRITE) ) next_state=STATE_WRITE;
					else			      	       next_state=STATE_IDLE;
				end
				else		     			       next_state=STATE_READMISS;
			end
			STATE_READMISS:begin
				next_state=STATE_READSYS;
			end
			STATE_READSYS:begin
				if(readup) next_state=STATE_READDATA;
				else	   next_state=STATE_READSYS;
			end
			STATE_READDATA:begin
				if( (PStrobe)&&(PRw==`RW_READ) )       next_state=STATE_READ;
				else if( (PStrobe)&&(PRw==`RW_WRITE) ) next_state=STATE_WRITE;
				else			      	       next_state=STATE_IDLE;
			end
			STATE_WRITE:begin
				if(SysReady) next_state=STATE_WRITEDATA;
				else	     next_state=STATE_WRITE;
			end
			STATE_WRITEDATA:begin
				if( (PStrobe)&&(PRw==`RW_READ) )       next_state=STATE_READ;
				else if( (PStrobe)&&(PRw==`RW_WRITE) ) next_state=STATE_WRITE;
				else			      	       next_state=STATE_IDLE;
			end
			default:begin
				next_state=STATE_IDLE;
			end
		endcase
	end

	always@(state)begin
		case(state)
			STATE_IDLE:begin
				write           =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b1;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CData    =`CDATA_UNK;
				select_CWOffset =`CWOFS_UNK;
				do_buffer_flush =1'b0;
			end
			STATE_READ:begin
				write           =1'b0;
				RW_hit_state    =1'b1;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CData    =`CDATA_UNK;
				select_CWOffset =`CWOFS_UNK;
				do_buffer_flush =1'b0;
			end
			STATE_READMISS:begin
				write           =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b1;
				SysRW           =`RW_READ;
				select_CData    =`CDATA_UNK;
				select_CWOffset =`CWOFS_UNK;
				do_buffer_flush =1'b1;
			end
			STATE_READSYS:begin
				write           =1'b1;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CData    =`CDATA_SYS;
				select_CWOffset =`CWOFS_SYS;
				do_buffer_flush =1'b0;
			end
			STATE_READDATA:begin
				write           =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b1;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CData    =`CDATA_UNK;
				select_CWOffset =`CWOFS_UNK;
				do_buffer_flush =1'b0;
			end
			STATE_WRITE:begin
				write           =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b1;
				SysRW           =`RW_WRITE;
				select_CData    =`CDATA_PRO;
				select_CWOffset =`CWOFS_PRO;
				do_buffer_flush =1'b0;
			end
			STATE_WRITEDATA:begin
				write           =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b1;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CData    =`CDATA_UNK;
				select_CWOffset =`CWOFS_UNK;
				do_buffer_flush =1'b0;
			end
			default:begin
				write           =1'b0;
				RW_hit_state    =1'b0;
				RW_ready        =1'b0;
				SysStrobe       =1'b0;
				SysRW           =`RW_UNK;
				select_CData    =`CDATA_UNK;
				select_CWOffset =`CWOFS_UNK;
				do_buffer_flush =1'b0;
			end
		endcase
	end

endmodule
