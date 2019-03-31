module ui_clear
	(
		input clk,						
        input reset_vga, // reset controller
        input enable_control, // enable the control
		// The ports below are for the VGA output.  Do not change.
		output [2:0] color, 
		output [7:0] x,
		output [6:0] y
	);

	
	wire enable, reset_datapath, done;
	control_UI_clear c0(clk, reset_vga, enable_control, enable, writeEn, reset_datapath, color);
	datapath_clear d0(clk, reset_datapath, enable, x, y, done);


endmodule


// enable unit set start the unit, change with a palse of 1 : 0000100000
module control_UI_clear(	input clear,
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
		if (!reset_n)
			current_state <= DISABLE;
		else
			current_state <= next_state;
	end
	
	assign color = 3'b111;
endmodule



module datapath_clear (input clk, 
				input reset_n, 
				input enable, 
				output reg [7:0] x,
				output reg [6:0] y,
				output done // signal for all ui drawing is done
				);

	// could vary according to shape
	wire [3:0] increment1, increment2 ;
	// when rate division done, frame enabled
	wire [24:0] rate_out;
	wire frame_enable;
	// when frame division done, x enabled 
	wire [4:0] frame_out;
	wire enable1;

	
	always @(posedge clk) begin : proc_
		if (!reset_n)
		begin
			x <= 8'd72;  // from middle
			y <= 7'd55;  // from top
		end
		else if (done)
		begin
			x <= 8'd72;  // from middle
			y <= 7'd55;  // from top
		end

		else if (enable1)   //T done
		begin
			x <= 8'd72 + increment1;
			y <= 7'd55 + increment2;

		end
		
	
	end


	// rate divider
	rate_divider rate1(clk, reset_n, enable, rate_out); 
	assign frame_enable = (rate_out == 25'd0) ? 1 : 0;
	
	// frame counter
	frame_counter frame1(clk, frame_enable, reset_n, frame_out);
	assign enable1 = (frame_out == 4'd2) ? 1 : 0;
	

	counter_15 c00(clk, enable1 && frame_enable, reset_n, increment1); // IN FRAME 4
	
	// assign y_enable = 1 when x goes through 1 row
	assign enable2 = (increment1 == 4'b1111) ? 1 : 0;
	
	counter_15 c20(clk, enable2 && frame_enable, reset_n, increment2);


	assign done = (frame_out == 5'd15) ? 1 : 0;
	// start done in 15 frame

endmodule


module counter_15 (clk, enable, reset_n, increment);
	input clk, enable, reset_n;
	// could vary according to shape
	output reg [3:0] increment;
	
	always @(posedge clk) begin
		if (!reset_n)
			begin
			increment <= 4'b0;
			end
		else if (enable) begin
			if (increment == 4'b1111)
				increment <= 4'b0000;
			else
				increment <= increment + 1'b1;
		end
	end
endmodule






