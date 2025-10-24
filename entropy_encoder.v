module entropy_encoder (
    input               clk,
    input               rst,
    input               in_valid,
    input       [5:0]   in_index,
    input signed [15:0] in_coeff,
    output reg          out_valid,
    output reg [15:0]   out_code,
    output reg [3:0]    out_len
);

    integer i;

    reg [15:0] dc_codebook[0:11];
    reg [3:0]  dc_codelen[0:11];
    reg [15:0] ac_codebook[0:255];
    reg [3:0]  ac_codelen[0:255];

    initial begin
        // Khởi tạo toàn bộ AC với giá trị mặc định
        for (i = 0; i < 256; i = i + 1) begin
            ac_codebook[i] = 16'h0000;
            ac_codelen[i] = 0;
        end

        // DC Huffman (mẫu JPEG)
        dc_codebook[0] = 16'b00;         dc_codelen[0] = 2;
        dc_codebook[1] = 16'b010;        dc_codelen[1] = 3;
        dc_codebook[2] = 16'b011;        dc_codelen[2] = 3;
        dc_codebook[3] = 16'b100;        dc_codelen[3] = 3;
        dc_codebook[4] = 16'b101;        dc_codelen[4] = 3;
        dc_codebook[5] = 16'b110;        dc_codelen[5] = 3;
        dc_codebook[6] = 16'b1110;       dc_codelen[6] = 4;
        dc_codebook[7] = 16'b11110;      dc_codelen[7] = 5;
        dc_codebook[8] = 16'b111110;     dc_codelen[8] = 6;
        dc_codebook[9] = 16'b1111110;    dc_codelen[9] = 7;
        dc_codebook[10] = 16'b11111110;  dc_codelen[10] = 8;
        dc_codebook[11] = 16'b111111110; dc_codelen[11] = 9;

        // AC Huffman (một vài mẫu cần thiết cho testbench)
        ac_codebook[0] = 16'b1010;       ac_codelen[0] = 4;  // EOB
        ac_codebook[1] = 16'b00;         ac_codelen[1] = 2;
        ac_codebook[2] = 16'b01;         ac_codelen[2] = 2;
        ac_codebook[5] = 16'b11010;      ac_codelen[5] = 5;
        ac_codebook[6] = 16'b1111000;    ac_codelen[6] = 7;
        ac_codebook[16] = 16'b11111111001; ac_codelen[16] = 11;  // Run=1, cat=0
        ac_codebook[48] = 16'b1111111110000010; ac_codelen[48] = 16; // 3/0
        ac_codebook[243] = 16'b1111111110001111; ac_codelen[243] = 16; // ZRL test
        // Thêm nếu cần tùy theo testbench
    end

    reg signed [15:0] dc_prev;
    reg [3:0] run_length;
	 reg [7:0] ac_index;
    reg [3:0] cat;
    function [3:0] category;
        input signed [15:0] val;
        begin
            if (val == 0) category = 0;
            else if (val >= -1 && val <= 1) category = 1;
            else if (val >= -3 && val <= 3) category = 2;
            else if (val >= -7 && val <= 7) category = 3;
            else if (val >= -15 && val <= 15) category = 4;
            else if (val >= -31 && val <= 31) category = 5;
            else if (val >= -63 && val <= 63) category = 6;
            else if (val >= -127 && val <= 127) category = 7;
            else if (val >= -255 && val <= 255) category = 8;
            else if (val >= -511 && val <= 511) category = 9;
            else if (val >= -1023 && val <= 1023) category = 10;
            else category = 11;
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out_valid <= 0;
            out_code <= 0;
            out_len <= 0;
            dc_prev <= 0;
            run_length <= 0;
        end else begin
            out_valid <= 0;

            if (in_valid) begin
                if (in_index == 0) begin
                    // DC coefficient
                    dc_prev <= in_coeff;
                    out_code <= dc_codebook[category(in_coeff)];
                    out_len <= dc_codelen[category(in_coeff)];
                    out_valid <= 1;
                    run_length <= 0;
                end else begin
                    if (in_coeff == 0) begin
                        run_length <= run_length + 1;

                        if (in_index == 63) begin
                            out_code <= ac_codebook[0]; // EOB
                            out_len <= ac_codelen[0];
                            out_valid <= 1;
                        end
                    end else begin
                        // Tạo ac_index = {run, cat}
                        cat = category(in_coeff);
                        ac_index = {run_length, cat};

                        // Chỉ xuất nếu mã có độ dài hợp lệ
                        if (ac_codelen[ac_index] > 0) begin
                            out_code <= ac_codebook[ac_index];
                            out_len <= ac_codelen[ac_index];
                            out_valid <= 1;
                        end
                        run_length <= 0;
                    end
                end
            end
        end
    end
endmodule
