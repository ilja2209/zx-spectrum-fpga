module debounce(
	input btn_in,
	input clk,
	
	output btn_out
);

	reg [22:0] cnt = 23'b0;
	reg btn_q = 0;
	
	wire btn_bounce_clk;

	assign btn_bounce_clk = cnt[16];
	assign btn_out = btn_q;
	
	always @(posedge btn_bounce_clk) begin
		if (btn_in & btn_bounce_clk)
			btn_q <= 1;
		if (~btn_in)
			btn_q <= 0;
	end
	
	always @(posedge clk) begin
		cnt <= cnt + 1'b1;
	end
	
endmodule