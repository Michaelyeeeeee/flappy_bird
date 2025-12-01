// flappy_game.sv
// 1. Removed Debug Magenta Background (Sky is always Cyan).
// 2. Increased Jump Strength (-5 to -9).
// 3. Kept Pipelining to ensure it compiles without timing errors.
`timescale 1ns/1ps

module flappy_game (
    input  logic clk,
    input  logic vsync,       
    input  logic flap_pulse,  
    input  logic btn_held,    // Unused for color now
    input  logic [9:0] x_val,
    input  logic [9:0] y_val,
    output logic [2:0] rgb_out
);

    // --- SIZES ---
    localparam integer BIRD_X      = 147;
    localparam integer BIRD_W      = 23;
    localparam integer BIRD_H      = 30;
    localparam integer FIXED_GAP_Y = 180;
    localparam integer GAP_SIZE    = 110;
    localparam integer PIPE_W      = 40;

    // --- PHYSICS ---
    localparam integer FALL_SPEED  = 2;  
    
    // UPDATED: Stronger Jump (-5 was too weak, -9 is snappy)
    localparam integer JUMP_SPEED  = -7; 
    
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
    integer i;

    // --- PHYSICS LOOP (60Hz) ---
    always_ff @(posedge clk) begin
        if (game_tick) begin
            case (state)
                STATE_READY: begin
                    bird_y <= 220;
                    bird_v <= 0;
                    pipe_x[0] <= 12'd500; pipe_x[1] <= 12'd800; pipe_x[2] <= 12'd1100;

                    if (jump_pending) begin
                        bird_v <= JUMP_SPEED;
                        state <= STATE_PLAY;
                    end
                end

                STATE_PLAY: begin
                    // Movement
                    if (jump_pending) begin
                        bird_v <= JUMP_SPEED; 
                    end else begin
                        // Gravity Logic:
                        // If moving up (negative), gravity pulls it down (+1)
                        // If falling (positive), cap at FALL_SPEED
                        if (bird_v < FALL_SPEED) bird_v <= bird_v + 1; 
                        else bird_v <= 6'(FALL_SPEED); 
                    end

                    bird_y <= bird_y + bird_v;

                    // Boundaries
                    if (bird_y < 0) bird_y <= 0;
                    if (bird_y > 450) state <= STATE_DEAD; 

                    // Pipes
                    for (i=0; i<3; i=i+1) begin
                        if (pipe_x[i] < -50) pipe_x[i] <= 12'd850; 
                        else pipe_x[i] <= pipe_x[i] - 12'(PIPE_SPEED);

                        // Physics Collision Check
                        if ( ($signed(12'(BIRD_X + BIRD_W)) > pipe_x[i]) && 
                             ($signed(12'(BIRD_X)) < pipe_x[i] + 12'(PIPE_W)) ) begin
                            if ( (bird_y < FIXED_GAP_Y) || (bird_y + BIRD_H > FIXED_GAP_Y + GAP_SIZE) ) begin
                                state <= STATE_DEAD;
                            end
                        end
                    end
                end

                STATE_DEAD: begin
                    if (jump_pending) state <= STATE_READY;
                end
            endcase
        end
    end

    // --- PIPELINED RENDERER ---
    logic pipe_flag;
    logic bird_flag;
    logic [2:0] stage2_color;

    always_ff @(posedge clk) begin
        // --- STAGE 1: Geometry Check ---
        pipe_flag <= 0;
        bird_flag <= 0;

        // Check Pipes
        for (i=0; i<3; i=i+1) begin
            if ( ($signed({2'b0, x_val}) >= pipe_x[i]) && 
                 ($signed({2'b0, x_val}) < pipe_x[i] + 12'(PIPE_W)) ) begin
                if (y_val < FIXED_GAP_Y || y_val > FIXED_GAP_Y + GAP_SIZE)
                    pipe_flag <= 1; 
            end
        end

        // Check Bird
        if (x_val >= BIRD_X && x_val < BIRD_X + BIRD_W &&
            y_val >= bird_y && y_val < bird_y + BIRD_H) begin
            bird_flag <= 1;     
        end

        // --- STAGE 2: Color Mux ---
        if (bird_flag) begin
            stage2_color <= (state == STATE_DEAD) ? 3'b100 : 3'b110; // Red or Yellow
        end else if (pipe_flag) begin
            stage2_color <= 3'b010; // Green
        end else begin
            // UPDATED: Always Cyan (3'b011). Removed the Magenta debug logic.
            stage2_color <= 3'b011; 
        end
    end

    assign rgb_out = stage2_color;

endmodule