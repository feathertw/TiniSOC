`timescale 1ns/10ps
`include "debug.v"
`include "top.v"
`include "im.v"
`include "dm.v"

`define PROG1
//`define PROG2
//`define PROG3

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

`ifdef PROG1
		$readmemb("mins/mins1.prog",IM.mem_data); //machine code for fig.2-2
		#50 `DEBUG_REG("ADDI  ",1,9)
		#50 `DEBUG_REG("XORI  ",1,3)
		#50 `DEBUG_REG("MOVI  ",0,3)
		#50 `DEBUG_SWX("SW    ",0,0)
		#50 `DEBUG_REG("ORI   ",0,7)
		#50 `DEBUG_REG("AND   ",1,3)
		#50 `DEBUG_LWX("LW    ",0,0)
		#50
		#50 `DEBUG_REG("ADD   ",1,6)
		#50 `DEBUG_REG("OR    ",1,7)
		#50 `DEBUG_REG("SUB   ",1,4)
		#50 `DEBUG_SWX("SWI   ",1,76)
		#50 `DEBUG_REG("SRLI  ",2,1)
		#50 `DEBUG_REG("SLLI  ",2,8)
		#50 `DEBUG_LWX("LWI   ",1,92)
		#50 `DEBUG_REG("AND   ",1,0)
		#50 `DEBUG_SWX("SWI   ",2,140)
		#50 `DEBUG_LWX("LWI   ",3,140)
		#50 `DEBUG_REG("SUB   ",3,5)
		#50 `DEBUG_REG("XOR   ",1,13)
		#50 `DEBUG_REG("ROTRI ",2,12)
`endif
`ifdef PROG2
		$readmemb("mins/mins2.prog",IM.mem_data);
		#50 `DEBUG_REG("MOVI  ",0,9)
		#50 `DEBUG_REG("MOVI  ",1,7)
		#50 `DEBUG_REG("MOVI  ",2,2)
		#50 `DEBUG_REG("ADD   ",3,16)
		#50 `DEBUG_REG("SUB   ",4,7)
		#50 `DEBUG_REG("AND   ",0,0)
		#50 `DEBUG_REG("OR    ",1,18)
		#50 `DEBUG_REG("XOR   ",0,5)
		#50 `DEBUG_REG("SRLI  ",2,2)
		#50 `DEBUG_REG("SLLI  ",3,20)
		#50 `DEBUG_REG("ROTRI ",4,144)
		#50 `DEBUG_REG("ADDI  ",0,20)
		#50 `DEBUG_REG("ORI   ",1,18)
		#50 `DEBUG_REG("XORI  ",2,12)
		#50 `DEBUG_SWX("SWI   ",2,4)
		#50 `DEBUG_SWX("SW    ",1,96)
		#50 `DEBUG_LWX("LW    ",3,96)
		#50 `DEBUG_LWX("LWI   ",4,4)
`endif
`ifdef PROG3
		$readmemb("mins/mins3.prog",IM.mem_data);
		#50 `DEBUG_REG("MOVI  ",0,10)
		#50 `DEBUG_REG("ADDI  ",1,21)
		#50 `DEBUG_REG("ADDI  ",2,15)
		#50 `DEBUG_REG("ORI   ",3,15)
		#50 `DEBUG_REG("ORI   ",4,15)
		#50 `DEBUG_REG("XORI  ",1,0)
		#50 `DEBUG_REG("XORI  ",2,7)
		#50 `DEBUG_SWX("SWI   ",1,8)
		#50 `DEBUG_SWX("SW    ",2,0)
		#50 `DEBUG_SWX("SW    ",3,56)
		#50 `DEBUG_LWX("LW    ",2,0)
		#50 `DEBUG_LWX("LW    ",3,56)
		#50 `DEBUG_LWX("LWI   ",4,8)
		#50 `DEBUG_REG("ADD   ",1,25)
		#50 `DEBUG_REG("SUB   ",2,-5)
		#50 `DEBUG_REG("AND   ",3,8)
		#50 `DEBUG_REG("OR    ",4,27)
		#50 `DEBUG_REG("XOR   ",1,-32)
		#50 `DEBUG_REG("SRLI  ",2,2)
		#50 `DEBUG_REG("SLLI  ",3,80)
		#50 `DEBUG_REG("ROTRI ",4,-993)
`endif
		#10
		//for( i=0;i<5;i=i+1 ) $display( "IM[%4d]=%b",i*4,IM.mem_data[i] ); 
		for( i=0;i<5;i=i+1 ) $display( "register[%d]=%d",i,TOP.REGFILE.rw_reg[i] );
		//for( i=0;i<5;i=i+1 ) $display( "DM[%4d]=%d",i*4,DM.mem_data[i] );
  		$display("____________________FINISH____________________\n");
		$finish;
	end
endmodule
