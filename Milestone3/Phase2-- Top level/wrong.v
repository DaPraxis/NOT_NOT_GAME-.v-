// this version only used for detect and debug, approved in milestone 1
//module ui_START(
//	input [3:0]KEY,
//	input CLOCK_50,
//	input [9:0]SW,
//	output VGA_CLK,   						//	VGA Clock
//	output VGA_HS,							//	VGA H_SYNC
//	output VGA_VS,							//	VGA V_SYNC
//	output VGA_BLANK_N,						//	VGA BLANK
//	output VGA_SYNC_N,						//	VGA SYNC
//	output [9:0] VGA_R,   						//	VGA Red[9:0]
//	output [9:0] VGA_G,	 						//	VGA Green[9:0]
//	output [9:0] VGA_B, 						//	VGA Blue[9:0]);
//	output [7:0] LEDR);   						
//	ui_start m1(CLOCK_50,KEY[0],~KEY[1],~KEY[2],   
//		  VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, LEDR[0]);
//
//endmodule

module ui_wrong
	(
		input clk,						
      input reset_vga, // reset controller
      input enable_control, // enable the control
		input clear,
		output [7:0] x,
		output [6:0] y,
		output [2:0] color,
		output done, 
		output writeEn
	);


	wire enable, reset_datapath;
	control_UI_correct c0(clear, clk, reset_vga, enable_control, enable, writeEn, reset_datapath, color);
	datapath_correct d0(clk, reset_datapath, enable, x, y, done);


endmodule


// enable unit set start the unit, change with a palse of 1 : 0000100000
module control_UI_wrong(	input clear,
			input clk, 
			   input reset_n,
			   input enable_unit,
			   output reg enable, 
			   output reg writeEn,
			   output reg reset_datapath, 
			   output [2:0] color);

	localparam 	ENABLE_STATE = 4'b0000, 
				ENABLE_WAIT = 4'b0001, 
				DRAW = 4'b0010,
				DISABLE = 4'b0011;
	reg [1:0] current_state, next_state;

	always @(*) begin
		case (current_state)
			DISABLE : next_state = (enable_unit) ? DRAW : DISABLE;
			// ENABLE_STATE : next_state = (enable_unit) ? ENABLE_STATE : ENABLE_WAIT;
			// ENABLE_WAIT : next_state = DRAW;
			DRAW : next_state = (reset_n) ? DRAW : DISABLE;
		endcase
	end

	always @(*) begin
		enable = 1'b0;
		writeEn = 1'b0;
		reset_datapath = 1'b0;
		case (current_state)
			DRAW: begin
				enable = 1'b1;
				writeEn = 1'b1;
				reset_datapath = 1'b1;
			end
		endcase
	end

	always @(posedge clk) begin
		if (!reset_n) begin
			current_state <= DISABLE;
		end
		else begin
			current_state <= next_state;
		end
	end
	
	assign color = (clear) ? 3'b000 : 3'b010;
endmodule



module datapath_wrong (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1, increment2, increment3, increment4, increment5, increment6, increment7, increment8, increment9, increment10,
	increment11, increment12, increment13, increment14, increment15, increment16, increment17 ;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1, enable2, enable3, enable4, enable5, enable6, enable7, enable8, enable9, enable10, enable11, enable12, enable13, enable14, enable15, enable16, enable17;

	
	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (done)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (enable4)
		begin
			x <= 8'd79 - increment4;
			y <= 7'd63 + increment4;
		end
		else if (enable3)
		begin
			x <= 8'd79 + increment3;
			y <= 7'd63 + increment3;
		end
		else if (enable2)
		begin
			x <= 8'd79 + increment2;
			y <= 7'd63 - increment2;
		end
		else if (enable1)
		begin
			x <= 8'd79 - increment1; 
			y <= 7'd63 - increment1; 
		end
	
	end


	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	assign enable1 = (frame_out == 4'd4) ? 1 : 0;
	
	counter_5 c1(clk, enable1, reset_n, increment1); // IN FRAME 4
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b100) ? 1 : 0;
	
	counter_5 c2(clk, enable2, reset_n, increment2);
	
	assign enable3 = (increment2 == 3'b100) ? 1 : 0;
	
	counter_5 c3(clk, enable3, reset_n, increment3);
	
	assign enable4 = (increment3 == 3'b100) ? 1 : 0;
	
	counter_4 c4(clk, enable4, reset_n, increment4);


	
	assign done = (frame_out == 5'd15) ? 1 : 0;
	// start done in 15 frame

endmodule



