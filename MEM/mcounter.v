module mcounter(
	clock,
	flush,
	signal,
	value,
	readup
);
	input clock;
	input flush;
	input signal;
	output [3:0] value;
	reg    [3:0] value;
	output readup;
	reg    readup;
	always@(posedge clock)begin
		if(flush)begin
			value<=4'b1;
			readup<=1'b0;
		end
		else if(signal)begin
			if(value==4'b1111)begin
				readup<=1'b1;
			end
			else begin
				readup<=1'b0;
				value<=value+1;
			end
		end
	end
endmodule
