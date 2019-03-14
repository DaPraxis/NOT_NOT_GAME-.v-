module top_level(answer, key_pressed, clk, reset_n);
	input [3:0] answer;
	input key_pressed, clk, reset_n;
	wire q_judge, q_life, enable_load, judge_signal, life_signal, q_reg, reset_life;
	wire [3:0] cur_state;
	control c0(key_pressed, q_judge, q_life, cur_state, enable_load, judge_signal, life_signal, clk, reset_n, reset_life);
	judge j0(q_reg, Current_state, judge_signal, q_judge);
	life_counter life0(reset_life, clk, life_signal, q_life);
	answer_register an0 (answer, enable_load, key_pressed, reset_n, q_reg)


endmodule 

module control(key_pressed, q_judge, q_life, cur_state, enable_load, judge_signal, life_signal, clk, reset_n, reset_life);
	input key_pressed, q_judge, q_life, clk, reset_n; // key_pressed means there is a input press from keyboard
	reg [4:0] Current_state, Next_state;
	reg time_wire_1, reset_timer, judge_signal, life_signal;
	output reg q_life, q_judge, enable_load, reset_life;
	output reg [2:0] cur_state;
	localparam UP= 5'b00000, 
				  UP_WAIT= 5'b00001,
				  DOWN= 5'b00010,
				  DOWN_WAIT= 5'b00011,
				  LEFT= 5'b00100,
				  LEFT_WAIT= 5'b00101,
				  RIGHT= 5'b00110,
				  RIGHT_WAIT= 5'b00111,
				  VOWAL= 5'b01000,
				  VOWAL_WAIT= 5'b01001,
				  DIGIT= 5'b01010,
				  DIGIT_WAIT= 5'b01011,
				  START= 5'b01100,
				  TIME_OUT= 5'b01101,
				  CORRECT_STATE= 5'b01110,
				  WRONG_STATE= 5'b01111,
				  DEAD= 5'b10000,
				  REALLY_DEAD= 5'b10001;
				  
	always @(*)
	begin
	case (Current_state)
		// TODO: initialize the register enable to 0, paraloading
		judge_signal=0;
		reset_timer=1'b1;
		life_signal=0;
		enable_load=0;
		reset_life =1;
		UP: begin 
			
			// key_pressed means there is a input press from keyboard
			// if time_wire_1 is 0, not exceed limit, 1 then exceed
			if(key_pressed && !time_wire_1)
				begin 
					Next_state<=UP_WAIT;
					enable_load = 1; // can load answer now
					judge_signal =1;
					cur_state <= 3'b000;
				end
			else if(key_pressed && time_wire_1)
				begin
					Next_state<=TIME_OUT;
				end
			else
				begin
					Next_state<=UP;
				end
			end
		UP_WAIT: begin
			reset_timer = 0; // reset timer
			if (q_judge)  // correct input 
				begin
					Next_state<= CORRECT_STATE;
				end
			else
				begin
					Next_state<= WRONG_STATE;
				end
			end
		// TODO: after complete above TODOs, copy paste for other instructions
		
		CORRECT_STATE: begin
			if (time_wire_1)
				begin 
					// TODO: Next_state = random()
					enable_load = 1; // can load answer now
				end
			else 
				begin
					Next_state<=Current_state;
				end
			end
		
		WRONG_STATE: begin
			if (time_wire_1)
				begin 
					life_signal=1;
					Next_state <=DEAD;
				end
			else 
				begin
					Next_state<=WRONG_STATE;
				end
			end
		
		DEAD: begin
			if (q_life==0)
				begin
					Next_state <= REALLY_DEAD;
				end
			else 
				begin
					Next_state <= START;
					reset_timer = 0;
				end
			end
			
		START: begin
			if (time_wire_1)
				begin
					Next_state <= // random instructions
					enable_load = 1; // can load answer now
				end
			else 
				begin
					Next_state <= DEAD;
				end
			end
		
		REALLY_DEAD: begin
			reset_life = 0;
		end
		
		TIME_OUT: begin
			if (time_wire_1)
				begin
					Next_state <= DEAD;
					life_signal = 1'b1;
				end
			else 
				begin
					Next_state <= TIME_OUT;
				end
			end
		
			
			
			
	endcase
	end
	timer_3s timer1(reset_timer, clk, time_wire_1);	

endmodule


module answer_register(answer, enable_load, key_pressed, reset_n, q);
	input [3:0] answer;
	input enable_load, key_pressed;
	output reg [3:0]q;
	always @(posedge clk)
		begin
			if (!reset_n)
				q <= 4'h0000;
			else if (key_pressed && enable_load)
				q <= answer;
				
		end

endmodule 




// cur_input read from resgister (q), cur_state: current state, signal: do judge or not; q is correct or not
module judge(cur_input, cur_state,signal, q);
	output reg q;
	input [3:0]cur_input; // input in hex
	input [2:0]cur_state;
	localparam UP= 3'b000, 
				  DOWN= 3'b001,
				  LEFT= 3'b010,
				  RIGHT= 3'b011,
				  VOWAL= 3'b100,
				  DIGIT= 3'b101;
	
	always @(*)
	begin
		if (signal)
			begin
			case(cur_state)
				UP : begin
					q <= (cur_input == 4'hE072);
						end
				DOWN : begin
					q <= (cur_input == 4'hE075);
						end
				RIGHT : begin
					q <= (cur_input == 4'hE06B);
						end
				LEFT : begin
					q <= (cur_input == 4'hE074);
						end
				VOWEL : begin
					q <= (cur_input == );  // TODO, when decide input
						end
				DIGIT : begin
					q <= (cur_input == );  // TODO, when decide input
						end
			end
	end
endmodule


module life_counter(reset_n, clk, signal, q);
	always @(posedge clk)
	begin
		if (!reset_n)
			begin
				q<=2'b11;
			end
		else if(signal)
			begin
				q<=q-1'b1;
			end
	end
	
	
endmodule


module timer_3s(reset_n, clk, q);
	input reset, clk;
	output reg q;
	reg [26:0]count;
	always@(posedge clk)
		begin
			if (!reset_n)
				begin 
					q<=0;
					count<=0;
				end
			else
				begin 
					count<=count+1;
					if (count==26'b1000111100001101000110000000)
						begin
							q<=1;
						end
				end
		end
		
endmodule
