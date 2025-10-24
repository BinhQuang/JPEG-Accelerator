`timescale 1ns/100ps

module bamodule_tb;

    // Signals
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] pixel_in;
    wire out_valid;
    wire [15:0] out_code;
    wire [3:0] out_len;
    wire done;

    // Instantiate the DUT (Device Under Test)
    bamodule dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pixel_in(pixel_in),
        .out_valid(out_valid),
        .out_code(out_code),
        .out_len(out_len),
        .done(done)
    );

    // Clock generation: 10ns period (100 MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    integer i;
    reg [7:0] pixel_block [0:63]; // 8x8 pixel block

    initial begin
        // Initialize pixel block (gradient pattern for testing)
        for (i = 0; i < 64; i = i + 1) begin
            pixel_block[i] = 8'd128 + (i % 8) * 4; // Simple gradient: 128, 132, 136, ..., 156
        end

        // Initialize signals
        rst_n = 0;
        start = 0;
        pixel_in = 8'd0;

        // Reset sequence
        #20 rst_n = 1; // Deassert reset after 20ns

        // Wait for a few cycles
        #20;

        // Start the encoder
        start = 1;
        #10 start = 0;

        // Feed pixel data
        for (i = 0; i < 64; i = i + 1) begin
            pixel_in = pixel_block[i];
            #10; // One clock cycle per pixel
        end
        pixel_in = 8'd0; // Clear input after block

        // Wait for processing to complete
        wait (done == 1);
        #50; // Wait a bit longer to observe final outputs

        // Stop simulation
        $display("Test completed at time %0t", $time);
        $stop;
    end

    // Monitor outputs
    initial begin
        $monitor("Time=%0t | rst_n=%b | start=%b | pixel_in=%h | out_valid=%b | out_code=%h | out_len=%d | done=%b",
                 $time, rst_n, start, pixel_in, out_valid, out_code, out_len, done);
    end

endmodule
