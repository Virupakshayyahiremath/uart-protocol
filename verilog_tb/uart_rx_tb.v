`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.03.2026 11:13:04
// Design Name: 
// Module Name: uart_rx_tb
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


module uart_rx_tb();

    reg clk, rst, rx, rdy_clr, clk_en;
    wire rdy;
    wire [7:0] data_out;

    uart_rx DUT(clk, rst, rx, rdy_clr, clk_en, rdy, data_out);

    // ── Clock: 100MHz ─────────────────────────────────────
    initial clk = 0;
    always #5 clk = ~clk;

    // ── clk_en: pulse every 651 cycles (16x @ 9600 baud) ─
    integer clk_en_count = 0;
    always @(posedge clk) begin
        if (clk_en_count == 650) begin
            clk_en_count <= 0;
            clk_en       <= 1;
        end else begin
            clk_en_count <= clk_en_count + 1;
            clk_en       <= 0;
        end
    end

    // ── Wait for next clk_en pulse ────────────────────────
    task wait_en;
        begin
            @(posedge clk);
            while (!clk_en) @(posedge clk);
        end
    endtask

    // ── Send one UART byte (LSB first) ────────────────────
    task send_byte(input [7:0] data);
        integer i;
        begin
            wait_en;            // sync to clk_en boundary
            rx = 0;             // START bit
            repeat(16) wait_en;

            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];   // DATA bits LSB first
                repeat(16) wait_en;
            end

            rx = 1;             // STOP bit
            repeat(16) wait_en;
        end
    endtask

    // ── Check received data ───────────────────────────────
    task check(input [7:0] expected);
        begin
            wait(rdy);
            if (data_out === expected)
                $display("PASS: sent=%0d received=%0d", expected, data_out);
            else
                $display("FAIL: sent=%0d received=%0d", expected, data_out);
            @(posedge clk);
            rdy_clr = 1;
            @(posedge clk);
            rdy_clr = 0;
        end
    endtask

    // ── Stimulus ──────────────────────────────────────────
    initial begin
        // init
        rx      = 1;
        rdy_clr = 0;
        rst     = 1;
        repeat(2) @(posedge clk);
        rst = 0;

        // test cases
        fork send_byte(8'd25);  check(8'd25);  join
        fork send_byte(8'd170); check(8'd170); join
        fork send_byte(8'd255); check(8'd255); join
        fork send_byte(8'd0);   check(8'd0);   join

        $display("All tests done");
        $stop;
    end

endmodule