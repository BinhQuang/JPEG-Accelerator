module quantization (
    input wire clk,
    input wire rst,
    input wire signed [11:0] dct_in [0:7][0:7], // 8x8 DCT input
    output reg signed [11:0] quantized_out [0:7][0:7]
);

// Standard JPEG quantization table (luminance)
reg [7:0] quant_table [0:7][0:7];

integer i, j;

initial begin
    quant_table[0][0] = 16; quant_table[0][1] = 11; quant_table[0][2] = 10; quant_table[0][3] = 16;
    quant_table[0][4] = 24; quant_table[0][5] = 40; quant_table[0][6] = 51; quant_table[0][7] = 61;

    quant_table[1][0] = 12; quant_table[1][1] = 12; quant_table[1][2] = 14; quant_table[1][3] = 19;
    quant_table[1][4] = 26; quant_table[1][5] = 58; quant_table[1][6] = 60; quant_table[1][7] = 55;

    quant_table[2][0] = 14; quant_table[2][1] = 13; quant_table[2][2] = 16; quant_table[2][3] = 24;
    quant_table[2][4] = 40; quant_table[2][5] = 57; quant_table[2][6] = 69; quant_table[2][7] = 56;

    quant_table[3][0] = 14; quant_table[3][1] = 17; quant_table[3][2] = 22; quant_table[3][3] = 29;
    quant_table[3][4] = 51; quant_table[3][5] = 87; quant_table[3][6] = 80; quant_table[3][7] = 62;

    quant_table[4][0] = 18; quant_table[4][1] = 22; quant_table[4][2] = 37; quant_table[4][3] = 56;
    quant_table[4][4] = 68; quant_table[4][5] = 109; quant_table[4][6] = 103; quant_table[4][7] = 77;

    quant_table[5][0] = 24; quant_table[5][1] = 35; quant_table[5][2] = 55; quant_table[5][3] = 64;
    quant_table[5][4] = 81; quant_table[5][5] = 104; quant_table[5][6] = 113; quant_table[5][7] = 92;

    quant_table[6][0] = 49; quant_table[6][1] = 64; quant_table[6][2] = 78; quant_table[6][3] = 87;
    quant_table[6][4] = 103; quant_table[6][5] = 121; quant_table[6][6] = 120; quant_table[6][7] = 101;

    quant_table[7][0] = 72; quant_table[7][1] = 92; quant_table[7][2] = 95; quant_table[7][3] = 98;
    quant_table[7][4] = 112; quant_table[7][5] = 100; quant_table[7][6] = 103; quant_table[7][7] = 99;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset output matrix
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                quantized_out[i][j] <= 0;
            end
        end
    end else begin
        // Perform quantization: quantized = round(dct / quant_table)
        for (i = 0; i < 8; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                quantized_out[i][j] <= dct_in[i][j] / quant_table[i][j]; // simple division (can improve rounding)
            end
        end
    end
end

endmodule
