`define WAIT_STATE 2
`define WS `WAIT_STATE
`define IM_ADDR_OFS 32'hffff_ffc0
module im(
	clock,
	reset,
	IM_read,
	IM_write,
	IM_enable,
	IM_address,
	IM_in,
	IM_out,
	IM_ready
);
	parameter data_size=32;
	parameter mem_size=4096;
	parameter mem_size_bit=12;

	input clock;
	input reset;
	input IM_read;
	input IM_write;
	input IM_enable;
	input [mem_size_bit-1:0] IM_address;
	input [data_size-1:0] IM_in;
	output [data_size-1:0] IM_out;
	output IM_ready;

	reg [data_size-1:0] IM_out;
	reg IM_ready;

	reg [data_size-1:0] mem_data[mem_size-1:0];

	reg REG_IM_enable [`WAIT_STATE:0];
	reg REG_IM_read   [`WAIT_STATE:0];
	reg REG_IM_write  [`WAIT_STATE:0];
	reg [31:0] REG_IM_address [`WAIT_STATE:0];
	reg [31:0] REG_IM_data    [`WAIT_STATE:0];

	reg [31:0] IM_base_address;
	reg [ 3:0] count_value;
	reg do_count;
	integer i;

	always@(negedge clock)begin
		REG_IM_enable[0] <=IM_enable;
		REG_IM_read[0]   <=IM_read;
		REG_IM_write[0]  <=IM_write;
		REG_IM_address[0]<=IM_address;
		REG_IM_data[0]   <=IM_in;

		for(i=0;i<`WAIT_STATE;i=i+1) REG_IM_enable[i+1] <=REG_IM_enable[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_IM_read[i+1]   <=REG_IM_read[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_IM_write[i+1]  <=REG_IM_write[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_IM_address[i+1]<=REG_IM_address[i];
		for(i=0;i<`WAIT_STATE;i=i+1) REG_IM_data[i+1]   <=REG_IM_data[i];
	end

	always@(posedge clock)begin
		if(reset)begin
			for(i=0;i<mem_size;i=i+1)begin
				mem_data[i]<=0;
				IM_out<=0;
				IM_ready<=1'b0;
				do_count<=1'b0;
			end
		end
		else begin
			if(IM_enable&&IM_read)begin
				IM_base_address<=(IM_address&`IM_ADDR_OFS);
			end
			if(REG_IM_enable[`WS])begin
				if(REG_IM_read[`WS])begin
					IM_out<=mem_data[( IM_base_address/4)];
					IM_ready<=1'b1;
					do_count<=1'b1;
					count_value<=4'b1;
				end
				else if(REG_IM_write[`WS])begin
					mem_data[(REG_IM_address[`WS]/4)] <= REG_IM_data[`WS];
				end
			end
		end
	end
	always@(posedge clock)begin
		if(do_count)begin
			if(count_value)begin
				IM_out<=mem_data[( (IM_base_address+4*count_value)/4)];
				IM_ready<=1'b1;
				count_value<=count_value+4'b1;
			end
			else begin
				IM_ready<=1'b0;
				do_count<=1'b0;
			end
		end
	end
endmodule
