module dm(
	clock,
	reset,
	DM_read,
	DM_write,
	DM_enable,
	DM_address,
	DM_in,
	DM_out,
	DM_ready
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
	input [data_size-1:0] DM_in;
	output [data_size-1:0] DM_out;
	output DM_ready;

	reg [data_size-1:0] DM_out;
	reg DM_ready;

	reg [data_size-1:0] mem_data[mem_size-1:0];

	reg REG_DM_enable [1:0];
	reg REG_DM_read   [1:0];
	reg REG_DM_write  [1:0];
	reg [31:0] REG_DM_address [1:0];
	reg [31:0] REG_DM_data    [1:0];
	integer i;

	always@(posedge clock)begin
		if(reset)begin
			for(i=0;i<mem_size;i=i+1)begin
				mem_data[i]<=0;
				DM_out<=0;
				DM_ready<=1'b1;
			end
		end
		else begin
			REG_DM_enable[0] <=DM_enable;
			REG_DM_read[0]   <=DM_read;
			REG_DM_write[0]  <=DM_write;
			REG_DM_address[0]<=DM_address;
			REG_DM_data[0]   <=DM_in;

			REG_DM_enable[1] <=REG_DM_enable[0];
			REG_DM_read[1]   <=REG_DM_read[0];
			REG_DM_write[1]  <=REG_DM_write[0];
			REG_DM_address[1]<=REG_DM_address[0];
			REG_DM_data[1]   <=REG_DM_data[0];

			if(DM_enable&&DM_read)begin
				DM_ready<=1'b0;
			end
			if(REG_DM_enable[1])begin
				if(REG_DM_read[1])begin
					DM_out<=mem_data[(REG_DM_address[1]/4)];
					DM_ready<=1'b1;
				end
				else if(REG_DM_write[1])begin
					mem_data[(REG_DM_address[1]/4)] <= DM_in;
				end
			end
		end
	end
endmodule
