module top (
output logic ICE_PMOD2B_IO1, // HSYNC
output logic ICE_PMOD2B_IO2, // VSYNC
output logic ICE_PMOD2A_IO1, // R
output logic ICE_PMOD2A_IO2, // G
output logic ICE_PMOD2A_IO3, // B
);

logic [2:0] c;
logic [9:0] x_pos, y_pos;
logic pll;

vga_pll vga_clk(
    .VGA_CLK(pll)
);

vga u0(
.game_clk(),
.pll(pll),
.rgb(c),
.hsync(ICE_PMOD2B_IO1),
.vsync(ICE_PMOD2B_IO2),
.x_pos(x_pos),
.y_pos(y_pos),
.color({ICE_PMOD2A_IO1, ICE_PMOD2A_IO2, ICE_PMOD2A_IO3})
);

vga_test u1(
.clk(pll),
.color(c)
);
endmodule