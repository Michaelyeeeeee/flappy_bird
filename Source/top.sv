`default_nettype none
module top (
    input  logic ICE_PB,    
    output logic ICE_42, // VSYNC
    output logic ICE_36, // HSYNC
    output logic ICE_45, // RED: ICE (MSB to LSB) 45 47 2 4
    output logic ICE_31, // GREEN: ICE (MSB to LSB) 31 34 38 43
    output logic ICE_44_G6, // BLUE: ICE (MSB to LSB) 44_G6 46 48 3
);

    // make the pll
    logic pll_clk;
    vga_pll pll_inst (.VGA_CLK(pll_clk));

    // vga counters
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

    // debounce the button
    logic flap_pulse, btn_held;
    button_sync_debounce #( .DEBOUNCE_TICKS(250000) ) btn_inst (
        .clk(pll_clk),
        .btn_n_raw(ICE_PB),
        .flap_pulse(flap_pulse),
        .btn_held(btn_held)
    );

    // game logic
    logic [2:0] rgb;
    flappy_game game_inst (
        .clk(pll_clk),
        .flap_pulse(flap_pulse),
        .btn_held(btn_held), 
        .x_val(x), 
        .y_val(y),
        .rgb_out(rgb)
    );

    // output
    assign ICE_42 = hsync;
    assign ICE_36 = vsync;
    assign ICE_45 = video_on ? rgb[2] : 1'b0; // red
    assign ICE_31 = video_on ? rgb[1] : 1'b0; // green
    assign ICE_44_G6 = video_on ? rgb[0] : 1'b0; // blue

endmodule