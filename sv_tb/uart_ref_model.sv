`timescale 1ns / 1ps
//-----------------------------------------------------------------
// uart_ref_model : golden/predictive model, decoupled from the DUT.
//
// This DUT is a straight loopback (uart_top wires tx_serial -> rx
// internally), so the prediction is trivial: whatever data_in the
// monitor observed is exactly what data_out should be, with rdy=1.
//
// IMPORTANT: the incoming transaction from the monitor already has
// data_out filled in too (see uart_monitor.sv NOTE 3), but that
// field is deliberately IGNORED here. This model computes its own
// expected data_out from data_in only -- if it just echoed the
// monitor's data_out back out, the scoreboard's compare would be a
// trivial no-op that could never fail.
//-----------------------------------------------------------------
class uart_ref_model;

    mailbox #(uart_transaction) mon2ref;
    mailbox #(uart_transaction) ref2scb;

    uart_transaction txn_in, txn_exp;

    function new(mailbox #(uart_transaction) mon2ref,
                 mailbox #(uart_transaction) ref2scb);
        this.mon2ref = mon2ref;
        this.ref2scb = ref2scb;
        txn_exp          = new();
    endfunction

    task start();
        
        fork
            begin
                forever begin
                    mon2ref.get(txn_in);

                    txn_exp.data_in  = txn_in.data_in;
                    txn_exp.data_out = txn_in.data_in;   // golden prediction
                    txn_exp.rdy      = 1'b1;

                    ref2scb.put(txn_exp);
                    txn_exp.display("REF MODEL - predicted");
                end
            end
        join_none
    endtask

endclass