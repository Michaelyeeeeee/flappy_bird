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
    
    // Vertical movement updates only on the VSYNC (60 Hz) clock pulse
    always_ff @(posedge clk) begin
        if (vsync) begin
            if (jump_pulse) begin
                // Move bird up by 60 pixels
                bird_y_reg <= bird_y_reg - JUMP_DIST;
            end 
            else begin
                // Move bird down by 1 pixel/frame
                bird_y_reg <= bird_y_reg + DOWN_VELOCITY;
            end
            
            // Prevent bird from going above the top boundary
            if (bird_y_reg < JUMP_DIST) begin
                bird_y_reg <= 10'd0;
            end
            
            // Prevent bird from falling below the floor
            if (bird_y_reg > (SCREEN_HEIGHT - BIRD_SIZE)) begin
                bird_y_reg <= SCREEN_HEIGHT - BIRD_SIZE;
            end
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