`timescale 1ns / 1ps
//-----------------------------------------------------------------
// uart_test : CLASS (not program). Owns the environment and
// exposes a single run() task. Instantiated and called from an
// initial block in tb_top.sv, since a class needs a module/program
// context to be constructed and to run tasks from.
//
// Race-safety note: without a `program` block, this test's code
// technically executes in the Active region alongside the DUT's
// `always @(posedge clk)` blocks. That's still safe here because
// every pin access goes through vif.drv_cb / vif.mon_cb (clocking
// blocks), which have their own well-defined race-free scheduling
// independent of whether the calling code lives in a module or a
// program. If any component is ever changed to touch vif signals
// directly (bypassing the clocking blocks), that protection goes
// away and race conditions become possible again.
//-----------------------------------------------------------------
class uart_test;

    virtual uart_if vif;
    uart_env        env;

    function new(virtual uart_if vif);
        this.vif = vif;
        env      = new(vif);
    endfunction

    task run();
        env.run();
    endtask

endclass