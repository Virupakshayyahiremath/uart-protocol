`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.03.2026 12:44:44
// Design Name: 
// Module Name: uart_baud_generator_tb
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


module uart_baud_generator_tb();
    reg clk;
    reg rst;
    wire enb_tx;
    wire enb_rx;
    
    uart_baud_generator DUT(clk,rst,enb_tx,enb_rx);
    initial clk = 0;
    always #5clk = ~clk;
    task initialize;
        begin
            rst = 1'b0;
        end
    endtask
    
    task apply_reset;
        begin
            @(posedge clk);
            rst = 1;
            @(posedge clk);
            rst = 0;
            $display("Reset released at time %0t", $time);
        end
    endtask
    
    task run_simulation;
        begin
            repeat(2000000) @(posedge clk);
            $display("Simulation completed at time %0t", $time);
        end
    endtask
    
    initial
        begin
            $monitor("Time=%0t rst=%b enb_tx=%b enb_rx=%b",$time, rst, enb_tx, enb_rx);
            initialize;
            apply_reset;
            run_simulation;
            $stop;
        end
endmodule
