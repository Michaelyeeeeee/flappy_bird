`timescale 1ns/1ps

module vga(
input logic game_clk, // possibly just put PLL in this module or have universal PLL and no slower game clock
// input logic pll,
input logic [2:0] rgb,
output logic hsync, vsync, // active high
output logic [9:0] x_pos, y_pos,
output logic [2:0] color
);
    logic pll;

    vga_pll vga_clk(
        .VGA_CLK(pll)
    );

    vga_counter counter(
        .clk(pll),
        .hsync(hsync),
        .vsync(vsync),
        .x_val(x_pos),
        .y_val(y_pos)
    );

    vga_color display_color(
        .clk(pll),
        .x_val(x_pos),
        .y_val(y_pos),
        .rgb_in(rgb),
        .color(color)
    );
endmodule