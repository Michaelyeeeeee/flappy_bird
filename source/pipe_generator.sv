//======================================================================
//  Pipe Generator – 3 Scrolling Pipes
//======================================================================
//
//  DESIGN SPEC:
//  ---------------------------------------------------------------
//  * Pipe width:        60 px
//  * Gap height:        90 px
//  * 3 pipes on screen
//  * Pipes spaced:      240 px apart
//  * Screen width:      640 px
//  * Pipes scroll left continuously
//  * When a pipe leaves screen, it wraps to right side
//  * Provides each pipe's:
//        - x position
//        - gap_center
//        - gap_height
//
//======================================================================

`default_nettype none

module pipe_generator (
    input  logic        clk,
    input  logic        rst,
    input  logic        en,     // game tick

    // Replaced array ports with normal signals
    output logic [9:0]  pipe_x0,
    output logic [9:0]  pipe_x1,
    output logic [9:0]  pipe_x2,

    output logic [15:0] gap_center0,
    output logic [15:0] gap_center1,
    output logic [15:0] gap_center2,

    output logic [15:0] gap_height0,
    output logic [15:0] gap_height1,
    output logic [15:0] gap_height2
);

    localparam PIPE_W      = 60;
    localparam GAP_H       = 90;
    localparam PIPE_SPACE  = 240;
    localparam SCREEN_W    = 640;

    // LFSR for pseudo-random gap centers
    logic [7:0] lfsr = 8'hA5;

    //------------------------------------------------------------------
    // Initialize pipe positions and gap centers
    //------------------------------------------------------------------
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            pipe_x0 <= 10'd640;                     // first appears at right
            pipe_x1 <= 10'd640 + PIPE_SPACE;
            pipe_x2 <= 10'd640 + PIPE_SPACE*2;

            gap_center0 <= 16'd240;
            gap_center1 <= 16'd240;
            gap_center2 <= 16'd240;

            gap_height0 <= GAP_H;
            gap_height1 <= GAP_H;
            gap_height2 <= GAP_H;
        end

        //------------------------------------------------------------------
        // Scroll and respawn
        //------------------------------------------------------------------
        else if (en) begin

            // pipe_x0 --------------------------------
            pipe_x0 <= pipe_x0 - 1;
            if ($signed(pipe_x0) < -PIPE_W) begin
                pipe_x0 <= SCREEN_W + PIPE_W;
                lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5]};
                gap_center0 <= 100 + (lfsr % 280);
            end

            // pipe_x1 --------------------------------
            pipe_x1 <= pipe_x1 - 1;
            if ($signed(pipe_x1) < -PIPE_W) begin
                pipe_x1 <= SCREEN_W + PIPE_W;
                lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5]};
                gap_center1 <= 100 + (lfsr % 280);
            end

            // pipe_x2 --------------------------------
            pipe_x2 <= pipe_x2 - 1;
            if ($signed(pipe_x2) < -PIPE_W) begin
                pipe_x2 <= SCREEN_W + PIPE_W;
                lfsr <= {lfsr[6:0], lfsr[7] ^ lfsr[5]};
                gap_center2 <= 100 + (lfsr % 280);
            end

        end
    end

    // Constant gap height
    assign gap_height0 = GAP_H;
    assign gap_height1 = GAP_H;
    assign gap_height2 = GAP_H;

endmodule
