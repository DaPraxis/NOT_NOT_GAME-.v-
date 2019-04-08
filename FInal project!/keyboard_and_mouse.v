module keyboard_and_mouse(
    input clk,
	 input reset_n,
	 
	 inout PS2_CLK,
	 inout PS2_DAT,
	 
	 output [5:0] user,
	 output [2:0] feedback
	 );
	 
	 keyboard_tracker #(.PULSE_OR_HOLD(0)) tester1(
	     .clock(clk),
		  .reset(reset_n),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .w(user[0]),
		  .a(user[1]),
		  .s(user[2]),
		  .d(user[3]),
		  .space(feedback[0]),
		  .enter(feedback[1])
		  );
		  
	mouse_tracker tester2(
	     .clock(clk),
		  .reset(reset_n),
		  .enable_tracking(1'b1),
		  .PS2_CLK(PS2_CLK),
		  .PS2_DAT(PS2_DAT),
		  .left_click(user[5]),
		  .right_click(user[4])
		  );
endmodule
