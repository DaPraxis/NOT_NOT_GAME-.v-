// this version only used for detect and debug, approved in milestone 1
module ui_R(
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
	ui_r m1(CLOCK_50,KEY[0],~KEY[1],SW[2:0],   
		  VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G, VGA_B, LEDR[0]);

endmodule

module ui_r
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
			.clock(clk),
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
	wire enable, reset_datapath;
	control_UI c0(clk, reset_vga, enable_control, enable, writeEn, reset_datapath);
	datapath_R d0(clk, reset_datapath, enable, x, y, done);

endmodule


// enable unit set start the unit, change with a palse of 1 : 0000100000
module control_UI(input clk, 
			   input reset_n,
			   input enable_unit,
			   output reg enable, 
			   output reg writeEn,
			   output reg reset_datapath);

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
endmodule



module datapath_R (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [2:0] increment1;
	wire [2:0] increment2;
	wire [2:0] increment3, increment4, increment5, increment6, increment7, increment8;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1, enable2, enable3, enable4, enable5, enable6, enable7, enable8;

	
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
		else if (enable8)
		begin
			x <= 8'd79 + increment8;
			y <= 7'd67 + increment8;

		end
		else if (enable7)
		begin
			x <= 8'd79;
			y <= 7'd67 + increment7;

		end
		else if (enable6)
		begin
			x <= 8'd79;
			y <= 7'd63 + increment6;

		end
		else if (enable5)
		begin
			x <= 8'd81 - increment5;
			y <= 7'd67;

		end
		else if (enable4)
		begin
			x <= 8'd82 - increment4;
			y <= 7'd66 + increment4;

		end
		else if (enable3)
		begin
			x <= 8'd82;
			y <= 7'd64 + increment3;

		end
		else if (enable2)
		begin
			x <= 8'd81 + increment2;
			y <= 7'd63 + increment2;
		end
		else if (frame_enable & !enable2)
		begin
			x <= 8'd79 + increment1; 
			y <= 7'd63; 
		end
	
	end


	// rate divider
	rate_divider rate(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame(clk, frame_enable, reset_n, frame_out);
	// assign enable1 = (frame_out == 4'd0) ? 1 : 0;
	

	counter_4 c1(clk, frame_enable, reset_n, increment1); // --
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 3'b011) ? 1 : 0;
	
	counter_3 c2(clk, enable2 & frame_enable, reset_n, increment2);

	assign enable3 = (increment2 == 3'b010) ? 1 : 0;

	counter_4 c3(clk, enable3 & frame_enable, reset_n, increment3);

	assign enable4 = (increment3 == 3'b011) ? 1 : 0;

	counter_3 c4(clk, enable4 & frame_enable, reset_n, increment4);

	assign enable5 = (increment4 == 3'b010) ? 1 : 0;

	counter_4 c5(clk, enable5 & frame_enable, reset_n, increment5);

	assign enable6 = (increment5 == 3'b011) ? 1 : 0;

	counter_5 c6(clk, enable6 & frame_enable, reset_n, increment6);

	assign enable7 = (increment6 == 3'b100) ? 1 : 0;

	counter_5 c7(clk, enable7 & frame_enable, reset_n, increment7);

	assign enable8 = (increment7 == 3'b100) ? 1 : 0;

	counter_5 c8(clk, enable8 & frame_enable, reset_n, increment8);

	
	assign done = (frame_out == 5'd22) ? 1 : 0;
	// start done in 17 frame

endmodule

module counter_3 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b010)
				increment <= 3'b010;
			else 
				increment <= increment + 1'b1;
		end
	end
endmodule 

module counter_5 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b100)
				increment <= 3'b100;
			else 
				increment <= increment + 1'b1;
		end
	end
endmodule 


module counter_4 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b011)
				increment <= 3'b011;
			else 
				increment <= increment + 1'b1;
		end
	end
endmodule 

module counter_8 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [2:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 3'b0;
			end
		else if (enable) begin
			if (increment == 3'b111)
				increment <= 3'b111;
			else
				increment <= increment + 1'b1;
		end
	end
endmodule


// frame counter, count to 17 for every move so that the frame could refresh
module frame_counter(clk, enable, reset_n, out);
	input clk, enable, reset_n;
	output reg [4:0] out;
	
	always @(posedge clk) begin
		if (!reset_n) begin
			out <= 4'b0;
			end
		else if (enable) begin
			if (out == 5'd18)
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
		output reg [24:0] out;
		
		always @(posedge clk)
		begin
			if (!reset_n) begin
				out <= 25'd0;
				end
			else if (enable) begin
			   	if (out == 25'd3125000)
					begin
					out <= 25'd0;
					end
				else
					begin
					out <= out + 1'b1;
					end
			end
		end
endmodule