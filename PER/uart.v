`define ADDR_TX_FLAG	24'h00_0000
`define ADDR_RX_FLAG	24'h00_0004
`define ADDR_TX_DATA	24'h00_0008
`define ADDR_RX_DATA	24'h00_000C
`define ADDR_BAUDRATE	24'h00_0010

`define WAIT_STATE 2
`define WS `WAIT_STATE

module uart(
	clock,
	reset,
	MRead,
	MWrite,
	MEnable,
	MAddress,
	MWriteData,
	MReadData,
	MReady
);
	input  clock;
	input  reset;
	input  MRead;
	input  MWrite;
	input  MEnable;
	input  [23:0] MAddress;
	input  [31:0] MWriteData;
	output [31:0] MReadData;
	output MReady;

	reg [31:0] MReadData;
	reg MReady;

	reg REG_MEnable [`WS:0];
	reg REG_MRead   [`WS:0];
	reg REG_MWrite  [`WS:0];
	reg [23:0] REG_MAddress   [`WS:0];
	reg [31:0] REG_MWriteData [`WS:0];

	wire xMEnable=REG_MEnable[`WS];
	wire xMRead  =REG_MRead[`WS];
	wire xMWrite =REG_MWrite[`WS];
	wire [23:0] xMAddress  =REG_MAddress[`WS];
	wire [31:0] xMWriteData=REG_MWriteData[`WS-1];

	reg TX_FLAG;
	reg RX_FLAG;
	reg [31:0] TX_DATA;
	reg [31:0] RX_DATA;
	reg [31:0] BAUDRATE;

	integer i;

	always@(negedge clock)begin
		if(reset)begin
			TX_FLAG <=1'b0;
			RX_FLAG <=1'b0;
			TX_DATA <=32'b0;
			RX_DATA <=32'b0;
			BAUDRATE<=32'b0;
			for(i=0;i<`WS;i=i+1) REG_MEnable[i]	<=1'b0;
			for(i=0;i<`WS;i=i+1) REG_MRead[i]	<=1'b0;
			for(i=0;i<`WS;i=i+1) REG_MWrite[i]	<=1'b0;
			for(i=0;i<`WS;i=i+1) REG_MAddress[i]	<=24'b0;
			for(i=0;i<`WS;i=i+1) REG_MWriteData[i]	<=32'b0;
		end
		else begin
			if(MReady)begin
				REG_MEnable[0]	  <=MEnable;
				REG_MRead[0]	  <=MRead;
				REG_MWrite[0]	  <=MWrite;
				REG_MAddress[0]	  <=MAddress;
				REG_MWriteData[0] <=MWriteData;
			end
			else begin
				REG_MEnable[0]	  <=1'b0;
				REG_MRead[0]	  <=1'b0;
				REG_MWrite[0]	  <=1'b0;
				REG_MAddress[0]	  <=24'b0;
				REG_MWriteData[0] <=32'b0;
			end
			for(i=0;i<`WS;i=i+1) REG_MEnable[i+1]	<=REG_MEnable[i];
			for(i=0;i<`WS;i=i+1) REG_MRead[i+1]	<=REG_MRead[i];
			for(i=0;i<`WS;i=i+1) REG_MWrite[i+1]	<=REG_MWrite[i];
			for(i=0;i<`WS;i=i+1) REG_MAddress[i+1]	<=REG_MAddress[i];
			for(i=0;i<`WS;i=i+1) REG_MWriteData[i+1]<=REG_MWriteData[i];

		end
	end

	always@(posedge clock)begin
		if(reset)begin
			MReadData<=32'b0;
			MReady<=1'b1;
		end
		else begin
			if(MEnable&&MRead)begin
				MReady<=1'b0;
			end
			if(xMEnable&&xMWrite)begin
				if(xMAddress==`ADDR_TX_FLAG)  TX_FLAG<=xMWriteData[0];
				if(xMAddress==`ADDR_RX_FLAG)  RX_FLAG<=xMWriteData[0];
				if(xMAddress==`ADDR_TX_DATA)  TX_DATA<=xMWriteData;
				if(xMAddress==`ADDR_RX_DATA)  RX_DATA<=xMWriteData;
				if(xMAddress==`ADDR_BAUDRATE) BAUDRATE<=xMWriteData;
			end
			if(xMEnable&&xMRead)begin
				MReady<=1'b1;
				if(xMAddress==`ADDR_TX_FLAG)  MReadData<=32'b0|TX_FLAG;
				if(xMAddress==`ADDR_RX_FLAG)  MReadData<=32'b0|RX_FLAG;
				if(xMAddress==`ADDR_TX_DATA)  MReadData<=TX_DATA;
				if(xMAddress==`ADDR_RX_DATA)  MReadData<=RX_DATA;
				if(xMAddress==`ADDR_BAUDRATE) MReadData<=BAUDRATE;
			end
		end
	end
endmodule
