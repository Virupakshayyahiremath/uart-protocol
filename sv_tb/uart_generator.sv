`timescale 1ns / 1ps

class uart_generator;

    mailbox #(uart_transaction) gen2drv;
    uart_transaction gen_trans, data2send;

    function new(mailbox #(uart_transaction) gen2drv);
        this.gen2drv  = gen2drv;
        gen_trans = new();
    endfunction

    virtual task start();
        fork
            begin
                for(int i = 0; i < number_of_transactions; i++) 
                    begin
                        assert(gen_trans.randomize());
                        data2send = new gen_trans;
                        gen2drv.put(data2send);
                    end
            end
        join_none
    endtask

endclass