module user_lives(
	input reset_n,
	input incr,
	input clk, 
	output [1:0]q,
	output dead);
	
	wire enable;
	
	counter_control c1(reset_n, incr, clk, enable);
	lives_counter c2(enable, reset_n, clk,q,dead);

endmodule 


module user_point(
	input reset_n,
	input incr,
	input clk, 
	output [7:0]q);
	wire enable;
	counter_control c1(reset_n, incr, clk, enable);
	point_counter c2(enable, reset_n, clk,q);

endmodule 


module counter_control(
	input reset_n,
	input incr,
	input clk,
	output reg enable
	);
	
	
	localparam ONHOLD = 3'b000,
				  ENABLE = 3'b001,
				  REST = 3'b010;
				
	reg [2:0] CURRENT_STATE, NEXT_STATE;
	
	always@(*)
	begin
		case(CURRENT_STATE)
		ONHOLD: NEXT_STATE = (incr)? ENABLE: ONHOLD;
		ENABLE: NEXT_STATE = (incr)? ENABLE: REST;
		REST: NEXT_STATE = ONHOLD; // enable in rest;
		endcase
	end
	
	always@(posedge clk)
	begin
		enable <= 0;
		case (CURRENT_STATE)
		REST: enable <=1'b1;
		endcase
	end
	
	always@(posedge clk)
	begin
		if (!reset_n)
		CURRENT_STATE <= ONHOLD;
		else 
		CURRENT_STATE <= NEXT_STATE;
	end

endmodule


module lives_counter(
	input enable, 
	input reset_n, 
	input clk,
	output reg [1:0]q,
	output reg dead);

	
	always@(posedge clk)
	begin
	if (!reset_n)
		begin
		q <= 2'b11;
		dead <=0;
		end
	else if (enable)
			begin
			 if (q)
			 begin
				q <= q - 1'b1;
				if (q == 2'b10)
					dead <= 1;
			 end

			end
		
	end
	


endmodule

module point_counter(
	input enable, 
	input reset_n, 
	input clk,
	output reg [7:0] q);

	
	always@(posedge clk)
	begin
	if (!reset_n)
		q <= 0;
	else if (enable)
				q <= q + 1'b1;	
	end

endmodule
	
//module hex_decoder(hex_digit, segments);
//    input [3:0] hex_digit;
//    output reg [6:0] segments;
//   
//    always @(*)
//        case (hex_digit)
//            4'h0: segments = 7'b100_0000;
//            4'h1: segments = 7'b111_1001;
//            4'h2: segments = 7'b010_0100;
//            4'h3: segments = 7'b011_0000;
//            4'h4: segments = 7'b001_1001;
//            4'h5: segments = 7'b001_0010;
//            4'h6: segments = 7'b000_0010;
//            4'h7: segments = 7'b111_1000;
//            4'h8: segments = 7'b000_0000;
//            4'h9: segments = 7'b001_1000;
//            4'hA: segments = 7'b000_1000;
//            4'hB: segments = 7'b000_0011;
//            4'hC: segments = 7'b100_0110;
//            4'hD: segments = 7'b010_0001;
//            4'hE: segments = 7'b000_0110;
//            4'hF: segments = 7'b000_1110;   
//            default: segments = 7'h7f;
//        endcase
//endmodule


