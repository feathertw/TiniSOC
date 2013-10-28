module regfile(
	clock,
	reset,
	enable_reg_fetch,
	enable_reg_write,

	read_reg_addr1,
	read_reg_addr2,
	write_addr,
	write_reg_data,
	do_reg_write,

	reag_reg_data1,
	read_reg_data2,
	mem_write_data,
);

	parameter DataSize = 32;
	parameter AddrSize = 5;

	input clock;
	input reset;
	input enable_reg_fetch; 
	input enable_reg_write;

	input [AddrSize-1:0] read_reg_addr1;
	input [AddrSize-1:0] read_reg_addr2;
	input [AddrSize-1:0] write_addr;
	input [DataSize-1:0] write_reg_data;
	input do_reg_write;

	output reg [DataSize-1:0] reag_reg_data1;
	output reg [DataSize-1:0] read_reg_data2;
	output [DataSize-1:0] mem_write_data;

	reg [DataSize-1:0] rw_reg [31:0];
	integer i;

	assign mem_write_data = rw_reg[write_addr];

	always @(posedge clock, posedge reset) begin
		if(reset) begin
			for(i=0;i<32;i=i+1)
				rw_reg[i]<=32'b0;
		end
		else begin
			if(enable_reg_fetch) begin
				reag_reg_data1 <= rw_reg[read_reg_addr1];	
				read_reg_data2 <= rw_reg[read_reg_addr2];	
			end
			else if(enable_reg_write && do_reg_write) begin
				rw_reg[write_addr] <= write_reg_data;
			end
			else begin
				reag_reg_data1 <= 32'b0;
				read_reg_data2 <= 32'b0;
			end
		end
	end
endmodule	
	
