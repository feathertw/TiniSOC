module regwalls(
	clock,
	iREG1_instruction,
	oREG1_instruction
);
	input  clock;

	input  [31:0] iREG1_instruction;
	output [31:0] oREG1_instruction;
	reg    [31:0] oREG1_instruction;
	always@(negedge clock)begin
		oREG1_instruction=iREG1_instruction;
	end
endmodule
