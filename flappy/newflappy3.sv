//SPLIT GAME LOOPS
`timescale 1ns/1ps
`include "constants.sv"

module flappy_game (
        input  logic clk,   
        input  logic flap_pulse,  
        input  logic btn_held,    
        input  logic [9:0] x_val,
        input  logic [9:0] y_val,
        output logic [2:0] rgb_out
);

        // clock divider to slow down the game logic hz
        logic [18:0] tick_cnt;
        logic game_tick; 
        always_ff @(posedge clk) begin
                if (tick_cnt >= 416666) begin
                        tick_cnt <= 0;
                        game_tick <= 1;
                end else begin
                        tick_cnt <= tick_cnt + 1;
                        game_tick <= 0;
                end
        end


        // random number generator for the pipes w seed
        logic [7:0] rng = 8'hAB;
        always_ff @(posedge clk) rng <= {rng[6:0],rng[7]^rng[5]^rng[4]^rng[3]};

        logic [10:0] next_gap;
        assign next_gap =  11'd80 + rng;
        

        // make sure we catch the button press
        // sometimes the game tick misses the button so we save it here
        // metastability? smth smth
        logic jump_pending;
        always_ff @(posedge clk) begin
                if (flap_pulse) jump_pending <= 1;
                else if (game_tick) jump_pending <= 0;
        end


        // states for gameplay
        // 0 = Ready, 1 = Playing, 2 = Game Over
        typedef enum logic [1:0] { STATE_READY, STATE_PLAY, STATE_DEAD } state_t;
        state_t state = STATE_READY;

        // main FSM
        always_ff @(posedge clk) if( game_tick ) begin
                case( state )
                        STATE_READY: if( jump_pending ) state <= STATE_PLAY;
                        STATE_PLAY:  if( collision_detected ) state <= STATE_DEAD;
                        STATE_DEAD:  if( jump_pending ) state <= STATE_READY;
                endcase
        end


        // collision detection
        logic [1:0] check_id; 
        logic collision_detected;
        always_ff @(posedge clk) begin
                check_idx <= (check_id == 2 ? 0 : check_id + 1);
                if( state == STATE_READY ) collision_detected <= 0;
                else if( state == STATE_PLAY ) begin
                        //check if bird hit the floor
                        //no check for ceiling because birds can fly
                        if( bird_y > 450 ) collision_detected <= 1;

                        //check if inside pipe x coordinate
                        if( (pipe_x[check_idx] >= `COL_MIN_X)
                         && (pipe_x[check_idx] <= `COL_MAX_X) ) begin
                                //If we are NOT in the gap, we crashed
                                if( (bird_y < pipe_gap_y[check_idx]) 
                                 || (bird_y + `BIRD_H > pipe_gap_y[check_idx] + `GAP_SIZE) ) begin
                                        collision_detected <= 1;
                                end
                        end
                end
        end


        // Main Loops @ 60hz
        // 1 - Progress Bar
        logic [18:0] tick_global;
        always_ff @(posedge clk) if( game_tick ) begin
                if( state == STATE_READY )     tick_global <= 0;
                else if( state == STATE_PLAY ) tick_global <= tick_global + 1;
        end

        // 2 - Bird Position Update
        logic signed [10:0] bird_y = 220; 
        logic signed [5:0]  bird_v = 0;
        always_ff @(posedge clk) if( game_tick ) begin
                if( state == STATE_READY ) begin
                        bird_y <= 220; bird_v <= 0;
                        if( jump_pending ) bird_v <= `JUMP_SPEED;
                end else if( state == STATE_PLAY ) begin
                        //velocity update
                        if (jump_pending)              bird_v <= `JUMP_SPEED; 
                        else if (bird_v < `FALL_SPEED) bird_v <= bird_v + 1;
                        else                           bird_v <= `FALL_SPEED;
                        
                        //position update
                        bird_y <= bird_y + bird_v;
                        if( bird_y < 0 ) bird_y <= 0;
                end
        end

        // 3 - Pipe Update
        logic signed [11:0] pipe_x [0:2];  
        logic signed [10:0] pipe_gap_y [0:2];
        always_ff @(posedge clk) if( game_tick ) begin
                if( state == STATE_READY ) begin
                        //first 3 pipes hardcoded
                        pipe_x <= '{500,800,1100};
                        pipe_gap_y <= '{150,250,100};
                end else if( state == STATE_PLAY ) begin
                        for( int i = 0; i < 3; i++ ) begin
                                if (pipe_x[i] < -`PIPE_W) begin 
                                        //Pipe moved offscreen
                                        pipe_x[i] <= 12'd850; 
                                        pipe_gap_y[i] <= next_gap; // Set new random gap
                                end
                                else pipe_x[i] <= pipe_x[i] - `PIPE_SPEED;
                        end
                end
        end


        // drawing logic for all the things
    logic [2:0] x_hit_pipe;
    
    // Storeing differet colors for things cuz bird body can be either red or yellow depending on game stame

    logic bird_body_p1;
    logic bird_eye_p1;
    logic bird_wing_p1;

    logic pipe_pixel_p2;
    logic bird_body_p2;
    logic bird_eye_p2;
    logic bird_wing_p2;
    logic progress_bar;

    always_ff @(posedge clk) begin
        // check x coordinates fpr pipe
        x_hit_pipe <= 0;
        if ( ($signed({2'b0, x_val}) >= pipe_x[0]) && ($signed({2'b0, x_val}) < pipe_x[0] + 12'(`PIPE_W)) ) x_hit_pipe[0] <= 1;
        if ( ($signed({2'b0, x_val}) >= pipe_x[1]) && ($signed({2'b0, x_val}) < pipe_x[1] + 12'(`PIPE_W)) ) x_hit_pipe[1] <= 1;
        if ( ($signed({2'b0, x_val}) >= pipe_x[2]) && ($signed({2'b0, x_val}) < pipe_x[2] + 12'(`PIPE_W)) ) x_hit_pipe[2] <= 1;

        // displaying birby
        bird_body_p1 <= 0;
        if (x_val >= `BIRD_X && x_val < `BIRD_X + `BIRD_W && y_val >= bird_y && y_val < bird_y + `BIRD_H) 
            bird_body_p1 <= 1;

        // bird eye
        bird_eye_p1 <= 0;
        if (x_val >= `BIRD_X + 18 && x_val < `BIRD_X + 20 && y_val >= bird_y + 5 && y_val < bird_y + 8)
            bird_eye_p1 <= 1;

        // white rectangle for wing
        bird_wing_p1 <= 0;
        if (x_val >= `BIRD_X + 2 && x_val < `BIRD_X + 14 && y_val >= bird_y + 12 && y_val < bird_y + 20)
            bird_wing_p1 <= 1;

        progress_bar <= 0;
        if( y_val < 20 && x_val < 5 + (tick_global >> 2) )
            progress_bar <= 1;

        pipe_pixel_p2 <= 0;
        bird_body_p2 <= bird_body_p1;
        bird_eye_p2  <= bird_eye_p1;
        bird_wing_p2 <= bird_wing_p1;

        //drawing pipe based on gap gap should be background color
        if (x_hit_pipe[0]) begin if (y_val < pipe_gap_y[0] || y_val > pipe_gap_y[0] + `GAP_SIZE) pipe_pixel_p2 <= 1; end
        else if (x_hit_pipe[1]) begin if (y_val < pipe_gap_y[1] || y_val > pipe_gap_y[1] + `GAP_SIZE) pipe_pixel_p2 <= 1; end
        else if (x_hit_pipe[2]) begin if (y_val < pipe_gap_y[2] || y_val > pipe_gap_y[2] + `GAP_SIZE) pipe_pixel_p2 <= 1; end

        //colors
        if( progress_bar ) rgb_out <= 3'b111; //white progress bar
        else if (bird_body_p2) begin
            // Eye goes on top, then wing, then body
            if (bird_eye_p2) rgb_out <= 3'b000;       // Black Eye
            else if (bird_wing_p2) rgb_out <= 3'b111; // White Wing
            else rgb_out <= (state == STATE_DEAD) ? 3'b100 : 3'b110; // Red if dead, Yellow if alive
        end
        else if (pipe_pixel_p2) rgb_out <= 3'b010; // Green Pipe
        else rgb_out <= 3'b011; // Cyan Background
    end

endmodule