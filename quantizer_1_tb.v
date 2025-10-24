`timescale 1ns / 1ps

module quantizer_1_tb;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg signed [15:0] dct_in;

    // Outputs
    wire signed [15:0] quant_out;
    wire valid_out;
    wire done;
	 wire [7:0] q_monitor;


    // Instantiate DUT
    quantizer_1 uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .dct_in(dct_in),
        .quant_out(quant_out),
        .valid_out(valid_out),
        .done(done),
		  .q_monitor(q_monitor)
    );

    // Clock generation
    always #5 clk = ~clk;

    // DCT input array
    reg signed [15:0] dct_values [0:63];
    integer i;

    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        start = 0;
        dct_in = 0;

        // Fill DCT array with example values (you can change these)
        for (i = 0; i < 64; i = i + 1)
            dct_values[i] = i * 10 - 320; // some negative, some positive

        // Reset
        #20;
        rst_n = 1;

        // Wait a few cycles
        #20;

        // Start processing
        start = 1;
        #10;
        start = 0;

        // Feed all 64 DCT inputs, one per cycle
        for (i = 0; i < 64; i = i + 1) begin
            @(posedge clk);
            dct_in = dct_values[i];
            @(posedge clk); // wait for LOAD
            @(posedge clk); // COMPUTE
            @(posedge clk); // OUTPUT
            if (valid_out)
                $display("Time=%0t | Idx=%0d | DCT_IN=%0d | Q_VAL=%0d | Quant_Out=%0b | Valid=%b",
         $time, i, dct_values[i], q_monitor, quant_out, valid_out);
        end

        // Wait for done
        @(posedge done);
        $display("Quantization DONE at time %0t", $time);

        #20;
        $finish;
    end

endmodule
