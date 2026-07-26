`timescale 1ns/1ps

module uart_tb_top;

    import uart_pkg::*;

    parameter cycle = 10;

    logic clk;
    logic rst;

    // Interface
    uart_if intf(clk, rst);

    // Test Handle
    uart_test test_h;

    // DUT
    uart_top dut (
        .clk      (clk),
        .rst      (rst),
        .wr_en    (intf.wr_en),
        .rdy_clr  (intf.rdy_clr),
        .data_in  (intf.data_in),
        .rdy      (intf.rdy),
        .busy     (intf.busy),
        .data_out (intf.data_out)
    );

    // Reduce baud divisor for faster simulation
    defparam dut.baud_gen.clk_freq  = 1600;
    defparam dut.baud_gen.baud_rate = 100;

    // Clock Generation
    initial begin
        clk = 0;
        forever #(cycle/2) clk = ~clk;
    end

    // Reset Generation
    initial begin
        rst = 1'b1;
        repeat(5) @(posedge clk);
        rst = 1'b0;
    end

    initial begin

`ifdef VCS
        $fsdbDumpvars(0, uart_tb_top);
`else
        $dumpfile("uart_tb.vcd");
        $dumpvars(0, uart_tb_top);
`endif

        // Configure Test
        number_of_transactions = 500;

        // Create Test
        test_h = new(intf);

        // Run Test
        test_h.run();

        $finish;

    end

endmodule