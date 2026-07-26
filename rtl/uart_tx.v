`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.03.2026 12:53:15
// Design Name: 
// Module Name: uart_tx
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


module uart_tx (
    input        clk,
    input        rst,
    input        wr_en,  // Write enable signal to start transmission
    input        enb,    // Enable signal from baud generator to control timing
    input  [7:0] data_in,

    output reg   tx,
    output       tx_busy
);

//-----------------------------------------------------
// State Encoding
//-----------------------------------------------------
parameter STATE_IDLE  = 2'b00;
parameter STATE_START = 2'b01;
parameter STATE_DATA  = 2'b10;
parameter STATE_STOP  = 2'b11;

//-----------------------------------------------------
// Registers (current state)
//-----------------------------------------------------
reg [7:0] data;
reg [2:0] bitpos;
reg [1:0] state;

//-----------------------------------------------------
// Next-state signals (combinational block outputs)
//-----------------------------------------------------
reg [7:0] next_data;
reg [2:0] next_bitpos;
reg [1:0] next_state;
reg       next_tx;

//-----------------------------------------------------
// Block 1: Sequential — register all state on clock edge
//-----------------------------------------------------
always @(posedge clk) begin
    if (rst) begin
        state  <= STATE_IDLE;
        tx     <= 1'b1;       // UART line idle high
        data   <= 8'h00;
        bitpos <= 3'b000;
    end
    else begin
        state  <= next_state;
        tx     <= next_tx;
        data   <= next_data;
        bitpos <= next_bitpos;
    end
end

//-----------------------------------------------------
// Block 2: Combinational — compute next-state logic
//-----------------------------------------------------
always @(*) begin

    // Default: hold current values
    next_state  = state;
    next_tx     = tx;
    next_data   = data;
    next_bitpos = bitpos;

    case (state)

        //-----------------------------------------
        // IDLE State
        //-----------------------------------------
        STATE_IDLE: begin
            next_tx = 1'b1;
            
            if (wr_en) begin
                next_data   = data_in;
                next_bitpos = 3'b000;
                next_state  = STATE_START;
            end
        end

        //-----------------------------------------
        // START Bit
        //-----------------------------------------
        STATE_START: begin
            if (enb) begin
                next_tx    = 1'b0;       // Start bit
                next_state = STATE_DATA;
            end
        end

        //-----------------------------------------
        // DATA Bits
        //-----------------------------------------
        STATE_DATA: begin
            if (enb) begin
                next_tx = data[bitpos];

                if (bitpos == 3'd7)
                    next_state = STATE_STOP;
                else
                    next_bitpos = bitpos + 1'b1;
            end
        end

        //-----------------------------------------
        // STOP Bit
        //-----------------------------------------
        STATE_STOP: begin
            if (enb) begin
                next_tx    = 1'b1;       // Stop bit
                next_state = STATE_IDLE;
            end
        end

        //-----------------------------------------
        // Default
        //-----------------------------------------
        default: begin
            next_state  = STATE_IDLE;
            next_tx     = 1'b1;
            next_bitpos = 3'b000;
        end

    endcase
end

//-----------------------------------------------------
// Busy Signal
//-----------------------------------------------------
assign tx_busy = (state != STATE_IDLE);

endmodule
