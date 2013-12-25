`define TRN_IDLE	2'b00
`define TRN_BUSY	2'b01
`define TRN_NONSEQ	2'b10
`define TRN_SEQ		2'b11

`define RSP_OKAY	2'b00
`define RSP_ERROR	2'b01
`define RSP_RETRY	2'b10
`define RSP_SPLIT	2'b11

`define SIZ_8BIT	3'b000
`define SIZ_16BIT	3'b001
`define SIZ_32BIT	3'b010
`define SIZ_64BIT	3'b011
`define SIZ_128BIT	3'b100
`define SIZ_256BIT	3'b101
`define SIZ_512BIT	3'b110
`define SIZ_1024BIT	3'b111

`define BUR_SINGLE	3'b000
`define BUR_INCR	3'b001
`define BUR_WRAP4	3'b010
`define BUR_INCR4	3'b011
`define BUR_WRAP8	3'b100
`define BUR_INCR8	3'b101
`define BUR_WRAP16	3'b110
`define BUR_INCR16	3'b111

`define HMST_0 3'b000
`define HMST_1 3'b001
`define HMST_2 3'b010

`define HSEL_1 2'b01
`define HSEL_2 2'b10
