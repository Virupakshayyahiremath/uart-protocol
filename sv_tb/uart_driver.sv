`timescale 1ns/1ps

class uart_driver;

   // Virtual Interface
   virtual uart_if.DRIVER vif;

   // Transaction Handle
   uart_transaction data2duv;

   // Mailbox
   mailbox #(uart_transaction) gen2drv;

   //--------------------------------------------------
   // Constructor
   //--------------------------------------------------
   function new(virtual uart_if.DRIVER vif,
                mailbox #(uart_transaction) gen2drv);

      this.vif     = vif;
      this.gen2drv = gen2drv;

   endfunction

   //--------------------------------------------------
   // Reset Task
   //--------------------------------------------------
   virtual task reset();

      vif.drv_cb.wr_en   <= 0;
      vif.drv_cb.data_in <= '0;
      vif.drv_cb.rdy_clr <= 0;

      wait(!vif.rst);

   endtask

   //--------------------------------------------------
   // Drive Task
   //--------------------------------------------------
   virtual task drive();

      // Wait until transmitter is free
      wait(vif.drv_cb.busy == 0);

      @(vif.drv_cb);
      vif.drv_cb.data_in <= data2duv.data_in;
      vif.drv_cb.wr_en   <= 1;

      @(vif.drv_cb);
      vif.drv_cb.wr_en <= 0;

      // Wait until receiver indicates data is ready
      wait(vif.drv_cb.rdy == 1);

      // Clear ready signal
      @(vif.drv_cb);
      vif.drv_cb.rdy_clr <= 1;

      @(vif.drv_cb);
      vif.drv_cb.rdy_clr <= 0;

      data2duv.display("UART DRIVER");

   endtask

   //--------------------------------------------------
   // Start Task
   //--------------------------------------------------
   virtual task start();

      reset();

      fork
         forever
         begin
            // Receive transaction from generator
            gen2drv.get(data2duv);

            // Drive transaction to DUT
            drive();
         end
      join_none

   endtask

endclass