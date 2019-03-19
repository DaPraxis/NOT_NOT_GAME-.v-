module mux_instructions(
	input [2:0] instruction);

endmodule 

module mux_control(
		input enable,
		input [2:0]instruction,
		input reset_n,
		input done, 
		input clear
		);

	localparam UP = 6'b000000, 
			   UP_WAIT = 6'b000001,
			   UP_CLEAR = 6'b000010,
			   UP_CLEAR_WAIT = 6'b000011, 
			   DOWN = 6'b000100, 
			   DOWN_WAIT = 6'b000101,
			   DOWN_CLEAR = 6'b000110,
			   DOWN_CLEAR_WAIT = 6'b000111,
			   LEFT = 6'b001000, 
			   LEFT_WAIT = 6'b001001,
			   LEFT_CLEAR = 6'b001010,
			   LEFT_CLEAR_WAIT = 6'b001011,
			   RIGHT = 6'b001100 , 
			   RIGHT_WAIT = 6'b001101,
			   RIGHT_CLEAR = 6'b001110,
			   RIGHT_CLEAR_WAIT = 6'b001111,
			   L = 6'b010000 , 
			   L_WAIT = 6'b010001,
			   L_CLEAR = 6'b010010,
			   L_CLEAR_WAIT = 6'b010011,
			   R = 6'b010100 , 
			   R_WAIT = 6'b010101,
			   R_CLEAR = 6'b010110,
			   R_CLEAR_WAIT = 6'b010111,
			   ON_HOLD = 6'b011000,
			   PREPARE_INSTRUCTION = 6'b011001;

	reg [5:0] CURRENT_STATE, NEXT_STATE;
	reg [5:0] clear_state; // register state to be cleared
	reg clear_ui;	   
	always @(*) begin : proc_
		case (CURRENT_STATE)
			ON_HOLD : NEXT_STATE =  enable ? PREPARE_INSTRUCTION: ON_HOLD;
			PREPARE_INSTRUCTION : 
				if ((!enable) & (!clear_ui))
				begin
					case (instruction)
						3'b000:  NEXT_STATE = UP;    // UP
						3'b001:  NEXT_STATE = DOWN;  // DOWN
					 	3'b010:  NEXT_STATE = LEFT;  // LEFT
						3'b011:  NEXT_STATE = RIGHT; // RIGHT
						3'b100:  NEXT_STATE = L;   	 // L
						3'b101:  NEXT_STATE = R;     // R
					endcase
				end
				else if ((!enable) & (clear_ui))
				begin
					case (instruction)
						3'b000:  NEXT_STATE = UP_CLEAR;    // UP
						3'b001:  NEXT_STATE = DOWN_CLEAR;  // DOWN
					 	3'b010:  NEXT_STATE = LEFT_CLEAR;  // LEFT
						3'b011:  NEXT_STATE = RIGHT_CLEAR; // RIGHT
						3'b100:  NEXT_STATE = L_CLEAR;   	 // L
						3'b101:  NEXT_STATE = R_CLEAR;     // R
					endcase
				end
				else 
					begin
					NEXT_STATE = PREPARE_INSTRUCTION;
					end
			UP: NEXT_STATE = done ? UP_WAIT : UP;
			UP_WAIT = done ? UP_WAIT : ON_HOLD;
			DOWN: NEXT_STATE = done ? DOWN_WAIT : DOWN;
			DOWN_WAIT = done ? DOWN_WAIT : ON_HOLD;
			RIGHT: NEXT_STATE = done ? RIGHT_WAIT : RIGHT;
			RIGHT_WAIT = done ? RIGHT_WAIT : ON_HOLD;
			LEFT: NEXT_STATE = done ? LEFT_WAIT : LEFT;
			LEFT_WAIT = done ? LEFT_WAIT : ON_HOLD;
			L: NEXT_STATE = done ? L_WAIT : L;
			L_WAIT = done ? L_WAIT : ON_HOLD;
			R: NEXT_STATE = done ? R_WAIT : R;
			R_WAIT = done ? R_WAIT : ON_HOLD;
			
			default : /* default */;
		endcase
	end

	always @(*) begin : FSM_ASS
		case (CURRENT_STATE)
			PREPARE_INSTRUCTION: 
				clear_ui <= clear; // used for later
	
	end


endmodule

// change instruction when change_instruction is high
module instruction_shift(
	input change_instruction, 
	input clk,
	input rst_n,
	output reg [2:0] instruction);
	wire [3:0]random;
	reg [3:0]ran;
	random r1 (clk, rst_n, random);
	always @(posedge change_instruction) begin : proc_
		ran <= random;
		if (ran < 4'b0011)
			instruction <= 3'b000; // UP
		else if (ran < 4'b0110)
			instruction <= 3'b001; // DOWN
		else if (ran < 4'b1001)
			instruction <= 3'b010; // LEFT
		else if (ran < 4'b1011)
			instruction <= 3'b011; // RIGHT
		else if (ran < 4'b1101)
			instruction <= 3'b100; // VOWEL
		else 
			instruction <= 3'b101; // DIGIT
	end
	

endmodule // module


module dff_0(clock,reset_n,data_in,q);
		input clock,reset_n,data_in;
		output reg q;
		always@(posedge clock)
		   begin
			if(reset_n == 0) 
				  q <= 1'b0; 
			else
				  q<= data_in;
			end
endmodule

module dff_1(clock,reset_n,data_in,q);
		input clock,reset_n,data_in;
		output reg q;
		always@(posedge clock)
		   begin
			if(reset_n == 0) 
				  q <= 1'b1; 
			else
				  q<= data_in;
			end
endmodule



module random(clock,reset_n,q);
		input clock,reset_n;
		output [3:0] q;
		
		dff_0 m1(clock,reset_n,q[2] ^ q[3],q[0]);
		dff_1 m2(clock,reset_n,q[0],q[1]);
		dff_1 m3(clock,reset_n,q[1],q[2]);
		dff_1 m4(clock,reset_n,q[2],q[3]);
endmodule