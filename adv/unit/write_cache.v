module write_cache(
	clock,
	offset,
	pro_data,
	cache_data,
	write_data
);
	input  clock;
	input  [`OFS-1:0] offset;
	input  [31:0] pro_data;
	input  [`BLK-1:0] cache_data;
	output [`BLK-1:0] write_data;

	reg [`BLK-1:0] write_data;
	reg [`BLK-1:0] data;

	always@(negedge clock)begin
		write_data<=data;
	end

	always@(*)begin
		data=(32'hFFFF_FFFF)<<(32*offset);
		data=~data;
		data=data&cache_data;
		data=data|(pro_data<<(32*offset));
	end
endmodule
