module RISC_V (clk, rst);

    input clk, rst;

    wire StallF, PCSrcE;
	wire RegWriteW;
	wire [2:0] ImmSrcD;
	wire ALUSrcE;
	wire [2:0] ALUControlE;
	wire MemWriteM;
	wire [1:0] ResultSrcW;
	wire [1:0] ForwardAE, ForwardBE;
	wire PCTargetSelectE;
	wire StallD;
	wire FlushE, FlushD;

	wire [31:0] InstrD;
	wire ZEROE;
	wire [4:0] RS1D, RS2D, RS1E, RS2E, RDE, RDM, RDW;
	wire ResultSrcE_0;
    wire RegWriteM;

    Datapath DPTH(StallF, PCSrcE, RegWriteW, ImmSrcD, ALUSrcE, ALUControlE, MemWriteM, ResultSrcW,
				ForwardAE, ForwardBE, FlushD, FlushE, StallD, PCTargetSelectE, clk, rst,
				InstrD, ZEROE,
				RS1D, RS2D, RS1E, RS2E, RDE, RDM, RDW);

    Controller CNT(PCSrcE, RegWriteW, ImmSrcD, ALUSrcE, ALUControlE, MemWriteM, ResultSrcW,
				  PCTargetSelectE, ResultSrcE_0, RegWriteM, clk, rst,
				  InstrD, ZEROE, FlushE);

    HazardUnit HU(RS1D, RS2D, RS1E, RS2E, RDE, PCSrcE, ResultSrcE_0, RDM, RegWriteM, RDW, RegWriteW,
                  StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE);

endmodule