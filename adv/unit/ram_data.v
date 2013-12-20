module ram_data(
	clock,
	index,
	offset_write,
	offset_read,
	data_in,
	data_out,
	do_write
);
	input  clock;
	input  [`IDX-1:0] index;
	input  [`OFS-1:0] offset_write;
	input  [`OFS-1:0] offset_read;
	input  [`WOR-1:0] data_in;
	output [`WOR-1:0] data_out;
	input  do_write;

	reg [`WOR-1:0] data_out;
	reg [`BLK-1:0] data_ram [`DEP-1:0];

	always@(negedge clock)begin
		if(do_write) write_offset(data_in,offset_write);
	end
	always@(posedge clock)begin
		read_offset(offset_read);
	end

	task write_offset;
		input [31:0] value;
		input [`OFS:0] offset_write;
		case(offset_write)
			`OFS'd0:  data_ram[index][31+`WOR* 0:`WOR* 0]<=value;
			`OFS'd1:  data_ram[index][31+`WOR* 1:`WOR* 1]<=value;
			`OFS'd2:  data_ram[index][31+`WOR* 2:`WOR* 2]<=value;
			`OFS'd3:  data_ram[index][31+`WOR* 3:`WOR* 3]<=value;
			`OFS'd4:  data_ram[index][31+`WOR* 4:`WOR* 4]<=value;
			`OFS'd5:  data_ram[index][31+`WOR* 5:`WOR* 5]<=value;
			`OFS'd6:  data_ram[index][31+`WOR* 6:`WOR* 6]<=value;
			`OFS'd7:  data_ram[index][31+`WOR* 7:`WOR* 7]<=value;
			`OFS'd8:  data_ram[index][31+`WOR* 8:`WOR* 8]<=value;
			`OFS'd9:  data_ram[index][31+`WOR* 9:`WOR* 9]<=value;
			`OFS'd10: data_ram[index][31+`WOR*10:`WOR*10]<=value;
			`OFS'd11: data_ram[index][31+`WOR*11:`WOR*11]<=value;
			`OFS'd12: data_ram[index][31+`WOR*12:`WOR*12]<=value;
			`OFS'd13: data_ram[index][31+`WOR*13:`WOR*13]<=value;
			`OFS'd14: data_ram[index][31+`WOR*14:`WOR*14]<=value;
			`OFS'd15: data_ram[index][31+`WOR*15:`WOR*15]<=value;
			default:  ;
		endcase
	endtask

	task read_offset;
		input [`OFS:0] offset_read;
		case(offset_read)
			`OFS'd0:  data_out<=data_ram[index][31+`WOR* 0:`WOR* 0];
			`OFS'd1:  data_out<=data_ram[index][31+`WOR* 1:`WOR* 1];
			`OFS'd2:  data_out<=data_ram[index][31+`WOR* 2:`WOR* 2];
			`OFS'd3:  data_out<=data_ram[index][31+`WOR* 3:`WOR* 3];
			`OFS'd4:  data_out<=data_ram[index][31+`WOR* 4:`WOR* 4];
			`OFS'd5:  data_out<=data_ram[index][31+`WOR* 5:`WOR* 5];
			`OFS'd6:  data_out<=data_ram[index][31+`WOR* 6:`WOR* 6];
			`OFS'd7:  data_out<=data_ram[index][31+`WOR* 7:`WOR* 7];
			`OFS'd8:  data_out<=data_ram[index][31+`WOR* 8:`WOR* 8];
			`OFS'd9:  data_out<=data_ram[index][31+`WOR* 9:`WOR* 9];
			`OFS'd10: data_out<=data_ram[index][31+`WOR*10:`WOR*10];
			`OFS'd11: data_out<=data_ram[index][31+`WOR*11:`WOR*11];
			`OFS'd12: data_out<=data_ram[index][31+`WOR*12:`WOR*12];
			`OFS'd13: data_out<=data_ram[index][31+`WOR*13:`WOR*13];
			`OFS'd14: data_out<=data_ram[index][31+`WOR*14:`WOR*14];
			`OFS'd15: data_out<=data_ram[index][31+`WOR*15:`WOR*15];
			default:  ;
		endcase
	endtask
endmodule
