module main_dp(input clk, rst, start, Inz_Cnt_4, Inc_Cnt_4, Inz_Cnt_256, Inc_Cnt_256, Dec_Cnt_256, read, write, push_256, Inz_Cnt_queue, Inc_Cnt_queue, load,
                  output co_4, cell_val, empty, same, border_reached, reached_the_end, output [7:0] Move_wire);
	
	
	reg [7:0] main_stack [255:0]; 
	reg [7:0] next_move_stack[3:0];
	reg [7:0] Count_256;
	reg [1:0] Count_4;
	reg [7:0] next_move;
	reg [3:0] next_X, next_Y;
	wire [3:0] next_X_wire, next_Y_wire;
	wire [3:0] X,Y;
	wire [7:0] next_move_wire;
	wire left_border_reached, right_border_reached, up_border_reached, down_border_reached;
	reg [7:0] Move;
	reg [7:0] Count_queue;
	
	always @(posedge clk)begin
		if(start)begin
			main_stack[0] <= 8'h00;
			main_stack[255] <= 8'hff;
		end
	end
	
		
	always @(posedge clk, posedge rst) begin
        if (rst)
            Count_256 <= 8'b0;
        else if (Inz_Cnt_256)
            Count_256 <= 8'b0;
        else if (Inc_Cnt_256)
            Count_256 <= Count_256 + 1;
		else if (Dec_Cnt_256)
			Count_256 <= Count_256 - 1;
    end
	
	always @(posedge clk, posedge rst) begin
        if (rst)
            Count_4 <= 2'b0;
        else if (Inz_Cnt_4)
            Count_4 <= 2'b0;
        else if (Inc_Cnt_4)
            Count_4 <= Count_4 + 1;
    end
	
	always @(posedge clk)begin
        if (push_256)
            main_stack[Count_256 + 1] <= {next_X, next_Y};
    end
	
	memory Mem(clk, read, write, next_X_wire, next_Y_wire, cell_val);
	
	assign next_move_wire = next_move;
	assign next_X_wire = next_X;
	assign next_Y_wire = next_Y;
			
	always @(*) begin
		next_X = X;
		next_Y = Y;
		case (Count_4)
			2'd0: next_Y = Y + 1;
			2'd1: next_X = X + 1;
			2'd2: next_X = X - 1;
			2'd3: next_Y = Y - 1;
			default: /* no change */;
		endcase
	end

	wire move_up    = (Count_4 == 2'd0);
	wire move_right = (Count_4 == 2'd1);
	wire move_left  = (Count_4 == 2'd2);
	wire move_down  = (Count_4 == 2'd3);

	assign up_border_reached    = (Y == 4'd15) && move_up;
	assign right_border_reached = (X == 4'd15) && move_right;
	assign left_border_reached  = (X == 4'd0 ) && move_left;
	assign down_border_reached  = (Y == 4'd0 ) && move_down;

	assign border_reached =
		   up_border_reached || right_border_reached ||
		   left_border_reached || down_border_reached;
	
	assign empty = ~|Count_256;
	assign co_4 = &Count_4;
	
	assign X = main_stack[Count_256][7:4];
	assign Y = main_stack[Count_256][3:0];
	
	assign same = main_stack[255] == {next_X, next_Y};
	
	always @(posedge clk, posedge rst) begin
        if (rst)
            Count_queue <= 8'b0;
        else if (Inz_Cnt_queue)
            Count_queue <= 8'b0;
        else if (Inc_Cnt_queue)
            Count_queue <= Count_queue + 1;
    end
	
	always @(posedge clk, posedge rst) begin
		if(rst)
			Move <= 8'b0;
		else if(load)
			Move <= main_stack[Count_queue]; 
	end	
	
	assign reached_the_end = (Count_queue == Count_256 + 2);
	assign Move_wire = Move;
	
endmodule
	
