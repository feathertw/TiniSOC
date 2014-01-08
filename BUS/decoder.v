module decoder(
	HRESETn,
	HADDR,
	HSEL_Default,
	HSEL_S1,
	HSEL_S2,
	HSEL_S3
);
	input  HRESETn;
	input  [31:0] HADDR;
	output HSEL_Default;
	output HSEL_S1;
	output HSEL_S2;
	output HSEL_S3;

	wire HSEL_Default=( (!HRESETn)|( (!HSEL_S1)&&(!HSEL_S2)&&(!HSEL_S3) ))? 1'b1:1'b0;
	wire HSEL_S1=( (32'h0000_0000<=HADDR)&&(HADDR<32'h0004_0000) )? 1'b1:1'b0;
	wire HSEL_S2=( (32'h0010_0000<=HADDR)&&(HADDR<32'h0014_0000) )? 1'b1:1'b0;
	wire HSEL_S3=( (32'h0200_0000<=HADDR)&&(HADDR<32'h1000_0000) )? 1'b1:1'b0;
endmodule
