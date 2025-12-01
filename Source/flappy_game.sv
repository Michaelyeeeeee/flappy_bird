// flappy_game.sv
// UPDATED RENDERER: Added Black Eye and White Wing to the bird.
`timescale 1ns/1ps

module flappy_game (
    input  logic clk,
    input  logic vsync,       
    input  logic flap_pulse,  
    input  logic btn_held,    
    input  logic [9:0] x_val,
    input  logic [9:0] y_val,
    output logic [2:0] rgb_out
);

    // --- SIZES ---
    localparam integer BIRD_X      = 147;
    localparam integer BIRD_W      = 23;
    localparam integer BIRD_H      = 30;
    localparam integer GAP_SIZE    = 110;
    localparam integer PIPE_W      = 40;
    
    // Collision Boundaries
    localparam integer COL_MIN_X   = 108; 
    localparam integer COL_MAX_X   = 169; 

    // --- PHYSICS ---
    localparam integer FALL_SPEED  = 2;  
    localparam integer JUMP_SPEED  = -10; 
    localparam integer PIPE_SPEED  = 2;

    // --- CLOCK DIVIDER (60 Hz) ---
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

    // --- RANDOM GAP GEN ---
    logic [7:0] random_num = 8'hAB;
    logic [10:0] next_random_gap;
    always_ff @(posedge clk) begin
        random_num <= {random_num[6:0], random_num[7] ^ random_num[5] ^ random_num[4] ^ random_num[3]};
        next_random_gap <= 11'd80 + {3'b0, random_num};
    end

    // --- BUTTON MEMORY ---
    logic jump_pending;
    always_ff @(posedge clk) begin
        if (flap_pulse) jump_pending <= 1;
        else if (game_tick) jump_pending <= 0;
    end

    // --- STATE MACHINE ---
    typedef enum logic [1:0] { STATE_READY, STATE_PLAY, STATE_DEAD } state_t;
    state_t state = STATE_READY;

    // Variables
    logic signed [10:0] bird_y = 220; 
    logic signed [5:0]  bird_v = 0;    
    logic signed [11:0] pipe_x [0:2];  
    logic signed [10:0] pipe_gap_y [0:2]; 
    
    // Sequential Collision Logic
    logic [1:0] check_idx; 
    logic collision_detected;

    always_ff @(posedge clk) begin
        if (check_idx == 2) check_idx <= 0; else check_idx <= check_idx + 1;

        if (state == STATE_READY) collision_detected <= 0;
        else if (state == STATE_PLAY) begin
            if (bird_y < 0 || bird_y > 450) collision_detected <= 1;
            if ( (pipe_x[check_idx] >= 12'(COL_MIN_X)) && (pipe_x[check_idx] <= 12'(COL_MAX_X)) ) begin
                if ( (bird_y < pipe_gap_y[check_idx]) || (bird_y + BIRD_H > pipe_gap_y[check_idx] + GAP_SIZE) ) begin
                    collision_detected <= 1;
                end
            end
        end
    end

    // --- MOVEMENT LOOP (60Hz) ---
    integer i;
    always_ff @(posedge clk) begin
        if (game_tick) begin
            if (collision_detected && state == STATE_PLAY) state <= STATE_DEAD;

            case (state)
                STATE_READY: begin
                    bird_y <= 220; bird_v <= 0;
                    pipe_x[0] <= 12'd500; pipe_x[1] <= 12'd800; pipe_x[2] <= 12'd1100;
                    pipe_gap_y[0] <= 11'd150; pipe_gap_y[1] <= 11'd250; pipe_gap_y[2] <= 11'd100;
                    if (jump_pending) begin bird_v <= JUMP_SPEED; state <= STATE_PLAY; end
                end
                STATE_PLAY: begin
                    if (jump_pending) bird_v <= JUMP_SPEED; 
                    else if (bird_v < FALL_SPEED) bird_v <= bird_v + 1; 
                    else bird_v <= 6'(FALL_SPEED); 
                    bird_y <= bird_y + bird_v; if (bird_y < 0) bird_y <= 0;
                    for (i=0; i<3; i=i+1) begin
                        if (pipe_x[i] < -50) begin pipe_x[i] <= 12'd850; pipe_gap_y[i] <= next_random_gap; end 
                        else pipe_x[i] <= pipe_x[i] - 12'(PIPE_SPEED);
                    end
                end
                STATE_DEAD: begin if (jump_pending) state <= STATE_READY; end
            endcase
        end
    end

    // --- PIPELINED RENDERER (Updated for Details) ---
    logic [2:0] x_hit_pipe;
    
    // P1 = Pipeline Stage 1 registers
    logic bird_body_p1;
    logic bird_eye_p1;
    logic bird_wing_p1;

    // P2 = Pipeline Stage 2 registers
    logic pipe_pixel_p2;
    logic bird_body_p2;
    logic bird_eye_p2;
    logic bird_wing_p2;

    always_ff @(posedge clk) begin
        // --- STAGE 1: Geometry Check ---
        x_hit_pipe <= 0;
        if ( ($signed({2'b0, x_val}) >= pipe_x[0]) && ($signed({2'b0, x_val}) < pipe_x[0] + 12'(PIPE_W)) ) x_hit_pipe[0] <= 1;
        if ( ($signed({2'b0, x_val}) >= pipe_x[1]) && ($signed({2'b0, x_val}) < pipe_x[1] + 12'(PIPE_W)) ) x_hit_pipe[1] <= 1;
        if ( ($signed({2'b0, x_val}) >= pipe_x[2]) && ($signed({2'b0, x_val}) < pipe_x[2] + 12'(PIPE_W)) ) x_hit_pipe[2] <= 1;

        // 1. Main Body Check
        bird_body_p1 <= 0;
        if (x_val >= BIRD_X && x_val < BIRD_X + BIRD_W && y_val >= bird_y && y_val < bird_y + BIRD_H) 
            bird_body_p1 <= 1;

        // 2. Eye Check (3x3 pixels, offset X+16, Y+5 from top-left)
        bird_eye_p1 <= 0;
        if (x_val >= BIRD_X + 18 && x_val < BIRD_X + 20 && y_val >= bird_y + 5 && y_val < bird_y + 8)
            bird_eye_p1 <= 1;

        // 3. Wing Check (10x8 pixels, offset X+4, Y+12 from top-left)
        bird_wing_p1 <= 0;
        if (x_val >= BIRD_X + 2 && x_val < BIRD_X + 14 && y_val >= bird_y + 12 && y_val < bird_y + 20)
            bird_wing_p1 <= 1;

        // --- STAGE 2: Y Check & Pipeline pass-through ---
        pipe_pixel_p2 <= 0;
        // Pass bird parts through pipeline so they stay synced
        bird_body_p2 <= bird_body_p1;
        bird_eye_p2  <= bird_eye_p1;
        bird_wing_p2 <= bird_wing_p1;

        if (x_hit_pipe[0]) begin if (y_val < pipe_gap_y[0] || y_val > pipe_gap_y[0] + GAP_SIZE) pipe_pixel_p2 <= 1; end
        else if (x_hit_pipe[1]) begin if (y_val < pipe_gap_y[1] || y_val > pipe_gap_y[1] + GAP_SIZE) pipe_pixel_p2 <= 1; end
        else if (x_hit_pipe[2]) begin if (y_val < pipe_gap_y[2] || y_val > pipe_gap_y[2] + GAP_SIZE) pipe_pixel_p2 <= 1; end

        // --- STAGE 3: Color Priority Mux ---
        if (bird_body_p2) begin
            // Priority: Eye > Wing > Body
            if (bird_eye_p2) rgb_out <= 3'b000;      // Black Eye
            else if (bird_wing_p2) rgb_out <= 3'b111; // White Wing
            else rgb_out <= (state == STATE_DEAD) ? 3'b100 : 3'b110; // Red/Yellow Body
        end
        else if (pipe_pixel_p2) rgb_out <= 3'b010; // Green Pipe
        else rgb_out <= 3'b011; // Cyan BG
    end

endmodule