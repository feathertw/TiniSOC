module wait_state_ctr(
	clock,
	load,
	load_value,
	carry
);
	input clock;
	input load;
	input [1:0] load_value;
	output carry;

	reg [1:0] count;
	
	wire carry = (count==2'b0);
	always@(posedge clock)begin
		if(load) count<=load_value;
		else	 count<=count-2'b1;
	end

endmodule
