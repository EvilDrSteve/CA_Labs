`timescale 1ns / 1ps

module TB_debouncer;

    // Inputs
    reg clk;
    reg pbin;
    
    // Outputs
    wire pbout;
    
    // Instantiate the debouncer
    debouncer uut (
        .clk(clk),
        .pbin(pbin),
        .pbout(pbout)
    );
    
    // Clock generation: 100MHz (10ns period)
    initial clk = 0;
    always #5 clk = ~clk;
    
    // Task to simulate button bounce
    task bounce_press;
        integer i;
        begin
            $display("Time %0t: Button press with bouncing", $time);
            // Simulate bouncing (rapid on/off transitions)
            for (i = 0; i < 10; i = i + 1) begin
                pbin = 1'b1;
                #(50 + $urandom % 100);  // Random high time
                pbin = 1'b0;
                #(30 + $urandom % 80);   // Random low time
            end
            // Finally settle HIGH
            pbin = 1'b1;
            $display("Time %0t: Button settled HIGH", $time);
        end
    endtask
    
    task bounce_release;
        integer i;
        begin
            $display("Time %0t: Button release with bouncing", $time);
            // Simulate bouncing on release
            for (i = 0; i < 8; i = i + 1) begin
                pbin = 1'b0;
                #(40 + $urandom % 100);
                pbin = 1'b1;
                #(20 + $urandom % 60);
            end
            // Finally settle LOW
            pbin = 1'b0;
            $display("Time %0t: Button settled LOW", $time);
        end
    endtask
    
    // Monitor pbout for pulses
    always @(posedge pbout) begin
        $display("Time %0t: >>> pbout PULSE DETECTED <<<", $time);
    end
    
    // Test sequence
    initial begin
        $display("========================================");
        $display("       Debouncer Testbench Start        ");
        $display("========================================");
        
        // Initialize
        pbin = 0;
        #1000;
        
        // Test 1: Clean press (no bounce) - baseline test
        $display("\n--- Test 1: Clean press (no bounce) ---");
        pbin = 1;
        #600000;  // Wait for debounce time (>5000 cycles * 10ns = 50us)
        pbin = 0;
        #600000;
        
        // Test 2: Bouncy button press
        $display("\n--- Test 2: Bouncy button press ---");
        bounce_press();
        #600000;  // Wait for debounce
        bounce_release();
        #600000;
        
        // Test 3: Multiple quick bouncy presses
        $display("\n--- Test 3: Multiple presses ---");
        bounce_press();
        #800000;
        bounce_release();
        #400000;
        bounce_press();
        #800000;
        bounce_release();
        #600000;
        
        // Test 4: Very short glitch (should be filtered)
        $display("\n--- Test 4: Short glitch (should be ignored) ---");
        pbin = 1;
        #1000;  // Only 100 clock cycles, less than 5000 threshold
        pbin = 0;
        #600000;
        
        $display("\n========================================");
        $display("       Debouncer Testbench End          ");
        $display("========================================");
        $finish;
    end
    
    // Optional: Generate VCD for waveform viewing
    initial begin
        $dumpfile("TB_debouncer.vcd");
        $dumpvars(0, TB_debouncer);
    end

endmodule