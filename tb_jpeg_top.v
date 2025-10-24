`timescale 1ns / 1ps

module tb_jpeg_top;

  // Inputs
  reg clk;
  reg rst_n;
  reg start;
  reg [7:0] R, G, B;
  reg pixel_valid;

  // Outputs
  wire signed [15:0] dct_Y;
  wire signed [15:0] dct_Cb;
  wire signed [15:0] dct_Cr;
  wire done;

  // Instantiate the Unit Under Test (UUT)
  jpeg_topfour uut (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .R(R),
    .G(G),
    .B(B),
    .pixel_valid(pixel_valid),
    .dct_Y(dct_Y),
    .dct_Cb(dct_Cb),
    .dct_Cr(dct_Cr),
    .done(done)
  );

  // Clock generation: 10ns period
  always #5 clk = ~clk;

  integer i;

  // Input pixel data (64 pixels = 8x8)
  reg [7:0] input_R [0:63];
  reg [7:0] input_G [0:63];
  reg [7:0] input_B [0:63];

  initial begin
    // Initialize
    clk = 0;
    rst_n = 0;
    start = 0;
    R = 0; G = 0; B = 0;
    pixel_valid = 0;

    // Reset pulse
    #20;
    rst_n = 1;

    // Start signal
    #10;
    start = 1;
    #10;
    start = 0;

    // Prepare test pixels (you can modify for custom pattern)
    for (i = 0; i < 64; i = i + 1) begin
      input_R[i] = i;      // Simple ramp pattern
      input_G[i] = i + 1;
      input_B[i] = i + 2;
    end

    // Feed 64 pixels
    for (i = 0; i < 64; i = i + 1) begin
      @(posedge clk);
      R <= input_R[i];
      G <= input_G[i];
      B <= input_B[i];
      pixel_valid <= 1;
    end

    // Stop input
    @(posedge clk);
    pixel_valid <= 0;

    // Wait for done signal
    wait(done);

    // Hold for a bit then finish
    #50;
    $display("Simulation finished.");
    $stop;
  end

endmodule
