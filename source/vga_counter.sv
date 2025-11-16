/* Horizontal and vertical counter for VGA
 *
 * input clk - PLL clock at 25MHz
 * output hsync vsync - active high signal for VGA sync
 * output x_val, y_val - current position of VGA counter 
 */

`timescale 1ns/1ps

module vga_counter(
input logic clk,
output logic hsync, vsync,
output logic [9:0] x_val, y_val
);
    // display parameters
    parameter X_MAX         = 10'd639;  // 640th horizontal bit
    parameter Y_MAX         = 10'd479;   // 480th vertical bit
    parameter H_SYNC_START  = 10'd656;  // hsync start bit
    parameter H_SYNC_END    = 10'd751;  // hsync stop bit (inclusive)
    parameter V_SYNC_START  = 10'd490;  // vsync start bit
    parameter V_SYNC_END    = 10'd491;  // vsync stop bit (inclusive)
    parameter X_SIZE        = 10'd799;  // maximum x size
    parameter Y_SIZE        = 10'd524;  // maximum y size

    // counters
    logic [9:0] x_cur = 10'd0; 
    logic [9:0] y_cur = 10'd0;
    logic hsync_reg = 0;
    logic vsync_reg = 0;

    logic hsync_reg1, vsync_reg1; // This creates additional cycle delay
    logic hsync_reg2, vsync_reg2; // This creates second additional cycle delay

    // pipeline registers for x_val and y_val
    logic [9:0] x_val_reg1, x_val_reg2;
    logic [9:0] y_val_reg1, y_val_reg2;

    always_ff @ (posedge clk) begin
        // horizontal counter increments until end of display
        if (x_cur == X_SIZE)
            x_cur <= 10'd0;
        else
            x_cur <= x_cur + 10'd1;

        // vertical counter increments when a line completes
        if (x_cur == X_SIZE) begin
            if (y_cur == Y_SIZE)
                y_cur <= 10'd0;
            else
                y_cur <= y_cur + 10'd1;
        end

        // hsync vsync check
        // flip flops to delay to match color synchronization
        hsync_reg1 <= (x_cur >= H_SYNC_START) && (x_cur <= H_SYNC_END);
        vsync_reg1 <= (y_cur >= V_SYNC_START) && (y_cur <= V_SYNC_END);
        hsync_reg2 <= hsync_reg1;
        vsync_reg2 <= vsync_reg1;

        // pipeline x_val and y_val to add 2-cycle delay
        x_val_reg1 <= x_cur;
        x_val_reg2 <= x_val_reg1;

        y_val_reg1 <= y_cur;
        y_val_reg2 <= y_val_reg1;
    end

    assign x_val = x_val_reg2;
    assign y_val = y_val_reg2;
    assign hsync = hsync_reg2;
    assign vsync = vsync_reg2;
endmodule