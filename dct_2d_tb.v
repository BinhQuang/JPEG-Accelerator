`timescale 1ns / 1ps

module dct_2d_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] pixel_in;

    // Outputs
    wire signed [15:0] dct_out;
    wire valid_out;
    wire done;

    // Instantiate the DUT
    dct_2d uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pixel_in(pixel_in),
        .dct_out(dct_out),
        .valid_out(valid_out),
        .done(done)
    );

    // Clock generation: 100MHz
    always #5 clk = ~clk;

    // Input pixels
    reg [7:0] input_pixels [0:63];
    integer i, j;

    initial begin
        $display("=== Starting DCT 2D Testbench ===");
        clk = 0;
        rst_n = 0;
        start = 0;
        pixel_in = 0;

        // Initialize test pattern
        for (i = 0; i < 64; i = i + 1)
            input_pixels[i] = i; // or use 128, or other patterns

        // Reset
        #20;
        rst_n = 1;

        // Wait then start
        #20;
        start = 1;

        // Print DCT coefficients
        $display("=== DCT Coefficients (scaled by 1024) ===");
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                $write("%d\t", uut.dct_coeff[i][j]);
            end
            $write("\n");
        end
        $display("=========================================");

        // Send input pixels
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge clk);
            pixel_in <= input_pixels[i];
            $display("Sending pixel_in[%0d] = %d", i, input_pixels[i]);
        end

        // Stop input
        @(posedge clk);
        start <= 0;
        pixel_in <= 0;

        // Wait for done
        wait (done);
        #20;
        $display("=== Simulation Done ===");
        $finish;
    end

    // Monitor output
    always @(posedge clk) begin
        if (valid_out) begin
            $display("DCT Output #%0d: %d", uut.counter, dct_out);
        end
    end

endmodule
