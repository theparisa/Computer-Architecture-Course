module memory(input clk, RD, WR, input [3:0] X, Y, output reg D_out);

    reg [15:0] mem_16x16 [15:0];

    integer row;

    initial begin
        $readmemb("C:/Users/EMTOO/Desktop/UT_Term6/Computer_Arch/CAs/updated/MEM.txt", mem_16x16);
    end

    always @(posedge clk, posedge RD) begin
        if(RD) 
            D_out = mem_16x16[15 - Y][15 - X];
    end

    always @(posedge clk) begin
        if (WR) 
            mem_16x16[15 - Y][15 - X] = 1'b1;
    end

endmodule
