module ram_valid(
	clock,
	reset,
	index,
	valid_in,
	valid_out,
	do_write
);
	input  clock;
	input  reset;
	input  [`IDX-1:0] index;
	input  valid_in;
	output valid_out;
	input  do_write;

	reg valid_out;
	reg valid_bit [`DEP-1:0];
	integer i;
	
	always@(negedge clock)begin
		if(reset)begin
			for(i=0;i<`DEP;i=i+1) valid_bit[i]<=1'b0;
		end
		else if(do_write)begin
			valid_bit[index]<=valid_in;
		end
	end
	always@(posedge clock)begin
		valid_out<=valid_bit[index];
	end

endmodule
