`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.03.2026 10:15:26
// Design Name: 
// Module Name: uart_tx_tb
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


module uart_tx_tb();
    reg clk;
    reg rst;
    reg wr_en;
    reg en;
    reg[7:0] data_in;
    wire tx;
    wire tx_busy;
    
    uart_tx DUT(clk,rst,wr_en,en, data_in, tx, tx_busy);
    
    initial clk = 0;
    always #5 clk = ~clk;
    // Baud enable generator - 9600 baud @ 100MHz
    // One pulse every 10416 cycles (104160ns), 1 cycle wide
    initial 
        begin
            en = 0;
            forever begin
                #104160 en = 1;
                #10     en = 0;
            end
        end
    
    task initialize;
        begin
            rst = 1'b0;
            wr_en = 1'b0;
            data_in = 8'd0;
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
    
    task send_data(input [7:0] data_in_tb);
        begin
            @(posedge clk);
            wr_en = 1'b1;
            data_in = data_in_tb;
            @(posedge clk);
            wr_en = 1'b0;
            $display("Data sent: %0d (8'b%8b) at time %0t",data_in_tb, data_in_tb, $time);
        end
    endtask
    
    initial
        begin
            $monitor("Time=%0t, rst=%b, wr_en=%b, en=%b, data_in=%d, tx=%b, tx_busy=%b",$time,rst,wr_en,en,data_in,tx,tx_busy);
            initialize;
            apply_reset;
            send_data(8'd25); //00011001 -- 10011000
            #1200000 $stop;  // wait full frame + margin
        end
endmodule