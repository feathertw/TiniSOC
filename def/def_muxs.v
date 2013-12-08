`define PC_4 	 	3'b000
`define PC_14BIT 	3'b001
`define PC_16BIT	3'b010
`define PC_24BIT 	3'b011
`define PC_REGISTER 	3'b100

`define ALUSRC2_RBDATA	3'b000
`define ALUSRC2_IMM	3'b001
`define ALUSRC2_LSWI	3'b010
`define ALUSRC2_LSW	3'b011
`define ALUSRC2_BENX	3'b100
`define ALUSRC2_UNKNOWN 3'bxxx

`define IMM_5BIT_ZE	2'b00
`define IMM_15BIT_SE	2'b01
`define IMM_15BIT_ZE	2'b10
`define IMM_20BIT_SE	2'b11
`define IMM_UNKOWN	2'bxx

`define WRREG_ALURESULT 2'b00
`define WRREG_IMMDATA 	2'b01
`define WRREG_MEM	2'b10
`define WRREG_UNKOWN	2'bxx

`define FOR_RG_ORI 	3'b000
`define FOR_RG_REG4	3'b001
`define FOR_RG_REG3	3'b010
`define FOR_RG_REG2_IMM 3'b011
`define FOR_RG_REG2_ALU 3'b100
