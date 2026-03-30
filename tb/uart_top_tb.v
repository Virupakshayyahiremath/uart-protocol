`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.03.2026 23:15:19
// Design Name: 
// Module Name: uart_top_tb
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


module uart_top_tb();
    reg        clk, rst;
    reg  [7:0] data_in;
    reg        wr_en;
    reg        rdy_clr;
    wire       rdy;
    wire       busy;
    wire [7:0] dout;

    // BUG1 FIX: named port connections
    uart_top dut(
        .clk      (clk),
        .rst      (rst),
        .data_in  (data_in),
        .wr_en    (wr_en),
        .rdy_clr  (rdy_clr),
        .rdy      (rdy),
        .busy     (busy),
        .data_out (dout)
    );

    // BUG2 FIX: initialize wr_en too
    initial
        {clk, rst, data_in, rdy_clr, wr_en} = 0;

    always #5 clk = ~clk;

    // ── Task: send_byte ──────────────────────────────────────
    task send_byte(input [7:0] din);
        begin
            @(negedge clk);
            data_in = din;
            wr_en   = 1'b1;
            @(negedge clk);
            wr_en   = 1'b0;
        end
    endtask

    // ── Task: clear_ready ────────────────────────────────────
    task clear_ready;
        begin
            @(negedge clk);
            rdy_clr = 1'b1;
            @(negedge clk);
            rdy_clr = 1'b0;
        end
    endtask

    // ── Task: check_data ─────────────────────────────────────
    task check_data(input [7:0] expected);
        begin
            wait(rdy);                          // BUG3 FIX: wait rdy directly
            if (dout === expected)
                $display("[%0t] PASS: sent=%h received=%h",
                          $time, expected, dout);
            else
                $display("[%0t] FAIL: sent=%h received=%h",
                          $time, expected, dout);
            clear_ready;
        end
    endtask

    // ── Stimulus ─────────────────────────────────────────────
    initial begin
        // Reset
        @(negedge clk);
        rst = 1'b1;
        @(negedge clk);
        rst = 1'b0;

        // Test 1: send 0x41 = 'A'
        send_byte(8'h41);
        check_data(8'h41);

        // Test 2: send 0x55 = 'U'
        send_byte(8'h55);
        check_data(8'h55);

        // Test 3: send 0xFF
        send_byte(8'hFF);
        check_data(8'hFF);

        // Test 4: send 0x00
        send_byte(8'h00);
        check_data(8'h00);

        $display("[%0t] All tests complete", $time);
        repeat(20) @(negedge clk);  // BUG4 FIX: proper settling time
        $finish;
    end
endmodule