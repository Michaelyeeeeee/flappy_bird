/* Horizontal and vertical counter for VGA
 *
 * input clk - PLL clock at 25MHz
 * output hsync vsync - active high signal for VGA sync
 * output x_val, y_val - current position of VGA counter 
 */
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
        hsync_reg <= (x_cur >= H_SYNC_START) && (x_cur <= H_SYNC_END);
        vsync_reg <= (y_cur >= V_SYNC_START) && (y_cur <= V_SYNC_END);
    end

    assign x_val = x_cur;
    assign y_val = y_cur;
    assign hsync = hsync_reg;  // assuming hsync is active high
    assign vsync = vsync_reg;  // assuming vsync is active high
endmodule