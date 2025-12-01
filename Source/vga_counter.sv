module vga_counter(
    input  logic clk,
    output logic hsync,      
    output logic vsync,      
    output logic [9:0] x_val,
    output logic [9:0] y_val,
    output logic video_on    
);
    parameter X_MAX = 10'd639;  // 640th horizontal bit
    parameter Y_MAX = 10'd479;   // 480th vertical bit
    parameter H_SYNC_START = 10'd656;  // hsync start bit
    parameter H_SYNC_END = 10'd751;  // hsync stop bit (inclusive)
    parameter V_SYNC_START = 10'd490;  // vsync start bit
    parameter V_SYNC_END = 10'd491;  // vsync stop bit (inclusive)
    parameter X_SIZE = 10'd799;  // maximum x size
    parameter Y_SIZE = 10'd524;  // maximum y size


    logic [9:0] h_cnt;
    logic [9:0] v_cnt;

    // counters
    always_ff @(posedge clk) begin
        if (h_cnt == X_SIZE) begin
            h_cnt <= 0;
            if (v_cnt == Y_SIZE) v_cnt <= 0;
            else v_cnt <= v_cnt + 1;
        end else begin
            h_cnt <= h_cnt + 1;
        end
    end

    // output
    always_ff @(posedge clk) begin
        hsync <= !((h_cnt >= H_SYNC_START) && (h_cnt <= H_SYNC_END));
        vsync <= !((v_cnt >= V_SYNC_START) && (v_cnt <= V_SYNC_END));
        video_on <= (h_cnt <= X_MAX) && (v_cnt <= Y_MAX);
        x_val <= h_cnt;
        y_val <= v_cnt;
    end
endmodule