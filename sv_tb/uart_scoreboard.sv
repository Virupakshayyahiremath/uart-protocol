`timescale 1ns/1ps

class uart_scoreboard;

   // Event to indicate completion
   event DONE;

   // Counters
   int exp_data_count = 0;
   int act_data_count = 0;
   int data_verified  = 0;

   // Transaction handles
   uart_transaction exp_txn;
   uart_transaction act_txn;
   uart_transaction cov_txn;

   // Mailboxes
   mailbox #(uart_transaction) ref2scb;
   mailbox #(uart_transaction) mon2scb;

   //------------------------------------------------------------
   // Functional Coverage
   //------------------------------------------------------------
   covergroup uart_coverage;

      option.per_instance = 1;

      DATA : coverpoint cov_txn.data_in
      {
         bins ZERO = {8'h00};
         bins LOW  = {[8'h01:8'h55]};
         bins MID  = {[8'h56:8'hAA]};
         bins HIGH = {[8'hAB:8'hFE]};
         bins MAX  = {8'hFF};
      }

      STATUS : coverpoint (exp_txn.data_out === act_txn.data_out)
      {
         bins PASS = {1};
         ignore_bins FAIL = {0};
      }

      DATAxSTATUS : cross DATA, STATUS;

   endgroup

   //------------------------------------------------------------
   // Constructor
   //------------------------------------------------------------
   function new(mailbox #(uart_transaction) ref2scb,
                mailbox #(uart_transaction) mon2scb);

      this.ref2scb = ref2scb;
      this.mon2scb = mon2scb;

      uart_coverage = new();

   endfunction

   //------------------------------------------------------------
   // Start Task
   //------------------------------------------------------------
   virtual task start();

      fork
         while(1)
         begin

            // Expected transaction
            ref2scb.get(exp_txn);
            exp_data_count++;

            // Actual transaction
            mon2scb.get(act_txn);
            act_data_count++;

            // Compare
            check(act_txn);

         end
      join_none

   endtask

   //------------------------------------------------------------
   // Check Task
   //------------------------------------------------------------
   virtual task check(uart_transaction act);

      if ((exp_txn.data_out === act.data_out) &&
          (exp_txn.rdy      === act.rdy))
      begin

         $display("\n******** SCOREBOARD PASS ********");
         exp_txn.display("Expected");
         act.display("Actual");

      end
      else
      begin

         $display("\n******** SCOREBOARD FAIL ********");
         exp_txn.display("Expected");
         act.display("Actual");

         $display("Expected Data = %0h  Actual Data = %0h",
                   exp_txn.data_out,
                   act.data_out);

         $display("Expected RDY  = %0b  Actual RDY  = %0b",
                   exp_txn.rdy,
                   act.rdy);

      end

      // Copy transaction for coverage
      cov_txn = new();
      cov_txn = exp_txn;

      uart_coverage.sample();

      // Increment verified count
      data_verified++;

      // Trigger completion event
      if(data_verified >= number_of_transactions)
         ->DONE;

   endtask

   //------------------------------------------------------------
   // Report
   //------------------------------------------------------------
   virtual function void report();

      $display("\n======================================================");
      $display("              UART SCOREBOARD REPORT");
      $display("------------------------------------------------------");
      $display(" Expected Transactions : %0d", exp_data_count);
      $display(" Actual Transactions   : %0d", act_data_count);
      $display(" Verified Transactions : %0d", data_verified);
      $display(" Functional Coverage   : %0.2f%%",
               uart_coverage.get_coverage());
      $display("======================================================\n");

   endfunction

endclass