// ON LED SIDE:
// HSYNC PIN: ICE 42
// VSYNC PIN: ICE 36
// RED: ICE (MSB to LSB) 45 47 2 4
// GREEN: ICE (MSB to LSB) 31 34 38 43
// BLUE: ICE (MSB to LSB) 44_G6 46 48 3
// VCC: 


module top (
output logic ICE_42, // HSYNC
output logic ICE_36, // VSYNC
output logic ICE_45, // R
output logic ICE_31, // G
output logic ICE_44_G6, // B
output logic ICE_27 //pll
);

logic [2:0] c;
logic [9:0] x_pos, y_pos;
logic pll;

assign ICE_27 = pll;

vga_pll vga_clk(
    .VGA_CLK(pll)
);

vga u0(
.game_clk(),
.pll(pll),
.rgb(c),
.hsync(ICE_42),
.vsync(ICE_36),
.x_pos(x_pos),
.y_pos(y_pos),
.color({ICE_45, ICE_31, ICE_44_G6})
);

vga_test u1(
.clk(pll),
.color(c)
);
endmodule