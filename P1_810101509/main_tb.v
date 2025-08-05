module main_tb ();
    reg clk = 1'b0;
    reg rst;
    reg Start;
    reg Run;

    wire Fail;
	wire Done;
    wire The_End;
    wire [7:0] Move;

    main_top UUT(clk, rst, Start, Run,
                 Fail, Done, The_End, Move); 

    always #3 clk = ~clk;

    initial begin
        Start = 1'b0;
        rst = 1'b1;
        Run = 1'b0;  
        
        #30 rst = 1'b0;  

        #15 Start = 1'b1;
        #10;  
        #15 Start = 1'b0;
		
		if (Fail == 1'b1) begin
            $display("Failing was asserted. Exiting simulation.");
            $stop;
        end

        wait (Done == 1'b1); 

        #10 Run = 1'b1;

        #5000;
        if (Done == 1'b0) begin
            $display("Done was not asserted. Exiting simulation.");
            $stop;
        end

        #2000;
        $stop;
    end
endmodule