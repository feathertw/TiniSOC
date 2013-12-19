module read_buffer(
	clock,
	do_buffer_flush,
	SysAck,
	SysData_out,
	buffer_data
);
	input clock;
	input do_buffer_flush;
	input SysAck;
	input [31:0] SysData_out;
	output [`BLK-1:0] buffer_data;
	reg    [`BLK-1:0] buffer_data;
	reg [3:0] counter;

	always@(negedge clock)begin
		if(do_buffer_flush)begin
			buffer_data<=`BLK'b0;
			counter<=4'b0;
		end
		else if(SysAck)begin
			buffer_data<=buffer_data|(SysData_out<<(32*counter));
			counter<=counter+1;
		end
	end
endmodule
