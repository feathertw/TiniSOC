module offset(
	offset_in,
	offset_out,
	offset
);
	input  [`BLK-1:0] offset_in;
	output [`WOR-1:0] offset_out; 
	input  [`OFS-1:0] offset;

	wire [`WOR-1:0] offset_out=(offset_in>>(`WOR*offset))&32'hffff_ffff;
endmodule
