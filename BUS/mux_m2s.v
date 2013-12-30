module mux_m2s(
	HCLK,
	HRESETn,
	HMASTER,
	HREADY,
	
	HTRANS_M1,
	HTRANS_M2,
	HWRITE_M1,
	HWRITE_M2,
	HSIZE_M1,
	HSIZE_M2,
	HBURST_M1,
	HBURST_M2,
	HPROT_M1,
	HPROT_M2,
	HADDR_M1,
	HADDR_M2,
	HWDATA_M1,
	HWDATA_M2,

	HTRANS,
	HWRITE,
	HSIZE,
	HBURST,
	HPROT,
	HADDR,
	HWDATA
);
	input HCLK;
	input HRESETn;
	input [2:0] HMASTER;
	input HREADY;
	
	input  [ 1:0] HTRANS_M1;
	input  [ 1:0] HTRANS_M2;
	input         HWRITE_M1;
	input         HWRITE_M2;
	input  [ 2:0] HSIZE_M1;
	input  [ 2:0] HSIZE_M2;
	input  [ 2:0] HBURST_M1;
	input  [ 2:0] HBURST_M2;
	input  [ 3:0] HPROT_M1;
	input  [ 3:0] HPROT_M2;
	input  [31:0] HADDR_M1;
	input  [31:0] HADDR_M2;
	input  [31:0] HWDATA_M1;
	input  [31:0] HWDATA_M2;

	output [ 1:0] HTRANS;
	output        HWRITE;
	output [ 2:0] HSIZE;
	output [ 2:0] HBURST;
	output [ 3:0] HPROT;
	output [31:0] HADDR;
	output [31:0] HWDATA;
	reg    [ 1:0] HTRANS;
	reg           HWRITE;
	reg    [ 2:0] HSIZE;
	reg    [ 2:0] HBURST;
	reg    [ 3:0] HPROT;
	reg    [31:0] HADDR;
	reg    [31:0] HWDATA;

	reg    [ 2:0] HMASTER_pre;
	always@(posedge HCLK or negedge HRESETn)begin
		if(!HRESETn)    HMASTER_pre<= 3'b0;
		else if(HREADY) HMASTER_pre<= HMASTER;
	end
	
	always@(HMASTER or HTRANS_M1 or HTRANS_M2)begin
		case(HMASTER)
			`HMST_0: HTRANS=`TRN_IDLE;
			`HMST_1: HTRANS=HTRANS_M1;
			`HMST_2: HTRANS=HTRANS_M2;
			default: HTRANS='bx;
		endcase
	end

	always@(HMASTER or HWRITE_M1 or HWRITE_M2)begin
		case(HMASTER)
			`HMST_0: HWRITE='bx;
			`HMST_1: HWRITE=HWRITE_M1;
			`HMST_2: HWRITE=HWRITE_M2;
			default: HWRITE='bx;
		endcase
	end

	always@(HMASTER or HSIZE_M1 or HSIZE_M2)begin
		case(HMASTER)
			`HMST_0: HSIZE='bx;
			`HMST_1: HSIZE=HSIZE_M1;
			`HMST_2: HSIZE=HSIZE_M2;
			default: HSIZE='bx;
		endcase
	end

	always@(HMASTER or HBURST_M1 or HBURST_M2)begin
		case(HMASTER)
			`HMST_0: HBURST='bx;
			`HMST_1: HBURST=HBURST_M1;
			`HMST_2: HBURST=HBURST_M2;
			default: HBURST='bx;
		endcase
	end

	always@(HMASTER or HPROT_M1 or HPROT_M2)begin
		case(HMASTER)
			`HMST_0: HPROT='bx;
			`HMST_1: HPROT=HPROT_M1;
			`HMST_2: HPROT=HPROT_M2;
			default: HPROT='bx;
		endcase
	end

	always@(HMASTER or HADDR_M1 or HADDR_M2)begin
		case(HMASTER)
			`HMST_0: HADDR=32'hFFFF_FFFF;
			`HMST_1: HADDR=HADDR_M1;
			`HMST_2: HADDR=HADDR_M2;
			default: HADDR='bx;
		endcase
	end

	always@(HMASTER_pre or HWDATA_M1 or HWDATA_M2)begin
		case(HMASTER_pre)
			`HMST_0: HWDATA='bx;
			`HMST_1: HWDATA=HWDATA_M1;
			`HMST_2: HWDATA=HWDATA_M2;
			default: HWDATA='bx;
		endcase
	end

endmodule
