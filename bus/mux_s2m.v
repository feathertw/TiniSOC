module mux_s2m(
	HCLK,
	HRESETn,

	HSEL_Default,
	HSEL_S1,
	HSEL_S2,
	HREADY_S1,
	HREADY_S2,
	HRESP_S1,
	HRESP_S2,
	HRDATA_S1,
	HRDATA_S2,

	HREADY,
	HRESP,
	HRDATA
);
	input HCLK;
	input HRESETn;

	input         HSEL_Default;
	input         HSEL_S1;
	input         HSEL_S2;
	input         HREADY_S1;
	input         HREADY_S2;
	input  [ 1:0] HRESP_S1;
	input  [ 1:0] HRESP_S2;
	input  [31:0] HRDATA_S1;
	input  [31:0] HRDATA_S2;

	output        HREADY;
	output [ 1:0] HRESP;
	output [31:0] HRDATA;
	reg           HREADY;
	reg    [ 1:0] HRESP;
	reg    [31:0] HRDATA;

	reg [4:0] HSEL_Reg;
	always@(posedge HCLK or negedge HRESETn)begin
		if(!HRESETn)begin
			HSEL_Reg<= 5'b0;
		end
		else if(HREADY)begin
			HSEL_Reg<= {HSEL_S2,HSEL_S1};
		end
	end

	always@(HSEL_Reg or HREADY_S1 or HREADY_S2)begin
		case(HSEL_Reg)
			`HSEL_1: HREADY= HREADY_S1;
			`HSEL_2: HREADY= HREADY_S2;
			default: HREADY= 1'b1;
		endcase
	end

	always@(HSEL_Reg or HRESP_S1 or HRESP_S2)begin
		case(HSEL_Reg)
			`HSEL_1: HRESP= HRESP_S1;
			`HSEL_2: HRESP= HRESP_S2;
			default: HRESP= `RSP_OKAY;
		endcase
	end

	always@(HSEL_Reg or HRDATA_S1 or HRDATA_S2)begin
		case(HSEL_Reg)
			`HSEL_1: HRDATA= HRDATA_S1;
			`HSEL_2: HRDATA= HRDATA_S2;
			default: HRDATA= 'bx;
		endcase
	end
endmodule
