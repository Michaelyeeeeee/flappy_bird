`default_nettype none
//
module shift_pipe_seq(
	input logic clk, en, rst,
	input logic [15:0] nxt_pipe,
	output logic [127:0] out
);
	logic [127:0] Q;
	always_ff @(posedge clk,posedge rst) begin
		if(rst) Q <= 0;
		else if(en) Q <= {Q[111:0],nxt_pipe};
	end
	assign out = Q;
endmodule

//collision detection, out = 1 iff collision

`define BIRD_SZ 15
module collision(
	input logic [15:0] bird_y, low, high,
	output logic out
);
	assign out = (bird_y < low + BIRD_SZ) || (bird_y + BIRD_SZ >= high);
endmodule


//TODO FIGURE OUT NEGATIVE NUMBERS
`define BIRD_ACC = 1;
`define JUMP_VEL = 7;
module update_position(
	input logic clk,en,rst,
	input logic jmp,
	output logic pos
);
	logic [15:0] bird_y;
	logic [15:0] bird_v;
	logic [15:0] nxt_bird_y;
	logic [15:0] nxt_bird_v;
	
	always_ff @(posedge clk,posedge rst) begin
		if(rst) begin
			bird_y <= 16'd240;
			bird_v <= 16'd0;
		end else if(en) begin
			bird_y <= nxt_bird_y;
			bird_v <= nxt_bird_v;
		end
	end
	
	always_comb begin
		if(jmp) nxt_bird_v = JUMP_VEL;
		else    nxt_bird_v = bird_v - BIRD_ACC;
		nxt_bird_y = bird_y + bird_v;
	end
	assign pos = bird_y;
endmodule

//the bird should be at the 160 pixels from the left border
//the bird will start at y = 240 pixels from the top

//constant downwards velocity (for now.) ~~80 pixels fall per second?
//the jump will be 60 pixels per button press
//it will be flip flopped

//SQUARE bird
//30 pixel sides

//90 pipe gap height

//60 pipe width
//you can see 3 pipes on the screen
//240 pixels of space between each pipe
