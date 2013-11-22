`timescale 1ns/10ps
`include "mem/im.v"
`include "mem/dm.v"

`include "def/def_debug.v"
`include "top.v"

`define DELAY 50

module top_tb;

	reg clk;
	reg rst;
	wire alu_overflow;

	wire IM_read; 
	wire IM_write; 
	wire IM_enable;
	wire [9:0] IM_address;
	wire [31:0] IM_out;

	wire DM_read;
	wire DM_write;
	wire DM_enable;
	wire [11:0] DM_address;
	wire [31:0] DM_in;
	wire [31:0] DM_out;

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
		.IM_address(IM_address),
		.IMin(),
		.IMout(IM_out)
	); 
	dm DM(
		.clock(clk),
		.reset(rst),
		.DM_read(DM_read),
		.DM_write(DM_write),
		.DM_enable(DM_enable),
		.DM_address(DM_address),
		.DMin(DM_in),
		.DMout(DM_out)
	); 
  
	initial begin
		$dumpfile("wave/top.vcd");
		$dumpvars;
		//$fsdbDumpfile("wave/top.fsdb");
		//$fsdbDumpvars();
	end

	//clock gen.
	always #5 clk=~clk;
  
	initial begin
  		$display("\n____________________TESTBENCH____________________");
		clk=0;
		rst=1'b1;
		#12 rst=1'b0;

`ifdef PROG
		$readmemb("mem/mins.prog",IM.mem_data);
		$readmemb("mem/mdat.prog",DM.mem_data);

		$display("\n\nPROG\n");
		#(`DELAY) `DEBUG_LWX("LWI   ",0,0)
		#(`DELAY) `DEBUG_REG("ADDI  ",0,1<<31)		`DEBUG_OVE(1)
		#(`DELAY) `DEBUG_LWX("LWI   ",0,4)
		#(`DELAY) `DEBUG_REG("ADDI  ",0,(1<<31)-1)	`DEBUG_OVE(1)
		#(`DELAY) `DEBUG_BXJ("J     ",16,12)
		#(`DELAY) `DEBUG_REG("MOVI  ",0,20)
		#(`DELAY) `DEBUG_BXJ("J     ",32,-12)
		#(`DELAY) `DEBUG_REG("ADDI  ",1,10)
		#(`DELAY) `DEBUG_BXJ("J     ",24,12)
		#(`DELAY) `DEBUG_BXJ("BNE   ",36,-16)
		#(`DELAY) `DEBUG_REG("ADDI  ",1,20)
		#(`DELAY) `DEBUG_BXJ("J     ",24,12)
		#(`DELAY) `DEBUG_BXJ("BNE   ",36,4)
		#(`DELAY) `DEBUG_BXJ("BEQ   ",40,4)
		#(`DELAY) `DEBUG_REG("SUB   ",0,0)
		#(`DELAY) `DEBUG_BXJ("J     ",48,-8)
		#(`DELAY) `DEBUG_BXJ("BEQ   ",40,12)
		#(`DELAY) `DEBUG_LWX("LWI   ",0,0)
		#(`DELAY) `DEBUG_REG("MOVI  ",1,1)
		#(`DELAY) `DEBUG_REG("ADD   ",0,1<<31)		`DEBUG_OVE(1)
		#(`DELAY) `DEBUG_LWX("LWI   ",0,4)
		#(`DELAY) `DEBUG_REG("SUB   ",0,(1<<31)-1)	`DEBUG_OVE(1)
		#(`DELAY) `DEBUG_REG("MOVI  ",0,10)
		#(`DELAY) `DEBUG_REG("MOVI  ",1,-3)
		#(`DELAY) `DEBUG_REG("ADD   ",0,7)
		#(`DELAY) `DEBUG_REG("SUB   ",0,10)
		#(`DELAY)
		#(`DELAY) `DEBUG_REG("MOVI  ",1,10)
		#(`DELAY) `DEBUG_REG("MOVI  ",2,12)
		#(`DELAY) `DEBUG_REG("AND   ",0,8)
		#(`DELAY) `DEBUG_REG("OR    ",0,14)
		#(`DELAY) `DEBUG_REG("XOR   ",0,6)
		#(`DELAY) `DEBUG_REG("SRLI  ",0,2)
		#(`DELAY) `DEBUG_REG("SLLI  ",0,1<<31)
		#(`DELAY) `DEBUG_REG("ROTRI ",0,(1<<31)+2)
		#(`DELAY) `DEBUG_REG("ORI   ",0,14)
		#(`DELAY) `DEBUG_REG("XORI  ",0,6)
		#(`DELAY) `DEBUG_REG("MOVI  ",0,11)
		#(`DELAY) `DEBUG_REG("MOVI  ",2,8)
		#(`DELAY) `DEBUG_SWX("SWI   ",0,4)
		#(`DELAY) `DEBUG_LWX("LWI   ",1,4)
		#(`DELAY) `DEBUG_REG("MOVI  ",0,22)
		#(`DELAY) `DEBUG_REG("MOVI  ",2,4)
		#(`DELAY) `DEBUG_SWX("SW    ",0,36)
		#(`DELAY) `DEBUG_LWX("LW    ",1,36)
`endif
`ifdef PROG1
		$readmemb("mem/mins1.prog",IM.mem_data);
		//$readmemb("mem/mdat.prog",DM.mem_data);

		$display("\n\nPROG1\n");
		#40
		//#(`DELAY)
		#60
`endif
		#10
		for( i=0;i<3;i=i+1 ) $display( "IM[%4d]=%b",i*4,IM.mem_data[i] );
		for( i=0;i<9;i=i+1 ) $display( "register[%d]=%d",i,TOP.REGFILE.rw_reg[i] );
		//for( i=0;i<8;i=i+1 ) $display( "DM[%4d]=%d",i*4,DM.mem_data[i] );
  		$display("____________________FINISH____________________\n");
		$finish;
	end
endmodule
