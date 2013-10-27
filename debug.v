`define DEBUG(IR,REG,VALUE) \
	if(TOP.REGFILE.rw_reg[(REG)]==(VALUE) )	begin \
		$display("_%s R%-2d=%4d TEST PASS",(IR),(REG),(VALUE) ); \
	end \
	else begin \
		$write("%c[1;31m",27); \
		$display("*****%s R%-2d=%-2d!=%2d TEST FALSE*****" \
			,(IR),(REG),TOP.REGFILE.rw_reg[(REG)],VALUE ); \
		$write("%c[0m",27); \
	end
