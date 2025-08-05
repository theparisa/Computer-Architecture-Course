module RISC_V (clk, rst);

    input clk,rst;

    wire regwrite, ALUsrc, memwrite;
	wire [1:0] pcsrc, resultsrc;
	wire [2:0] OpCode, ImmSrc;
	wire clk,rst;
	wire ZERO;
	wire [31:0] instruction;

    Datapath DPTH   (pcsrc, ImmSrc, regwrite, ALUsrc, OpCode, memwrite, resultsrc, clk,rst, ZERO, instruction);
    Controller CNT  (instruction, ZERO, pcsrc, ImmSrc, regwrite, ALUsrc, OpCode, memwrite, resultsrc);

endmodule