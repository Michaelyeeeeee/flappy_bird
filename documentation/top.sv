// top.sv
`default_nettype none
`timescale 1ns/1ps

module top (
    input  logic ICE_PB,    
    output logic ICE_42, ICE_36, // Syncs
    output logic ICE_45, ICE_31, ICE_44_G6, // RGB
    output logic ICE_27 // PLL Check
);

    logic pll_clk;
    vga_pll pll_inst (.VGA_CLK(pll_clk));
    assign ICE_27 = pll_clk;

    logic hsync, vsync, video_on;
    logic [9:0] x, y;
    
    vga_counter vga_cnt (
        .clk(pll_clk),
        .hsync(hsync), 
        .vsync(vsync), // This goes to the game now
        .x_val(x), .y_val(y),
        .video_on(video_on)
    );

    logic flap_pulse, btn_held;
    button_sync_debounce #( .DEBOUNCE_TICKS(250000) ) btn_inst (
        .clk(pll_clk),
        .btn_n_raw(ICE_PB),
        .flap_pulse(flap_pulse),
        .btn_held(btn_held)
    );

    logic [2:0] rgb;
    flappy_game game_inst (
        .clk(pll_clk),
        .vsync(vsync),     // <--- NEW CONNECTION
        .flap_pulse(flap_pulse),
        .btn_held(btn_held),
        .x_val(x), .y_val(y),
        .rgb_out(rgb)
    );

    // Outputs
    assign ICE_42 = hsync;
    assign ICE_36 = vsync;
    
    // Force Black borders
    assign ICE_45    = video_on ? rgb[2] : 0;
    assign ICE_31    = video_on ? rgb[1] : 0;
    assign ICE_44_G6 = video_on ? rgb[0] : 0;

endmodule