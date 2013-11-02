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
		#(`DELAY*100)
`endif
`ifdef PROG1
		$display("PROG1\n");
		$readmemb("mins/mins1.prog",IM.mem_data); //machine code for fig.2-2
		#(`DELAY) `DEBUG_REG("MOVI  ",0,3)
		#(`DELAY) `DEBUG_SWX("SWI   ",0,12)
		#(`DELAY) `DEBUG_LWX("LWI   ",1,12)
		#(`DELAY) `DEBUG_REG("ADDI  ",1,12)
		#(`DELAY) `DEBUG_REG("ORI   ",0,7)
		#(`DELAY) `DEBUG_REG("XORI  ",1,6)
		#(`DELAY) 
		#(`DELAY) `DEBUG_REG("ADD   ",1,13)
		#(`DELAY) `DEBUG_REG("SUB   ",1,6)
		#(`DELAY) `DEBUG_REG("AND   ",1,6)
		#(`DELAY) `DEBUG_SWX("SWI   ",1,76)
		#(`DELAY) `DEBUG_LWX("LWI   ",2,76)
		#(`DELAY) `DEBUG_REG("OR    ",2,7)
		#(`DELAY) `DEBUG_REG("XOR   ",2,1)
		#(`DELAY) `DEBUG_REG("SRLI  ",2,1)
		#(`DELAY) `DEBUG_REG("SLLI  ",2,16)
		#(`DELAY) `DEBUG_REG("ROTRI ",2,28)
		#(`DELAY) `DEBUG_SWX("SWI   ",2,124)
		#(`DELAY) `DEBUG_LWX("LWI   ",3,124)
		#(`DELAY) `DEBUG_REG("SUB   ",3,21)
		#(`DELAY) `DEBUG_REG("AND   ",1,4)
`endif
`ifdef PROG2
		$display("PROG2\n");
		$readmemb("mins/mins2.prog",IM.mem_data);
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
		#(`DELAY*10)
`endif
`ifdef PROG3
		$display("PROG3\n");
		$readmemb("mins/mins3.prog",IM.mem_data);
		#(`DELAY) `DEBUG_REG("MOVI  ",0,130)
		#(`DELAY) `DEBUG_REG("ADDI  ",0,890)
`endif
`ifdef PROG4
		$display("PROG4\n");
		$readmemb("mins/mins4.prog",IM.mem_data);
		#(`DELAY) `DEBUG_REG("MOVI  ",0,1)
		#(`DELAY) `DEBUG_REG("MOVI  ",1,65536)
		#(`DELAY) `DEBUG_REG("SUB   ",0,-65535)
`endif
`ifdef PROG5
		$display("PROG5\n");
		$readmemb("mins/mins5.prog",IM.mem_data);
		#(`DELAY) `DEBUG_REG("MOVI  ",0,-255)
		#(`DELAY) `DEBUG_REG("SLLI  ",0,-2040)
		#(`DELAY) `DEBUG_REG("ADDI  ",0,-2033)
`endif
`ifdef PROG6
		$display("PROG6\n");
		$readmemb("mins/mins6.prog",IM.mem_data);
		#(`DELAY) `DEBUG_REG("MOVI  ",0,40)
		#(`DELAY) `DEBUG_REG("SLLI  ",0,80)
		#(`DELAY) `DEBUG_REG("MOVI  ",1,160)
		#(`DELAY) `DEBUG_REG("SRLI  ",1,40)
		#(`DELAY) `DEBUG_REG("ADD   ",0,120)
`endif
`ifdef PROG7
		$display("PROG7\n");
		$readmemb("mins/mins7.prog",IM.mem_data);
		$readmemb("mins/mdat7.prog",DM.mem_data);
		#(`DELAY) `DEBUG_LWX("LWI   ",0,0)
		#(`DELAY) `DEBUG_LWX("LWI   ",1,4)
		#(`DELAY) `DEBUG_LWX("LWI   ",2,8)
		#(`DELAY) `DEBUG_LWX("LWI   ",3,12)
		#(`DELAY) `DEBUG_LWX("LWI   ",4,16)
		#(`DELAY*500)
`endif
`ifdef PROG8
		$display("PROG8\n");
		$readmemb("mins/mins7.prog",IM.mem_data);
		$readmemb("mins/mdat8.prog",DM.mem_data);
		#(`DELAY) `DEBUG_LWX("LWI   ",0,0)
		#(`DELAY) `DEBUG_LWX("LWI   ",1,4)
		#(`DELAY) `DEBUG_LWX("LWI   ",2,8)
		#(`DELAY) `DEBUG_LWX("LWI   ",3,12)
		#(`DELAY) `DEBUG_LWX("LWI   ",4,16)
		#(`DELAY*500)
`endif
`ifdef PROG9
		$display("PROG9\n");
		$readmemb("mins/mins7.prog",IM.mem_data);
		$readmemb("mins/mdat9.prog",DM.mem_data);
		#(`DELAY) `DEBUG_LWX("LWI   ",0,0)
		#(`DELAY) `DEBUG_LWX("LWI   ",1,4)
		#(`DELAY) `DEBUG_LWX("LWI   ",2,8)
		#(`DELAY) `DEBUG_LWX("LWI   ",3,12)
		#(`DELAY) `DEBUG_LWX("LWI   ",4,16)
		#(`DELAY*500)
`endif
		#10
		//for( i=0;i<3;i=i+1 ) $display( "IM[%4d]=%b",i*4,IM.mem_data[i] ); 
		for( i=0;i<5;i=i+1 ) $display( "register[%d]=%d",i,TOP.REGFILE.rw_reg[i] );
		for( i=0;i<5;i=i+1 ) $display( "DM[%4d]=%d",i*4,DM.mem_data[i] );
  		$display("____________________FINISH____________________\n");
		$finish;
	end
endmodule
