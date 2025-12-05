// top.sv
`default_nettype none
`timescale 1ns/1ps

module top (
    input  logic ICE_PB,    
    output logic ICE_42, ICE_36, // Syncs (HSYNC, VSYNC)
    output logic ICE_45, ICE_31, ICE_44_G6, // RGB
    output logic ICE_27 // PLL Check
);

    // 1. PLL (12MHz -> 25MHz)
    logic pll_clk;
    vga_pll pll_inst (.VGA_CLK(pll_clk));
    assign ICE_27 = pll_clk;

    // 2. VGA Counter (Registered outputs for stability)
    logic hsync, vsync, video_on;
    logic [9:0] x, y;
    
    vga_counter vga_cnt (
        .clk(pll_clk),
        .hsync(hsync), 
        .vsync(vsync),
        .x_val(x), 
        .y_val(y),
        .video_on(video_on)
    );

    // 3. Button Debounce
    logic flap_pulse, btn_held;
    button_sync_debounce #( .DEBOUNCE_TICKS(250000) ) btn_inst (
        .clk(pll_clk),
        .btn_n_raw(ICE_PB),
        .flap_pulse(flap_pulse),
        .btn_held(btn_held)
    );

    // 4. Game Engine
    logic [2:0] rgb;
    flappy_game game_inst (
        .clk(pll_clk),
        .flap_pulse(flap_pulse),
        .btn_held(btn_held), 
        .x_val(x), 
        .y_val(y),
        .rgb_out(rgb)
    );

    // 5. Output Assignments
    // Direct drive Syncs (Cleanest signal)
    assign ICE_42 = hsync;
    assign ICE_36 = vsync;
    
    // Mask Colors (Force Black during blanking intervals)
    assign ICE_45    = video_on ? rgb[2] : 1'b0; // Red
    assign ICE_31    = video_on ? rgb[1] : 1'b0; // Green
    assign ICE_44_G6 = video_on ? rgb[0] : 1'b0; // Blue

endmodule