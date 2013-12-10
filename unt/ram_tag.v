module ram_tag(
	clock,
	index,
	tag_in,
	tag_match,
	write
);
	input clock;
	input [`IDX-1:0] index;
	input [`TAG-1:0] tag_in;
	output tag_match;
	input write;

	reg tag_match;
	reg [`TAG-1:0] tag_ram [`DEP-1:0];

	always@(negedge clock)begin
		if(write) tag_ram[index]<=tag_in;
	end
	always@(posedge clock)begin
		tag_match<=(tag_ram[index]==tag_in);
	end
endmodule
