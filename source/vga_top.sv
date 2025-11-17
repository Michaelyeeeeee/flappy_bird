module vga_top (

);

logic [2:0] c;
logic [9:0] x_pos, y_pos;

vga u0(
.game_clk(),
.rgb(c),
.hsync(),
.vsync(),
.x_pos(x_pos),
.y_pos(y_pos),
.color()
);

vga_test u1(

);
endmodule