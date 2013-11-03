`timescale 1ns/10ps
`include "debug.v"
`include "top.v"
`include "im.v"
`include "dm.v"

`define DELAY 60

module top_tb;

	reg clk;
	reg rst;
	wire alu_overflow;

	wire IM_read; 
	wire IM_write; 
	wire IM_enable;
	wire [9:0] IM_address;
	wire [9:0] xIM_address;
	wire [31:0] IM_out;

	wire DM_read;
	wire DM_write;
	wire DM_enable;
	wire [11:0] DM_address;
	wire [11:0] xDM_address;
	wire [31:0] DM_in;
	wire [31:0] DM_out;

	assign xIM_address=IM_address/4;
	assign xDM_address=DM_address/4;

	integer i;

	top TOP(
		.clk(clk),
		.rst(rst),
		.instruction(IM_out),
		.alu_overflow(alu_overflow),

		.IM_read(IM_read),
	        .IM_write(IM_write),
	        .IM_enable(IM_enable),
	        .IM_address(IM_address),

		.DM_read(DM_read),
	        .DM_write(DM_write),
	        .DM_enable(DM_enable),
		.DM_address(DM_address),
		.DM_in(DM_in),
		.DM_out(DM_out)
	); 
 
	im IM(
		.clock(clk),
		.reset(rst),
		.IM_read(IM_read),
		.IM_write(IM_write),
		.IM_enable(IM_enable),
		.IM_address(xIM_address),
		.IMin(),
		.IMout(IM_out)
	); 
	dm DM(
		.clock(clk),
		.reset(rst),
		.DM_read(DM_read),
		.DM_write(DM_write),
		.DM_enable(DM_enable),
		.DM_address(xDM_address),
		.DMin(DM_in),
		.DMout(DM_out)
	); 
  
	initial begin
		$dumpfile("wave/top.vcd");
		$dumpvars;
  		$fsdbDumpfile("wave/top.fsdb");
  		$fsdbDumpvars();
	end

	//clock gen.
	always #5 clk=~clk;
  
	initial begin
  		$display("\n____________________TESTBENCH____________________");
		clk=0;
		rst=1'b1;
		#10 rst=1'b0;

`ifdef PROG
		$display("PROG\n");
		$readmemb("mins/mins.prog",IM.mem_data); //machine code for fig.2-2
		#(`DELAY) `DEBUG_REG("MOVI  ",0,3)
		#(`DELAY) `DEBUG_SWX("SWI   ",0,12)
		#(`DELAY) `DEBUG_LWX("LWI   ",1,12)
		#(`DELAY) `DEBUG_BXJ("BEQ   ",12,8)
		#(`DELAY*100)
`endif
`ifdef PROG1
		$display("PROG1\n");
		$readmemb("mins/mins1.prog",IM.mem_data); //machine code for fig.2-2
		#(`DELAY*0) `DEBUG_REG("MOVI  ",0,0)
		#(`DELAY*6) `DEBUG_MEM("A:    ",8,170)
		#(`DELAY*2) `DEBUG_MEM("B:    ",12,240)
		#(`DELAY*2) `DEBUG_MEM("C:    ",16,15)
		#(`DELAY*2) `DEBUG_MEM("D:    ",20,85)
		#(`DELAY*4) `DEBUG_MEM("E:    ",24,160)
		#(`DELAY*4) `DEBUG_MEM("E:    ",24,175)
		#(`DELAY*4) `DEBUG_MEM("E:    ",24,250)
`endif
`ifdef PROG2
		$display("PROG2\n");
		$readmemb("mins/mins2.prog",IM.mem_data); //machine code for fig.2-2
		#(`DELAY*0) `DEBUG_REG("MOVI  ",0,0)
		#(`DELAY*6) `DEBUG_MEM("L:    ",8,250)
		#(`DELAY*2) `DEBUG_MEM("M:    ",12,184)
		#(`DELAY*2) `DEBUG_MEM("N:    ",16,311)
		#(`DELAY*3) `DEBUG_MEM("X:    ",20,7)
		#(`DELAY*3) `DEBUG_MEM("Y:    ",24,1472)
		#(`DELAY*4) `DEBUG_MEM("Z:    ",28,1479)
		#(`DELAY*4) `DEBUG_MEM("Z:    ",28,1527)
`endif
		#10
		//for( i=0;i<3;i=i+1 ) $display( "IM[%4d]=%b",i*4,IM.mem_data[i] ); 
		for( i=0;i<5;i=i+1 ) $display( "register[%d]=%d",i,TOP.REGFILE.rw_reg[i] );
		for( i=0;i<8;i=i+1 ) $display( "DM[%4d]=%d",i*4,DM.mem_data[i] );
  		$display("____________________FINISH____________________\n");
		$finish;
	end
endmodule
