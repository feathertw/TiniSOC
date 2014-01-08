module mux_s2m(
	HCLK,
	HRESETn,

	HSEL_Default,
	HSEL_S1,
	HSEL_S2,
	HSEL_S3,
	HREADY_S1,
	HREADY_S2,
	HREADY_S3,
	HRESP_S1,
	HRESP_S2,
	HRESP_S3,
	HSPLIT_S1,
	HSPLIT_S2,
	HSPLIT_S3,
	HRDATA_S1,
	HRDATA_S2,
	HRDATA_S3,

	HREADY,
	HRESP,
	HSPLIT,
	HRDATA
);
	input HCLK;
	input HRESETn;

	input         HSEL_Default;
	input         HSEL_S1;
	input         HSEL_S2;
	input         HSEL_S3;
	input         HREADY_S1;
	input         HREADY_S2;
	input         HREADY_S3;
	input  [ 1:0] HRESP_S1;
	input  [ 1:0] HRESP_S2;
	input  [ 1:0] HRESP_S3;
	input  [15:0] HSPLIT_S1;
	input  [15:0] HSPLIT_S2;
	input  [15:0] HSPLIT_S3;
	input  [31:0] HRDATA_S1;
	input  [31:0] HRDATA_S2;
	input  [31:0] HRDATA_S3;

	output        HREADY;
	output [ 1:0] HRESP;
	output [15:0] HSPLIT;
	output [31:0] HRDATA;
	reg           HREADY;
	reg    [ 1:0] HRESP;
	reg    [15:0] HSPLIT;
	reg    [31:0] HRDATA;

	reg [4:0] HSEL_Reg;
	always@(posedge HCLK or negedge HRESETn)begin
		if(!HRESETn)begin
			HSEL_Reg<= 5'b0;
		end
		else if(HREADY)begin
			HSEL_Reg<= {HSEL_S3,HSEL_S2,HSEL_S1};
		end
	end

	always@(HSEL_Reg or HREADY_S1 or HREADY_S2 or HREADY_S3)begin
		case(HSEL_Reg)
			`HSEL_1: HREADY= HREADY_S1;
			`HSEL_2: HREADY= HREADY_S2;
			`HSEL_3: HREADY= HREADY_S3;
			default: HREADY= 1'b1;
		endcase
	end

	always@(HSEL_Reg or HRESP_S1 or HRESP_S2 or HRESP_S3)begin
		case(HSEL_Reg)
			`HSEL_1: HRESP= HRESP_S1;
			`HSEL_2: HRESP= HRESP_S2;
			`HSEL_3: HRESP= HRESP_S3;
			default: HRESP= `RSP_OKAY;
		endcase
	end

	always@(HSEL_Reg or HSPLIT_S1 or HSPLIT_S2 or HSPLIT_S3)begin
		case(HSEL_Reg)
			`HSEL_1: HSPLIT= HSPLIT_S1;
			`HSEL_2: HSPLIT= HSPLIT_S2;
			`HSEL_3: HSPLIT= HSPLIT_S3;
			default: HSPLIT= 'bx;
		endcase
	end

	always@(HSEL_Reg or HRDATA_S1 or HRDATA_S2 or HRDATA_S3)begin
		case(HSEL_Reg)
			`HSEL_1: HRDATA= HRDATA_S1;
			`HSEL_2: HRDATA= HRDATA_S2;
			`HSEL_3: HRDATA= HRDATA_S3;
			default: HRDATA= 'bx;
		endcase
	end
endmodule
