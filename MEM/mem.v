`define WAIT_STATE 2
`define WS `WAIT_STATE
`define M_ADDR_OFS 32'hffff_ffc0

`include "mcounter.v"
module mem(
	clock,
	reset,
	MRead,
	MWrite,
	MEnable,
	MAddress,
	MWriteData,
	MReadData,
	MReady
);
	parameter data_size=32;
	parameter mem_size=1024*256/4;
	parameter mem_size_bit=10+8-2;

	input clock;
	input reset;
	input MRead;
	input MWrite;
	input MEnable;
	input [mem_size_bit-1:0] MAddress;
	input [data_size-1:0] MWriteData;
	output [data_size-1:0] MReadData;
	output MReady;

	reg [data_size-1:0] mem_data[mem_size-1:0];

	reg MReady;
	reg [data_size-1:0] MReadData;

	reg REG_MEnable [`WAIT_STATE:0];
	reg REG_MRead   [`WAIT_STATE:0];
	reg REG_MWrite  [`WAIT_STATE:0];
	reg [31:0] REG_MAddress [`WAIT_STATE:0];
	reg [31:0] REG_MData    [`WAIT_STATE:0];

	reg [31:0] MBaseAddress;
	reg do_counter_flush;
	reg do_counter_start;
	wire [3:0] counter_value;
	wire counter_up;

	integer i;

	mcounter MCOUNTER(
		.clock(clock),
		.flush(do_counter_flush),
		.signal(do_counter_start),
		.value(counter_value),
		.readup(counter_up)
	);

	always@(negedge clock)begin
		if(MReady&&(!do_counter_start) )begin
			REG_MEnable[0] <=MEnable;
			REG_MRead[0]   <=MRead;
			REG_MWrite[0]  <=MWrite;
			REG_MAddress[0]<=MAddress;
			REG_MData[0]   <=MWriteData;
		end
		else begin
			REG_MEnable[0] <=1'b0;
			REG_MRead[0]   <=1'b0;
			REG_MWrite[0]  <=1'b0;
			REG_MAddress[0]<='b0;
			REG_MData[0]   <='b0;
		end

		for(i=0;i<`WAIT_STATE;i=i+1) REG_MEnable[i+1] <=REG_MEnable[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_MRead[i+1]   <=REG_MRead[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_MWrite[i+1]  <=REG_MWrite[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_MAddress[i+1]<=REG_MAddress[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_MData[i+1]   <=REG_MData[i];
	end

	always@(posedge clock)begin
		if(reset)begin
			for(i=0;i<mem_size;i=i+1)begin
				mem_data[i]<=0;
				MReadData<=0;
				MReady<=1'b1;
				do_counter_flush<=1'b1;
				do_counter_start<=1'b0;
			end
		end
		else begin
			if(REG_MEnable[0]&&REG_MRead[0])begin
				MReady<=1'b0;
				MBaseAddress<=(MAddress&`M_ADDR_OFS);
				do_counter_flush<=1'b1;
			end
			if(REG_MEnable[`WS])begin
				if(REG_MRead[`WS])begin
					MReady<=1'b1;
					MReadData<=mem_data[( MBaseAddress/4)];
					do_counter_flush<=1'b0;
					do_counter_start<=1'b1;
				end
				else if(REG_MWrite[`WS])begin
					mem_data[(REG_MAddress[`WS]/4)] <= REG_MData[`WS-1];
				end
			end
			if(do_counter_start)begin
				MReadData<=mem_data[( (MBaseAddress+4*counter_value)/4)];
			end
			if(counter_up)begin
				do_counter_start<=1'b0;
			end
		end
	end
endmodule
