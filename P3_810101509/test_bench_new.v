`timescale 1ns/1ns
module test_bench_new();
    reg clk = 1'b0; 
    reg rst;
    top_module_new UUT(clk, rst);

    always #3 clk = ~clk;

    initial begin
        rst = 1'b0;
        #20;
        rst = 1'b1;
		#20;
        rst = 1'b0;
        #20;
        
        #1000;

        $stop;
    end
    
endmodule


