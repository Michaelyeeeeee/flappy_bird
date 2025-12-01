module button_sync_debounce #(
    parameter integer DEBOUNCE_TICKS = 250000 
)(
    input  logic clk,
    input  logic btn_n_raw, 
    output logic flap_pulse,
    output logic btn_held   
);

    logic b_sync;
    always_ff @(posedge clk) b_sync <= btn_n_raw;

    logic [17:0] cnt;
    logic state = 1; 

    always_ff @(posedge clk) begin
        if (b_sync != state) begin
            cnt <= cnt + 1;
            if (cnt == DEBOUNCE_TICKS) begin 
                state <= b_sync;
                cnt <= 0;
            end
        end else begin
            cnt <= 0;
        end
    end

    assign btn_held = (state == 1'b0);
    
    logic state_last;
    always_ff @(posedge clk) begin
        state_last <= state;
        flap_pulse <= (state_last == 1'b1) && (state == 1'b0);
    end
endmodule