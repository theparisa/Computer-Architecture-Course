module Register #(parameter SIZE = 32) (dataIN, Stall, Flush, clk,rst, dataOUT);
	input [SIZE-1:0] dataIN;
    input Stall, Flush;
	input clk,rst;
	output [SIZE-1:0] dataOUT;

	reg [SIZE-1:0] rg;
	assign dataOUT = rg;

	always @(posedge clk, posedge rst) begin
		if(rst)			rg <= {(SIZE){1'b0}};
        else if(Flush)  rg <= {(SIZE){1'b0}};
		else if(~Stall) rg <= dataIN;
	end

endmodule

module MUX #(parameter SIZE = 2, parameter WL = 32) (dataIN, select, dataOUT);

	parameter SELECT_SIZE = $clog2(SIZE);

	input [SIZE-1:0][WL-1:0] dataIN;
	input [SELECT_SIZE-1:0] select;

	output [WL-1:0] dataOUT;

	assign dataOUT = dataIN[select];

endmodule

module Adder #(parameter WL = 32) (A, B, S);

	input [WL-1:0] A;
	input [WL-1:0] B;
	output [WL-1:0] S;

	assign S = A + B;
endmodule



module ALU #(parameter WL = 32) (OpCode, operand1, operand2, result, ZERO);

	parameter[2:0]	ADD = 3'b000,
					SUB = 3'b001,
					AND = 3'b010,
					OR =  3'b011,
					SLT = 3'b100,
					XOR = 3'b101,
					PASS= 3'b110;

	input [2:0] OpCode;
	input signed [WL-1:0] operand1, operand2;
	output signed [WL-1:0] result;
	output ZERO;

	reg signed [WL-1:0] result_temp;
	assign result = result_temp;

	always @(OpCode, operand1, operand2) begin
		result_temp = {(WL){1'b0}};
		case(OpCode)
			ADD: begin result_temp = operand1 + operand2; end
			SUB: begin result_temp = operand1 - operand2; end
			AND: begin result_temp = operand1 & operand2; end
			OR:  begin result_temp = operand1 | operand2; end
			SLT: begin result_temp = (operand1 < operand2) ? {{(WL-1){1'b0}}, 1'b1} : {(WL){1'b0}}; end
			XOR: begin result_temp = operand1 ^ operand2; end
			PASS:begin result_temp = operand2; end
			default: result_temp = operand2;
		endcase
	end

	assign ZERO = ~|{result};
endmodule

module ImmediateExtension (ImmSrc, Inst, Imm);

	parameter[2:0]	I_TYPE =	2'b000,
					S_TYPE =	2'b001,
					B_TYPE =	2'b010,
					J_TYPE =	2'b011,
					U_Type =	2'b100;

	input	[2:0]	ImmSrc;
	input	[31:0]	Inst;
	output	[31:0]	Imm;

	reg [31:0] Imm_temp;
	assign Imm = Imm_temp;

	always @(ImmSrc, Inst) begin
		Imm_temp = 32'b0;
		case(ImmSrc)
			I_TYPE: begin Imm_temp = {{20{Inst[31]}}, Inst[31:20]}; end
			S_TYPE: begin Imm_temp = {{20{Inst[31]}}, Inst[31:25], Inst[11:7]}; end
			B_TYPE: begin Imm_temp = {{20{Inst[31]}}, Inst[7], Inst[30:25], Inst[11:8], 1'b0}; end
			J_TYPE: begin Imm_temp = {{12{Inst[31]}}, Inst[19:12], Inst[20], Inst[30:21], 1'b0}; end
			U_Type: begin Imm_temp = {Inst[31:12], 12'b0}; end
			default: Imm_temp = 32'b0;
		endcase
	end

endmodule

module ProgramCounter #(parameter SIZE = 32) (parallelIN, clk,rst,Stall, parallelOUT);

	input [SIZE-1:0] parallelIN;
	input clk,rst, Stall;
	output [SIZE-1:0] parallelOUT;

	reg [SIZE-1:0] Storage;
	assign parallelOUT = Storage;

	always @(posedge rst, posedge clk) begin
		if(rst) Storage <= {(SIZE){1'b0}};
		else if (~Stall)	Storage <= parallelIN;
	end

endmodule


module RegisterFile (RS1, RS2, RD, WriteData, RegWrite, clk,rst, RD1, RD2);

	input [4:0] RS1, RS2, RD;
	input [31:0] WriteData;
	input RegWrite;
	input clk,rst;
	output [31:0] RD1, RD2;

	reg [31:0][31:0] RegFile;

	always @(negedge clk, posedge rst) begin
		if(rst) RegFile = 0;
		else begin
			if(RegWrite & (RD != 5'b00000))	RegFile[RD] <= WriteData;
		end
	end

	assign RD1 = RegFile[RS1];
	assign RD2 = RegFile[RS2];

endmodule


module InstructionMemory (pc, instruction);


	input [31:0] pc;
	output [31:0] instruction;

	reg [7:0] instMem [$pow(2, 16)-1:0];

    wire [31:0] adr;
    assign adr = {pc[31:2], 2'b00};

    initial $readmemh("Instructions.mem", instMem);

    assign instruction = {instMem[adr + 3], instMem[adr + 2], instMem[adr + 1], instMem[adr]};

endmodule


module DataMemory (addressIN, dataIN, writeEN, clk,rst, dataOUT);

	input [31:0] addressIN;
	input [31:0] dataIN;
	input clk,rst, writeEN;
	output [31:0] dataOUT;


	reg [7:0] dataMem [$pow(2, 16)-1:0];

	wire [31:0] adr;
    assign adr = {addressIN[31:2], 2'b00};

	always @(negedge rst) begin
		$readmemh("Data.mem", dataMem);
	end

	initial $readmemh("Data.mem", dataMem);

	integer i;
	always @(posedge clk, posedge rst) begin
        if(rst)	begin
			for(i = 0 ; i < $pow(2, 16); i = i + 1) dataMem[i] = 0;
		end
		else begin
			if (writeEN)
				{dataMem[adr + 3], dataMem[adr + 2], dataMem[adr + 1], dataMem[adr]} <= dataIN;
		end
	end


	assign dataOUT = {dataMem[adr + 3], dataMem[adr + 2], dataMem[adr + 1], dataMem[adr]};

endmodule


module Datapath_FETCH (PCTargetE, StallF, PCSrcE, clk, rst, InstrF, PCF, PCPlus4F);

	input [31:0] PCTargetE;
	input PCSrcE, StallF;
	input clk,rst;

	output [31:0] PCF, PCPlus4F, InstrF;

	wire [31:0] NPC;
	MUX #(2, 32) NextPCMUX (
		.dataIN({PCTargetE,PCPlus4F}),
		.select(PCSrcE),
		.dataOUT(NPC)
		);

	ProgramCounter #(32) PC (
		.parallelIN(NPC),
		.clk(clk),
		.rst(rst),
		.Stall(StallF),
		.parallelOUT(PCF)
		);

	Adder #(32) PCPlus4FAdder (
		.A(PCF),
		.B(32'd4),
		.S(PCPlus4F)
		);

	InstructionMemory InstrMEM(
		.pc(PCF),
		.instruction(InstrF)
		);
endmodule

module Datapath_DECODE (InstrD_in, PCD_in, PCPlus4D_in, ResultW, RDW, ImmSrcD, RegWriteW, clk, rst,
						PCPlus4D, ExtImmD, RDD, RS1D, RS2D, PCD, RD1D, RD2D, InstrD);

	input [31:0] InstrD_in, PCD_in, PCPlus4D_in, ResultW;
	input [4:0] RDW;
	input [2:0] ImmSrcD;
	input RegWriteW;
	input clk,rst;

	output [31:0] PCD, PCPlus4D, ExtImmD;
	output [4:0] RDD, RS1D, RS2D;
	output [31:0] RD1D, RD2D, InstrD;

	assign InstrD = InstrD_in;
	assign PCD = PCD_in;
	assign PCPlus4D = PCPlus4D_in;
	assign RS1D = InstrD[19:15];
	assign RS2D = InstrD[24:20];
	assign RDD = InstrD[11:7];

	RegisterFile RegFile (
		.RS1(InstrD[19:15]),
		.RS2(InstrD[24:20]),
		.RD(RDW),
		.WriteData(ResultW),
		.RegWrite(RegWriteW),
		.clk(clk),
		.rst(rst),
		.RD1(RD1D),
		.RD2(RD2D)
		);

	ImmediateExtension ImmEXT (
	.ImmSrc(ImmSrcD),
	.Inst(InstrD),
	.Imm(ExtImmD)
	);
endmodule

module Datapath_EXECUTE (RD1E, RD2E, PCE, RS1E_in, RS2E_in, RDE_in, ExtImmE, PCPlus4E_in,
						ResultW, ALUResultM, ForwardAE, ForwardBE, ALUControlE, ALUSrcE, PCTargetSelectE, clk, rst,
						RS1E, RS2E, RDE, PCPlus4E, PCTargetE, WriteDataE, ALUResultE, ZEROE);

	input [31:0] RD1E, RD2E, PCE;
	input [4:0] RS1E_in, RS2E_in, RDE_in;
	input [31:0] ExtImmE, PCPlus4E_in, ResultW, ALUResultM;
	input [1:0] ForwardAE, ForwardBE;
	input [2:0] ALUControlE, ALUSrcE;
	input PCTargetSelectE;
	input clk,rst;

	output [4:0] RS1E, RS2E, RDE;
	output [31:0] PCPlus4E, PCTargetE, WriteDataE, ALUResultE;
	output ZEROE;

	assign RS1E = RS1E_in;
	assign RS2E = RS2E_in;
	assign RDE = RDE_in;
	assign PCPlus4E = PCPlus4E_in;

	wire [31:0] SrcAE, SrcBE_MUX_IN, SrcBE;
	assign WriteDataE = SrcBE_MUX_IN;
	MUX #(3, 32) SrcAE_FORWARD_MUX (
		.dataIN({ALUResultM, ResultW, RD1E}),
		.select(ForwardAE),
		.dataOUT(SrcAE)
		);
	MUX #(3, 32) SrcBE_FORWARD_MUX (
		.dataIN({ALUResultM, ResultW, RD2E}),
		.select(ForwardBE),
		.dataOUT(SrcBE_MUX_IN)
		);

	MUX #(2, 32) SrcBE_MUX (
		.dataIN({ExtImmE, SrcBE_MUX_IN}),
		.select(ALUSrcE),
		.dataOUT(SrcBE)
		);

	wire [31:0] PCTarget_TEMP;
	MUX #(2, 32) PCTargetE_MUX (
		.dataIN({SrcAE, PCE}),
		.select(PCTargetSelectE),
		.dataOUT(PCTarget_TEMP)
		);

	Adder #(32) PCTarget_ADDER (
		.A(PCTarget_TEMP),
		.B(ExtImmE),
		.S(PCTargetE)
		);

	ALU #(32) ALU__(
		.OpCode(ALUControlE),
		.operand1(SrcAE),
		.operand2(SrcBE),
		.result(ALUResultE),
		.ZERO(ZEROE)
		);
endmodule

module Datapath_MEMORY_ACCESS (ALUResultM_in, WriteDataM, RDM_in, PCPlus4M_in, MemWriteM, clk, rst,
							   ALUResultM, RDM, PCPlus4M, ReadDataM);

	input [31:0] ALUResultM_in, WriteDataM;
	input [4:0] RDM_in;
	input [31:0] PCPlus4M_in;
	input MemWriteM;
	input clk, rst;

	output [31:0] ALUResultM;
	output [4:0] RDM;
	output [31:0] PCPlus4M, ReadDataM;

	assign ALUResultM = ALUResultM_in;
	assign PCPlus4M = PCPlus4M_in;
	assign RDM = RDM_in;

	DataMemory DataMEM(
		.addressIN(ALUResultM),
		.dataIN(WriteDataM),
		.writeEN(MemWriteM),
		.clk(clk),
		.rst(rst),
		.dataOUT(ReadDataM)
		);
endmodule

module Datapath_WRITE_BACK (ALUResultW, ReadDataW, RDW_in, PCPlus4W, ResultSrcW, clk, rst,
							RDW, ResultW);

	input [31:0] ALUResultW, ReadDataW;
	input [4:0] RDW_in;
	input [31:0] PCPlus4W;
	input [1:0] ResultSrcW;
	input clk, rst;

	output [4:0] RDW;
	output [31:0] ResultW;

	assign RDW = RDW_in;

	MUX #(3, 32) ResultSrcW_MUX (
		.dataIN({PCPlus4W, ReadDataW, ALUResultW}),
		.select(ResultSrcW),
		.dataOUT(ResultW)
		);
endmodule


module Datapath (StallF, PCSrcE, RegWriteW, ImmSrcD, ALUSrcE, ALUControlE, MemWriteM, ResultSrcW,
				ForwardAE, ForwardBE, FlushD, FlushE, StallD, PCTargetSelectE, clk, rst,
				InstrD, ZEROE,
				RS1D, RS2D, RS1E, RS2E, RDE, RDM, RDW);

	input StallF, PCSrcE;
	input RegWriteW;
	input [2:0] ImmSrcD;
	input ALUSrcE;
	input [2:0] ALUControlE;
	input MemWriteM;
	input [1:0] ResultSrcW;
	input [1:0] ForwardAE, ForwardBE;
	input PCTargetSelectE;
	input StallD;
	input FlushE, FlushD;
	input clk, rst;

	output [31:0] InstrD;
	output ZEROE;
	output [4:0] RS1D, RS2D, RS1E, RS2E, RDE, RDM, RDW;

	supply0 GND;

	wire [31:0] PCTargetE, InstrF, PCF, PCPlus4F;
	wire [31:0] InstrD_in, PCD_in, PCPlus4D_in, ResultW;
	wire [31:0] PCD, PCPlus4D, ExtImmD;
	wire [4:0] RDD;
	wire [31:0] RD1D, RD2D;
	wire [31:0] RD1E, RD2E, PCE;
	wire [4:0] RS1E_in, RS2E_in, RDE_in;
	wire [31:0] ExtImmE, PCPlus4E_in, ALUResultM;
	wire [31:0] PCPlus4E, WriteDataE, ALUResultE;
	wire [31:0] ALUResultM_in, WriteDataM;
	wire [4:0] RDM_in;
	wire [31:0] PCPlus4M_in;
	wire [31:0] PCPlus4M, ReadDataM;
	wire [31:0] ALUResultW, ReadDataW;
	wire [4:0] RDW_in;
	wire [31:0] PCPlus4W;


	Datapath_FETCH FETCH (PCTargetE, StallF, PCSrcE, clk, rst, InstrF, PCF, PCPlus4F);

	Register #(32) Instr_FtoD (
			.dataIN(InstrF),
			.Stall(StallD),
			.Flush(FlushD),
			.clk(clk),
			.rst(rst),
			.dataOUT(InstrD_in)
			);

	Register #(32) PC_FtoD (
		.dataIN(PCF),
		.Stall(StallD),
		.Flush(FlushD),
		.clk(clk),
		.rst(rst),
		.dataOUT(PCD_in)
		);

	Register #(32) PCPlus4_FtoD (
		.dataIN(PCPlus4F),
		.Stall(StallD),
		.Flush(FlushD),
		.clk(clk),
		.rst(rst),
		.dataOUT(PCPlus4D_in)
		);

	Datapath_DECODE DECODE (InstrD_in, PCD_in, PCPlus4D_in, ResultW, RDW, ImmSrcD, RegWriteW, clk, rst,
						PCPlus4D, ExtImmD, RDD, RS1D, RS2D, PCD, RD1D, RD2D, InstrD);

	Register #(32) RD1_DtoE (
		.dataIN(RD1D),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(RD1E)
		);

	Register #(32) RD2_DtoE (
		.dataIN(RD2D),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(RD2E)
		);

	Register #(32) PC_DtoE (
		.dataIN(PCD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(PCE)
		);

	Register #(5) RS1_DtoE (
		.dataIN(RS1D),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(RS1E_in)
	);

	Register #(5) RS2_DtoE (
		.dataIN(RS2D),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(RS2E_in)
	);

	Register #(5) RD_DtoE (
		.dataIN(RDD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(RDE_in)
	);

	Register #(32) PCPlus4_DtoE (
		.dataIN(PCPlus4D),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(PCPlus4E_in)
	);

	Register #(32) ExtImm_DtoE (
		.dataIN(ExtImmD),
		.Stall(GND),
		.Flush(FlushE),
		.clk(clk),
		.rst(rst),
		.dataOUT(ExtImmE)
	);

	Datapath_EXECUTE EXECUTE (RD1E, RD2E, PCE, RS1E_in, RS2E_in, RDE_in, ExtImmE, PCPlus4E_in,
						ResultW, ALUResultM, ForwardAE, ForwardBE, ALUControlE, ALUSrcE, PCTargetSelectE, clk, rst,
						RS1E, RS2E, RDE, PCPlus4E, PCTargetE, WriteDataE, ALUResultE, ZEROE);


	Register #(32) ALUResult_EtoM (
			.dataIN(ALUResultE),
			.Stall(GND),
			.Flush(GND),
			.clk(clk),
			.rst(rst),
			.dataOUT(ALUResultM_in)
		);

	Register #(32) WriteData_EtoM (
			.dataIN(WriteDataE),
			.Stall(GND),
			.Flush(GND),
			.clk(clk),
			.rst(rst),
			.dataOUT(WriteDataM)
		);

	Register #(5) RD_EtoM (
			.dataIN(RDE),
			.Stall(GND),
			.Flush(GND),
			.clk(clk),
			.rst(rst),
			.dataOUT(RDM_in)
		);

	Register #(32) PCPlus4_EtoM (
			.dataIN(PCPlus4E),
			.Stall(GND),
			.Flush(GND),
			.clk(clk),
			.rst(rst),
			.dataOUT(PCPlus4M_in)
		);


	Datapath_MEMORY_ACCESS MEMORY_ACCESS (ALUResultM_in, WriteDataM, RDM_in, PCPlus4M_in, MemWriteM, clk, rst,
							   ALUResultM, RDM, PCPlus4M, ReadDataM);


	Register #(32) ALUResult_MtoW (
			.dataIN(ALUResultM),
			.Stall(GND),
			.Flush(GND),
			.clk(clk),
			.rst(rst),
			.dataOUT(ALUResultW)
		);

	Register #(32) ReadData_MtoW (
			.dataIN(ReadDataM),
			.Stall(GND),
			.Flush(GND),
			.clk(clk),
			.rst(rst),
			.dataOUT(ReadDataW)
		);

	Register #(5) RD_MtoW (
			.dataIN(RDM),
			.Stall(GND),
			.Flush(GND),
			.clk(clk),
			.rst(rst),
			.dataOUT(RDW_in)
		);

	Register #(32) PCPlus4_MtoW (
			.dataIN(PCPlus4M),
			.Stall(GND),
			.Flush(GND),
			.clk(clk),
			.rst(rst),
			.dataOUT(PCPlus4W)
		);

	Datapath_WRITE_BACK WRITE_BACK (ALUResultW, ReadDataW, RDW_in, PCPlus4W, ResultSrcW, clk, rst,
							RDW, ResultW);


endmodule