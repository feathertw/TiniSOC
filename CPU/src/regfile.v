`include "def_system.v"
`include "def_muxs.v"

`define SRIDX_SYSTEM_MODE	128
`define SRIDX_IRET_MODE		129
`define SRIDX_KERNEL_STACK	178
`define SRIDX_USER_STACK	186

module regfile(
	clock,
	reset,
	enable_reg_fetch,
	enable_reg_write,

	reg_ra_addr,
	reg_rb_addr,
	reg_rt_addr,
	write_reg_addr,
	write_reg_data,
	write_ra_addr,
	write_ra_data,
	do_reg_write,
	do_ra_write,

	sub_op_sridx,
	select_misc,
	do_misc,
	xREG4_select_misc,
	xREG4_do_misc,
	xREG4_sub_op_sridx,
	do_kernel_mode,
	do_user_mode,

	do_hazard,
	reg_ra_data,
	reg_rb_data,
	reg_rt_data,
	system_reg,
	iret_mode
);

	parameter DataSize = 32;
	parameter AddrSize = 5;

	input clock;
	input reset;
	input enable_reg_fetch; 
	input enable_reg_write;

	input [AddrSize-1:0] reg_ra_addr;
	input [AddrSize-1:0] reg_rb_addr;
	input [AddrSize-1:0] reg_rt_addr;
	input [AddrSize-1:0] write_reg_addr;
	input [DataSize-1:0] write_reg_data;
	input [AddrSize-1:0] write_ra_addr;
	input [DataSize-1:0] write_ra_data;
	input do_reg_write;
	input do_ra_write;

	input [9:0] sub_op_sridx;
	input [1:0] select_misc;
	input do_misc;
	input [1:0] xREG4_select_misc;
	input xREG4_do_misc;
	input [9:0] xREG4_sub_op_sridx;
	input do_kernel_mode;
	input do_user_mode;

	output do_hazard;
	output [DataSize-1:0] reg_ra_data;
	output [DataSize-1:0] reg_rb_data;
	output [DataSize-1:0] reg_rt_data;
	output [DataSize-1:0] system_reg;
	output iret_mode;

	reg [DataSize-1:0] reg_rt_data;
	reg [DataSize-1:0] reg_ra_data;
	reg [DataSize-1:0] reg_rb_data;
	reg [DataSize-1:0] system_reg;

	reg [DataSize-1:0] rw_reg [31:0];
	reg [DataSize-1:0] rw_r31_banked;
	reg system_mode;
	reg iret_mode;

	integer i;

	always @(posedge clock or posedge reset) begin
		if(reset) begin
			for(i=0;i<32;i=i+1) rw_reg[i]<=32'b0;
			rw_r31_banked	    	     <=32'b0;
			system_mode		     <= 1'b0;
			iret_mode		     <= 1'b0;
		end
		else begin
			if(enable_reg_fetch) begin
				reg_rt_data <= rw_reg[reg_rt_addr];
				reg_ra_data <= rw_reg[reg_ra_addr];
				reg_rb_data <= rw_reg[reg_rb_addr];
			end
			if(enable_reg_write && do_reg_write) begin
				rw_reg[write_reg_addr] <= write_reg_data;
			end
			if(enable_reg_write && do_ra_write) begin
				rw_reg[write_ra_addr] <= write_ra_data;
			end
			if(do_misc)begin
				if(select_misc==`MISC_MFSR)begin
					case(sub_op_sridx)
						`SRIDX_SYSTEM_MODE:begin
							system_reg <= system_mode;
						end
						`SRIDX_IRET_MODE:begin
							system_reg <= iret_mode;
						end
						`SRIDX_KERNEL_STACK:begin
							if(system_mode==`SYSTEM_MODE_KERNEL) system_reg <=rw_reg[31];
							else				     system_reg <=rw_r31_banked;
						end
						`SRIDX_USER_STACK:begin
							if(system_mode==`SYSTEM_MODE_USER) system_reg <=rw_reg[31];
							else				   system_reg <=rw_r31_banked;
						end
					endcase
				end
			end
			if(do_kernel_mode||do_user_mode)begin
				iret_mode   <= system_mode;
				if(do_kernel_mode) 	system_mode <= `SYSTEM_MODE_KERNEL;
				else if(do_user_mode)   system_mode <= `SYSTEM_MODE_USER;
				if( (do_kernel_mode&&system_mode!=`SYSTEM_MODE_KERNEL)
				  ||(do_user_mode  &&system_mode!=`SYSTEM_MODE_USER))begin
					rw_reg[31]    <= rw_r31_banked;
					rw_r31_banked <= rw_reg[31];
				end
			end
			else if(xREG4_do_misc)begin
				if(xREG4_select_misc==`MISC_MTSR)begin
					case(xREG4_sub_op_sridx)
						`SRIDX_SYSTEM_MODE:begin
							system_mode <= write_reg_data[0];
							if(system_mode!=write_reg_data[0])begin
								rw_reg[31]    <= rw_r31_banked;
								rw_r31_banked <= rw_reg[31];
							end
						end
						`SRIDX_IRET_MODE:begin
							iret_mode <= write_reg_data[0];
						end
					endcase
				end
			end
		end
	end

	reg work;
	reg [1:0] count;
	assign do_hazard = (count>0)? 1:0;
	always @(posedge clock) begin
		if(reset)begin
			work  <= 'b0;
			count <= 'h0;
		end
		else if(work&&count>'d0)begin
			count <= count -'h1;
			if(count=='h1) work <= 1'b0;
		end
		else if(do_misc)begin
			if(select_misc==`MISC_MTSR)begin
				work <= 1'b1;
				count <=2'h3;
			end
		end
	end
endmodule	
	
