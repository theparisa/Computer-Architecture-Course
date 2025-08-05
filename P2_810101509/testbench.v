`timescale 1ns/1ns
module RISC_V_TB();

	reg clk,rst;

	RISC_V UUT (clk, rst);

	initial begin clk = 1 ; rst = 1 ;#25 rst = 1'b0; end
	always #5 clk = ~clk;
	initial begin #2000 $stop; end

endmodule
