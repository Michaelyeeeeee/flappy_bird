`timescale 1ns/1ps

module vga_tb();
    logic game_clk;
    logic pll;
    logic [2:0] rgb;
    logic hsync, vsync;
    logic [9:0] x_pos, y_pos;
    logic [2:0] color;

    vga dut (
        .game_clk(game_clk),
        .pll(pll),
        .rgb(rgb),
        .hsync(hsync),
        .vsync(vsync),
        .x_pos(x_pos),
        .y_pos(y_pos),
        .color(color)
    );

    initial pll = 0;
    always #20 pll = ~pll;  // 40 ns period

    initial game_clk = 0;
    always #40 game_clk = ~game_clk; // 80 ns period

    initial begin
        $dumpfile("vga_tb.vcd");
        $dumpvars(0, vga_tb);
    end


    // generates white in visible screen
    always_ff @(posedge game_clk) begin
        rgb <= 3'b111;
    end

    integer num_sync_wrong = 0;
    integer num_color_wrong = 0;

    // checks if generated sync is correct
    always_ff @(posedge pll) begin
        // Sync check
        if (x_pos >= 10'd656 && x_pos <= 10'd751) begin
            if (hsync != 1'b1) begin 
                $display ("HSYNC error: Should be HIGH at x=%0d, y=%0d (Check X:%0d)", x_pos, y_pos, x_pos);
                num_sync_wrong = num_sync_wrong + 1;
            end
        end else begin
            if (hsync != 1'b0) begin
                $display ("HSYNC error: Should be LOW at x=%0d, y=%0d (Check X:%0d)", x_pos, y_pos, x_pos);
                num_sync_wrong = num_sync_wrong + 1;
            end
        end

        if (y_pos >= 10'd490 && y_pos <= 10'd491) begin
            if (vsync != 1'b1) begin
                $display ("VSYNC error: Should be HIGH at x=%0d, y=%0d (Check Y:%0d)", x_pos, y_pos, y_pos);
                num_sync_wrong = num_sync_wrong + 1;
            end
        end else begin
            if (vsync != 1'b0) begin
                $display ("VSYNC error: Should be LOW at x=%0d, y=%0d (Check Y:%0d)", x_pos, y_pos, y_pos);
                num_sync_wrong = num_sync_wrong + 1;
            end
        end

        // Color check
        if (x_pos <= 10'd639 && y_pos <= 10'd479) begin
            if (color != 3'b111) begin
                $display("COLOR error: Should be ON inside visible area at x=%0d, y=%0d", x_pos, y_pos);
                num_color_wrong = num_color_wrong + 1;
            end
        end else begin
            if (color != 3'b000) begin
                $display("COLOR error: Should be OFF outside visible area at x=%0d, y=%0d", x_pos, y_pos);
                num_color_wrong = num_color_wrong + 1;
            end
        end
    end

    initial begin
        #16_800_000; // loads 1 frame
        if (num_color_wrong != 0 || num_sync_wrong != 0) begin
            $display  ("Number of sync pixels in the incorrect location: %0d", num_sync_wrong);
            $display("Number of color pixels in incorrect location: %0d", num_color_wrong);
        end
        else begin
            $display ("All pixels are in the correct location!");
        end
        $finish;
    end
endmodule