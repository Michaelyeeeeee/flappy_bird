module vga_counter(
    input  logic clk,
    output logic hsync,      
    output logic vsync,      
    output logic [9:0] x_val,
    output logic [9:0] y_val,
    output logic video_on    
);

    localparam H_TOTAL = 800;
    localparam V_TOTAL = 525;

    logic [9:0] h_cnt;
    logic [9:0] v_cnt;

    // counters
    always_ff @(posedge clk) begin
        if (h_cnt == H_TOTAL - 1) begin
            h_cnt <= 0;
            if (v_cnt == V_TOTAL - 1) v_cnt <= 0;
            else v_cnt <= v_cnt + 1;
        end else begin
            h_cnt <= h_cnt + 1;
        end
    end

    // output
    always_ff @(posedge clk) begin
        hsync <= !((h_cnt >= 656) && (h_cnt < 752));
        vsync <= !((v_cnt >= 490) && (v_cnt < 492));
        video_on <= (h_cnt < 640) && (v_cnt < 480);
        x_val <= h_cnt;
        y_val <= v_cnt;
    end
endmodule