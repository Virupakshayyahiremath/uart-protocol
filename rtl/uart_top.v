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


module uart_top(
    input        clk,
    input        rst,
    input  [7:0] data_in,
    input        wr_en,
    input        rdy_clr,
    output       rdy,
    output       busy,
    output [7:0] data_out
);
    wire rx_clk_en;  // 16x oversample enable from baud generator
    wire tx_clk_en;  // 1x bit-rate enable from baud generator
    wire tx_temp;    // TX output looped back to RX input

    // Baud rate generator
    uart_baud_generator bg(
        .clk    (clk),
        .rst    (rst),
        .enb_tx (tx_clk_en),
        .enb_rx (rx_clk_en)
    );

    // UART transmitter
    uart_tx us(
        .clk     (clk),
        .rst     (rst),
        .wr_en   (wr_en),
        .enb     (tx_clk_en),
        .data_in (data_in),
        .tx      (tx_temp),
        .tx_busy (busy)
    );

    // UART receiver (loopback from TX)
    // NOTE: For real hardware, replace tx_temp with external rx pin
    uart_rx ur(
        .clk      (clk),
        .rst      (rst),
        .rx       (tx_temp),
        .rdy_clr  (rdy_clr),
        .clk_en   (rx_clk_en),
        .rdy      (rdy),
        .data_out (data_out)
    );

endmodule
