
module MUX #(parameter SIZE = 2, parameter WL = 32) (dataIN, select, dataOUT);

	parameter SELECT_SIZE = $clog2(SIZE);

	input [SIZE-1 : 0][WL-1 : 0] dataIN;
	input [SELECT_SIZE-1 : 0] select;

	output [WL-1 : 0] dataOUT;

	assign dataOUT = dataIN[select];

endmodule

module Adder (A, B, S);

	input [31 : 0] A;
	input [31 : 0] B;
	output [31 : 0] S;

	assign S = A + B;
endmodule



module ALU (OpCode, operand1, operand2, result, ZERO);

	parameter[2 : 0]	ADD = 3'b000,
						SUB = 3'b001,
						AND = 3'b010,
						OR =  3'b011,
						SLT = 3'b100;

	input [2 : 0] OpCode;
	input signed [31 : 0] operand1, operand2;
	output signed [31 : 0] result;
	output ZERO;

	reg signed [31 : 0] result_temp;
	assign result = result_temp;

	always @(OpCode, operand1, operand2) begin
		result_temp = 32'b0;
		case(OpCode)
			ADD: begin result_temp = operand1 + operand2; end
			SUB: begin result_temp = operand1 - operand2; end
			AND: begin result_temp = operand1 & operand2; end
			OR:  begin result_temp = operand1 | operand2; end
			SLT: begin result_temp = (operand1 < operand2) ? 32'd1 : 32'd0; end
			default: result_temp = operand1;
		endcase
	end

	assign ZERO = ~|{result};
endmodule

module ImmediateExtension (ImmSrc, Inst, Imm);

	parameter[2 : 0]	I_TYPE =	2'b000,
						S_TYPE =	2'b001,
						B_TYPE =	2'b010,
						J_TYPE =	2'b011,
						U_Type =	2'b100;

	input	[2 : 0]		ImmSrc;
	input	[31 : 0]	Inst;
	output	[31 : 0]	Imm;

	reg [31 : 0] Imm_temp;
	assign Imm = Imm_temp;

	always @(ImmSrc, Inst) begin
		Imm_temp = 32'b0;
		case(ImmSrc)
			I_TYPE: begin Imm_temp = {{20{Inst[31]}}, Inst[31 : 20]}; end
			S_TYPE: begin Imm_temp = {{20{Inst[31]}}, Inst[31 : 25], Inst[11 : 7]}; end
			B_TYPE: begin Imm_temp = {{20{Inst[31]}}, Inst[7], Inst[30 : 25], Inst[11 : 8], 1'b0}; end
			J_TYPE: begin Imm_temp = {{12{Inst[31]}}, Inst[19 : 12], Inst[20], Inst[30 : 21], 1'b0}; end
			U_Type: begin Imm_temp = {Inst[31 : 12], 12'b0}; end
			default: Imm_temp = 32'b0;
		endcase
	end

endmodule

module ProgramCounter (parallelIN, clk,rst, parallelOUT);

	input [31 : 0] parallelIN;
	input clk,rst;
	output [31 : 0] parallelOUT;

	reg [31 : 0] Storage;
	assign parallelOUT = Storage;

	always @(posedge rst, posedge clk) begin
		if(rst) Storage <= 32'b0;
		else	Storage <= parallelIN;
	end

endmodule


module RegisterFile (rs1, rs2, rd, writeData, regwrite, clk ,rst, data1, data2);

	input [4 : 0] rs1, rs2, rd;
	input [31 : 0] writeData;
	input regwrite;
	input clk,rst;
	output [31 : 0] data1, data2;

	reg [31 : 0][31 : 0] RegFile;

	always @(posedge clk, posedge rst) begin
		if(rst) RegFile = 0;
		else begin
			if(regwrite & (rd != 5'b00000))	RegFile[rd] <= writeData;
		end
	end

	assign data1 = RegFile[rs1];
	assign data2 = RegFile[rs2];

endmodule


module InstructionMemory (pc, instruction);


	input [31 : 0] pc;
	output [31 : 0] instruction;

	reg [7 : 0] instMem [$pow(2, 16)-1:0];

    wire [31 : 0] adr;
    assign adr = {pc[31 : 2], 2'b00};

    initial $readmemh("Instructions.mem", instMem);

    assign instruction = {instMem[adr + 3], instMem[adr + 2], instMem[adr + 1], instMem[adr]};

endmodule


module DataMemory (addressIN, dataIN, writeEN, clk,rst, dataOUT);

	input [31 : 0] addressIN;
	input [31 : 0] dataIN;
	input clk,rst, writeEN;
	output [31 : 0] dataOUT;


	reg [7 : 0] dataMem [$pow(2, 16)-1:0];

	wire [31 : 0] adr;
    assign adr = {addressIN[31 : 2], 2'b00};

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


module Datapath(pcsrc, ImmSrc, regwrite, ALUsrc, OpCode, memwrite, resultsrc, clk,rst, ZERO, instruction);

	input regwrite, ALUsrc, memwrite;
	input [1 : 0] pcsrc, resultsrc;
	input [2 : 0] OpCode, ImmSrc;
	input clk,rst;
	output ZERO;
	output [31 : 0] instruction;

	wire [31 : 0] PCIN, PCOUT;
	ProgramCounter PC (.parallelIN(PCIN), .clk(clk),.rst(rst), .parallelOUT(PCOUT));

	InstructionMemory IMEM (.pc(PCOUT), .instruction(instruction));

	wire [31 : 0] data1, data2, writeData;
	RegisterFile regfile (.rs1(instruction[19 : 15]), .rs2(instruction[24 : 20]), .rd(instruction[11 : 7]),
							.writeData(writeData), .regwrite(regwrite), .clk(clk),.rst(rst), .data1(data1), .data2(data2));

	wire [31 : 0] immediate, ALU_data2;
	MUX #(2, 32) ALU_input_MUX (.dataIN({immediate, data2}), .select(ALUsrc), .dataOUT(ALU_data2));

	wire [31 : 0] ALU_out;
	ALU ALU__ (.OpCode(OpCode), .operand1(data1), .operand2(ALU_data2), .result(ALU_out), .ZERO(ZERO));

	wire [31 : 0] DataMemOut;
	DataMemory DMEM (.addressIN(ALU_out), .dataIN(data2), .writeEN(memwrite), .clk(clk),.rst(rst), .dataOUT(DataMemOut));

	ImmediateExtension imm_ext (.ImmSrc(ImmSrc), .Inst(instruction), .Imm(immediate));

	wire [31 : 0] jump_adr, NEXT_PC;
	Adder JumpAdrArrer (.A(immediate), .B(PCOUT), .S(jump_adr));
	Adder NextPCAdder (.A(PCOUT), .B(32'd4), .S(NEXT_PC));

	MUX #(3, 32) pc_src_mux (.dataIN({NEXT_PC,jump_adr, ALU_out}), .select(pcsrc), .dataOUT(PCIN));
	MUX #(4, 32) resultsrc_mux (.dataIN({immediate, NEXT_PC, DataMemOut, ALU_out}), .select(resultsrc), .dataOUT(writeData));

endmodule
