// selects what color to display for pixel
// if pixel is part of bird, display bird
// if pixel is part of pipe, display pipe
// if pixel is not bird and not pipe, display blue (default)
// if pixel is bird and pipe, freeze screen (pipes stop moving, bird cannot move)

`default_nettype none
`timescale 1ns/1ps

module display(
    input  logic        clk,         // System Clock (25 MHz)
    input  logic        vsync,       // Vertical Sync (60 Hz frame clock)
    input  logic [2:0]  bird_rgb,    // Color output from bird module
    input  logic [2:0]  pipe_rgb,    // Color output from pipe module
    output logic [2:0]  final_rgb,   // Final color to VGA
    output logic        game_running // Control signal to halt pipe/bird movement
);
    localparam BG_COLOR      = 3'b001; // Blue 

    /// state of display
    typedef enum logic {
        STATE_RUNNING,
        STATE_FROZEN
    } game_state_t;

    game_state_t game_state, next_game_state;
    
    logic is_bird, is_pipe, is_collision;

    // Determine presence of Bird/Pipe based on their color output
    assign is_bird = (bird_rgb != BG_COLOR);
    assign is_pipe = (pipe_rgb != BG_COLOR);

    // Collision occurs if both are true
    assign is_collision = is_bird & is_pipe;

    always_ff @(posedge vsync) begin
        game_state <= next_game_state;
    end

    // next state logic
    always_comb begin
        next_game_state = game_state; // default: continue running
        
        case (game_state)
            STATE_RUNNING: begin
                if (is_collision) begin
                    next_game_state = STATE_FROZEN;
                end
            end
            STATE_FROZEN: begin
                next_game_state = STATE_FROZEN;
            end
        endcase
    end

    assign game_running = (game_state == STATE_RUNNING);
    
    // Choosing color of pixel
    always_comb begin
        final_rgb = BG_COLOR; 
        
        if (is_bird) begin
            final_rgb = bird_rgb;
        end 
        else if (is_pipe) begin
            final_rgb = pipe_rgb;
        end 
        else begin
            final_rgb = BG_COLOR;
        end
    end

endmodule