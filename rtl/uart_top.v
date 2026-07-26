`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2026 23:09:45
// Design Name: 
// Module Name: uart_top
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


module uart_top (
    input        clk,
    input        rst,
    input        wr_en,
    input        rdy_clr,
    input  [7:0] data_in,

    output       rdy,
    output       busy,
    output [7:0] data_out
);

    //-------------------------------------------------
    // Internal Signals
    //-------------------------------------------------
    wire tx_clk_en;
    wire rx_clk_en;
    wire tx_serial;

    //-------------------------------------------------
    // Baud Rate Generator
    //-------------------------------------------------
    uart_baud_generator baud_gen (
        .clock  (clk),
        .reset  (rst),
        .enb_tx (tx_clk_en),
        .enb_rx (rx_clk_en)
    );

    //-------------------------------------------------
    // UART Transmitter
    //-------------------------------------------------
    uart_tx tx_inst (
        .clk     (clk),
        .rst     (rst),
        .wr_en   (wr_en),
        .enb     (tx_clk_en),
        .data_in (data_in),
        .tx      (tx_serial),
        .tx_busy (busy)
    );

    //-------------------------------------------------
    // UART Receiver
    //-------------------------------------------------
    uart_rx rx_inst (
        .clk      (clk),
        .rst      (rst),
        .rx       (tx_serial),   // Loopback connection
        .rdy_clr  (rdy_clr),
        .clken    (rx_clk_en),
        .rdy      (rdy),
        .data_out (data_out)
    );

endmodule