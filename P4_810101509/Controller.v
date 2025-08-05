module ALU_Controller(ALUOp, OpCode, f3, f7, ALUControl);
    input [1:0] ALUOp;
    input [2:0] f3;
    input [6:0] f7;
    input [6:0] OpCode;
    output [2:0] ALUControl;
    reg    [2:0] ALUControl_temp;
    assign ALUControl = ALUControl_temp;

    parameter [2:0]	ADD = 3'b000,
					SUB = 3'b001,
					AND = 3'b010,
					OR =  3'b011,
					SLT = 3'b100,
					XOR = 3'b101,
                    PASS= 3'b110;

    parameter [1:0] ADD_OP     = 2'b00,
                    SUB_OP     = 2'b01,
                    CHECK_F_OP = 2'b10,
                    PASS_OP  = 2'b11;

    parameter [6:0]	ADD_OPC =	7'd51,
					SUB_OPC =	7'd51,
					AND_OPC =	7'd51,
					OR_OPC =	7'd51,
					SLT_OPC =	7'd51,
					LW_OPC =	7'd3,
					ADDI_OPC =	7'd19,
					XORI_OPC =	7'd19,
					ORI_OPC =	7'd19,
					SLTI_OPC =	7'd19,
					JALR_OPC =	7'd103,
					SW_OPC =	7'd35,
					JAL_OPC =	7'd111,
					BEQ_OPC =	7'd99,
					BNE_OPC =	7'd99,
					LUI_OPC =	7'd55;

	parameter [2:0]	ADD_F3 =	3'd0,
					SUB_F3 =	3'd0,
					AND_F3 =	3'd7,
					OR_F3 =		3'd6,
					SLT_F3 =	3'd2,
					LW_F3 =		3'd2,
					ADDI_F3 =	3'd0,
					XORI_F3 =	3'd4,
					ORI_F3 =	3'd6,
					SLTI_F3 =	3'd2,
					JALR_F3 =	3'd0,
					SW_F3 =		3'd2,
					BEQ_F3 =	3'd0,
					BNE_F3 =	3'd1;

	parameter [6:0] ADD_F7 =	7'd0,
					SUB_F7 =	7'd32,
					AND_F7 =	7'd0,
					OR_F7 =		7'd0,
					SLT_F7 =	7'd0;

    always @(ALUOp, f3, f7) begin
        ALUControl_temp = ADD;
        case(ALUOp)
            ADD_OP: begin ALUControl_temp = ADD; end
            SUB_OP: begin ALUControl_temp = SUB; end
            PASS_OP:begin ALUControl_temp = PASS; end
            CHECK_F_OP: begin
                if ( (OpCode ==  ADD_OPC) & (f3 == ADD_F3) & (f7 == ADD_F7) ) begin ALUControl_temp = ADD ; end
				else if ( (OpCode ==  SUB_OPC) & (f3 == SUB_F3) & (f7 == SUB_F7) ) begin ALUControl_temp = SUB ; end
				else if ( (OpCode ==  AND_OPC) & (f3 == AND_F3) & (f7 == AND_F7) ) begin ALUControl_temp = AND ; end
				else if ( (OpCode ==  OR_OPC) & (f3 == OR_F3) & (f7 == OR_F7) ) begin ALUControl_temp = OR ; end
				else if ( (OpCode ==  SLT_OPC) & (f3 == SLT_F3) & (f7 == SLT_F7) ) begin ALUControl_temp = SLT ; end
				else if ( (OpCode ==  LW_OPC) & (f3 == LW_F3) ) begin ALUControl_temp = ADD ; end
				else if ( (OpCode ==  ADDI_OPC) & (f3 == ADDI_F3) ) begin ALUControl_temp = ADD ; end
				else if ( (OpCode ==  XORI_OPC) & (f3 == XORI_F3) ) begin ALUControl_temp = XOR ; end
				else if ( (OpCode ==  ORI_OPC) & (f3 == ORI_F3) ) begin ALUControl_temp = OR ; end
				else if ( (OpCode ==  SLTI_OPC) & (f3 == SLTI_F3) ) begin ALUControl_temp = SLT ; end
				else if ( (OpCode ==  JALR_OPC) & (f3 == JALR_F3) ) begin ALUControl_temp = ADD ; end
				else if ( (OpCode ==  SW_OPC) & (f3 == SW_F3) ) begin ALUControl_temp = ADD ; end
				else if ( (OpCode ==  JAL_OPC) ) begin ALUControl_temp = ADD ; end
				else if ( (OpCode ==  BEQ_OPC) & (f3 == BEQ_F3) ) begin ALUControl_temp = SUB ; end
				else if ( (OpCode ==  BNE_OPC) & (f3 == BNE_F3) ) begin ALUControl_temp = SUB ; end
				else if ( (OpCode ==  LUI_OPC) ) begin ALUControl_temp = PASS ; end
            end
        endcase
    end
endmodule


module PCController(Jump, ZERO, BrEQ, BrNE, PCSrc);
	input Jump;
	input ZERO;
	input BrEQ, BrNE;
	output PCSrc;
	reg PCSrc_temp;
	assign PCSrc = PCSrc_temp;

	always @(Jump, ZERO, BrEQ, BrNE) begin
		PCSrc_temp = 1'b0;
		if(Jump)	PCSrc_temp = 1'b1;
		else if(BrEQ)	PCSrc_temp = ZERO ? 1'b1 : 1'b0;
		else if(BrNE)	PCSrc_temp = ZERO ? 1'b0 : 1'b1;
	end
endmodule

module MainController (InstrD, RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchEQD, BranchNED,
                  ALUControlD, ALUSrcD, ImmSrcD, PCTargetSelectD);

    parameter [6:0]	ADD_OPC =	7'd51,
					SUB_OPC =	7'd51,
					AND_OPC =	7'd51,
					OR_OPC =	7'd51,
					SLT_OPC =	7'd51,
					LW_OPC =	7'd3,
					ADDI_OPC =	7'd19,
					XORI_OPC =	7'd19,
					ORI_OPC =	7'd19,
					SLTI_OPC =	7'd19,
					JALR_OPC =	7'd103,
					SW_OPC =	7'd35,
					JAL_OPC =	7'd111,
					BEQ_OPC =	7'd99,
					BNE_OPC =	7'd99,
					LUI_OPC =	7'd55;

	parameter [2:0]	ADD_F3 =	3'd0,
					SUB_F3 =	3'd0,
					AND_F3 =	3'd7,
					OR_F3 =		3'd6,
					SLT_F3 =	3'd2,
					LW_F3 =		3'd2,
					ADDI_F3 =	3'd0,
					XORI_F3 =	3'd4,
					ORI_F3 =	3'd6,
					SLTI_F3 =	3'd2,
					JALR_F3 =	3'd0,
					SW_F3 =		3'd2,
					BEQ_F3 =	3'd0,
					BNE_F3 =	3'd1;

	parameter [6:0] ADD_F7 =	7'd0,
					SUB_F7 =	7'd32,
					AND_F7 =	7'd0,
					OR_F7 =		7'd0,
					SLT_F7 =	7'd0;


    input [31:0] InstrD;

    output RegWriteD;
    output [1:0] ResultSrcD;
    output MemWriteD, JumpD, BranchEQD, BranchNED;
    output [2:0] ALUControlD;
    output ALUSrcD;
    output [2:0] ImmSrcD;
    output PCTargetSelectD;

    wire [6:0] OpCode;
    wire [2:0] f3;
    wire [6:0] f7;

    assign f3 = InstrD[14:12];
	assign f7 = InstrD[31:25];
	assign OpCode = InstrD[6:0];

    reg [1:0] ALUOp;
    ALU_Controller ALUNT(
        .ALUOp(ALUOp),
        .OpCode(OpCode),
        .f3(f3),
        .f7(f7),
        .ALUControl(ALUControlD)
        );

    reg RegWriteD_temp;
    reg [1:0] ResultSrcD_temp;
    reg ALUSrcD_temp;
    reg [2:0] ImmSrcD_temp;
    reg PCTargetSelectD_temp;

    assign RegWriteD = RegWriteD_temp;
    assign ResultSrcD = ResultSrcD_temp;
    assign ALUSrcD = ALUSrcD_temp;
    assign ImmSrcD = ImmSrcD_temp;
    assign PCTargetSelectD = PCTargetSelectD_temp;

    parameter [1:0] ADD_OP     = 2'b00,
                    SUB_OP     = 2'b01,
                    CHECK_F_OP = 2'b10,
                    PASS_OP  = 2'b11;

    always @(OpCode, f3, f7) begin
        ALUOp = ADD_OP;
        if ((OpCode == LW_OPC) & (f3 == LW_F3)) begin ALUOp = ADD_OP; end
        else if((OpCode == SW_OPC) & (f3 == SW_F3)) begin ALUOp = ADD_OP; end
        else if((OpCode == JALR_OPC) & (f3 == JALR_F3)) begin ALUOp = PASS_OP; end
        else if((OpCode == JAL_OPC)) begin ALUOp = ADD_OP; end
        else if(((OpCode == BEQ_OPC) & (f3 == BEQ_F3)) | ((OpCode == BNE_OPC) & (f3 == BNE_F3))) begin ALUOp = SUB_OP; end
        else if(OpCode == LUI_OPC) begin ALUOp = PASS_OP; end
        else begin ALUOp = CHECK_F_OP; end
    end

    // always @(OpCode, f3, f7) begin
    //     RegWriteD_temp = 1'b1;
    //     if ((OpCode == SW_OPC) & (f3 == SW_F3)) RegWriteD_temp = 1'b0;
    //     else if(((OpCode == BEQ_OPC) & (f3 == BEQ_F3)) | ((OpCode == BNE_OPC) & (f3 == BNE_F3))) RegWriteD_temp = 1'b0;
    //     else RegWriteD_temp = 1'b1;
    // end

    always @(OpCode, f3, f7) begin
		ResultSrcD_temp = 2'b00;
		RegWriteD_temp = 1'b0;
		if ((OpCode == ADD_OPC) & (f3 == ADD_F3) & (f7 == ADD_F7)) begin		ResultSrcD_temp = 2'b00; RegWriteD_temp = 1'b1; end
		if ((OpCode == SUB_OPC) & (f3 == SUB_F3) & (f7 == SUB_F7)) begin 	ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
		if ((OpCode == AND_OPC) & (f3 == AND_F3) & (f7 == AND_F7)) begin 	ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
		if ((OpCode == OR_OPC) & (f3 == OR_F3) & (f7 == OR_F7)) begin 	ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
		if ((OpCode == SLT_OPC) & (f3 == SLT_F3) & (f7 == SLT_F7)) begin 	ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
		if ((OpCode == LW_OPC) & (f3 == LW_F3)) begin					 	ResultSrcD_temp = 2'b01;	RegWriteD_temp = 1'b1; end
		if ((OpCode == ADDI_OPC) & (f3 == ADDI_F3)) begin 				ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
		if ((OpCode == XORI_OPC) & (f3 == XORI_F3)) begin 				ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
		if ((OpCode == ORI_OPC) & (f3 == ORI_F3)) begin 					ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
		if ((OpCode == SLTI_OPC) & (f3 == SLTI_F3)) begin 				ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
		if ((OpCode == JALR_OPC) & (f3 == JALR_F3)) begin 				ResultSrcD_temp = 2'b10;	RegWriteD_temp = 1'b1; end
		// if ((OpCode == SW_OPC) & (f3 == SW_F3)) begin 					ResultSrcD_temp = 2'b;	RegWriteD_temp = 1'b1; end
		if ((OpCode == JAL_OPC)) begin 									ResultSrcD_temp = 2'b10;	RegWriteD_temp = 1'b1; end
		// if ((OpCode == BEQ_OPC) & (f3 == BEQ_F3)) begin				ResultSrcD_temp = 2'b;	RegWriteD_temp = 1'b1; end
		// if ((OpCode == BNE_OPC) & (f3 == BNE_F3)) begin				ResultSrcD_temp = 2'b;	RegWriteD_temp = 1'b1; end
		if ((OpCode == LUI_OPC)) begin					 				ResultSrcD_temp = 2'b00;	RegWriteD_temp = 1'b1; end
	end

    assign MemWriteD = ((OpCode == SW_OPC) & (f3 == SW_F3));
    assign JumpD = (((OpCode == JALR_OPC) & (f3 == JALR_F3)) | (OpCode == JAL_OPC));
    assign BranchEQD = ((OpCode == BEQ_OPC) & (f3 == BEQ_F3));
    assign BranchNED = ((OpCode == BNE_OPC) & (f3 == BNE_F3));

    always @(OpCode, f3, f7) begin
		ALUSrcD_temp = 1'b0;
		if ((OpCode == ADD_OPC) & (f3 == ADD_F3) & (f7 == ADD_F7))				ALUSrcD_temp = 1'b0;
		else if ((OpCode == SUB_OPC) & (f3 == SUB_F3) & (f7 == SUB_F7)) 		ALUSrcD_temp = 1'b0;
		else if ((OpCode == AND_OPC) & (f3 == AND_F3) & (f7 == AND_F7)) 		ALUSrcD_temp = 1'b0;
		else if ((OpCode == OR_OPC) & (f3 == OR_F3) & (f7 == OR_F7)) 			ALUSrcD_temp = 1'b0;
		else if ((OpCode == SLT_OPC) & (f3 == SLT_F3) & (f7 == SLT_F7)) 		ALUSrcD_temp = 1'b0;
		if ((OpCode == LW_OPC) & (f3 == LW_F3))					 			ALUSrcD_temp = 1'b1;
		else if ((OpCode == ADDI_OPC) & (f3 == ADDI_F3)) 						ALUSrcD_temp = 1'b1;
		else if ((OpCode == XORI_OPC) & (f3 == XORI_F3)) 						ALUSrcD_temp = 1'b1;
		else if ((OpCode == ORI_OPC) & (f3 == ORI_F3)) 						ALUSrcD_temp = 1'b1;
		else if ((OpCode == SLTI_OPC) & (f3 == SLTI_F3)) 						ALUSrcD_temp = 1'b1;
		// else if ((OpCode == JALR_OPC) & (f3 == JALR_F3)) 						ALUSrcD_temp = 1'b1;
		else if ((OpCode == SW_OPC) & (f3 == SW_F3)) 							ALUSrcD_temp = 1'b1;
		// else if ((OpCode == JAL_OPC)) 											ALUSrcD_temp = 1'b0;
		else if ((OpCode == BEQ_OPC) & (f3 == BEQ_F3)) 						ALUSrcD_temp = 1'b0;
		else if ((OpCode == BNE_OPC) & (f3 == BNE_F3)) 						ALUSrcD_temp = 1'b0;
		else if ((OpCode == LUI_OPC))					 						ALUSrcD_temp = 1'b1;
	end


    parameter [2:0]	IT_IMM =	3'b000,
					ST_IMM =	3'b001,
					BT_IMM =	3'b010,
					JT_IMM =	3'b011,
					UT_IMM =	3'b100;

    always @(OpCode, f3, f7) begin
		ImmSrcD_temp = 3'b000;
		case(OpCode)
			ADDI_OPC:	ImmSrcD_temp = IT_IMM;
			JALR_OPC:	ImmSrcD_temp = IT_IMM;
			SW_OPC:		ImmSrcD_temp = ST_IMM;
			JAL_OPC:	ImmSrcD_temp = JT_IMM;
			BEQ_OPC:	ImmSrcD_temp = BT_IMM;
			LUI_OPC:	ImmSrcD_temp = UT_IMM;
		endcase
	end

    assign PCTargetSelectD_temp = ((OpCode == JALR_OPC) & (f3 == JALR_F3)) ? 1'b1 : 1'b0;
endmodule

module Controller (PCSrcE, RegWriteW, ImmSrcD, ALUSrcE, ALUControlE, MemWriteM, ResultSrcW,
				  PCTargetSelectE, ResultSrcE_0, RegWriteM, clk, rst,
				  InstrD, ZEROE, FlushE);

	input [31:0] InstrD;
	input ZEROE;
	input FlushE;
	input clk,rst;

	output PCSrcE, RegWriteW;
    output [2:0] ImmSrcD;
	output ALUSrcE;
	output [2:0] ALUControlE;
	output MemWriteM;
	output [1:0] ResultSrcW;
	output PCTargetSelectE;
	output ResultSrcE_0;
	output RegWriteM;




    wire RegWriteD;
    wire [1:0] ResultSrcD;
    wire MemWriteD, JumpD, BranchEQD, BranchNED;
    wire [2:0] ALUControlD;
    wire ALUSrcD;
    wire PCTargetSelectD;
	wire RegWriteE;
	wire [1:0] ResultSrcE;
	wire MemWriteE;
	wire JumpE;
	wire BranchEQE;
	wire BranchNEE;

	assign ResultSrcE_0 = ResultSrcE[0];

	supply0 GND;

	MainController MC (InstrD, RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchEQD, BranchNED,
                  ALUControlD, ALUSrcD, ImmSrcD, PCTargetSelectD);


	Register #(1) RegWrite_DtoE (
		.dataIN(RegWriteD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(RegWriteE)
		);

	Register #(2) ResultSrc_DtoE (
		.dataIN(ResultSrcD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(ResultSrcE)
		);


	Register #(1) MemWrite_DtoE (
		.dataIN(MemWriteD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(MemWriteE)
		);


	Register #(1) Jump_DtoE (
		.dataIN(JumpD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(JumpE)
		);


	Register #(1) BranchEQ_DtoE (
		.dataIN(BranchEQD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(BranchEQE)
		);


	Register #(1) BranchNE_DtoE (
		.dataIN(BranchNED),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(BranchNEE)
		);


	Register #(3) ALUControl_DtoE (
		.dataIN(ALUControlD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(ALUControlE)
		);


	Register #(1) ALUSrc_DtoE (
		.dataIN(ALUSrcD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(ALUSrcE)
		);

	Register #(1) PCTargetSelect_DtoE (
		.dataIN(PCTargetSelectD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(PCTargetSelectE)
		);

	PCController PCCNT (
		.Jump(JumpE),
		.ZERO(ZEROE),
		.BrEQ(BranchEQE),
		.BrNE(BranchNEE),
		.PCSrc(PCSrcE)
		);

	wire [1:0] ResultSrcM;
	wire MemWriteM;

	Register #(1) RegWrite_EtoM(
		.dataIN(RegWriteE),
		.Stall(GND),
		.Flush(GND),
		.clk(clk),
		.rst(rst),
		.dataOUT(RegWriteM)
		);

	Register #(2) ResultSrc_EtoM(
		.dataIN(ResultSrcE),
		.Stall(GND),
		.Flush(GND),
		.clk(clk),
		.rst(rst),
		.dataOUT(ResultSrcM)
		);

	Register #(1) MemWrite_EtoM(
		.dataIN(MemWriteE),
		.Stall(GND),
		.Flush(GND),
		.clk(clk),
		.rst(rst),
		.dataOUT(MemWriteM)
		);

	Register #(1) RegWrite_MtoW(
		.dataIN(RegWriteM),
		.Stall(GND),
		.Flush(GND),
		.clk(clk),
		.rst(rst),
		.dataOUT(RegWriteW)
		);

	Register #(2) ResultSrc_MtoW(
		.dataIN(ResultSrcM),
		.Stall(GND),
		.Flush(GND),
		.clk(clk),
		.rst(rst),
		.dataOUT(ResultSrcW)
		);

endmodule