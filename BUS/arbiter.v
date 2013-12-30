module arbiter(
	HCLK,
	HRESETn,
	HTRANS,
	HBURST,
	HREADY,
	HRESP,
	HSPLIT,

	HBUSREQ_M0,
	HBUSREQ_M1,
	HBUSREQ_M2,
	HLOCK_M0,
	HLOCK_M1,
	HLOCK_M2,

	HGRANT_M0,
	HGRANT_M1,
	HGRANT_M2,
	HMASTER,
	HMASTERLOCK
);
	input HCLK;
	input HRESETn;
	input [ 1:0] HTRANS;
	input [ 2:0] HBURST;
	input HREADY;
	input [ 1:0] HRESP;
	input [15:0] HSPLIT;

	input HBUSREQ_M0;
	input HBUSREQ_M1;
	input HBUSREQ_M2;
	input HLOCK_M0;
	input HLOCK_M1;
	input HLOCK_M2;

	output HGRANT_M0;
	output HGRANT_M1;
	output HGRANT_M2;
	output [2:0] HMASTER;
	output HMASTERLOCK;
	reg    HGRANT_M0;
	reg    HGRANT_M1;
	reg    HGRANT_M2;

	reg  [2:0] CurrentMaster;
	reg  [2:0] NextMaster;
	reg  [2:0] GrantMaster;

	reg  Lock;
	reg  RegLock1;
	reg  RegLock2;

	wire [2:0] HMASTER= CurrentMaster[2:0];
	wire [2:0] HBUSREQ= {HBUSREQ_M2,HBUSREQ_M1,HBUSREQ_M0};
	reg  [2:0] index;
	integer i;

	always@(HBUSREQ or CurrentMaster)begin
		NextMaster=`HMST_0;
		for(i=0;i<8;i=i+1)begin
			index=CurrentMaster+i+1;
			if( (1<<(index) )& HBUSREQ) NextMaster=index;
		end
	end

	always@(RegLock1 or RegLock2 or CurrentMaster or NextMaster)begin
		if(RegLock1||RegLock2) GrantMaster=CurrentMaster;
		else		       GrantMaster=NextMaster;
	end

	always@(GrantMaster)begin
		HGRANT_M0=1'b0;
		HGRANT_M1=1'b0;
		HGRANT_M2=1'b0;
		case(GrantMaster)
			`HMST_0: HGRANT_M0=1'b1;
			`HMST_1: HGRANT_M1=1'b1;
			`HMST_2: HGRANT_M2=1'b1;
			default: ;
		endcase
	end

	always@(posedge HCLK or HRESETn)begin
		if(!HRESETn)    CurrentMaster<= `HMST_0;
		else if(HREADY) CurrentMaster<= (HTRANS==`TRN_BUSY)? CurrentMaster:GrantMaster;
	end

	always@(GrantMaster or HLOCK_M1 or HLOCK_M2)begin
		case(GrantMaster)
			`HMST_0: Lock= 1'b0;
			`HMST_1: Lock= HLOCK_M1;
			`HMST_2: Lock= HLOCK_M2;
			default: Lock= 1'b0;
		endcase
	end

	always@(posedge HCLK or negedge HRESETn)begin
		if(!HRESETn)begin
			RegLock1<= 1'b0;
			RegLock2<= 1'b0;
		end
		else if(HREADY)begin
			RegLock1<= Lock;
			//RegLock2<= RegLock1;
		end
	end
endmodule
