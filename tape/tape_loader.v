module tape_loader
(
	input clk,
	input din,
	input rst,
	output dout,
	output dclk,
	output dcsn,
	output ear
);

	wire [11:0] data_adc;
	
	assign dclk = clk;
	
	adc_interface adc_interface
	(
		.addr(2'b00),  // Choose zero channel of ADC
		.data(data_adc),
		.sclk(dclk),
		.rst(rst),
		.din(din),
		.dout(dout),
		.csn(dcsn)
	);
	
	tape_dsp tape_dsp
	(
		.in_adc(data_adc),
		.ear(ear)
	);


endmodule
