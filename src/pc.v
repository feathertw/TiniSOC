module pc(
	clock,
	reset,
	enable_pc,
	next_pc,
	current_pc
);
	input clock;
	input reset;
	input enable_pc;
	input [9:0] next_pc;
	output reg [9:0] current_pc;

	always@(posedge clock) begin
		if(reset) 	   current_pc<=0;
		else if(enable_pc) current_pc<=next_pc;
	end
endmodule
