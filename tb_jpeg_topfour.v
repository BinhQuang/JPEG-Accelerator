`timescale 1ns / 1ps

module tb_jpeg_topfour;

  reg clk;
  reg rst_n;
  reg start;
  reg pixel_valid;
  reg [7:0] R, G, B;

  wire signed [15:0] dct_Y, dct_Cb, dct_Cr;
  wire done;

  // Instantiate jpeg_topfour
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

  // Clock generation
  initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100MHz clock
  end

  integer i;
  reg [7:0] img_R [0:4095];
  reg [7:0] img_G [0:4095];
  reg [7:0] img_B [0:4095];

  initial begin
    // Tạo ảnh RGB giả lập 64x64 pixel
    for (i = 0; i < 4096; i = i + 1) begin
      img_R[i] = i % 256;
      img_G[i] = (i * 2) % 256;
      img_B[i] = (i * 3) % 256;
    end
  end

  initial begin
    // Reset
    rst_n = 0;
    start = 0;
    pixel_valid = 0;
    R = 0; G = 0; B = 0;
    #20;
    rst_n = 1;

    // Bắt đầu cấp dữ liệu
    #10;
    start = 1;

    for (i = 0; i < 4096; i = i + 1) begin
      @(posedge clk);
      R <= img_R[i];
      G <= img_G[i];
      B <= img_B[i];
      pixel_valid <= 1;
    end

    // Ngưng cấp dữ liệu
    @(posedge clk);
    pixel_valid <= 0;
    start <= 0;

    // Chờ xử lý hoàn tất
    wait (done);
    $display("JPEG processing done at time %t", $time);

    // Kết thúc mô phỏng
    #100;
    $finish;
  end

  // Theo dõi output khi có kết quả
  always @(posedge clk) begin
    if (done) begin
      $display("DCT_Y = %d, DCT_Cb = %d, DCT_Cr = %d", dct_Y, dct_Cb, dct_Cr);
    end
  end

endmodule
