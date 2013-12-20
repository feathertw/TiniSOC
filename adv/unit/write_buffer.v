module write_buffer(
	clock,
	reset,
	BSysStrobe,
	BSysRW,
	BSysAddress,
	BSysData,
	BReady,
	SysStrobe,
	SysRW,
	SysAddress,
	SysData,
	SysReady
);
	input  clock;
	input  reset;
	input  BSysStrobe;
	input  BSysRW;
	input  [31:0] BSysAddress;
	input  [31:0] BSysData;
	output BReady;
	output SysStrobe;
	output SysRW;
	output [31:0] SysAddress;
	output [31:0] SysData;
	input  SysReady;

	reg SysStrobe;
	reg SysRW;
	reg [31:0] SysAddress;
	reg [31:0] SysData;

	reg        BRw      [15:0];
	reg [31:0] BAddress [15:0];
	reg [31:0] BData    [15:0];

	reg [3:0] head;
	reg [3:0] tail;

	wire BReady=(tail==(head+4'b1))? 1'b0:1'b1;

	always@(negedge clock)begin
		if(reset)begin
			head<=4'b0;
			tail<=4'b0;
		end
		else if(BSysStrobe && BReady)begin
			BRw[head]<=SysRW;
			BAddress[head]<=SysAddress;
			BData[head]<=SysData;
			head<=head+4'b1;
		end
	end
	always@(posedge clock)begin
		if(head!=tail)begin
			SysStrobe<=1'b1;
			SysRW<=BRw[tail];
			SysAddress<=BSysAddress[tail];
			SysData<=BSysData[tail];
			tail<=tail+4'b1;
		end
	end

endmodule
