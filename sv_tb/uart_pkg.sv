`timescale 1ns / 1ps
//-----------------------------------------------------------------
// uart_pkg : shared config + aggregates every class-based TB file.
//
// `include order matters here: each file below only references
// class types declared in files ABOVE it, so this order must be
// preserved (uart_transaction has no dependencies -> goes first;
// uart_env depends on all the others -> goes last).
//
// uart_if.sv is NOT included here -- interfaces live outside
// packages by convention. It must be compiled separately, before
// this package, since uart_driver/uart_monitor reference
// `virtual uart_if.DRIVER` / `virtual uart_if.MONITOR` types.
//
// tb_top can override number_of_transactions at elaboration time
// with a parameter override (defparam/#()) or you can just edit
// the value here for a fixed run count.
//-----------------------------------------------------------------
package uart_pkg;

    int number_of_transactions = 1;

    `include "uart_txn.sv"
    `include "uart_generator.sv"
    `include "uart_driver.sv"
    `include "uart_monitor.sv"
    `include "uart_ref_model.sv"
    `include "uart_scoreboard.sv"
    `include "uart_env.sv"
    `include "uart_test.sv"

endpackage