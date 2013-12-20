module counter(
	clock,
	flush,
	signal,
	value
);
	input clock;
	input flush;
	input signal;
	output [`OFS-1:0] value;
	reg    [`OFS-1:0] value;

	always@(negedge clock)begin
		if(flush)begin
			value<=`OFS'b0;
		end
		else if(signal)begin
			value<=value+1;
		end
	end
endmodule
