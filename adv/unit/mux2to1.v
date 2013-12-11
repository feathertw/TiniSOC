module mux2to1(s,in0,in1,out);
	input  s;
	input  [31:0] in0;
	input  [31:0] in1;
	output [31:0] out;
	wire   [31:0] out=(s)?in1:in0;
endmodule
