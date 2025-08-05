module main_cu(input clk, rst, start, co_4, cell_val, empty, same, border_reached, Run, reached_the_end,
               output reg Inz_Cnt_4, Inc_Cnt_4, Inz_Cnt_256, Inc_Cnt_256, Dec_Cnt_256, read, write, push_256, impossible, The_End, load, Inz_Cnt_queue, Inc_Cnt_queue, Done);

    reg [4:0] pstate, nstate;

    parameter [4:0] 
        Idle = 0,
		initializing = 1,
		checking_border = 2,
        start_reading = 3,
        completing_reading = 4, 
		evaluating_cell_val = 5,
        going_to_next_cell = 6,
		pushing_to_main_stack = 7,
		completing_pushing = 8,
		comparing_curr_cell_to_goal = 9,
		Increasing_stack_level = 10,
		poping_from_main_stack = 11,
		completing_poping = 12, 
		failing = 13,
		reaching_the_goal = 14,
		starting_to_show_the_path = 15,
		loading = 16,
		Increasing_queue_level = 17,
		checking_to_reach_the_end = 18,
		finish_showing_the_path = 19;
		
		

	always @(pstate, start, co_4, cell_val, empty, same, border_reached, Run, reached_the_end) begin
        nstate = Idle;
        {Inz_Cnt_4, Inc_Cnt_4, Inz_Cnt_256, Inc_Cnt_256, Dec_Cnt_256, read, write, push_256, impossible, The_End, load, Inz_Cnt_queue, Inc_Cnt_queue, Done} = 14'b0;

        case (pstate)
			Idle: begin
				nstate = start ? initializing : Idle;
				Inz_Cnt_256 = 1'b1;
			end
			initializing: begin
				nstate = checking_border;
				Inz_Cnt_4 = 1'b1;
			end
			checking_border: begin
				nstate = (border_reached & ~co_4) ? going_to_next_cell : 
						 (border_reached & co_4) ? poping_from_main_stack : start_reading;
			end
			start_reading: begin
				nstate = completing_reading;
				read = 1'b1;
			end
			completing_reading: begin
				nstate = evaluating_cell_val;
			end
			evaluating_cell_val: begin
				nstate = (cell_val & ~co_4) ? going_to_next_cell:
						 (cell_val & co_4) ? poping_from_main_stack:
						 (~cell_val) ? pushing_to_main_stack : evaluating_cell_val;
			end
			going_to_next_cell: begin
				nstate = checking_border;
				Inc_Cnt_4 = 1'b1;
			end
			pushing_to_main_stack: begin
				nstate = completing_pushing;
				push_256 = 1'b1;
				write = 1'b1;
			end
			completing_pushing: begin
				nstate = comparing_curr_cell_to_goal;
			end
			comparing_curr_cell_to_goal: begin
				nstate = same ? reaching_the_goal : Increasing_stack_level;
			end
			Increasing_stack_level:  begin
				nstate = initializing;
				Inc_Cnt_256 = 1'b1;
			end
			poping_from_main_stack: begin
				nstate = completing_poping;
				Dec_Cnt_256 = 1'b1;
			end
			completing_poping: begin
				nstate = empty ? failing : initializing;
			end
			failing: begin
				nstate = Idle;
				impossible = 1'b1;
			end
			reaching_the_goal: begin
				nstate = starting_to_show_the_path;
				The_End = 1'b1;
			end
			starting_to_show_the_path: begin
				nstate = Run ? loading : starting_to_show_the_path;
				Inz_Cnt_queue = 1'b1;
			end
			loading: begin
				nstate = Increasing_queue_level;
				load = 1'b1;
			end
			Increasing_queue_level: begin
				nstate = checking_to_reach_the_end;
				Inc_Cnt_queue = 1'b1;
			end
			checking_to_reach_the_end: begin
				nstate = reached_the_end ? finish_showing_the_path : loading;
			end
			finish_showing_the_path: begin
				nstate = Idle;
				Done = 1'b1;
			end
			default: nstate = Idle;
		endcase
	end
	
	always @(posedge clk, posedge rst) begin
        if (rst)
            pstate <= Idle;
        else
            pstate <= nstate;
    end

    
endmodule
		
			
		
        