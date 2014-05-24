`define SISTICK_CONTROL 	   0
`define SYSTICK_RELOAD_VALUE  	   1
`define SYSTICK_CONTROL_ENABLE 	   0
`define SYSTICK_CONTROL_CLEAR 	   1
`define SYSTICK_CONTROL_CONTINUOUS 2

`define SYSTICK_STATUS 	      	   0
`define SYSTICK_CURRENT_VALUE 	   1
`define SYSTICK_STATUS_FLAG 	   0

module systick(
	clock,
	reset,
	do_mem_read,
	do_mem_write,
	mem_address,
	din,
	dout,
	do_enable,
	do_systick_it
);
	input  clock;
	input  reset;
	input  do_mem_read;
	input  do_mem_write;
	input  [31:0] mem_address;
	input  [31:0] din;
	output [31:0] dout;
	input  do_enable;
	output do_systick_it;

	wire position = mem_address[ 2];
	wire readonly = mem_address[12];
	reg  [31:0] memory [1:0];
	reg  [31:0] dout;

	wire control_enable      = memory[`SISTICK_CONTROL][`SYSTICK_CONTROL_ENABLE];
	wire control_clear       = memory[`SISTICK_CONTROL][`SYSTICK_CONTROL_CLEAR];
	wire control_continuous  = memory[`SISTICK_CONTROL][`SYSTICK_CONTROL_CONTINUOUS];
	wire [31:0] reload_value = memory[`SYSTICK_RELOAD_VALUE];

	wire [31:0] status={31'b0,status_flag};
	reg  status_flag;
	reg  [31:0] current_value;

	assign do_systick_it = status_flag;

	reg  enable_r;
	wire enable_pulse = control_enable & (~enable_r);
	always @(posedge clock)begin
		if(reset) enable_r <= 'b0;
		else	  enable_r <= control_enable;
	end

	integer i;
	always @(posedge clock) begin
		if(reset) begin
			for(i=0;i<2;i=i+1) memory[i] <= 32'b0;
		end
		else if(do_enable)begin
			if(do_mem_write) memory[position] <= din;
		end
	end
	always @(posedge clock) begin
		if(reset) begin
			status_flag <= 'b0;
		end
		else begin
			if(current_value=='b1&&control_enable) status_flag <= 'b1;
			else				       status_flag <= 'b0;
		end
	end
	always @(posedge clock) begin
		if(reset) begin
			current_value <= 'b0;
		end
		else begin
			if(control_clear)			   current_value <= 'b0;
			else if(control_enable)begin
				if(current_value=='b0&&(control_continuous||enable_pulse))
					current_value <= reload_value;
				else if(!(current_value=='b0))
					current_value <= current_value-'b1;
			end
		end
	end

	always @(posedge clock) begin
		if(reset) begin
			dout <= 32'b0;
		end
		else if(do_enable)begin
			if(do_mem_read) begin
				if(!readonly) begin
					dout <= memory[position];
				end
				else begin
					case(position)
						`SYSTICK_STATUS:	dout <= status;
						`SYSTICK_CURRENT_VALUE: dout <= current_value;
					endcase
				end
			end
		end
	end

endmodule
