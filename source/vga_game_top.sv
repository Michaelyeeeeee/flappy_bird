module vga_game_top(
    input logic clk,
    input logic button,
    output logic [2:0] color
);
    parameter X_SIZE = 10'd799;  // maximum x size
    parameter Y_SIZE = 10'd524;  // maximum y size

    logic [9:0] x = 10'd0;
    logic [9:0] y = 10'd0;
    logic buttonpress = 1'b0;

    //logic button_last,press_edge;

    always_ff @ (posedge clk) begin

        if (((y > 210) && (y < 240)) && ((x < 170) && (x > 147)) )begin
            color <= 3'b110;
        end else begin
            color <= 3'b011;
        end
        
        if (x == X_SIZE) begin
            if (y == Y_SIZE) begin
                y <= 10'd0;
            end else begin
                y <= y + 10'd1;
            end
        end
        if (x == X_SIZE) begin
            x <= 10'd0;
        end else begin
            x <= x + 10'd1;
        end

        if (buttonpress) begin
            color <= ~color;
        end
    end

    always_ff @ (negedge button) begin
        buttonpress <= ~buttonpress;
    end


endmodule 
