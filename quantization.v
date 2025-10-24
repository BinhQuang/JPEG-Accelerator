module quantization (
    input wire clk,
    input wire rst,
    input wire signed [11:0] dct_in [0:63],        // Flattened 8x8 = 64 elements
    output reg signed [11:0] quantized_out [0:63]  // Output also flattened
);

reg [7:0] quant_table [0:63];  // Flattened quantization table

integer i;

initial begin
    quant_table[ 0] = 16; quant_table[ 1] = 11; quant_table[ 2] = 10; quant_table[ 3] = 16;
    quant_table[ 4] = 24; quant_table[ 5] = 40; quant_table[ 6] = 51; quant_table[ 7] = 61;

    quant_table[ 8] = 12; quant_table[ 9] = 12; quant_table[10] = 14; quant_table[11] = 19;
    quant_table[12] = 26; quant_table[13] = 58; quant_table[14] = 60; quant_table[15] = 55;

    quant_table[16] = 14; quant_table[17] = 13; quant_table[18] = 16; quant_table[19] = 24;
    quant_table[20] = 40; quant_table[21] = 57; quant_table[22] = 69; quant_table[23] = 56;

    quant_table[24] = 14; quant_table[25] = 17; quant_table[26] = 22; quant_table[27] = 29;
    quant_table[28] = 51; quant_table[29] = 87; quant_table[30] = 80; quant_table[31] = 62;

    quant_table[32] = 18; quant_table[33] = 22; quant_table[34] = 37; quant_table[35] = 56;
    quant_table[36] = 68; quant_table[37] = 109; quant_table[38] = 103; quant_table[39] = 77;

    quant_table[40] = 24; quant_table[41] = 35; quant_table[42] = 55; quant_table[43] = 64;
    quant_table[44] = 81; quant_table[45] = 104; quant_table[46] = 113; quant_table[47] = 92;

    quant_table[48] = 49; quant_table[49] = 64; quant_table[50] = 78; quant_table[51] = 87;
    quant_table[52] = 103; quant_table[53] = 121; quant_table[54] = 120; quant_table[55] = 101;

    quant_table[56] = 72; quant_table[57] = 92; quant_table[58] = 95; quant_table[59] = 98;
    quant_table[60] = 112; quant_table[61] = 100; quant_table[62] = 103; quant_table[63] = 99;
end

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (i = 0; i < 64; i = i + 1) begin
            quantized_out[i] <= 12'sd0;
        end
    end else begin
        for (i = 0; i < 64; i = i + 1) begin
            quantized_out[i] <= dct_in[i] / quant_table[i]; // Truncating division
        end
    end
end

endmodule
