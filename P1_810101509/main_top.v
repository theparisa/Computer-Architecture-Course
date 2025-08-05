module main_top(input clk, rst, Start, Run,
				output Fail, Done, The_End, output [7:0] Move);

	wire co_4, cell_val, empty, same, border_reached, Inz_Cnt_4, Inc_Cnt_4, Inz_Cnt_256, Inc_Cnt_256, Dec_Cnt_256, read, write, push_256;
	wire Inz_Cnt_queue, Inc_Cnt_queue, load, reached_the_end;
	
	
	main_dp dp_inst(clk, rst, Start, Inz_Cnt_4, Inc_Cnt_4, Inz_Cnt_256, Inc_Cnt_256, Dec_Cnt_256, read, write, push_256, Inz_Cnt_queue, Inc_Cnt_queue, load,
                    co_4, cell_val, empty, same, border_reached, reached_the_end, Move);
	
	main_cu cu_inst(clk, rst, Start, co_4, cell_val, empty, same, border_reached, Run, reached_the_end,
                    Inz_Cnt_4, Inc_Cnt_4, Inz_Cnt_256, Inc_Cnt_256, Dec_Cnt_256, read, write, push_256, Fail, Done, load, Inz_Cnt_queue, Inc_Cnt_queue, The_End);
	
endmodule
	
					
