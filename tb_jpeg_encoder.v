`timescale 1ns / 1ps

module tb_jpeg_encoder;

    // Inputs
    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] R_in, G_in, B_in;
    reg valid_in;

    // Outputs
    wire [15:0] code_out;
    wire [3:0] code_len;
    wire valid_out;
    wire img_done;

    // Instantiate DUT
    jpeg_encoder uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .R_in(R_in),
        .G_in(G_in),
        .B_in(B_in),
        .valid_in(valid_in),
        .code_out(code_out),
        .code_len(code_len),
        .valid_out(valid_out),
        .img_done(img_done)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Input stimulus
    integer i;

    initial begin
        $display("\n--- JPEG Encoder Testbench Start ---");

        // Initialize
        clk = 0;
        rst_n = 0;
        start = 0;
        valid_in = 0;
        R_in = 0;
        G_in = 0;
        B_in = 0;

        // Reset
        #20;
        rst_n = 1;

        // Feed a block of 8x8 pixels (total 64 pixels)
        #10;
        start = 1;
        valid_in = 1;
        for (i = 0; i < 64; i = i + 1) begin
            R_in = i;     // Example data, could be any pattern
            G_in = i + 10;
            B_in = i + 20;
            #10;          // Wait one clock cycle
        end

        // End of input
        valid_in = 0;
        start = 0;

        // Wait until image processing done
        wait(img_done);
        $display("\n--- JPEG Encoding Done ---");
        #50;

        $stop;
    end

    // Monitor output codes
    always @(posedge clk) begin
        if (valid_out) begin
            $display("  [ENCODED] Code = %b, Len = %0d", code_out, code_len);
        end
    end

endmodule
