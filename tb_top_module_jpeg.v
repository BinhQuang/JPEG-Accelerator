`timescale 1ns / 1ps

module tb_top_module_jpeg;

    // Clock and reset
    reg clk;
    reg rst_n;
    reg start;

    // RGB input
    reg [7:0] R, G, B;

    // Output from DUT
    wire [15:0] out_code;
    wire [3:0]  out_len;
    wire        out_valid;
    wire        img_done;

    // Instantiate the DUT
    top_module_jpeg #(
        .IMG_WIDTH(64),
        .IMG_HEIGHT(64)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .R(R),
        .G(G),
        .B(B),
        .out_code(out_code),
        .out_len(out_len),
        .out_valid(out_valid),
        .img_done(img_done)
    );

    // Clock generation
    always #5 clk = ~clk; // 100 MHz

    // Task to apply one pixel
    task apply_pixel(input [7:0] r, input [7:0] g, input [7:0] b);
        begin
            R <= r;
            G <= g;
            B <= b;
            @(posedge clk);
        end
    endtask

    // Main test
    initial begin
        // Init
        clk = 0;
        rst_n = 0;
        start = 0;
        R = 0; G = 0; B = 0;

        // Reset pulse
        #20;
        rst_n = 1;
        #10;

        // Start JPEG pipeline
        start = 1;
        @(posedge clk);
        start = 0;

        // Send 64 x 64 pixels (here just send dummy values)
        repeat (4096) begin
            apply_pixel(8'hAA, 8'hBB, 8'hCC);
        end

        // Wait for image done
        wait (img_done);
        $display("Image processing done.");
        #100;
        $finish;
    end

endmodule
