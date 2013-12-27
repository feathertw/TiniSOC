module counter(
	clock,
	flush,
	signal,
	value,
	readup
);
	input clock;
	input flush;
	input signal;
	output [`OFS-1:0] value;
	reg    [`OFS-1:0] value;
	output readup;
	reg    readup;

	always@(negedge clock)begin
		if(flush)begin
			value<=`OFS'b0;
		end
		else if(signal)begin
			value<=value+1;
		end
	end
	always@(posedge clock)begin
		if(value==4'b1111) readup<=1'b1;
		else		   readup<=1'b0;
	end
endmodule
