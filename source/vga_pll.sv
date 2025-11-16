// Taken from Brightspace

module vga_pll (
    output logic VGA_CLK
);
    // Step 1: Internal 12 MHz oscillator
    logic clk_int;
    SB_HFOSC #(
        .CLKHF_DIV("0b10")  // Divide by 4, 12 MHz (default is 48 MHz)
    ) u_hfosc (
        .CLKHFEN(1'b1),
        .CLKHFPU(1'b1),
        .CLKHF(clk_int)
    );

    // Step 2: PLL to generate ~25 MHz
    logic pll_out;

    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .PLLOUT_SELECT("GENCLK"),
        .DIVR(4'b0000),     
        .DIVF(7'd66),       
        .DIVQ(3'b101),         
        .FILTER_RANGE(3'b100)
    ) u_pll (
        .REFERENCECLK(clk_int),
        .PLLOUTCORE(pll_out),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    // Step 3: Output
    assign VGA_CLK = pll_out;
endmodule