`include "def_opcode.v"
 
module alu(
	reset,
	enable_execute,
	src1,
	src2,
	opcode,
	sub_op_base,
	sub_op_ls,

	alu_result,
	alu_overflow,
	alu_zero
);

    input reset;
    input enable_execute;
    input [31:0] src1;
    input [31:0] src2;
    input [5:0]  opcode;
    input [4:0]  sub_op_base;
    input [7:0]  sub_op_ls;

    output [31:0] alu_result;
    output alu_overflow;
    output alu_zero;
    
    reg [31:0] alu_result;
    reg alu_overflow;

    reg [63:0] rotate;
    reg a;
    reg b;

    assign alu_zero=(alu_result==32'b0)?1'b1:1'b0;

    always @(reset or enable_execute or opcode or sub_op_base or sub_op_ls or src1 or src2) begin
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
                            {a,alu_result[30:0]}=src1[30:0]+src2[30:0];
                            {b,alu_result[31]}=src1[31]+src2[31]+a;
                            alu_overflow=a^b;
                        end
                        `SUB:begin
                            {a,alu_result[30:0]}=src1[30:0]-src2[30:0];
                            {b,alu_result[31]}=src1[31]-src2[31]-a;
                            alu_overflow=a^b;
                        end
                        `AND:begin
                            alu_result=src1&src2;
                            alu_overflow=1'b0;
                        end
                        `OR :begin
                            alu_result=src1|src2;
                            alu_overflow=1'b0;
                        end
                        `XOR:begin
                            alu_result=src1^src2;
                            alu_overflow=1'b0;
                        end
                        `SRLI:begin
                            alu_result=src1>>src2;
                            alu_overflow=1'b0;
                        end
                        `SLLI:begin
                            alu_result=src1<<src2;
                            alu_overflow=1'b0;
                        end
                        `ROTRI:begin
                            rotate={src1,src1}>>src2;
                            alu_result=rotate[31:0];
                            alu_overflow=1'b0;
                        end

                        default:begin
                            alu_result=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
                            alu_overflow=1'bx;
                        end
                    endcase
                end
                `ADDI:begin
                    {a,alu_result[30:0]}=src1[30:0]+src2[30:0];
                    {b,alu_result[31]}=src1[31]+src2[31]+a;
                    alu_overflow=a^b;
                end
                `ORI:begin
                    alu_result=src1|src2;
                    alu_overflow=1'b0;
                end
                `XORI:begin
                    alu_result=src1^src2;
                    alu_overflow=1'b0;
                end
                `MOVI:begin
                    alu_result=src1;
                    alu_overflow=1'b0;
                end
		`LWI:begin
                    {a,alu_result[30:0]}=src1[30:0]+src2[30:0];
                    {b,alu_result[31]}=src1[31]+src2[31]+a;
                    alu_overflow=a^b;
		end
		`SWI:begin
                    {a,alu_result[30:0]}=src1[30:0]+src2[30:0];
                    {b,alu_result[31]}=src1[31]+src2[31]+a;
                    alu_overflow=a^b;
		end
		`TY_LS:begin
			case(sub_op_ls)
				`LW:begin
					{a,alu_result[30:0]}=src1[30:0]+src2[30:0];
					{b,alu_result[31]}=src1[31]+src2[31]+a;
					alu_overflow=a^b;
				end
				`SW:begin
					{a,alu_result[30:0]}=src1[30:0]+src2[30:0];
					{b,alu_result[31]}=src1[31]+src2[31]+a;
					alu_overflow=a^b;
				end
				default:begin
					alu_result=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
					alu_overflow=1'bx;
				end
			endcase
		end
		`TY_B:begin
                            alu_result=src1^src2;
                            alu_overflow=1'b0;
		end
		`JJ:begin
			alu_result=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			alu_overflow=1'bx;
		end
                default:begin
			alu_result=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
			alu_overflow=1'bx;
                end
            endcase
        end
	else begin
		alu_result=32'bxxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx_xxxx;
		alu_overflow=1'bx;
	end
    end
endmodule
