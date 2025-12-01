// button_sync_debounce.sv
// Handles Active-Low Button (0 = Pressed, 1 = Released)
`timescale 1ns/1ps

module button_sync_debounce #(
    // This parameter was missing in the last version, causing the error!
    parameter integer DEBOUNCE_TICKS = 250000 
)(
    input  logic clk,
    input  logic btn_n_raw, // Active Low Input
    output logic flap_pulse,
    output logic btn_held   // 1 if button is currently being pressed
);

    // 1. Synchronize to clock (avoid glitches)
    logic b_sync;
    always_ff @(posedge clk) b_sync <= btn_n_raw;

    // 2. Debounce Counter
    logic [17:0] cnt;
    logic state = 1; // Default 1 (Released)

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

    // 3. Output Logic
    // If state is 0 (Low), button is HELD.
    assign btn_held = (state == 1'b0);

    // 4. One-Shot Pulse
    // Triggers when state goes from 1 (Released) to 0 (Pressed)
    logic state_last;
    always_ff @(posedge clk) begin
        state_last <= state;
        flap_pulse <= (state_last == 1'b1) && (state == 1'b0);
    end

endmodule