module game_top(
    input logic clk,
    output logic [2:0] color
);
    parameter X_SIZE = 10'd799;  // maximum x size
    parameter Y_SIZE = 10'd524;  // maximum y size

    logic [9:0] x = 10'd0;
    logic [9:0] y = 10'd0;

    always_ff @ (posedge clk) begin
         if ((y < 50) && x < 50) begin
            color = 3'b010;
        end else begin
            color = 3'b011;
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
    end
    //assign color = 3'b011;

endmodule
