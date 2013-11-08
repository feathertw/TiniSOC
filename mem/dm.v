module dm(
	clock,
	reset,
	DM_read,
	DM_write,
	DM_enable,
	DM_address,
	DMin,
	DMout
);
	parameter data_size=32;
	parameter mem_size=4096;
	parameter mem_size_bit=12;

	input clock;
	input reset;
	input DM_read;
	input DM_write;
	input DM_enable;
	input [mem_size_bit-1:0] DM_address;
	input [data_size-1:0] DMin;
	output [data_size-1:0] DMout;

	reg [data_size-1:0] DMout;

	reg [data_size-1:0] mem_data[mem_size-1:0];

	integer i;

	always@(posedge clock)begin
		if(reset)begin
			for(i=0;i<mem_size;i=i+1)begin
				mem_data[i]<=0;
				DMout<=0;
			end
		end
		else if(DM_enable)begin
			if(DM_read)begin
				DMout<=mem_data[(DM_address/4)];
			end
			else if(DM_write)begin
				mem_data[(DM_address/4)] <= DMin;
			end
		end
	end
endmodule
