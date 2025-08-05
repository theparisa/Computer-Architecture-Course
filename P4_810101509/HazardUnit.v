module HazardUnit (RS1D, RS2D, RS1E, RS2E, RDE, PCSrcE, ResultSrcE_0, RDM, RegWriteM, RDW, RegWriteW,
                  StallF, StallD, FlushD, FlushE, ForwardAE, ForwardBE);

    input [4:0] RS1D, RS2D, RS1E, RS2E, RDE;
    input PCSrcE, ResultSrcE_0;
    input [4:0] RDM;
    input RegWriteM;
    input [4:0] RDW;
    input RegWriteW;

    output StallF, StallD, FlushD, FlushE;
    output [1:0] ForwardAE, ForwardBE;

    reg [1:0] ForwardAE_temp, ForwardBE_temp;
    assign ForwardAE = ForwardAE_temp;
    assign ForwardBE = ForwardBE_temp;

    always @(RS1E, RDM, RegWriteM, RDW) begin
        ForwardAE_temp = 2'b00;
        if ((RS1E == RDM) & RegWriteM & (RS1E != 5'b00000)) ForwardAE_temp = 2'b10;
        else if((RS1E == RDW) & RegWriteW & (RS1E != 5'b00000)) ForwardAE_temp = 2'b01;
        else ForwardAE_temp = 2'b00;
    end

    always @(RS2E, RDM, RegWriteM, RDW) begin
        ForwardBE_temp = 2'b00;
        if ((RS2E == RDM) & RegWriteM & (RS2E != 5'b00000)) ForwardBE_temp = 2'b10;
        else if((RS2E == RDW) & RegWriteW & (RS2E != 5'b00000)) ForwardBE_temp = 2'b01;
        else ForwardBE_temp = 2'b00;
    end

    wire lwStall;
    assign lwStall = ResultSrcE_0 & ((RS1D == RDE) | (RS2D == RDE));
    assign StallF = lwStall;
    assign StallD = lwStall;

    assign FlushD = PCSrcE;
    assign FlushE = lwStall | PCSrcE;

endmodule