module top_module_new(input clk, rst);
    wire load_D_I, pop, push, write_en, push_sel, tos_sel, mem_adr_sel, ZERO, sh_1;
    wire [1:0] adr_sel, alu_sel; wire [1:0] alu_op; wire [2:0] func_op;

    data_path_new data_path_inst(clk, rst, load_D_I, pop, push, write_en, push_sel, tos_sel, mem_adr_sel, sh_1, adr_sel, alu_sel, alu_op,
                             func_op , ZERO);

    contoller_new contoller_inst(clk, rst , ZERO, func_op,
                             load_D_I, pop, push, write_en, push_sel, tos_sel, mem_adr_sel, sh_1, adr_sel, alu_sel, alu_op);

endmodule

