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
	target_pc,
	do_branch,
	sub_op_j,
	do_flush_REG1,
	hit_addr,
	hit_target,
	hit_branch,
	hit_link,
	hit
);
	input  clock;
	input  reset;
	input  enable_ram;
	input  do_write;
	input  [31:0] current_pc;
	input  [31:0] target_pc;
	input  do_branch;
	input  sub_op_j;
	input  do_flush_REG1;

	output [31:0] hit_addr;
	output [31:0] hit_target;
	output hit_branch;
	output hit_link;
	output hit;
	reg    [31:0] hit_addr;
	reg    [31:0] hit_target;
	reg    hit_branch;
	reg    hit_link;
	reg    hit;

	reg [31:0] ram_addr   [3:0];
	reg [31:0] ram_target [3:0];
	reg ram_link  [3:0];
	reg ram_valid [3:0];
	reg [ 1:0] ram_state  [3:0];
	reg [ 1:0] ram_pri    [3:0];

	reg [ 1:0] next_state;
	reg [ 1:0] hit_num;

	reg _hit_branch;
	reg [ 1:0] _hit_num;
	reg _hit;

	reg xdo_flush_REG1;
	reg [ 1:0] xhit_num;
	reg xhit;

	reg [ 2:0] i;

	parameter STATE_MBRANCH	   =2'b00;
	parameter STATE_SBRANCH	   =2'b01;
	parameter STATE_SNONBRANCH =2'b10;
	parameter STATE_MNONBRANCH =2'b11;

	always@(negedge clock)begin
		if(reset)begin
			for(i=0;i<4;i=i+1) ram_valid[i]<=1'b0;
			ram_pri[0]<=2'd0;
			ram_pri[1]<=2'd1;
			ram_pri[2]<=2'd2;
			ram_pri[3]<=2'd3;
			xdo_flush_REG1<=1'b0;
		end
		else if(enable_ram)begin
			if(do_write)begin
				ram_addr[`PRI3]  <=current_pc-4;
				ram_target[`PRI3]<=target_pc;
				ram_link[`PRI3]  <=sub_op_j;
				ram_valid[`PRI3] <=1'b1;
				if(do_branch) ram_state[`PRI3]<=STATE_SBRANCH;
				else	      ram_state[`PRI3]<=STATE_SNONBRANCH;
				ram_pri[0]<=ram_pri[3];
				ram_pri[1]<=ram_pri[0];
				ram_pri[2]<=ram_pri[1];
				ram_pri[3]<=ram_pri[2];
			end
			if( (hit)&&(!do_flush_REG1))begin
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
			if( (xhit)&&(!xdo_flush_REG1) )begin
				ram_state[xhit_num]<=next_state;
			end
			xdo_flush_REG1<=do_flush_REG1;
		end
	end
	always@(posedge clock)begin
		if(reset)begin
			hit_addr  <=32'b0;
			hit_target<=32'b0;
			hit_branch<= 1'b0;
			hit_link  <= 1'b0;
			hit_num   <= 2'b0;
			hit	  <= 1'b0;
			xhit_num  <= 2'b0;
			xhit      <= 1'b0;
		end
		else if(enable_ram)begin
			hit_addr  <=ram_addr[_hit_num];
			hit_target<=ram_target[_hit_num];
			hit_branch<=_hit_branch;
			hit_link  <=ram_link[_hit_num];
			hit_num   <=_hit_num;
			hit	  <=_hit;
			xhit_num  <=hit_num;
			xhit      <=hit;
		end
	end
	always@(*)begin
		_hit=1'b0;
		_hit_num=2'dx;
		_hit_branch=1'bx;
		if(ram_addr[0]==current_pc&&ram_valid[0]) begin _hit=1'b1; _hit_num=2'd0; end
		if(ram_addr[1]==current_pc&&ram_valid[1]) begin _hit=1'b1; _hit_num=2'd1; end
		if(ram_addr[2]==current_pc&&ram_valid[2]) begin _hit=1'b1; _hit_num=2'd2; end
		if(ram_addr[3]==current_pc&&ram_valid[3]) begin _hit=1'b1; _hit_num=2'd3; end
		if(_hit)begin
			if(     ram_state[_hit_num]==STATE_MBRANCH) _hit_branch=1'b1;
			else if(ram_state[_hit_num]==STATE_SBRANCH) _hit_branch=1'b1;
			else 					    _hit_branch=1'b0;
		end
	end
	always@(*)begin
		case(ram_state[xhit_num])
			STATE_MBRANCH:   if(do_branch) next_state=STATE_MBRANCH;    else next_state=STATE_SBRANCH;
			STATE_SBRANCH:   if(do_branch) next_state=STATE_MBRANCH;    else next_state=STATE_SNONBRANCH;
			STATE_SNONBRANCH:if(do_branch) next_state=STATE_SBRANCH;    else next_state=STATE_MNONBRANCH;
			STATE_MNONBRANCH:if(do_branch) next_state=STATE_SNONBRANCH; else next_state=STATE_MNONBRANCH;
			default: next_state=STATE_SBRANCH;
		endcase
	end
endmodule
