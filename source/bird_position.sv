//======================================================================
//  Flappy Bird – Bird Position Update (Constant Velocity Version)
//======================================================================
//
//  DESIGN SPEC (from project):
//  ---------------------------------------------------------------
//  * Bird horizontal position fixed at x = 160 pixels
//  * Bird starts at y = 240 pixels from the top
//  * Bird size: 30 × 30 pixels (vertical size relevant only here)
//  * Gravity = constant downward movement (NO acceleration)
//  * Fall speed target: ~80 px/sec   (exact depends on tick rate)
//  * Jump = 60 pixels upward instantly (one button press)
//  * Update runs on a divided clock from 725 kHz → rate TBD
//
//  Because the update tick frequency is not finalized,
//  BIRD_FALL is a temporary constant (2 px per tick).
//  Replace when the divider is known.
//
//======================================================================

`default_nettype none

`define BIRD_FALL    16'sd2      // constant downward fall (px per tick)
`define BIRD_JUMP   -16'sd60     // instant upward jump (60 px) neg cuz of coordinate sys... 0,0 at top left?

module bird_position (
  input  logic        clk,     // main PLL clock (725 kHz)?
  input  logic        en,      // game tick (divider output) for pause we can maybe have an and or smth with this en
    input  logic        rst,
    input  logic        jmp,
    output logic [15:0] pos      // bird vertical position (y)
);

    logic signed [15:0] bird_y;
    logic signed [15:0] nxt_y;

    always_ff @(posedge clk or posedge rst) begin
        if (rst)
            bird_y <= 16'sd240;       // initial Y position
        else if (en)
            bird_y <= nxt_y;
    end

    always_comb begin
        if (jmp)
            nxt_y = bird_y + `BIRD_JUMP;     // jump up 60 px
        else
            nxt_y = bird_y + `BIRD_FALL;     // fall constant amount
    end

    assign pos = bird_y;

endmodule
