module vga_test(
    input logic clk,
    output logic [2:0] color
);
    parameter X_SIZE = 10'd799;  // maximum x size
    parameter Y_SIZE = 10'd524;  // maximum y size

    logic [9:0] x = 10'd0;
    logic [9:0] y = 10'd0;

    always_ff @ (posedge clk) begin
        if (x < 80) color = 3'b000;
        else if (x < 160) color = 3'b001;
        else if (x < 240) color = 3'b010;
        else if (x < 320) color = 3'b100;
        else if (x < 400) color = 3'b101;
        else if (x < 480) color = 3'b110;
        else color = 3'b111;

        if (x == X_SIZE) begin
            x <= 10'd0;
        end else begin
            x <= x + 10'd1;
        end
        
        if (x == X_SIZE) begin
            if (y == Y_SIZE)
                y <= 10'd0;
        end else begin
                y <= y + 10'd1;
        end
    end
endmodule