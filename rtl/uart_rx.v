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


module uart_rx(
    input            clk,
    input            rst,
    input            rx,
    input            rdy_clr,
    input            clk_en,
    output reg       rdy,
    output reg [7:0] data_out
);
    parameter RX_STATE_START = 2'b00;
    parameter RX_STATE_DATA  = 2'b01;
    parameter RX_STATE_STOP  = 2'b10;

    reg [1:0] state;
    reg [3:0] sample;
    reg [3:0] index;
    reg [7:0] temp;

    always @(posedge clk) begin
        if (rst) begin
            rdy      <= 0;
            data_out <= 0;
            state    <= RX_STATE_START;
            sample   <= 0;
            index    <= 0;
            temp     <= 0;
        end else begin

            if (rdy_clr)
                rdy <= 0;

            if (clk_en) begin
                case (state)

                    // ── START BIT ──────────────────────────────────────
                    // Wait for rx to go LOW (start bit detected)
                    // Count 16 samples to reach the END of the start bit
                    // Then transition to DATA collection
                    RX_STATE_START: begin
                        if (!rx || sample != 0) begin   
                            sample <= sample + 4'b1;
                            if (sample == 15) begin
                                state  <= RX_STATE_DATA;
                                index  <= 0;
                                sample <= 0;
                                temp   <= 0;
                            end
                        end
                    end

                    // ── DATA BITS ───────────────────────────────────────
                    // Sample each bit at midpoint (sample==8)
                    // Collect 8 bits LSB first into temp
                    // Transition to STOP after bit 7
                    RX_STATE_DATA: begin
                        sample <= sample + 4'b1;
                        if (sample == 4'h8) begin
                            temp[index] <= rx;
                            if (index == 3'd7) begin
                                state  <= RX_STATE_STOP;
                                sample <= 0;          
                            end else
                                index <= index + 1;
                        end
                    end

                    // ── STOP BIT ────────────────────────────────────────
                    // Wait for sample==15 (full stop bit duration)
                    // Validate rx==1 (framing check)
                    // Assert rdy and latch data_out if valid
                    RX_STATE_STOP: begin
                        if (sample == 15) begin
                            state  <= RX_STATE_START;
                            sample <= 0;
                            if (rx) begin              
                                data_out <= temp;
                                rdy      <= 1'b1;
                            end
                        end else begin
                            sample <= sample + 4'b1;
                        end
                    end

                    default: begin
                        state <= RX_STATE_START;
                    end

                endcase
            end
        end
    end
endmodule