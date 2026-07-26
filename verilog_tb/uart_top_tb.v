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



module uart_top_tb;

reg clk;
reg rst;
reg [7:0] data_in;
reg wr_en;
reg rdy_clr;

wire rdy;
wire busy;
wire [7:0] data_out;

uart_top dut (
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rdy_clr(rdy_clr),
    .data_in(data_in),
    .rdy(rdy),
    .busy(busy),
    .data_out(data_out)
);

initial begin
    clk     = 0;
    rst     = 0;
    data_in = 8'h00;
    wr_en   = 0;
    rdy_clr = 0;
end

always #5 clk = ~clk;

task send_byte(input [7:0] din);
begin
    @(negedge clk);
    data_in = din;
    wr_en   = 1'b1;

    @(negedge clk);
    wr_en   = 1'b0;
end
endtask

task clear_ready;
begin
    @(negedge clk);
    rdy_clr = 1'b1;

    @(negedge clk);
    rdy_clr = 1'b0;
end
endtask

initial begin

    // Reset
    @(negedge clk);
    rst = 1'b1;

    @(negedge clk);
    rst = 1'b0;

    //-------------------------------------------------
    // Test 1
    //-------------------------------------------------
    send_byte(8'h41);

    wait(busy);
    wait(!busy);
    wait(rdy);

    $display("Time=%0t Received=%h", $time, data_out);

    clear_ready();

    //-------------------------------------------------
    // Test 2
    //-------------------------------------------------
    send_byte(8'h55);

    wait(busy);
    wait(!busy);
    wait(rdy);

    $display("Time=%0t Received=%h", $time, data_out);

    clear_ready();

    #1000;
    $finish;
end

endmodule