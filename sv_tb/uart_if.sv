`timescale 1ns / 1ps

interface uart_if (input logic clk, input logic rst);

    logic       wr_en;
    logic [7:0] data_in;
    logic       busy;

    logic       rdy_clr;
    logic       rdy;
    logic [7:0] data_out;

    clocking drv_cb @(posedge clk);
        default input #1 output #1;
        output wr_en, data_in, rdy_clr;
        input  busy, rdy, data_out;
    endclocking

    clocking mon_cb @(posedge clk);
        default input #1;
        input wr_en, data_in, busy, rdy_clr, rdy, data_out;
    endclocking

    modport DRIVER  (clocking drv_cb, input rst);
    modport MONITOR (clocking mon_cb, input rst);

endinterface