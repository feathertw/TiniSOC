`define DEBUG_REG(IR,REG,VALUE) \
	if(TOP.REGFILE.rw_reg[(REG)]==(VALUE) )	begin \
		$display("_%s R%-2d\t=%6d \t\tTEST PASS",(IR),(REG),(VALUE) ); \
	end \
	else begin \
		$write("%c[1;31m",27); \
		$display("*****%s R%-2d=%-2d!=%2d TEST FALSE*****" \
			,(IR),(REG),TOP.REGFILE.rw_reg[(REG)],VALUE ); \
		$write("%c[0m",27); \
	end

`define DEBUG_LWX(IR,REG,MEM) \
	if(TOP.REGFILE.rw_reg[(REG)]==DM.mem_data[((MEM)/4)] )	begin \
		$display("_%s R%-2d\t=%6d= DM[%4d] \tTEST PASS" \
			,(IR),(REG),DM.mem_data[((MEM)/4)],(MEM) ); \
	end \
	else begin \
		$write("%c[1;31m",27); \
		$display("*****%s R%-2d=%-2d!=DM[%4d] TEST FALSE*****" \
			,(IR),(REG),TOP.REGFILE.rw_reg[(REG)],(MEM) ); \
		$write("%c[0m",27); \
	end

`define DEBUG_SWX(IR,REG,MEM) \
	if(TOP.REGFILE.rw_reg[(REG)]==DM.mem_data[((MEM)/4)] )	begin \
		$display("_%s DM[%4d]=%6d= R%-2d\t\tTEST PASS" \
			,(IR),(MEM),DM.mem_data[((MEM)/4)],(REG) ); \
	end \
	else begin \
		$write("%c[1;31m",27); \
		$display("*****%s R%-2d=%-2d!=DM[%4d] TEST FALSE*****" \
			,(IR),(REG),TOP.REGFILE.rw_reg[(REG)],(MEM) ); \
		$write("%c[0m",27); \
	end
/*
`define DEBUG_SWX(IR,MEM,VALUE) \
	if(DM.mem_data[((MEM)/4)]==(VALUE) )	begin \
		$display("_%s DM[%4d]=%6d \t\tTEST PASS",(IR),(MEM),(VALUE) ); \
	end \
	else begin \
		$write("%c[1;31m",27); \
		$display("*****%s DM[%4d]=%-2d!=%2d TEST FALSE*****" \
			,(IR),(MEM),DM.mem_data[((MEM)/4)],(VALUE) ); \
		$write("%c[0m",27); \
	end
*/
