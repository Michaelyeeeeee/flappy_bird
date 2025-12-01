`default_nettype none
`define BIRD_SZ     15
`define PIPE_WIDTH  60
`define PIPE_ALLOW  45
`define PIPE_GAP    240
`define SKY         480
`define NUM_PIPES   4
typedef int seq_t[`NUM_PIPES-1 : 0];

module vga_game_top(
	input logic clk,
	input logic button,
	output logic [2:0] color
);
	parameter X_SIZE = 32'sd799;  // maximum x size
	parameter Y_SIZE = 32'sd524;  // maximum y size

	int x = 32'sd0;
	int y = 32'sd0;
	logic buttonpress = 1'b0;

	logic CLK; clockdivider inst0( .clk(clk),.rst(1'b1),.CLK(CLK) );
	int bx,by;
	seq_t seq;
	
	game_state inst1(
		.clk(CLK), .rst(1'b1), .press(),
		.ox(bx), .oy(by), .oscore(), .oseq(seq),
		.d1(),.d2(),.d3(),.d4(),.d5()
	);
	
	//handle display
	always_ff @ (posedge clk) begin
		
		if (((y >  (by - `BIRD_SZ)) && (y < (by + `BIRD_SZ))) && ((x < 170) && (x > 147))) begin
			color <= 3'b110;
		end else if( (170-bx + 0*`PIPE_GAP) < x && 
			x < (170-bx + 0*`PIPE_GAP + `PIPE_WIDTH) && 
			(( y < seq[0] - `PIPE_ALLOW) || (y > seq[0] + `PIPE_ALLOW)) ) color <= 3'b010; 
		else if( (170-bx + 1*`PIPE_GAP) < x && 
			x < (170-bx + 1*`PIPE_GAP + `PIPE_WIDTH) && 
			(( y < seq[1] - `PIPE_ALLOW) || (y > seq[1] + `PIPE_ALLOW)) ) color <= 3'b010; 
		else if( (170-bx + 2*`PIPE_GAP) < x && 
			x < (170-bx + 2*`PIPE_GAP + `PIPE_WIDTH) && 
			(( y < seq[2] - `PIPE_ALLOW) || (y > seq[2] + `PIPE_ALLOW)) ) color <= 3'b010; 
		else if( (170-bx + 3*`PIPE_GAP) < x && 
			x < (170-bx + 3*`PIPE_GAP + `PIPE_WIDTH) && 
			(( y < seq[3] - `PIPE_ALLOW) || (y > seq[3] + `PIPE_ALLOW)) ) color <= 3'b010; 
		else color <= 3'b011;

		if (x == X_SIZE) begin
		    	if (y == Y_SIZE) begin
				y <= 0;
		    	end else begin
				y <= y + 1;
		    	end
		end
		if (x == X_SIZE) begin
		    	x <= 32'sd0;
		end else begin
		    	x <= x + 32'sd1;
		end

		if (buttonpress) begin
		    	color <= ~color;
		end
	end

	always_ff @ (negedge button) begin
		buttonpress <= ~buttonpress;
	end


endmodule 
