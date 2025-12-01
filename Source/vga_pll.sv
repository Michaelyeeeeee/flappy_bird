// vga_pll.sv
module vga_pll (
    output logic VGA_CLK
);
    logic clk_int;
    SB_HFOSC #( .CLKHF_DIV("0b10") ) u_hfosc (
        .CLKHFEN(1'b1),
        .CLKHFPU(1'b1),
        .CLKHF(clk_int)
    );

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

    assign VGA_CLK = pll_out;
endmodule