`default_nettype none
`timescale 1ns/1ps

module pipe (
    input  logic        clk,        // System Clock (25 MHz)
    input  logic        vsync,      // Vertical Sync (used for animation timing)
    input  logic [9:0]  x_pos,      // Current Pixel X position
    input  logic [9:0]  y_pos,      // Current Pixel Y position
    output logic [2:0]  pipe_rgb    // Output Color (000 or 010)
);
    localparam PIPE_WIDTH   = 10'd60;
    localparam PIPE_GAP     = 10'd120;   // Vertical opening size
    localparam PIPE_DIST    = 10'd240;  // Horizontal space between pipes
    localparam NUM_PIPES    = 3;        // 3 pipes is enough to cover 640px width + buffers
    localparam PIPE_SPEED   = 10'd2;    // Pixels moved per frame
    
    localparam GAP_CENTER   = 10'd240;
    localparam GAP_TOP      = GAP_CENTER - (PIPE_GAP / 2); // 180
    localparam GAP_BOT      = GAP_CENTER + (PIPE_GAP / 2); // 300
    
    // Pipe Spacing logic: (Width 60 + Gap 240 = 300 pixels cycle)
    localparam PIPE_CYCLE   = PIPE_WIDTH + PIPE_DIST;
    
    localparam SCREEN_W     = 10'd640;
    localparam START_OFFSET = 11'd650; 

    // Movement Logic
	// location of x of each pipe (signed to allow off screen)
    logic signed [11:0] pipe_x [0:NUM_PIPES-1];
    
    // Detect VSYNC edge to trigger movement once per frame (60Hz)
    logic vsync_prev;
    logic frame_pulse;
    
    always_ff @(posedge clk) begin
        vsync_prev <= vsync;
        frame_pulse <= (vsync && !vsync_prev);
    end

    // init all pipe positions (offset each by 300 pixels)
    initial begin
        int i;
        for (i = 0; i < NUM_PIPES; i++) begin
            pipe_x[i] = START_POS_RIGHT + (TOTAL_SPAN) - ( (i + 1) * PIPE_CYCLE );
        end
    end

    // Update positions
    always_ff @(posedge clk) begin
        if (frame_pulse) begin
            int i;
            for (i = 0; i < NUM_PIPES; i++) begin
                // Move pipe to the left
                pipe_x[i] <= pipe_x[i] - signed'(PIPE_SPEED);

                // check if whole pipe can't be seen on the left
				// left edge + width = right edge < 0
                if ((pipe_x[i] + signed'(PIPE_WIDTH)) < 0) begin
                    // reset pipe back to far right
                    pipe_x[i] <= pipe_x[i] + signed'(NUM_PIPES * PIPE_CYCLE);
                end
            end
        end
    end

	// drawing logic
    logic is_pipe_pixel;
    logic [3:0] pipe_active_flags; // Debug/Temp bitmask

    always_comb begin
        is_pipe_pixel = 1'b0;
        
        // if not in gap (y pos)
        if (y_pos < GAP_TOP || y_pos > GAP_BOT) begin
            
            // check x of each pipe
            for (int i = 0; i < NUM_PIPES; i++) begin
                // Check if current x_pos is within this pipe's horizontal area
                if (signed'(x_pos) >= pipe_x[i] && signed'(x_pos) < (pipe_x[i] + signed'(PIPE_WIDTH))) begin
                    is_pipe_pixel = 1'b1;
                end
            end
        end
    end

    assign pipe_rgb = is_pipe_pixel ? 3'b010 : 3'b001;

endmodule
