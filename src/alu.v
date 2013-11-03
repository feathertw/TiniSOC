`include "def_op.v"
 
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
	alu_zero,
);

    input reset;
    input enable_execute;
    input [31:0] src1;
    input [31:0] src2;
    input [5:0]  opcode;
    input [4:0]  sub_op_base;
    input [7:0]  sub_op_ls;

    output reg [31:0] alu_result;
    output reg alu_overflow;
    output alu_zero;
    
    reg [63:0] rotate;
    reg a;
    reg b;

    assign alu_zero=(alu_result==32'b0)?1'b1:1'b0;

    always @(*) begin
        if(reset) begin
            alu_result=32'b0;
            alu_overflow=1'b0;
        end
        else if(enable_execute)begin
            case(opcode)
                `TY_BASE: //subopcode
                begin
                    case(sub_op_base)
                        //NOP:
                        //begin
                        //  alu_result=32'b0;
                        //  alu_overflow=1'b0;
                        //end   
                        `ADD:
                        begin
                            {a,alu_result[30:0]}=src1[30:0]+src2[30:0];
                            {b,alu_result[31]}=src1[31]+src2[31]+a;
                            alu_overflow=a^b;
                        end
                        `SUB:
                        begin
                            {a,alu_result[30:0]}=src1[30:0]-src2[30:0];
                            {b,alu_result[31]}=src1[31]-src2[31]-a;
                            alu_overflow=a^b;
                        end
                        `AND:
                        begin
                            alu_result=src1&src2;
                            alu_overflow=1'b0;
                        end
                        `OR :
                        begin
                            alu_result=src1|src2;
                            alu_overflow=1'b0;
                        end
                        `XOR:
                        begin
                            alu_result=src1^src2;
                            alu_overflow=1'b0;
                        end
                        `SRLI:
                        begin
                            alu_result=src1>>src2;
                            alu_overflow=1'b0;
                        end
                        `SLLI:
                        begin
                            alu_result=src1<<src2;
                            alu_overflow=1'b0;
                        end
                        `ROTRI:
                        begin
                            rotate={src1,src1}>>src2;
                            alu_result=rotate[31:0];
                            alu_overflow=1'b0;
                        end

                        default:
                        begin
                            alu_result=32'b0;
                            alu_overflow=1'b0;
                        end
                    endcase
                end
                `ADDI: //ADDI
                begin
                    {a,alu_result[30:0]}=src1[30:0]+src2[30:0];
                    {b,alu_result[31]}=src1[31]+src2[31]+a;
                    alu_overflow=a^b;
                end
                `ORI: //ORI
                begin
                    alu_result=src1|src2;
                    alu_overflow=1'b0;
                end
                `XORI: //XORI
                begin
                    alu_result=src1^src2;
                    alu_overflow=1'b0;
                end
                `MOVI: //MOVI
                begin
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
                default:
                begin
                    alu_result=32'b0;
                    alu_overflow=1'b0;
                end
            endcase
        end
        //else begin
        //    alu_result=32'b0;
        //    alu_overflow=1'b0;
        //    //alu_result=alu_result;
        //    //alu_overflow=alu_overflow;
        //end
    end
endmodule
