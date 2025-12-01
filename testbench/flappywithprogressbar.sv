// flappy_game.sv
// My Flappy Bird game logic
// This module handles the movement, collisions, and drawing the bird/pipes
`timescale 1ns/1ps

// --- Game Settings ---
`define BIRD_X      147
`define BIRD_W      23
`define BIRD_H      30
`define GAP_SIZE    110
`define PIPE_W      40

// Where the pipe hits the bird
`define COL_MIN_X   108 
`define COL_MAX_X   169 

// Speed settings
`define FALL_SPEED  4
`define JUMP_SPEED  -10
`define PIPE_SPEED  4
`define PROGRESS_SLOWDOWN 10

module flappy_game (
    input  logic clk,   
    input  logic flap_pulse,  
    input  logic btn_held,    
    input  logic [9:0] x_val,
    input  logic [9:0] y_val,
    output logic [2:0] rgb_out
);

    // --- Clock Divider ---
    // We need to slow down the 25MHz clock to about 60 times a second
    // otherwise the game runs way too fast.
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

    // --- Random Number Generator ---
    // Creates random numbers for the pipe heights using some bit shifts
    logic [7:0] random_num = 8'hAB;
    logic [10:0] next_random_gap;
    always_ff @(posedge clk) begin
        random_num <= {random_num[6:0], random_num[7] ^ random_num[5] ^ random_num[4] ^ random_num[3]};
        next_random_gap <= 11'd80 + {3'b0, random_num}; // Make sure gap isn't off screen
    end

    // --- Button Input ---
    // Save the button press so we don't miss it between game ticks
    logic jump_pending;
    always_ff @(posedge clk) begin
        if (flap_pulse) jump_pending <= 1;
        else if (game_tick) jump_pending <= 0;
    end

    // --- Game States ---
    // 0 = Ready, 1 = Playing, 2 = Game Over
    typedef enum logic [1:0] { STATE_READY, STATE_PLAY, STATE_DEAD } state_t;
    state_t state = STATE_READY;

    // Position variables
    logic signed [10:0] bird_y = 220; 
    logic signed [5:0]  bird_v = 0;    
    logic signed [11:0] pipe_x [0:2];  
    logic signed [10:0] pipe_gap_y [0:2]; 
    
    // --- Collision Check ---
    // Check if the bird hit anything.
    // We check one pipe at a time to keep it simple for the FPGA.
    logic [1:0] check_idx; 
    logic collision_detected;

    always_ff @(posedge clk) begin
        // Cycle through the 3 pipes
        if (check_idx == 2) check_idx <= 0; else check_idx <= check_idx + 1;

        if (state == STATE_READY) collision_detected <= 0;
        else if (state == STATE_PLAY) begin
            // Check if bird hit floor or ceiling
            if (bird_y < 0 || bird_y > 450) collision_detected <= 1;
            
            // Check if bird is inside a pipe
            if ( (pipe_x[check_idx] >= 12'(`COL_MIN_X)) && (pipe_x[check_idx] <= 12'(`COL_MAX_X)) ) begin
                // If we are NOT in the gap, we crashed
                if ( (bird_y < pipe_gap_y[check_idx]) || (bird_y + `BIRD_H > pipe_gap_y[check_idx] + `GAP_SIZE) ) begin
                    collision_detected <= 1;
                end
            end
        end
    end

    // --- Main Game Loop ---
    // This runs 60 times a second to update positions
    integer i;
    logic [18:0] tick_global;
    
    always_ff @(posedge clk) begin
        if (game_tick) begin
            // If we crashed, go to dead state
            if (collision_detected && state == STATE_PLAY) state <= STATE_DEAD;

            case (state)
                STATE_READY: begin
                    // Reset everything to start position
                    tick_global <= 0;
                    //tick_cycle <= 0;
                    bird_y <= 220; bird_v <= 0;
                    pipe_x[0] <= 12'd500; pipe_x[1] <= 12'd800; pipe_x[2] <= 12'd1100;
                    pipe_gap_y[0] <= 11'd150; pipe_gap_y[1] <= 11'd250; pipe_gap_y[2] <= 11'd100;
                    // Start game on jump
                    if (jump_pending) begin bird_v <= `JUMP_SPEED; state <= STATE_PLAY; end
                end
                STATE_PLAY: begin
                    //add 1 to progress bar
                    tick_global <= tick_global + 1;

                    // Move Bird
                    if (jump_pending) bird_v <= `JUMP_SPEED; 
                    else if (bird_v < `FALL_SPEED) bird_v <= bird_v + 1; // Gravity
                    else bird_v <= 6'(`FALL_SPEED); 
                    
                    bird_y <= bird_y + bird_v; 
                    if (bird_y < 0) bird_y <= 0; // Don't fly above screen
                    
                    // Move Pipes
                    for (i=0; i<3; i=i+1) begin
                        if (pipe_x[i] < -50) begin 
                            // If pipe goes off screen, move it to the right
                            pipe_x[i] <= 12'd850; 
                            pipe_gap_y[i] <= next_random_gap; // Set new random gap
                        end 
                        else pipe_x[i] <= pipe_x[i] - 12'(`PIPE_SPEED);
                    end
                end
                STATE_DEAD: begin 
                    // Restart if button pressed
                    if (jump_pending) state <= STATE_READY; 
                end
            endcase
        end
    end

    // --- Drawing Logic ---
    // Figure out which pixel is what color
    logic [2:0] x_hit_pipe;
    
    // Registers to store what we are drawing
    logic bird_body_p1;
    logic bird_eye_p1;
    logic bird_wing_p1;

    logic pipe_pixel_p2;
    logic bird_body_p2;
    logic bird_eye_p2;
    logic bird_wing_p2;
    logic progress_bar;

    always_ff @(posedge clk) begin
        // Step 1: Check X coordinates
        x_hit_pipe <= 0;
        if ( ($signed({2'b0, x_val}) >= pipe_x[0]) && ($signed({2'b0, x_val}) < pipe_x[0] + 12'(`PIPE_W)) ) x_hit_pipe[0] <= 1;
        if ( ($signed({2'b0, x_val}) >= pipe_x[1]) && ($signed({2'b0, x_val}) < pipe_x[1] + 12'(`PIPE_W)) ) x_hit_pipe[1] <= 1;
        if ( ($signed({2'b0, x_val}) >= pipe_x[2]) && ($signed({2'b0, x_val}) < pipe_x[2] + 12'(`PIPE_W)) ) x_hit_pipe[2] <= 1;

        // Check if pixel is part of bird body
        bird_body_p1 <= 0;
        if (x_val >= `BIRD_X && x_val < `BIRD_X + `BIRD_W && y_val >= bird_y && y_val < bird_y + `BIRD_H) 
            bird_body_p1 <= 1;

        // Check if pixel is the eye
        bird_eye_p1 <= 0;
        if (x_val >= `BIRD_X + 18 && x_val < `BIRD_X + 20 && y_val >= bird_y + 5 && y_val < bird_y + 8)
            bird_eye_p1 <= 1;

        // Check if pixel is the wing
        bird_wing_p1 <= 0;
        if (x_val >= `BIRD_X + 2 && x_val < `BIRD_X + 14 && y_val >= bird_y + 12 && y_val < bird_y + 20)
            bird_wing_p1 <= 1;

        // Display the Progress Bar
        progress_bar <= 0;
        if( y_val < 20 && x_val < 5 + (tick_global >> 2) )
            progress_bar <= 1;

        // Step 2: Check Y coordinates and pass data along
        pipe_pixel_p2 <= 0;
        bird_body_p2 <= bird_body_p1;
        bird_eye_p2  <= bird_eye_p1;
        bird_wing_p2 <= bird_wing_p1;

        // Draw pipe green if we are NOT in the gap
        if (x_hit_pipe[0]) begin if (y_val < pipe_gap_y[0] || y_val > pipe_gap_y[0] + `GAP_SIZE) pipe_pixel_p2 <= 1; end
        else if (x_hit_pipe[1]) begin if (y_val < pipe_gap_y[1] || y_val > pipe_gap_y[1] + `GAP_SIZE) pipe_pixel_p2 <= 1; end
        else if (x_hit_pipe[2]) begin if (y_val < pipe_gap_y[2] || y_val > pipe_gap_y[2] + `GAP_SIZE) pipe_pixel_p2 <= 1; end

        // Step 3: Pick the final color
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
