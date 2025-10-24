module jpeg_topfour (
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire [7:0] R,
    input wire [7:0] G,
    input wire [7:0] B,
    input wire pixel_valid,

    output wire signed [15:0] dct_Y,
    output wire signed [15:0] dct_Cb,
    output wire signed [15:0] dct_Cr,
    output wire done
);

    // Tín hiệu kết nối giữa các khối
    wire [7:0] Y, Cb, Cr;
    wire rgb2ycbcr_done;

    wire [7:0] Cb_ds, Cr_ds;
    wire ds_valid;

    wire [7:0] blk_pixel_Y, blk_pixel_Cb, blk_pixel_Cr;
    wire blk_valid_Y, blk_valid_Cb, blk_valid_Cr;
    wire blk_done_Y, blk_done_Cb, blk_done_Cr;
    wire img_done_Y, img_done_Cb, img_done_Cr;

    wire signed [15:0] dct_out_Y, dct_out_Cb, dct_out_Cr;
    wire dct_valid_Y, dct_valid_Cb, dct_valid_Cr;
    wire dct_done_Y, dct_done_Cb, dct_done_Cr;

    // Giai đoạn 1: Chuyển đổi RGB sang YCbCr
    rgb2ycbcr u_rgb2ycbcr (
        .clk(clk),
        .rst_n(rst_n),
        .start(pixel_valid),
        .R(R),
        .G(G),
        .B(B),
        .Y(Y),
        .Cb(Cb),
        .Cr(Cr),
        .done(rgb2ycbcr_done)
    );

    // Giai đoạn 2: Downsampling Cb, Cr (4:2:0)
    downsampler_420 u_downsampler (
        .clk(clk),
        .rst_n(rst_n),
        .cb_in(Cb),
        .cr_in(Cr),
        .valid_in(rgb2ycbcr_done),
        .cb_out(Cb_ds),
        .cr_out(Cr_ds),
        .valid_out(ds_valid)
    );

    // Giai đoạn 3: Chia khối 8x8 cho từng kênh Y, Cb, Cr
    block_splitter blk_Y (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pixel_in(Y),
        .valid_in(rgb2ycbcr_done),
        .pixel_out(blk_pixel_Y),
        .valid_out(blk_valid_Y),
        .done(blk_done_Y),
        .img_done(img_done_Y)
    );

    block_splitter blk_Cb (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pixel_in(Cb_ds),
        .valid_in(ds_valid),
        .pixel_out(blk_pixel_Cb),
        .valid_out(blk_valid_Cb),
        .done(blk_done_Cb),
        .img_done(img_done_Cb)
    );

    block_splitter blk_Cr (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pixel_in(Cr_ds),
        .valid_in(ds_valid),
        .pixel_out(blk_pixel_Cr),
        .valid_out(blk_valid_Cr),
        .done(blk_done_Cr),
        .img_done(img_done_Cr)
    );

    // Giai đoạn 4: Tính DCT 2D cho từng khối
    dct_2d dct_Y1 (
        .clk(clk),
        .rst_n(rst_n),
        .start(blk_done_Y),
        .pixel_in(blk_pixel_Y),
        .dct_out(dct_out_Y),
        .valid_out(dct_valid_Y),
        .done(dct_done_Y)
    );

    dct_2d dct_Cb1 (
        .clk(clk),
        .rst_n(rst_n),
        .start(blk_done_Cb),
        .pixel_in(blk_pixel_Cb),
        .dct_out(dct_out_Cb),
        .valid_out(dct_valid_Cb),
        .done(dct_done_Cb)
    );

    dct_2d dct_Cr1 (
        .clk(clk),
        .rst_n(rst_n),
        .start(blk_done_Cr),
        .pixel_in(blk_pixel_Cr),
        .dct_out(dct_out_Cr),
        .valid_out(dct_valid_Cr),
        .done(dct_done_Cr)
    );

    // Gán output cuối
    assign dct_Y = dct_out_Y;
    assign dct_Cb = dct_out_Cb;
    assign dct_Cr = dct_out_Cr;
    assign done = dct_done_Y & dct_done_Cb & dct_done_Cr;

endmodule
