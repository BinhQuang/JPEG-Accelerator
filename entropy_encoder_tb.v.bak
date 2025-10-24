`timescale 1ns / 100ps

module entropy_encoder_tb;

    // Inputs
    reg clk;
    reg rst;
    reg in_valid;
    reg [5:0] in_index;
    reg signed [15:0] in_coeff;

    // Outputs
    wire out_valid;
    wire [15:0] out_code;
    wire [3:0] out_len;

    // DUT
    entropy_encoder uut (
        .clk(clk),
        .rst(rst),
        .in_valid(in_valid),
        .in_index(in_index),
        .in_coeff(in_coeff),
        .out_valid(out_valid),
        .out_code(out_code),
        .out_len(out_len)
    );

    // Clock generator
    always #5 clk = ~clk;

    // Test data
    reg signed [15:0] test_data[0:63];
    integer i;

    // Task to apply test block (no string parameter)
    task apply_block;
        begin
            for (i = 0; i < 64; i = i + 1) begin
                @(negedge clk);
                in_valid <= 1;
                in_index <= i[5:0];
                in_coeff <= test_data[i];
            end
            @(negedge clk);
            in_valid <= 0;
            #50;
        end
    endtask

    // Output monitor
    always @(posedge clk) begin
        if (out_valid)
            $display("  [OUT] Code: %b  Length: %0d", out_code, out_len);
    end

    initial begin
        // Initialize signals
        clk = 0;
        rst = 1;
        in_valid = 0;
        in_index = 0;
        in_coeff = 0;
        #20 rst = 0;

        // Test Case 1: DC = 100, AC all 0
        $display("\n--- Test case: DC = 100, AC all zero ---");
        test_data[0] = 100;
        for (i = 1; i < 64; i = i + 1)
            test_data[i] = 0;
        apply_block;

        // Test Case 2: DC = -50, AC[1]=20, AC[2..63]=0
        $display("\n--- Test case: DC = -50, AC[1] = 20 ---");
        test_data[0] = -50;
        test_data[1] = 20;
        for (i = 2; i < 64; i = i + 1)
            test_data[i] = 0;
        apply_block;

        // Test Case 3: DC = 15, AC[1..15]=0, AC[16]=5
        $display("\n--- Test case: DC = 15, AC[16] = 5, ZRL test ---");
        test_data[0] = 15;
        for (i = 1; i < 16; i = i + 1)
            test_data[i] = 0;
        test_data[16] = 5;
        for (i = 17; i < 64; i = i + 1)
            test_data[i] = 0;
        apply_block;

        // Stop simulation
        #100;
        $stop;
    end
endmodule