`define WAIT_STATE 2
`define WS `WAIT_STATE
`define M_ADDR_OFS 32'hffff_ffc0
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
	parameter mem_size=4096;
	parameter mem_size_bit=12;

	input clock;
	input reset;
	input MRead;
	input MWrite;
	input MEnable;
	input [mem_size_bit-1:0] MAddress;
	input [data_size-1:0] MWriteData;
	output [data_size-1:0] MReadData;
	output MReady;

	reg [data_size-1:0] MReadData;
	reg MReady;

	reg [data_size-1:0] mem_data[mem_size-1:0];

	reg REG_M_enable [`WAIT_STATE:0];
	reg REG_M_read   [`WAIT_STATE:0];
	reg REG_M_write  [`WAIT_STATE:0];
	reg [31:0] REG_M_address [`WAIT_STATE:0];
	reg [31:0] REG_M_data    [`WAIT_STATE:0];

	reg [31:0] M_base_address;
	reg [ 3:0] count_value;
	reg do_count;
	reg Reg_do_count;
	integer i;

	always@(negedge clock)begin
		if(MReady&&(!do_count)&&(!Reg_do_count) )begin
			REG_M_enable[0] <=MEnable;
			REG_M_read[0]   <=MRead;
			REG_M_write[0]  <=MWrite;
			REG_M_address[0]<=MAddress;
			REG_M_data[0]   <=MWriteData;
		end
		else begin
			REG_M_enable[0] <=1'b0;
			REG_M_read[0]   <=1'b0;
			REG_M_write[0]  <=1'b0;
			REG_M_address[0]<='b0;
			REG_M_data[0]   <='b0;
		end

		for(i=0;i<`WAIT_STATE;i=i+1) REG_M_enable[i+1] <=REG_M_enable[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_M_read[i+1]   <=REG_M_read[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_M_write[i+1]  <=REG_M_write[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_M_address[i+1]<=REG_M_address[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_M_data[i+1]   <=REG_M_data[i];
	end

	always@(posedge clock)begin
		if(reset)begin
			for(i=0;i<mem_size;i=i+1)begin
				mem_data[i]<=0;
				MReadData<=0;
				MReady<=1'b1;
				do_count<=1'b0;
			end
		end
		else begin
			if(REG_M_enable[0]&&REG_M_read[0])begin
				M_base_address<=(MAddress&`M_ADDR_OFS);
				MReady<=1'b0;
			end
			if(REG_M_enable[`WS])begin
				if(REG_M_read[`WS])begin
					MReadData<=mem_data[( M_base_address/4)];
					MReady<=1'b1;
					do_count<=1'b1;
					count_value<=4'b1;
				end
				else if(REG_M_write[`WS])begin
					mem_data[(REG_M_address[`WS]/4)] <= REG_M_data[`WS-1];
				end
			end
		end
	end
	always@(posedge clock)begin
		Reg_do_count<=do_count;
		if(do_count)begin
			if(count_value)begin
				MReadData<=mem_data[( (M_base_address+4*count_value)/4)];
				count_value<=count_value+4'b1;
			end
			else begin
				do_count<=1'b0;
			end
		end
	end
endmodule
