`default_nettype none

// Bird and pipe sizes from our design spec (discussion.sv)
`define BIRD_SZ  16'd30         // 30 px tall
`define PIPE_W   16'd60         // 60 px wide

module collision (
    input  logic [15:0] bird_x,       // fixed at 160 in your design
    input  logic [15:0] bird_y,
    input  logic [9:0]  pipe_x,       // x position of current pipe
    input  logic [15:0] gap_center,   // vertical center of pipe gap
    input  logic [15:0] gap_height,   // always 90 px but flexible
    output logic        birbded
);

    logic [15:0] bird_top;
    logic [15:0] bird_bottom;

    logic [15:0] gap_top;
    logic [15:0] gap_bottom;

    logic horiz_overlap;
    logic vert_fail;

    //------------------------------------------------------------------
    // Compute bird bounding box
    //------------------------------------------------------------------
    always_comb begin
        bird_top    = bird_y;
        bird_bottom = bird_y + `BIRD_SZ;
        //------------------------------------------------------------------
        // Gap boundaries
        //------------------------------------------------------------------
        gap_top    = gap_center - (gap_height >> 1);
        gap_bottom = gap_center + (gap_height >> 1);
    end

    //------------------------------------------------------------------
    // Horizontal collision: x overlap
    //------------------------------------------------------------------
    assign horiz_overlap =
           (bird_x + `BIRD_SZ > pipe_x) &&
           (bird_x < pipe_x + `PIPE_W);

    //------------------------------------------------------------------
    // Vertical failure: bird outside the gap
    //------------------------------------------------------------------
    assign vert_fail =
           (bird_bottom < gap_top) ||    // too high
           (bird_top > gap_bottom);      //too low
    // seems weird but this is cuz we r doing 0,0 at top left of screen i can change this is we change coordinate system
    //------------------------------------------------------------------
    // Collision = both conditions
    //------------------------------------------------------------------
    assign birbded = horiz_overlap && vert_fail;

endmodule
