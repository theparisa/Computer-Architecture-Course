module data_path_new(input clk, rst, load_D_I, pop, push, write_en, push_sel, tos_sel, mem_adr_sel, sh_1, input [1:0] adr_sel, alu_sel, input [1:0] alu_op,
                 output [2:0] func_op , output ZERO);

    reg [4:0] pc;
    reg [4:0] address;
    reg [2:0] func_op_reg;
    wire [4:0] mem_address;
    reg [4:0] tos;
    wire [7:0] operand1, operand2, pushed_data, d_out_mem;
    wire [7:0] poped_data;
    wire [7:0] alu_result;


    stack stack_call_1(.clk(clk), .push(push), .pop(pop), .tos(tos), .d_in(pushed_data),
                       .d_out(poped_data));
    
    reg [7:0] shift_reg;

    always@(posedge clk) begin
        if (sh_1) shift_reg <= poped_data;
    end

    memory memory_inst(.clk(clk), .write_en(write_en) ,.address_in(mem_address), .d_in(poped_data),
                       .d_out(d_out_mem));

    ALU ALU_inst(.op_code(alu_op), .operand1(operand1), .operand2(operand2),
			      .result(alu_result) , .ZERO(ZERO));

    always@(posedge clk) begin
        if (load_D_I)begin func_op_reg <= d_out_mem[7:5]; address <= d_out_mem[4:0]; end
    end
    assign func_op = func_op_reg;
    assign mem_address = mem_adr_sel ? address : pc;
    assign pushed_data = push_sel ? d_out_mem : alu_result;

    always@(posedge clk) begin
        if (rst)  begin pc<= 5'd25; tos <= 5'd15; end
    end

    always@(posedge clk) begin
        if (tos_sel) tos <= alu_result;
    end

    always@(posedge clk) begin
        if (adr_sel==2'd1) pc <= alu_result;
        else if (adr_sel==2'd2) pc <= address;
    end


    assign operand1 = alu_sel==2'd0 ? shift_reg :
                      alu_sel==2'd1 ? pc:
                      alu_sel==2'd2 ? tos : 8'd0;

    assign operand2 = alu_sel==2'd0 ? poped_data :
                      alu_sel==2'd1 ? 8'd1 :
                      alu_sel==2'd2 ? 1 : 8'd0;


endmodule

