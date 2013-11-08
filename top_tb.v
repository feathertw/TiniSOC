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
		$readmemb("mem/mins.prog",IM.mem_data);

		#(`DELAY) `DEBUG_REG("MOVI  ",1,10)
		#(`DELAY) `DEBUG_REG("MOVI  ",2,10)
		#(`DELAY) `DEBUG_REG("MOVI  ",3,30)
		#(`DELAY) `DEBUG_BXJ("BEQ   ",12,8)
		#(`DELAY) `DEBUG_REG("MOVI  ",4,40)
		#(`DELAY) `DEBUG_BXJ("BNE   ",24,8)
		#(`DELAY) `DEBUG_REG("MOVI  ",5,50)
		#(`DELAY) `DEBUG_BXJ("BEQ   ",36,4)
		#(`DELAY) `DEBUG_REG("MOVI  ",6,60)
		#(`DELAY) `DEBUG_BXJ("BNE   ",44,4)
		#(`DELAY) `DEBUG_REG("MOVI  ",7,70)
		#(`DELAY) `DEBUG_BXJ("J     ",52,8)

		#(`DELAY) `DEBUG_REG("MOVI  ",0,9)
		#(`DELAY) `DEBUG_REG("MOVI  ",1,7)
		#(`DELAY) `DEBUG_REG("MOVI  ",2,2)
		#(`DELAY) `DEBUG_REG("ADD   ",3,16)
		#(`DELAY) `DEBUG_REG("SUB   ",4,7)
		#(`DELAY) `DEBUG_REG("AND   ",0,0)
		#(`DELAY) `DEBUG_REG("OR    ",1,18)
		#(`DELAY) `DEBUG_REG("XOR   ",0,5)
		#(`DELAY) `DEBUG_REG("SRLI  ",2,2)
		#(`DELAY) `DEBUG_REG("SLLI  ",3,20)
		#(`DELAY) `DEBUG_REG("ROTRI ",4,144)
		#(`DELAY) `DEBUG_REG("ADDI  ",0,20)
		#(`DELAY) `DEBUG_REG("ORI   ",1,18)
		#(`DELAY) `DEBUG_REG("XORI  ",2,12)
		#(`DELAY) `DEBUG_SWX("SWI   ",2,4)
		#(`DELAY) `DEBUG_SWX("SW    ",1,96)
		#(`DELAY) `DEBUG_LWX("LW    ",3,96)
		#(`DELAY) `DEBUG_LWX("LWI   ",4,4)
`endif
		#10
		//for( i=0;i<3;i=i+1 ) $display( "IM[%4d]=%b",i*4,IM.mem_data[i] ); 
		//for( i=0;i<5;i=i+1 ) $display( "register[%d]=%d",i,TOP.REGFILE.rw_reg[i] );
		//for( i=0;i<8;i=i+1 ) $display( "DM[%4d]=%d",i*4,DM.mem_data[i] );
  		$display("____________________FINISH____________________\n");
		$finish;
	end
endmodule
