module contoller_new(input clk, rst , ZERO, input [2:0] func_op,
                 output reg load_D_I, pop, push, write_en, push_sel, tos_sel, mem_adr_sel, sh_1, output reg [1:0] adr_sel, alu_sel, output reg [1:0] alu_op);
    
    parameter[3:0] FETCH = 4'd0 , DECODE = 4'd1, POP1_L = 4'd2 , POP2_L = 4'd3, PUSH_L = 4'd4,
              increasing_tos = 4'd5, PUSH_M = 4'd6, POP_M = 4'd7, writing_data = 4'd8, JMP = 4'd9, reading_tos = 4'd10, JZ = 4'd11;
    
    parameter[2:0] ADD  = 3'b000 , SUB = 3'b001, AND = 3'b010, NOT = 3'b011, PUSH_I = 3'b100,
                   POP_I = 3'b101 , JMP_I = 3'b110 , JZ_I = 3'b111;

    reg [4:0] pstate, nstate;   

    always@(pstate, ZERO, func_op)begin
        {load_D_I, pop, push, write_en, push_sel, tos_sel, mem_adr_sel, sh_1} = 8'b0;
        adr_sel = 2'b0; alu_sel = 2'b0;
        alu_op = 2'd0;


        case(pstate)
            FETCH: load_D_I = 1'b1;
            DECODE: begin adr_sel = 2'd1; alu_sel = 2'd1; alu_op = 2'd0; end
            POP1_L: begin pop = 1'b1; alu_sel = 2'd2; alu_op = 2'd1; tos_sel = 1'b1;end
            POP2_L : begin pop = 1'b1; sh_1 = 1'b1; end
            PUSH_L : begin push = 1'b1; alu_sel = 2'd0; push_sel = 1'b0; alu_op = func_op[1:0]; end
            increasing_tos : begin tos_sel = 1'b1; alu_op = 2'd0; alu_sel = 2'd2; end
            PUSH_M : begin mem_adr_sel = 1'b1; push_sel = 1'b1; push = 1'b1; end
            POP_M : begin pop = 1'b1; tos_sel = 1'b1; alu_op = 2'd1; alu_sel = 2'd2; end
            writing_data : begin write_en = 1'b1; mem_adr_sel = 1'b1; end
            JMP : adr_sel = 2'd2;
            reading_tos : pop =1'b1;
            JZ : begin if(ZERO) adr_sel = 2'd2; end

        endcase
    end
    always@(pstate, func_op)begin
        nstate = 4'd0;

        case(pstate)
            FETCH: nstate = DECODE;
            DECODE: begin 
                case(func_op)
                    ADD : nstate = POP1_L; SUB : nstate = POP1_L; AND : nstate = POP1_L; NOT : nstate = POP2_L;
                    PUSH_I : nstate = increasing_tos;
                    POP_I : nstate = POP_M;
                    JMP_I : nstate = JMP;
                    JZ_I : nstate = reading_tos;
                endcase
            end
            POP1_L: nstate =  POP2_L;
            POP2_L : nstate = PUSH_L;
            PUSH_L : nstate = FETCH;
            increasing_tos : nstate = PUSH_M;
            PUSH_M : nstate = FETCH;
            POP_M : nstate = writing_data;
            writing_data : nstate = FETCH;
            JMP : nstate = FETCH;
            reading_tos : nstate = JZ;
            JZ : nstate = FETCH;
        endcase
    end

    always@(posedge clk, posedge rst)begin
        if (rst) pstate <= FETCH;
        else pstate <= nstate;
    end

endmodule

