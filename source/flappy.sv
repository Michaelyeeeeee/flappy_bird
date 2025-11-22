/*
	TODO:
- might have signed issue when generating next pipe
- implement scoring
- latch the button press
- figure out top module stuff (???)
- test it
*/

`default_nettype none
`define BIRD_SZ     15
`define BIRD_ACC    -1
`define BIRD_JMP    3
`define PIPE_WIDTH  60
`define PIPE_ALLOW  45
`define PIPE_GAP    240
`define SKY         480
`define NUM_PIPES   5
typedef int seq_t[`NUM_PIPES-1 : 0];

//out = 1 if collision else 0
module collision(
	input int bird_y, low, high,
	output logic out
);
	assign out = (bird_y - `BIRD_SZ < low) || (bird_y + `BIRD_SZ >= high);
endmodule

//computes low and high for current value of x
module cur_bound(
	input seq_t seq,
	input int x,
	output int low, high
);
	always_comb begin
		if( seq[0] == 0 ) begin
			low = 0;
			high = `SKY;
		end else if( x < `PIPE_WIDTH + `BIRD_SZ + `BIRD_SZ ) begin
			low = seq[0] - `PIPE_ALLOW;
			high = seq[0] + `PIPE_ALLOW;
		end else begin
			low = 0;
			high = `SKY;
		end
	end
endmodule

//random number generator
module lfsr(
	input logic clk,rst,press,
	output int out
);
	int Q;
	logic feedback;
	always_ff @(posedge clk,posedge rst) begin
		if(rst)        Q <= 32'h76767676;
		else if(press) Q <= Q + 32'h67676767;
		else           Q <= {Q[30:0],feedback};
	end
	assign feedback = Q[31]^Q[21]^Q[1]^Q[0];
	assign out = Q;
endmodule

module game_state(
	input logic clk,rst,press
);
	int rng;
	lfsr( .clk(clk), .rst(rst), .press(press), .out(rng) );

	int Q,x,y,v;
	int nQ,nx,ny,nv;

	seq_t seq,nseq;
	
	always_ff @(posedge clk,posedge rst) begin
		if(rst) begin
			{Q,x,y,v} <= {0,0,200,0};
			for( int i = 0; i < `NUM_PIPES; i++ ) seq[i] <= 0;
		end else begin
			{Q,x,y,v} <= {nQ,nx,ny,nv};
			for( int i = 0; i < `NUM_PIPES; i++ ) seq[i] <= nseq[i];
		end
	end

	int low,high;
	cur_bound inst0( .low(low), .high(high), .seq(seq), .x(x) );
	
	logic death;
	collision inst1( .low(low), .high(high), .bird_y(y), .out(death) );

	always_comb begin
		{nQ,nx,ny,nv} = {Q,x,y,v};
		for( int i = 0; i < `NUM_PIPES; i++ ) nseq[i] = seq[i];
		
		if( Q == 0 && press ) begin
			nQ = 1;
			nv = `BIRD_JMP;
		end
		
		if( death ) nQ = 2;

		if( Q == 1 && !death ) begin
			if( press ) nv = `BIRD_JMP;
			else        nv = v + `BIRD_ACC;

			ny = y + v;
			if( x < `PIPE_GAP-1 ) nx = x + 1;
			else begin
				nx = 0;
				for( int i = 1; i < `NUM_PIPES; i++ ) nseq[i-1] = seq[i];
				nseq[`NUM_PIPES-1] = (rng % (`SKY - `PIPE_ALLOW - `PIPE_ALLOW)) + `PIPE_ALLOW;
			end
		end

	end
endmodule
