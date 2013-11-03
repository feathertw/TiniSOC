module pc(
	clock,
	reset,
	enable_pc,
	pc_in,
	pc_out,
);
	input clock;
	input reset;
	input enable_pc;
	input [9:0] pc_in;
	output reg [9:0] pc_out;

	always@(posedge clock) begin
		if(reset) 	   pc_out<=0;
		else if(enable_pc) pc_out<=pc_in;
	end
endmodule
