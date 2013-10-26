`timescale 1ns/10ps
`include "../P1/debug.v"
`include "top.v"
`include "im.v"
`include "dm.v"

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
	wire [31:0] DM_in;
	wire [31:0] DM_out;

	wire [9:0] pc;
	
	assign IM_address=pc/4;

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
		.DM_out(DM_out),
		.mem_read_data(DM_out)
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
		.DM_address(DM_address),
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
		#10
		#40 `DEBUG("MOVI  ",0,4)
		#40 `DEBUG("ADDI  ",0,17)
		#40 `DEBUG("ORI   ",1,19)
		#40 `DEBUG("XORI  ",1,20)
		#40 
		#40 `DEBUG("ADD   ",1,37)
		#40 `DEBUG("SUB   ",1,20)
		#40 `DEBUG("AND   ",1,16)
		#40 `DEBUG("OR    ",0,17)
		#40 `DEBUG("XOR   ",2,1)
		#40 `DEBUG("SRLI  ",2,2)
		#40 `DEBUG("SLLI  ",2,16)
		#40 `DEBUG("ROTRI ",2,136)
	end
	initial begin
  		$display("\n____________________TESTBENCH____________________");
		clk=0;
		rst=1'b1;
		#10 rst=1'b0;
		
		$readmemb("ir_data.txt",IM.mem_data); //machine code for fig.2-2
		   
		#520
		$display( "done" );
		for( i=0;i<5;i=i+1 ) $display( "IM[%3d]=%b",i,IM.mem_data[i] ); 
		for( i=0;i<5;i=i+1 ) $display( "register[%d]=%d",i,TOP.REGFILE.rw_reg[i] ); 
		//for( i=0;i<31;i=i+1 ) $display( "IM[%h]=%h",i,IM.mem_data[i] ); 
		//for( i=0;i<32;i=i+1 ) $display( "register[%d]=%d",i,TOP.REGFILE.rw_reg[i] ); 
		//for( i=0;i<40;i=i+1 ) $display( "DM[%d]=%d",i,DM1.mem_data[i] );
		        
  		$display("____________________FINISH____________________\n");
		$finish;
	end
  
endmodule
