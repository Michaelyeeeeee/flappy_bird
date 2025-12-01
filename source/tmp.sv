`default_nettype none
`define BIRD_START  76
`define BIRD_SZ     15
`define BIRD_ACC    -1
`define BIRD_JMP    3
`define PIPE_WIDTH  60
`define PIPE_ALLOW  45
`define PIPE_GAP    240
`define SKY         480
`define NUM_PIPES   5
typedef int seq_t[`NUM_PIPES-1 : 0];

module game_state(
	input logic clk,rst,press,
        output int ox,oy,oscore,
        output seq_t oseq,
        output int d1,d2,d3,d4,d5
);
        // Q is the state
        //   0 - bird "frozen", pressing button will jump and move to Q = 1
        //   1 - game in progress
        //   2 - death, game "frozen" with bird's final position, must reset
	// x is the horizontal position, wrapping around modulo the
        // distance between adjacent pipes
        //   (the first few pipes are 0, which represents no pipe )
        //   a collision first occurs at x = 0, up to pipe_width + 2*bird_sz
        // y is the vertical position of the center of the bird
        // v is the vertical velocity
        // score is the total number of pipes passed
        int Q,x,y,v,score;
	int nQ,nx,ny,nv,nscore;
	seq_t seq,nseq;
	
	logic press_last,press_edge;
        assign press_edge = press && ~press_last;
        
        int rng;
	lfsr inst2( .clk(clk), .rst(rst), .press(press), .out(rng) );
	
	always_ff @(posedge clk,posedge rst) begin
		if(rst) begin
                        Q <= 0; x <= 0; y <= `BIRD_START; v <= 0; score <= 0;
                        press_last <= 0;
			for( int i = 0; i < `NUM_PIPES; i++ ) seq[i] <= 0;
		end else begin
			{Q,x,y,v,score} <= {nQ,nx,ny,nv,nscore};
                        press_last <= press;
			for( int i = 0; i < `NUM_PIPES; i++ ) seq[i] <= nseq[i];
		end
	end

	int low,high;
	cur_bound inst0( .low(low), .high(high), .seq(seq), .x(x) );
	
	logic death;
	collision inst1( .low(low), .high(high), .bird_y(y), .out(death) );

	always_comb begin
		{nQ,nx,ny,nv,nscore} = {Q,x,y,v,score};
		for( int i = 0; i < `NUM_PIPES; i++ ) nseq[i] = seq[i];
		
		if( Q == 0 && press_edge ) begin
			nQ = 1;
			nv = `BIRD_JMP;
		end
		
		
		if( Q == 1 && death ) nQ = 2;

		if( Q == 1 && !death ) begin
                        //update v
			if( press_edge ) nv = `BIRD_JMP;
			else             nv = v + `BIRD_ACC;

                        //update y
			ny = y + v;

                        //update x
			if( x < `PIPE_GAP-1 ) nx = x + 3;
			else begin
                                //update new pipes
				nx = 0;
				for( int i = 1; i < `NUM_PIPES; i++ ) nseq[i-1] = seq[i];
				nseq[`NUM_PIPES-1] = (rng % (`SKY - `PIPE_ALLOW - `PIPE_ALLOW)) + `PIPE_ALLOW;
			end

                        //update score
                        if( x == `PIPE_WIDTH + `BIRD_SZ + `BIRD_SZ )
                        if( !(seq[0] == 0) ) nscore = score + 1;
		end
	end

        assign {ox,oy,oscore} = {x,y,score};
        assign oseq = seq;
        
        assign d1 = Q;
        assign d2 = low;
        assign d3 = high;
        assign d4 = death;
        assign d5 = seq[4];
endmodule

//out = 1 if collision else 0
module collision(
	input int bird_y, low, high,
	output logic out
);
	assign out = (bird_y - `BIRD_SZ < low) || (bird_y + `BIRD_SZ >= high);
endmodule

//computes low and high bounds for the bird y position for current value of x
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
	output logic[31:0] out
);
	logic[31:0] Q;
	logic feedback;
	always_ff @(posedge clk,posedge rst) begin
		if(rst)        Q <= 32'h76767676;
		else if(press) Q <= Q + 32'h67676767;
		else           Q <= {Q[30:0],feedback};
	end
	assign feedback = Q[31]^Q[21]^Q[1]^Q[0];
	assign out = Q;
endmodule
