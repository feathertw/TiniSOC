`define TY_BASE	6'b100000
`define NOP	5'b01001
`define ADD	5'b00000
`define SUB	5'b00001
`define AND	5'b00010
`define OR	5'b00100
`define XOR   	5'b00011
`define SEB	5'b10000
`define SEH	5'b10001
`define SLT	5'b00110
`define SLTS	5'b00111
`define SRL	5'b01101
`define SLL	5'b01100
`define SRA	5'b01110
`define SRLI  	5'b01001
`define SLLI  	5'b01000
`define SRAI	5'b01010
`define ROTRI 	5'b01011
`define CMOVN	5'b11011
`define CMOVZ	5'b11010

`define ADDI  	6'b101000
`define SUBRI	6'b101001
`define ANDI	6'b101010
`define ORI   	6'b101100
`define XORI  	6'b101011
`define SLTI	6'b101110
`define SLTSI	6'b101111
`define LWI   	6'b000010
`define SWI   	6'b001010
`define LWIBI	6'b000110
`define SWIBI	6'b001110

`define MOVI  	6'b100010
`define SETHI	6'b100011

`define TY_LS	6'b011100
`define LW	8'b00000010
`define SW	8'b00001010

`define TY_B	6'b100110
`define BEQ	1'b0
`define BNE	1'b1

`define TY_BZ	6'b100111
`define BEQZ	4'b0010
`define BGEZ	4'b0100
`define BGTZ	4'b0110
`define BLEZ	4'b0111
`define BLTZ	4'b0101
`define BNEZ	4'b0011

`define TY_J	6'b100100
`define JJ	1'b0
`define JAL	1'b1

`define TY_JR	6'b100101
`define JR	5'b00000
`define JRAL	5'b00001

`define TY_MISC	6'b110010
`define MTSR	5'b00011
`define MFSR	5'b00010
`define SYSCALL	5'b01011
`define	IRET	5'b00100
