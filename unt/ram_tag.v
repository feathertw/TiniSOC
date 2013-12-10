module ram_tag(
	clock,
	index,
	tag_in,
	tag_hit,
	write
);
	input clock;
	input [`IDX-1:0] index;
	input [`TAG-1:0] tag_in;
	output tag_hit;
	input write;

	reg tag_hit;
	reg [`TAG-1:0] tag_ram [`DEP-1:0];

	always@(negedge clock)begin
		if(write) tag_ram[index]<=tag_in;
	end
	always@(posedge clock)begin
		tag_hit<=(tag_ram[index]==tag_in);
	end
endmodule
