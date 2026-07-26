
class uart_monitor;

    virtual uart_if.MONITOR     vif;
    mailbox #(uart_transaction) mon2ref;
    mailbox #(uart_transaction) mon2scb;

    uart_transaction rddata, data2ref, data2scb;

    function new(virtual uart_if.MONITOR vif,
                 mailbox #(uart_transaction) mon2ref,
                 mailbox #(uart_transaction) mon2scb);
        this.vif     = vif;
        this.mon2ref = mon2ref;
        this.mon2scb = mon2scb;
        rddata       = new();
    endfunction

    task monitor();
        @(vif.mon_cb);
        wait (vif.mon_cb.rdy);

        rddata.data_in  = vif.mon_cb.data_in;
        rddata.data_out = vif.mon_cb.data_out;
        rddata.rdy      = vif.mon_cb.rdy;

        rddata.display("MONITOR");

        // re-arm guard: don't re-trigger on the same rdy pulse
        wait (!vif.mon_cb.rdy);
    endtask

    task start();
        fork
            begin
                forever begin
                    monitor();
                    data2ref = new rddata;
                    data2scb = new rddata;
                    mon2ref.put(data2ref);
                    mon2scb.put(data2scb);
                end
            end
        join_none
    endtask

endclass