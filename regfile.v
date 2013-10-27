module regfile(
	clock,
	reset,
	mem_write_data,
	read_data1,
	read_data2,
	read_address1,
	read_address2,
	write_address,
	write_data,
	enable_reg_write,
	do_fetch,
	enable_writeback
);

	parameter DataSize = 32;
	parameter AddrSize = 5;

	output [DataSize-1:0] mem_write_data;
	output reg [DataSize-1:0] read_data1;
	output reg [DataSize-1:0] read_data2;

	input [AddrSize-1:0] read_address1;
	input [AddrSize-1:0] read_address2;
	input [AddrSize-1:0] write_address;
	input [DataSize-1:0] write_data;
	input clock;
	input reset;
	input enable_reg_write;
	input do_fetch; 
	input enable_writeback;

	reg [DataSize-1:0] rw_reg [31:0];
	integer i;

	assign mem_write_data = rw_reg[write_address];

	always @(posedge clock, posedge reset) begin
		if(reset) begin
			for(i=0;i<32;i=i+1)
				rw_reg[i]<=32'b0;
		end
		else begin
			if(do_fetch) begin
				read_data1 <= rw_reg[read_address1];	
				read_data2 <= rw_reg[read_address2];	
			end
			else if(enable_writeback && enable_reg_write) begin
				rw_reg[write_address] <= write_data;
			end
			else begin
				read_data1 <= 32'b0;
				read_data2 <= 32'b0;
			end
		end
	end
endmodule	
	
