class uart_env;

   // Virtual Interface
   virtual uart_if vif;

   // Mailboxes
   mailbox #(uart_transaction) gen2drv = new();
   mailbox #(uart_transaction) mon2ref = new();
   mailbox #(uart_transaction) mon2scb = new();
   mailbox #(uart_transaction) ref2scb = new();

   // Component Handles
   uart_generator  gen_h;
   uart_driver     drv_h;
   uart_monitor    mon_h;
   uart_ref_model  ref_mod_h;
   uart_scoreboard sb_h;

   //--------------------------------------------------
   // Constructor
   //--------------------------------------------------
   function new(virtual uart_if vif);
      this.vif = vif;
   endfunction

   //--------------------------------------------------
   // Build
   //--------------------------------------------------
   virtual task build();
      gen_h     = new(gen2drv);
      drv_h     = new(vif, gen2drv);
      mon_h     = new(vif, mon2ref, mon2scb);
      ref_mod_h = new(mon2ref, ref2scb);
      sb_h      = new(ref2scb, mon2scb);
   endtask

   //--------------------------------------------------
   // Reset DUT
   //--------------------------------------------------
   virtual task reset_dut();

      vif.wr_en    <= 0;
      vif.rdy_clr  <= 0;
      vif.data_in  <= 0;

      wait(!vif.rst);

      repeat(5)
         @(posedge vif.clk);

   endtask

   //--------------------------------------------------
   // Start
   //--------------------------------------------------
   virtual task start();

      gen_h.start();
      drv_h.start();
      mon_h.start();
      ref_mod_h.start();
      sb_h.start();

   endtask

   //--------------------------------------------------
   // Stop
   //--------------------------------------------------
   virtual task stop();

      wait(sb_h.DONE.triggered);

   endtask

   //--------------------------------------------------
   // Run
   //--------------------------------------------------
   virtual task run();

      build();
      reset_dut();
      start();
      stop();
      sb_h.report();

   endtask

endclass