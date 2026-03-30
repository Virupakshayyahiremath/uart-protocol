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


// ── uart_rx_tb.v complete ─────────────────────────────────
module uart_rx_tb();
    reg clk, rst;
    reg rx;
    reg rdy_clr;
    reg clk_en;
    wire rdy;
    wire [7:0] data_out;

    uart_rx DUT(clk, rst, rx, rdy_clr, clk_en, rdy, data_out);

    initial clk = 0;
    always #5 clk = ~clk;

    // ── clk_en generator ─────────────────────────────────
    reg [9:0] clk_en_count;
    initial clk_en_count = 0;
    initial clk_en       = 0;

    always @(posedge clk) begin
        if (clk_en_count == 10'd650) begin
            clk_en_count <= 0;
            clk_en       <= 1;
        end else begin
            clk_en_count <= clk_en_count + 1;
            clk_en       <= 0;
        end
    end

    // ── Task: wait for N clk_en pulses ───────────────────
    task wait_clk_en_pulses(input integer n);
        integer count;
        begin
            count = 0;
            while (count < n) begin
                @(posedge clk);
                if (clk_en) count = count + 1;
            end
        end
    endtask

    task initialize;
        begin
            rst     = 1'b0;
            rdy_clr = 1'b0;
            rx      = 1'b1;
        end
    endtask

    task apply_reset;
        begin
            @(posedge clk);
            rst = 1'b1;
            @(posedge clk);
            rst = 1'b0;
        end
    endtask

    // ── Task: send_byte ──────────────────────────────────
    task send_byte(input [7:0] data_in_tb);
        integer i;
        begin
            rx = 1'b0;                           // START
            wait_clk_en_pulses(16);

            for (i = 0; i < 8; i = i + 1) begin // DATA
                rx = data_in_tb[i];
                wait_clk_en_pulses(16);
            end

            rx = 1'b1;                           // STOP
            wait_clk_en_pulses(16);
        end
    endtask

    // ── Task: wait_for_ready ─────────────────────────────
    task wait_for_ready(input [7:0] expected);
        begin
            wait(rdy == 1'b1);
            if (data_out === expected)
                $display("[%0t] PASS: expected=%0d received=%0d",
                          $time, expected, data_out);
            else
                $display("[%0t] FAIL: expected=%0d received=%0d",
                          $time, expected, data_out);
            @(posedge clk);
            rdy_clr = 1'b1;
            @(posedge clk);
            rdy_clr = 1'b0;
        end
    endtask

    // ── Stimulus ─────────────────────────────────────────
    initial begin
        $monitor("Time=%0t rx=%b clk_en=%b rdy=%b data_out=%0d",
                  $time, rx, clk_en, rdy, data_out);
        initialize;
        apply_reset;

        fork send_byte(8'd25);  wait_for_ready(8'd25);  join
        fork send_byte(8'd170); wait_for_ready(8'd170); join
        fork send_byte(8'd255); wait_for_ready(8'd255); join
        fork send_byte(8'd0);   wait_for_ready(8'd0);   join

        $display("[%0t] All tests complete", $time);
        wait_clk_en_pulses(32);
        $stop;
    end
endmodule
