module vga_top (

);

logic c;

vga u0(
.game_clk,
.rgb(c),
.hsync(),
.vsync(),
.x_pos(),
.y_pos(),
.color()
);
endmodule