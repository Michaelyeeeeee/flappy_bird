`timescale 1ns/1ps

module vga_tb();
    logic game_clk;
    logic pll;
    logic [2:0] rgb;
    logic hsync, vsync;
    logic [9:0] x_pos, y_pos;
    logic [2:0] color;

    vga dut (
        .game_clk(game_clk),
        .pll(pll),
        .rgb(rgb),
        .hsync(hsync),
        .vsync(vsync),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .color(color)
    );

    initial pll = 0;
    always #20 pll = ~pll;  // 40 ns period

    initial game_clk = 0;
    always #40 game_clk = ~game_clk; // 80 ns period

    initial begin
        $dumpfile("vga_tb.vcd");
        $dumpvars(0, vga_tb);
    end

    initial begin
        
        $finish;
    end
endmodule