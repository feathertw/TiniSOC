module muxs(
	imm_5bit,
	imm_15bit,
	imm_20bit,
	read_data2,
	mux4to1_select,
	mux2to1_select,
	imm_reg_select,
	output_imm_reg_mux,
	write_data,
	alu_output,
);

	parameter DataSize = 32;

	output reg [DataSize-1:0] output_imm_reg_mux;
	output reg [DataSize-1:0] write_data;

	input [ 5-1:0] imm_5bit;
	input [15-1:0] imm_15bit;
	input [20-1:0] imm_20bit;
	input [DataSize-1:0] read_data2;
	
	input [1:0] mux4to1_select;
	input mux2to1_select;
	input [1:0] imm_reg_select;

	input [DataSize-1:0] alu_output;
	
	reg [DataSize-1:0] imm;

	always @(*) begin
		case(mux4to1_select)
			2'b00: begin //5bit ZE
				imm={ {27{1'b0}}, imm_5bit };
			end
			2'b01: begin //15bit SE
				imm={ {17{imm_15bit[14]}}, {imm_15bit} };
			end
			2'b10: begin //15bit ZE
				imm={ {17{1'b0}}, {imm_15bit} };
			end
			2'b11: begin //20bit SE
				imm={ {12{imm_20bit[19]}}, {imm_20bit} };
			end
		endcase
	end

	always @(*) begin
		case(imm_reg_select)
			2'b00: begin
				output_imm_reg_mux = read_data2;
			end
			2'b01: begin
				output_imm_reg_mux = imm;
			end
		endcase
	end

	always @(*) begin
		case(mux2to1_select)
			1'b0: begin
				write_data = alu_output;
			end
			1'b1: begin
				write_data = output_imm_reg_mux;
			end
		endcase
	end
endmodule

