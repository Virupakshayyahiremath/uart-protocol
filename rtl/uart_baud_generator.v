`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.03.2026 12:14:46
// Design Name: 
// Module Name: uart_baud_generator
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


module uart_baud_generator(
    input      clk,
    input      rst,
    output reg enb_tx,  //Shift data once per bit
    output reg enb_rx   //Sample 16 times per bit
    );
    parameter clk_freq = 100000000; // SYSTEM CLOCK FREQUENCY 100MHZ
    parameter baud_rate = 9600; //REQUIRED BAUD RATE
    reg [15:0] counter_tx; //REGISTER FOR CREATING THE SENDER CLOCK
    reg [15:0] counter_rx; // REGISTER FOR CREATING THE RECIEVER CLOCK
    
    parameter divisor_tx = clk_freq/baud_rate; //PRESCALAR OF SENDER
    parameter divisor_rx = clk_freq/(16 *baud_rate);    //PRESCALAR OF RECIEVER
       
    //SENDER CLOCK GENERATION LOGIC
    always@(posedge clk)
        begin
            if(rst)
                begin
                    counter_tx <= 0;
                    enb_tx <= 0;
                    //enb_rx = 0;
                 end
           //FOR 10,416 CLOCK CYCLES OF SYSTEM CLOCK 1 CLOCK CYCLE IS GENERATED
                     
            else if(counter_tx == divisor_tx - 1)
                begin
                    enb_tx <= 1;  //1-CYCLE PULSE
                    counter_tx <= 0;
                end
              else
                begin
                   counter_tx <= counter_tx + 1'b1;
                   enb_tx <= 0;
                end
         end
         
         
    //LOGIC FOR RECIEVER CLOCK
    always@(posedge clk)
        begin
            if(rst)
                begin
                    counter_rx <= 0;
                    enb_rx <= 0;
                 end
       
       //FOR GENERATING RECEIVER CLOCK
            else if(counter_rx == divisor_rx - 1)
                begin
                    counter_rx <= 0;
                    enb_rx <= 1;  //1-CYCLE PULSE
                end
            else
                begin
                    counter_rx <= counter_rx + 1;
                    enb_rx <= 0;
                end
         end
endmodule
