module ALU (input [1:0] op_code, input signed [7:0] operand1, operand2,
			output signed [7:0] result , output ZERO);

	parameter[1:0]	ADD = 2'b00,
					SUB = 2'b01,
					AND = 2'b10,
					NOT = 2'b11;

	reg signed [7:0] result_temp;
	assign result = result_temp;

	always @(op_code, operand1, operand2) begin
		result_temp = 8'b0;
		case(op_code)
			ADD: result_temp = operand1 + operand2;
			SUB: result_temp = operand1 - operand2; 
			AND: result_temp = operand1 & operand2;
			NOT: result_temp = ~operand2;
			default: result_temp = operand1;
		endcase
	end

	assign ZERO = ~|{operand1};
endmodule

