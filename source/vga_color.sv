/* Color for VGA
 *
 * input x_val, y_val - current position of VGA counter
 * input rgb - color from game logic
 * output color - display color
 */

`timescale 1ns/1ps

module vga_color (
    input  logic clk, // VGA clock (25MHz)
    input  logic [2:0]  rgb_in, // input from game logic
    input  logic [9:0]  x_val,
    input  logic [9:0]  y_val,
    output logic [2:0]  color
);
    // display parameters
    parameter X_MAX = 10'd639;
    parameter Y_MAX = 10'd479;

    // synch registers
    logic [2:0] rgb_sync0, rgb_sync1;

    always_ff @(posedge clk) begin
        // adds cycle delay to avoid glitches
        rgb_sync0 <= rgb_in;
        rgb_sync1 <= rgb_sync0;

        if (x_val <= X_MAX && y_val <= Y_MAX)
            color <= rgb_sync1;
        else
            color <= 3'b000;
    end

endmodule