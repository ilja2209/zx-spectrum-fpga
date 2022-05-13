/**
 * This ADC interface provides an serial to parallel interface for
 * a Texas instruments ADC128S052 chip. 
 * After reset the interface just loops collecting 1 reading from the
 * ADC chip every 16 sclk cycles and stores them into its internal memory
 * at one of 4 address spaces.  The data will be refreshed every 4x16 (64 cycles)
 * So a consumer should be setup to read the data before its gone. 
 */
module adc_interface  
(
  addr, 
  data,
  din, 
  dout,
  sclk, 
  rst,
  csn
);

	input [1:0]    addr;
	output [11:0]  data;
	input          sclk;
	input          rst;
	input          din;
	output         dout;
	output			csn;
			
	reg [11:0]    data_reg = 12'd0;
	reg           dout;
	reg 			  cs_reg = 1'b0;

	reg [3:0]     sclk_count = 4'b0000;

	reg  [11:0]   din_ff = 12'd0;

	assign csn = ~cs_reg;
	assign data = data_reg;

	/* Handle clock counting */
	always @ (posedge sclk or posedge rst)
	  if (rst) begin
		 sclk_count <= 4'b0000;
		 cs_reg <= 1'b0;
	  end else begin
		 sclk_count <= sclk_count + 1'b1;
		 cs_reg <= 1'b1;
	  end
		 
	/* Serial DOUT, based on sclk count, send the current address bit MSB first. 
	 * Note: since we are only selecting 4 Analog ports we just have 2 bits to send
	 * during the 2nd clock cycle we went a zero by defualt. 
	 */
	always @ (*)
	  case (sclk_count)
		 4'd3: dout = addr[1];
		 4'd4: dout = addr[0];
		 default: dout = 1'b0;
	  endcase
		  
	/* DeSerialize DIN, use a shift register to move DIN into a 12 bit register during
	 * clock cycles 4 -> 15
	 */
	always @ (posedge sclk or posedge rst)
	  if (rst)
			din_ff <= 12'd0;
	  else 
		 casez (sclk_count)
			4'b01??, 4'b1???: din_ff <= {din_ff[10:0],din};
		 endcase
		  
	/* Return static ram on read interface
	 * Write shift register to static ram on first clock
	 */ 
	always @ (negedge sclk) begin
	  if (sclk_count == 4'b0000) begin
		  data_reg <= din_ff;
	  end
	end

endmodule
