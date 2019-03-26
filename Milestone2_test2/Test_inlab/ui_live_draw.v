module ui_live_draw(  // DRAW autemately after reset!!!
	input [3:0]KEY,
	input CLOCK_50,
	input [9:0]SW,
	output VGA_CLK,   						//	VGA Clock
	output VGA_HS,							//	VGA H_SYNC
	output VGA_VS,							//	VGA V_SYNC
	output VGA_BLANK_N,						//	VGA BLANK
	output VGA_SYNC_N,						//	VGA SYNC
	output [9:0] VGA_R,   						//	VGA Red[9:0]
	output [9:0] VGA_G,	 						//	VGA Green[9:0]
	output [9:0] VGA_B, 						//	VGA Blue[9:0]);
	output [7:0] LEDR);  

	vga_adapter VGA(
			.resetn(KEY[0]),
			.clock(CLOCK_50),
			.colour(3'b010), 
			.x(x),
			.y(y),
			.plot(writeEn),
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
	wire [7:0] x;
	wire [6:0] y;

 	// reset : KEY[0]					
	live_draw m1(KEY[0],CLOCK_50, x, y, LEDR[0]);

endmodule

module live_draw (
	input reset_n, 
	input clk, 
	output [7:0] x,
	output [6:0] y, 
	output done);
	wire reset_datapath, enable_datapath;
	live_draw_datapath d1(.reset_n (reset_datapath), 
			    .clk (clk), 
				.enable(enable_datapath),
				.x(x),
				.y(y),
				.done(done));

	live_draw_control(
	.reset_n(reset_n), 
	.clk(clk),
	.done(done),
	.reset_live_draw(reset_datapath),
	.enable_datapath(enable_datapath)); // controls draw the word : LIVE
	

endmodule

module live_draw_datapath (input reset_n, 
			   input clk, 
			   input enable, 
			   output reg [7:0] x,
			   output reg [6:0] y,
			   output done);  // draw the word : LIVE

	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd10;  // from middle
			y <= 7'd10;  // from top
		end
		else if (done)
		begin
			x <= 8'd10;  // from middle
			y <= 7'd10;  // from top
		end	
		else if (enable11)
		begin
			x <= 8'd26 + increment11;
			y <= 7'd14;

		end
		else if (enable10)
		begin
			x <= 8'd26 + increment10;
			y <= 7'd12;

		end
		else if (enable9)
		begin
			x <= 8'd26;
			y <= 7'd10 + increment9;

		end
		else if (enable8)
		begin
			x <= 8'd26 + increment8;
			y <= 7'd10;

		end
		else if (enable7)
		begin
			x <= 8'd22 + increment7;
			y <= 7'd14 - increment7;

		end
		else if (enable6)
		begin
			x <= 8'd18 + increment6;
			y <= 7'd10 + increment6;

		end
		else if (enable5)
		begin
			x <= 8'd14 + increment5;
			y <= 7'd14;

		end
		else if (enable4)
		begin
			x <= 8'd16;
			y <= 7'd10 + increment4;

		end
		else if (enable3)
		begin
			x <= 8'd14  + increment3;  
			y <= 7'd10;

		end
		else if (enable2)  // L
		begin
			x <= 8'd10 + increment2;
			y <= 7'd14;
		end
		else if (enable)
		begin
			x <= 8'd10; 
			y <= 7'd10 + increment1; 
		end
	
	end


	counter_6_LIVE c1(clk, enable, reset_n, increment1);
	assign enable2 = (increment1 == 3'b101) ? 1 : 0;

	counter_6_LIVE c2(clk, enable2, reset_n, increment2);
	assign enable3 = (increment2 == 3'b101) ? 1 : 0;

	counter_6_LIVE c3(clk, enable3, reset_n, increment3);
	assign enable4 = (increment3 == 3'b101) ? 1 : 0;

	counter_6_LIVE c4(clk, enable4, reset_n, increment4);
	assign enable5 = (increment4 == 3'b101) ? 1 : 0;

	counter_6_LIVE c5(clk, enable5, reset_n, increment5);
	assign enable6 = (increment5 == 3'b101) ? 1 : 0;

	counter_6_LIVE c6(clk, enable6, reset_n, increment6);
	assign enable7 = (increment6 == 3'b101) ? 1 : 0;

	counter_6_LIVE c7(clk, enable7, reset_n, increment7);
	assign enable8 = (increment7 == 3'b101) ? 1 : 0;

	counter_6_LIVE c8(clk, enable8, reset_n, increment8);
	assign enable9 = (increment8 == 3'b101) ? 1 : 0;

	counter_6_LIVE c9(clk, enable9, reset_n, increment9);
	assign enable10 = (increment9 == 3'b101) ? 1 : 0;

	counter_6_LIVE c10(clk, enable10, reset_n, increment10);
	assign enable11 = (increment10 == 3'b101) ? 1 : 0;

	counter_6_LIVE c11(clk, enable11, reset_n, increment11);
	assign done = (increment11 == 3'b101) ? 1 : 0;
endmodule

module live_draw_control ( // DRAW autemately after reset
	input reset_n, 
	input clk,
	input done,
	output reg reset_live_draw,
	output reg enable_datapath); // controls draw the word : LIVE

localparam RESET = 3'b000,
	   DRAW = 3'b001,
	   DONE = 3'b010;

	reg [2:0] CURRENT_STATE, NEXT_STATE;

	always@(*)
		begin
			case (CURRENT_STATE)
			RESET: NEXT_STATE = (reset_n) ? RESET : DRAW;
			DRAW: NEXT_STATE = (done)? DONE : DRAW;
			DONE: NEXT_STATE = DONE;
			endcase
		end

	always@(*)
		begin
			reset_live_draw <= 1;
			enable_datapath <= 0;
			case (CURRENT_STATE)
			RESET: begin reset_live_draw <= 0; end
			DRAW: begin enable_datapath <= 1; end
			endcase
		end
	always@(posedge clk)
		begin
			if (!reset_n)
				begin
					CURRENT_STATE <= RESET;
				end
			else 
				begin
					CURRENT_STATE <= NEXT_STATE;
				end
		end


endmodule

module counter_6_LIVE (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b101)
				increment <= 3'b101;
			else 
				increment <= increment + 1'b1;
		end
	end
endmodule 
