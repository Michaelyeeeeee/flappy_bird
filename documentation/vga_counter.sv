// vga_counter.sv
// Standard 640x480 @ 60Hz Timing
`timescale 1ns/1ps

module vga_counter(
    input  logic clk,
    output logic hsync,      // Active Low HSYNC
    output logic vsync,      // Active Low VSYNC
    output logic [9:0] x_val,
    output logic [9:0] y_val,
    output logic video_on    // High when we are in the visible 640x480 area
);

    // Standard VGA Timing Constants (640x480 @ 60Hz, 25MHz Clock)
    localparam H_ACTIVE    = 640;
    localparam H_FRONT     = 16;
    localparam H_SYNC      = 96;
    localparam H_BACK      = 48;
    localparam H_TOTAL     = 800; // 640 + 16 + 96 + 48

    localparam V_ACTIVE    = 480;
    localparam V_FRONT     = 10;
    localparam V_SYNC      = 2;
    localparam V_BACK      = 33;
    localparam V_TOTAL     = 525; // 480 + 10 + 2 + 33

    logic [9:0] h_cnt;
    logic [9:0] v_cnt;

    // Horizontal Counter (0 to 799)
    always_ff @(posedge clk) begin
        if (h_cnt == H_TOTAL - 1)
            h_cnt <= 0;
        else
            h_cnt <= h_cnt + 1;
    end

    // Vertical Counter (0 to 524)
    always_ff @(posedge clk) begin
        if (h_cnt == H_TOTAL - 1) begin
            if (v_cnt == V_TOTAL - 1)
                v_cnt <= 0;
            else
                v_cnt <= v_cnt + 1;
        end
    end

    // Generate Sync Signals (Active Low)
    // HSYNC is Low during the sync pulse (pixels 656 to 751)
    assign hsync = !((h_cnt >= H_ACTIVE + H_FRONT) && (h_cnt < H_ACTIVE + H_FRONT + H_SYNC));
    
    // VSYNC is Low during the sync pulse (lines 490 to 491)
    assign vsync = !((v_cnt >= V_ACTIVE + V_FRONT) && (v_cnt < V_ACTIVE + V_FRONT + V_SYNC));

    // Current Pixel Output
    assign x_val = h_cnt;
    assign y_val = v_cnt;

    // Video On: High only when we are inside the 640x480 visible area
    assign video_on = (h_cnt < H_ACTIVE) && (v_cnt < V_ACTIVE);

endmodule