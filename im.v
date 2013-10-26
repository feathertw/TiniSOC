module im(
	clock,
	reset,
	IM_address,
	IM_read,
	IM_write,
	IM_enable,
	IMin,
	IMout
);
	parameter data_size=32;
	parameter mem_size=1024;
	parameter mem_size_bit=10;

	input clock;
	input reset;
	input IM_read;
	input IM_write;
	input IM_enable;
	input [mem_size_bit-1:0] IM_address;
	input [data_size-1:0] IMin;

	output reg [data_size-1:0] IMout;

	reg [data_size-1:0] mem_data[mem_size-1:0];

	integer i;

	always@(posedge clock)begin
		if(reset)begin
			for(i=0;i<mem_size;i=i+1)begin
				mem_data[i]<=0;
				IMout<=0;
			end
		end
		else if(IM_enable)begin
			if(IM_read)begin
				IMout<=mem_data[IM_address];
			end
			else if(IM_write)begin
				mem_data[IM_address] <= IMin;
			end
		end
	end
endmodule
