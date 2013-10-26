module pc(
	clock,
	reset,
	enable_pc,
	pc,
);
	input clock;
	input reset;
	input enable_pc;
	output reg [9:0] pc;

	always@(posedge clock) begin
		if(reset) 	   pc<=0;
		else if(enable_pc) pc<=pc+4;
	end
endmodule
