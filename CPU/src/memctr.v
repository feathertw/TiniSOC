module memctr(
	do_mem_read,
	do_mem_write,
	mem_address,
	do_dmem_enable,
	do_iomem_enable
);
	input  do_mem_read;
	input  do_mem_write;
	input  [31:0] mem_address;
	output do_dmem_enable;
	output do_iomem_enable;

	wire do_dmem_enable =(do_mem_read||do_mem_write)&&(mem_address<=32'h01ff_ffff);
	wire do_iomem_enable=(do_mem_read||do_mem_write)&&(mem_address>=32'h0200_0000);
endmodule
