// bird bottom left is at (160, 240)

//constant downwards velocity of 60 pixels per second
//the jump will be 60 pixels per button press

// bird is 30 x 30 pixels
// bird is yellow RGB  = 110

`default_nettype none
`timescale 1ns/1ps

module bird(
    input  logic        clk,         // System Clock (25 MHz)
    input  logic        vsync,       // Vertical Sync (60 Hz frame clock)
    input  logic        jump,        // User button press (Jump request)
    input  logic [9:0]  x_pos,       // Current Pixel X position from VGA counter
    input  logic [9:0]  y_pos,       // Current Pixel Y position from VGA counter
    output logic [2:0]  bird_rgb,
    output logic [9:0]  bird_y_out
);
    localparam START_X        = 10'd160;
    localparam START_Y        = 10'd240;
    localparam BIRD_SIZE      = 10'd30;
    localparam HALF_JUMP_DIST = 10'd30; // Jump distance is 60. Set to 30 for velocity calculation.
    localparam JUMP_DIST      = 10'd60; // 60 pixels jump upon button press
    localparam DOWN_VELOCITY  = 1;      // 1 pixel per frame (1 * 60 Hz = 60 pix/sec)
    localparam SCREEN_HEIGHT  = 10'd480;

    // Movement Logic

    // Register to store the bird's vertical center position
    logic [9:0] bird_y_reg = START_Y; 
    
    // Jump detection logic
    logic jump_prev;
    logic jump_pulse;
    
    always_ff @(posedge clk) begin
        jump_prev <= jump;
        jump_pulse <= jump && !jump_prev;
    end
    
    always_ff @(posedge clk) begin
        if (vsync) begin
            
            logic [9:0] next_y;
            
            if (jump_pulse) begin
                next_y = bird_y_reg - JUMP_DIST; // Move up
            end 
            else begin
                next_y = bird_y_reg + DOWN_VELOCITY; // Move down
            end
            
            // check if the calculated position is reaching ceiling
            if (next_y[9] == 1'b1 || next_y < 10'd0) begin 
                next_y = 10'd0;
            end
            
            // check if position is reaching floor
            else if (next_y > (SCREEN_HEIGHT - BIRD_SIZE)) begin
                next_y = SCREEN_HEIGHT - BIRD_SIZE;
            end
            
            bird_y_reg <= next_y;
        end
    end
    
    assign bird_y_out = bird_y_reg;

    // drawing logic
    logic is_bird_pixel;
    
    // determine if pixel is bird
    always_comb begin
        is_bird_pixel = 1'b0;
        
        // check x pos
        if (x_pos >= START_X && x_pos < (START_X + BIRD_SIZE)) begin
            // check y pos
            if (y_pos >= bird_y_reg && y_pos < (bird_y_reg + BIRD_SIZE)) begin
                is_bird_pixel = 1'b1;
            end
        end
    end

    assign bird_rgb = is_bird_pixel ? 3'b110 : 3'b001;

endmodule