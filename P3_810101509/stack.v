module stack (input clk, push, pop, input [4:0] tos, input [7:0] d_in, output [7:0] d_out);

reg [7:0] stack_reg [15:0];
reg [7:0] d_out_reg;
initial $readmemh("stack_file.mem", stack_reg);

always @(posedge clk) begin
    if (pop) d_out_reg <= stack_reg[tos];
    else if (push) stack_reg[tos] <= d_in;
end

assign d_out = d_out_reg;

endmodule
