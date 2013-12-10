module mux2to1.v(S,A,B,Z);
	input  S;
	input  [31:0] A;
	input  [31:0] B;
	output [31:0] Z;
	wire   [31:0] Z=S?A:B;
endmodule
