`include "def_opcode.v"
 
module alu(
	reset,
	enable_execute,
	alu_src1,
	alu_src2,
	opcode,
	sub_op_base,

	alu_result,
	alu_overflow
);

	input reset;
	input enable_execute;
	input [31:0] alu_src1;
	input [31:0] alu_src2;
	input [5:0]  opcode;
	input [4:0]  sub_op_base;

	output [31:0] alu_result;
	output alu_overflow;

	reg [31:0] alu_result;
	reg alu_overflow;

	reg [63:0] rotate;
	reg a;
	reg b;

	always @(reset or enable_execute or opcode or sub_op_base or alu_src1 or alu_src2) begin
		a='bx;
		b='bx;
		rotate='bx;
		if(reset) begin
		    alu_result=32'b0;
		    alu_overflow=1'b0;
		end
		else if(enable_execute)begin
		    case(opcode)
		        `TY_BASE:
		        begin
		            case(sub_op_base)
		                //NOP:begin
		                //  alu_result=32'b0;
		                //  alu_overflow=1'b0;
		                //end
		                `ADD:begin
		                    {a,alu_result[30:0]}=alu_src1[30:0]+alu_src2[30:0];
		                    {b,alu_result[31]}=alu_src1[31]+alu_src2[31]+a;
		                    alu_overflow=a^b;
		                end
		                `SUB:begin
		                    {a,alu_result[30:0]}=alu_src1[30:0]-alu_src2[30:0];
		                    {b,alu_result[31]}=alu_src1[31]-alu_src2[31]-a;
		                    alu_overflow=a^b;
		                end
		                `AND:begin
		                    alu_result=alu_src1&alu_src2;
		                    alu_overflow=1'b0;
		                end
		                `OR :begin
		                    alu_result=alu_src1|alu_src2;
		                    alu_overflow=1'b0;
		                end
		                `XOR:begin
		                    alu_result=alu_src1^alu_src2;
		                    alu_overflow=1'b0;
		                end
		                `SLT:begin
				    if(alu_src1<alu_src2) alu_result=32'b1;
				    else		  alu_result=32'b0;
		                    alu_overflow=1'b0;
		                end
		                `SLTS:begin
				    if(alu_src1[31]<alu_src2[31])	  alu_result=32'b0;
				    else if(alu_src1[31]>alu_src2[31])	  alu_result=32'b1;
				    else begin
					if(alu_src1[30:0]<alu_src2[30:0]) alu_result=32'b1;
					else				  alu_result=32'b0;
				    end
		                    alu_overflow=1'b0;
		                end
		                `SRL:begin
		                    alu_result=alu_src1>>alu_src2;
		                    alu_overflow=1'b0;
		                end
		                `SLL:begin
		                    alu_result=alu_src1<<alu_src2;
		                    alu_overflow=1'b0;
		                end
		                `SRLI:begin
		                    alu_result=alu_src1>>alu_src2;
		                    alu_overflow=1'b0;
		                end
		                `SLLI:begin
		                    alu_result=alu_src1<<alu_src2;
		                    alu_overflow=1'b0;
		                end
		                `ROTRI:begin
		                    rotate={alu_src1,alu_src1}>>alu_src2;
		                    alu_result=rotate[31:0];
		                    alu_overflow=1'b0;
		                end

		                default:begin
		                    alu_result=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
		                    alu_overflow=1'b0;
		                end
		            endcase
		        end
		        `ADDI:begin
		            {a,alu_result[30:0]}=alu_src1[30:0]+alu_src2[30:0];
		            {b,alu_result[31]}=alu_src1[31]+alu_src2[31]+a;
		            alu_overflow=a^b;
		        end
		        `SUBRI:begin
		            {a,alu_result[30:0]}=alu_src2[30:0]-alu_src1[30:0];
		            {b,alu_result[31]}=alu_src2[31]-alu_src1[31]-a;
		            alu_overflow=a^b;
		        end
		        `ANDI:begin
		            alu_result=alu_src1&alu_src2;
		            alu_overflow=1'b0;
		        end
		        `ORI:begin
		            alu_result=alu_src1|alu_src2;
		            alu_overflow=1'b0;
		        end
		        `XORI:begin
		            alu_result=alu_src1^alu_src2;
		            alu_overflow=1'b0;
		        end
			`LWI:begin
		            {a,alu_result[30:0]}=alu_src1[30:0]+alu_src2[30:0];
		            {b,alu_result[31]}=alu_src1[31]+alu_src2[31]+a;
		            alu_overflow=a^b;
			end
			`SWI:begin
		            {a,alu_result[30:0]}=alu_src1[30:0]+alu_src2[30:0];
		            {b,alu_result[31]}=alu_src1[31]+alu_src2[31]+a;
		            alu_overflow=a^b;
			end
			`TY_LS:begin
				{a,alu_result[30:0]}=alu_src1[30:0]+alu_src2[30:0];
				{b,alu_result[31]}=alu_src1[31]+alu_src2[31]+a;
				alu_overflow=a^b;
			end
		        default:begin
				alu_result=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
				alu_overflow=1'b0;
		        end
		    endcase
		end
		else begin
			alu_result=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			alu_overflow=1'b0;
		end
	end
endmodule
