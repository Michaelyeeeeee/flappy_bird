`default_nettype none
// ON LED SIDE:
// HSYNC PIN: ICE 42
// VSYNC PIN: ICE 36
// RED: ICE (MSB to LSB) 45 47 2 4
// GREEN: ICE (MSB to LSB) 31 34 38 43
// BLUE: ICE (MSB to LSB) 44_G6 46 48 3
// VCC: 
// JUMP: ICE PB


module top (
input ICE_PB,
output logic ICE_42, // HSYNC
output logic ICE_36, // VSYNC
output logic ICE_45, // R
output logic ICE_31, // G
output logic ICE_44_G6, // B
);

// logic [2:0] pipe_rgb_data;
logic [2:0] bird_rgb_data;
logic [9:0] bird_y_pos;
logic [9:0] x_pos, y_pos;
logic pll;

vga_pll vga_clk(
    .VGA_CLK(pll)
);

/*
pipe pipe_inst (
    .clk(pll),          // 25MHz Clock
    .vsync(ICE_36),     // Use the VSYNC signal to time movement (60fps)
    .x_pos(x_pos),      // Current X from VGA module
    .y_pos(y_pos),      // Current Y from VGA module
    .pipe_rgb(pipe_rgb_data) // Output color
); */

bird bird_inst (
    .clk(pll), 
    .vsync(ICE_36),           // Frame timing from VGA
    .jump(ICE_PB),            // Button input
    .x_pos(x_pos), 
    .y_pos(y_pos), 
    .bird_rgb(bird_rgb_data), // Output color (Yellow or Blue)
    .bird_y_out(bird_y_pos)   // Output Y position
);

vga vga_inst(
    .game_clk(),
    .pll(pll),
    .rgb(bird_rgb_data),
    .hsync(ICE_42),
    .vsync(ICE_36),
    .x_pos(x_pos),
    .y_pos(y_pos),
    .color({ICE_45, ICE_31, ICE_44_G6})
);

endmodule
