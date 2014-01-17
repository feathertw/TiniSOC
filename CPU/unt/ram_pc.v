`define PRI3 ram_pri[3]
`define PRI2 ram_pri[2]
`define PRI1 ram_pri[1]
`define PRI0 ram_pri[0]
module ram_pc(
	clock,
	reset,
	enable_ram,
	do_write,
	current_pc,
	next_pc,
	sub_op_j,
	hit_target,
	hit_link,
	hit
);
	input  clock;
	input  reset;
	input  enable_ram;
	input  do_write;
	input  [31:0] current_pc;
	input  [31:0] next_pc;
	input  sub_op_j;

	output [31:0] hit_target;
	output hit_link;
	output hit;
	reg    [31:0] hit_target;
	reg    hit_link;
	reg    hit;

	reg [31:0] ram_addr   [3:0];
	reg [31:0] ram_target [3:0];
	reg ram_link  [3:0];
	reg ram_valid [3:0];
	reg [ 1:0] ram_pri    [3:0];

	reg [ 1:0] hit_num;

	reg [ 1:0] _hit_num;
	reg _hit;

	reg [ 2:0] i;

	always@(negedge clock)begin
		if(reset)begin
			for(i=0;i<4;i=i+1) ram_valid[i]<=1'b0;
			ram_pri[0]<=2'd0;
			ram_pri[1]<=2'd1;
			ram_pri[2]<=2'd2;
			ram_pri[3]<=2'd3;
		end
		else begin
			if(do_write&&enable_ram)begin
				ram_addr[`PRI3]  <=current_pc-4;
				ram_target[`PRI3]<=next_pc;
				ram_link[`PRI3]  <=sub_op_j;
				ram_valid[`PRI3] <=1'b1;
				ram_pri[0]<=ram_pri[3];
				ram_pri[1]<=ram_pri[0];
				ram_pri[2]<=ram_pri[1];
				ram_pri[3]<=ram_pri[2];
			end
			if(hit&&enable_ram)begin
				if(hit_num==`PRI3)begin
					ram_pri[0]<=ram_pri[3];
					ram_pri[1]<=ram_pri[0];
					ram_pri[2]<=ram_pri[1];
					ram_pri[3]<=ram_pri[2];
				end
				if(hit_num==`PRI2)begin
					ram_pri[0]<=ram_pri[2];
					ram_pri[1]<=ram_pri[0];
					ram_pri[2]<=ram_pri[1];
				end
				if(hit_num==`PRI1)begin
					ram_pri[0]<=ram_pri[1];
					ram_pri[1]<=ram_pri[0];
				end
				if(hit_num==`PRI0)begin
				end
			end
		end
	end
	always@(posedge clock)begin
		if(reset)begin
			hit_num   <= 2'b0;
			hit_target<=32'b0;
			hit_link  <= 1'b0;
			hit	  <= 1'b0;
		end
		else begin
			hit_num   <=_hit_num;
			hit_target<=ram_target[_hit_num];
			hit_link  <=ram_link[_hit_num];
			hit	  <=_hit;
		end
	end
	always@(*)begin
		_hit=1'b0;
		_hit_num=2'dx;
		if(ram_addr[0]==current_pc&&ram_valid[0]) begin _hit=1'b1; _hit_num=2'd0; end
		if(ram_addr[1]==current_pc&&ram_valid[1]) begin _hit=1'b1; _hit_num=2'd1; end
		if(ram_addr[2]==current_pc&&ram_valid[2]) begin _hit=1'b1; _hit_num=2'd2; end
		if(ram_addr[3]==current_pc&&ram_valid[3]) begin _hit=1'b1; _hit_num=2'd3; end
	end
endmodule
