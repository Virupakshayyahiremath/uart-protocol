`timescale 1ns / 1ps

class uart_transaction;
    rand bit [7:0] data_in;


    bit [7:0] data_out;
    bit       rdy;

    function void display(string name);
        $display("----------------------------------------");
        $display("%s", name);
        $display("Time     : %0t", $time);
        $display("DATA_IN  : 0x%0h (%0d)", data_in, data_in);
        $display("DATA_OUT : 0x%0h (%0d)", data_out, data_out);
        $display("RDY      : %0b", rdy);
        $display("----------------------------------------");
    endfunction
endclass