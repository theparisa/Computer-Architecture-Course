module memory (input clk, write_en ,input [4:0] address_in, input[7:0] d_in, output [7:0] d_out);

	reg [7 : 0] memory_reg [31:0];

	initial $readmemh("MEM_file.mem", memory_reg);

	
	always @(posedge clk) begin
		if (write_en)
				memory_reg[address_in]<= d_in;
    end

	assign d_out = memory_reg[address_in];

endmodule