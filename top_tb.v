`timescale 1ns/10ps
`include "debug.v"
`include "top.v"
`include "im.v"
`include "dm.v"

`define PROG1

module top_tb;

	reg clk;
	reg rst;
	integer i;
	wire alu_overflow;

	//IM
	wire IM_read; 
	wire IM_write; 
	wire IM_enable;
	wire [9:0] IM_address;
	wire [31:0] IM_out;

	wire DM_read;
	wire DM_write;
	wire DM_enable;
	wire [11:0] DM_address;
	wire [11:0] oDM_address;
	wire [31:0] DM_in;
	wire [31:0] DM_out;

	wire [9:0] pc;
	
	assign IM_address=pc/4;
	assign oDM_address=DM_address/4;

	top TOP(
		.clk(clk),
		.rst(rst),
		.instruction(IM_out),
		.alu_overflow(alu_overflow),

	        .pc(pc),
		.IM_read(IM_read),
	        .IM_write(IM_write),
	        .IM_enable(IM_enable),
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
		.IM_address(IM_address),
		.IM_read(IM_read),
		.IM_write(IM_write),
		.IM_enable(IM_enable),
		.IMin(),
		.IMout(IM_out)
	); 
	dm DM(
		.clock(clk),
		.reset(rst),
		.DM_read(DM_read),
		.DM_write(DM_write),
		.DM_enable(DM_enable),
		.DM_address(oDM_address),
		.DMin(DM_in),
		.DMout(DM_out)
	); 
  
	initial begin
		$fsdbDumpfile("top.fsdb");
		$fsdbDumpvars(0, top_tb);
	end

	//clock gen.
	always #5 clk=~clk;
  
	initial begin
  		$display("\n____________________TESTBENCH____________________");
		clk=0;
		rst=1'b1;
		#10 rst=1'b0;

`ifdef PROG1
		$readmemb("ir_data1.prog",IM.mem_data); //machine code for fig.2-2
		#50 `DEBUG_REG("ADDI  ",1,9)
		#50 `DEBUG_REG("XORI  ",1,3)
		#50 `DEBUG_REG("MOVI  ",0,3)
		#50 `DEBUG_SWX("SW    ",0,3)
		#50 `DEBUG_REG("ORI   ",0,7)
		#50 `DEBUG_REG("AND   ",1,3)
		#50 `DEBUG_LWX("LW    ",0,0)
		#50
		#50 `DEBUG_REG("ADD   ",1,6)
		#50 `DEBUG_REG("OR    ",1,7)
		#50 `DEBUG_REG("SUB   ",1,4)
		#50 `DEBUG_SWX("SWI   ",76,4)
		#50 `DEBUG_REG("SRLI  ",2,1)
		#50 `DEBUG_REG("SLLI  ",2,8)
		#50 `DEBUG_LWX("LWI   ",1,92)
		#50 `DEBUG_REG("AND   ",1,0)
		#50 `DEBUG_SWX("SWI   ",140,8)
		#50 `DEBUG_LWX("LWI   ",3,140)
		#50 `DEBUG_REG("SUB   ",3,5)
		#50 `DEBUG_REG("XOR   ",1,13)
		#50 `DEBUG_REG("ROTRI ",2,12)
`endif
		#10
		//for( i=0;i<5;i=i+1 ) $display( "IM[%4d]=%b",i*4,IM.mem_data[i] ); 
		for( i=0;i<5;i=i+1 ) $display( "register[%d]=%d",i,TOP.REGFILE.rw_reg[i] );
		for( i=0;i<5;i=i+1 ) $display( "DM[%4d]=%d",i*4,DM.mem_data[i] );
  		$display("____________________FINISH____________________\n");
		$finish;
	end
endmodule
