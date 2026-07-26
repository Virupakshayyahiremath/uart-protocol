`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2026 23:05:52
// Design Name: 
// Module Name: uart_rx
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_rx (
    input        clk,
    input        rst,
    input        rx,
    input        rdy_clr,
    input        clken,

    output reg        rdy,
    output reg [7:0]  data_out
);

//-----------------------------------------------------
// State Encoding
//-----------------------------------------------------
parameter RX_STATE_START = 2'b00;
parameter RX_STATE_DATA  = 2'b01;
parameter RX_STATE_STOP  = 2'b10;

//-----------------------------------------------------
// Registers (current state)
//-----------------------------------------------------
reg [1:0] state;
reg [3:0] sample;
reg [3:0] index;
reg [7:0] temp;

//-----------------------------------------------------
// Next-state signals (combinational block outputs)
//-----------------------------------------------------
reg [1:0] next_state;
reg [3:0] next_sample;
reg [3:0] next_index;
reg [7:0] next_temp;
reg [7:0] next_data_out;
reg       next_rdy;

//-----------------------------------------------------
// stop_done: combinational flag — true when STOP state
// completes in this cycle. Used to give next_rdy a
// single-assignment path (eliminates W415a).
//-----------------------------------------------------
wire stop_done = clken && (state == RX_STATE_STOP) && (sample == 4'd15);

//-----------------------------------------------------
// Block 1: Sequential — register all state on clock edge
//-----------------------------------------------------
always @(posedge clk) begin
    if (rst) begin
        state    <= RX_STATE_START;
        sample   <= 4'd0;
        index    <= 4'd0;
        temp     <= 8'd0;
        data_out <= 8'd0;
        rdy      <= 1'b0;
    end
    else begin
        state    <= next_state;
        sample   <= next_sample;
        index    <= next_index;
        temp     <= next_temp;
        data_out <= next_data_out;
        rdy      <= next_rdy;
    end
end

//-----------------------------------------------------
// Block 2: Combinational — compute next-state logic
//-----------------------------------------------------
always @(*) begin

    // Default: hold current values
    next_state    = state;
    next_sample   = sample;
    next_index    = index;
    next_temp     = temp;
    next_data_out = data_out;

    // next_rdy: single assignment with explicit priority —
    //   STOP completion > rdy_clr > hold
    // stop_done is computed as a wire above, so this is
    // assigned exactly once here (W415a eliminated).
    next_rdy = stop_done ? 1'b1 :
               rdy_clr   ? 1'b0 :
                           rdy;

    if (clken) begin

        case (state)

        //-----------------------------------------
        // Wait for Start Bit
        // Fix: sample increment and reset are
        // mutually exclusive (else branch).
        //-----------------------------------------
        RX_STATE_START: begin
            if (sample == 4'd15) begin
                // Transition to DATA — reset sample, don't also increment
                next_state  = RX_STATE_DATA;
                next_sample = 4'd0;
                next_index  = 4'd0;
                next_temp   = 8'd0;
            end
            else if (!rx || sample != 0) begin
                next_sample = sample + 1'b1;
            end
        end

        //-----------------------------------------
        // Receive Data Bits
        // Fix: sample reset and increment are
        // mutually exclusive (if/else if).
        //-----------------------------------------
        RX_STATE_DATA: begin
            if ((index == 4'd8) && (sample == 4'd15)) begin
                // All 8 bits received — transition, reset sample
                next_state  = RX_STATE_STOP;
                next_sample = 4'd0;
            end
            else begin
                next_sample = sample + 1'b1;

                // Sample in the middle of each bit period
                if (sample == 4'd8) begin
                    next_temp[index] = rx;
                    next_index       = index + 1'b1;
                end
            end
        end

        //-----------------------------------------
        // Receive Stop Bit
        // next_rdy is NOT assigned here — it is
        // handled via stop_done in the single
        // priority ternary above (W415a fix).
        //-----------------------------------------
        RX_STATE_STOP: begin
            if (sample == 4'd15) begin
                next_state    = RX_STATE_START;
                next_data_out = temp;
                next_sample   = 4'd0;
            end
            else begin
                next_sample = sample + 1'b1;
            end
        end

        //-----------------------------------------
        // Default State
        //-----------------------------------------
        default: begin
            next_state  = RX_STATE_START;
            next_sample = 4'd0;
            next_index  = 4'd0;
        end

        endcase
    end
end

endmodule