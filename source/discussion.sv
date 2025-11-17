`default_nettype none
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

//on clock edge, out = 0 iff low <= bird_y < high
module collision(
	input logic clk,
	input logic [15:0] bird_y, low, high,
	output logic out
);
	always_ff @(posedge clk) begin
		
	end
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
