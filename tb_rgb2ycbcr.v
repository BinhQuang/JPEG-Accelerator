`timescale 1ns/100ps
module tb_rgb2ycbcr;

reg clk, rst_n, start;
reg [7:0] R, G, B;
wire [7:0] Y, Cb, Cr;
wire done;

// Instantiate DUT
rgb2ycbcr dut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .R(R),
    .G(G),
    .B(B),
    .Y(Y),
    .Cb(Cb),
    .Cr(Cr),
    .done(done)
);

// Clock generation
always #5 clk = ~clk;

initial begin
    // Init
    clk = 0;
    rst_n = 0;
    start = 0;
    R = 0; G = 0; B = 0;
    #20 rst_n = 1;

    // Test 1: Gray pixel (R=G=B=128)
    @(negedge clk);
    R = 8'd128;
    G = 8'd128;
    B = 8'd128;
    start = 1;
    @(negedge clk);
    start = 0;

    // Wait until done
    wait(done == 1);

    // Print result
    $display("Y  = %d", Y);
    $display("Cb = %d", Cb);
    $display("Cr = %d", Cr);

    // Test 2: Red pixel (255, 0, 0)
    @(negedge clk);
    R = 8'd255;
    G = 8'd0;
    B = 8'd0;
    start = 1;
    @(negedge clk);
    start = 0;
    wait(done == 1);
	
	 // Print result
    $display("Y  = %d", Y);
    $display("Cb = %d", Cb);
    $display("Cr = %d", Cr);
	 
	// // Test 3: Red pixel (255, 0, 255)
    @(negedge clk);
    R = 8'd255;
    G = 8'd0;
    B = 8'd255;
    start = 1;
    @(negedge clk);
    start = 0;
    wait(done == 1);
    $display("Y  = %d", Y);
    $display("Cb = %d", Cb);
    $display("Cr = %d", Cr);
	
	    // Test 4: Full RGB (R=G=B=255)
    @(negedge clk);
    R = 8'd255;
    G = 8'd255;
    B = 8'd255;
    start = 1;
    @(negedge clk);
    start = 0;

    // Wait until done
    wait(done == 1);

    // Print result
    $display("Y  = %d", Y);
    $display("Cb = %d", Cb);
    $display("Cr = %d", Cr);
    $stop;
end

endmodule
