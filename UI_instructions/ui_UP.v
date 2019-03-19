module ui_UP(
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
	output [7:0]LEDR);   						
	ui_up(CLOCK_50,KEY[0],~KEY[1],SW[2:0],   
		  VGA_CLK, VGA_VS, VGA_BLANK_N,	VGA_SYNC_N,	VGA_R, VGA_G, VGA_B, LEDR[0]);

endmodule

module ui_up
	(
		input clk,						
        input reset_vga, // reset controller
        input enable_control, // enable the control
        input [2:0] color,
		// The ports below are for the VGA output.  Do not change.
		output VGA_CLK,   						//	VGA Clock
		output VGA_HS,							//	VGA H_SYNC
		output VGA_VS,							//	VGA V_SYNC
		output VGA_BLANK_N,						//	VGA BLANK
		output VGA_SYNC_N,						//	VGA SYNC
		output [9:0] VGA_R,   						//	VGA Red[9:0]
		output [9:0] VGA_G,	 						//	VGA Green[9:0]
		output [9:0] VGA_B,   						//	VGA Blue[9:0]
		output done
	);

	vga_adapter VGA(
			.resetn(reset_vga),
			.clock(CLOCK_50),
			.colour(color [2:0]), 
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
	control c0(clk, reset_vga, enable_control, enable, writeEn);
	datapath d0(clk, reset_vga, enable, x, y, done);

endmodule


// enable unit set start the unit, change with a palse of 1 : 0000100000
module control(input clk, 
			   input reset_n,
			   input enable_unit,
			   output reg enable, 
			   output reg writeEn);

	localparam 	ENABLE_STATE = 4'b0000, 
				ENABLE_WAIT = 4'b0001, 
				DRAW = 4'b0010,
				DISABLE = 4'b0011;
	reg [1:0] current_state, next_state;

	always @(*) begin
		case (current_state)
			DISABLE : next_state = (enable_unit) ? ENABLE_STATE : DISABLE;
			ENABLE_STATE : next_state = (enable_unit) ? ENABLE_STATE : ENABLE_WAIT;
			ENABLE_WAIT : next_state = DRAW;
			DRAW : next_state = (reset_n) ? DRAW : DISABLE;
		endcase
	end

	always @(*) begin
		enable = 1'b0;
		writeEn = 1'b0;
		case (current_state)
			DRAW: begin
				enable = 1'b1;
				writeEn = 1'b1;
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
endmodule


module datapath(input clk, 
				input reset_n, 
				input enable, 
				output [7:0] x_out,
				output [6:0] y_out,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1;
	wire [2:0] increment2;
	wire [2:0] increment3;
	// when rate division done, frame enabled
	wire [20:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [3:0] frame_out;
	wire enable1, enable2, enable3;
	reg [7:0] x;
	reg [6:0] y;

	
	always @(posedge clk) begin : proc_
		if (reset_n)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end
		else if (done)
		begin
			x <= 8'd79;  // from middle
			y <= 7'd63;  // from top
		end	
		else if (enable3)
		begin
			x <= 8'd79 - increment3;
			y <= 7'd63 - increment3;

		end
		else if (enable2)
		begin
			x <= 8'd79 + increment2;
			y <= 7'd63 - increment2;
		end
		else if (enable1)
		begin
			x <= 8'd79;
			y <= 7'd63 - increment1;
		end
	
	end
	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 20'd0) 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	assign enable1 = (frame_out == 4'd10) 1 : 0;
	
	// x counter for square 4 * 4 plane
	// threshold = 2'b11
	// TODO: change x and y counter to shape
	counter_8 c1(clk, enable1, reset_n, increment1);
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b111) ? 1 : 0;
	
	counter_4 c2(clk, enable2, reset_n, increment2);

	assign enable3 = (increment2 == 2'b11) ? 1 : 0;

	counter_4 c3(clk, enable3, reset_n, increment3);

	assign done = (increment3 == 2'b11) ? 1 : 0; // stop the curser
	
endmodule

module counter_4 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			out <= 3'b0;
		else if (enable) begin
			if (out == 3'b011)
				out <= 3'b0;
			else
				out <= out + 1'b1;
		end
	end
endmodule 

module counter_8 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			out <= 3'b0;
		else if (enable) begin
			if (out == 3'b111)
				out <= 3'b0;
			else
				out <= out + 1'b1;
		end
	end
endmodule


// frame counter, count to 15 for every move so that the frame could refresh
module frame_counter(clk, enable, reset_n, out);
	input clk, enable, reset_n;
	output reg [3:0] out;
	
	always @(posedge clk) begin
		if (!reset_n)
			out <= 4'b0;
		else if (enable) begin
			if (out == 4'b1111)
				out <= 4'b0;
			else
				out <= out + 1'b1;
		end
	end
endmodule


// rate divider that divides the clk
module rate_divider(clk, reset_n, enable, out);
		input clk;
		input reset_n;
		input enable;
		output reg [19:0] out;
		
		always @(posedge clk)
		begin
			if (!reset_n)
				out <= 20'd0;
			else if (enable) begin
			   if (out == 20'd0)
					out <= 20'd1666666;
				else
					out <= out - 1'b1;
			end
		end
endmodule