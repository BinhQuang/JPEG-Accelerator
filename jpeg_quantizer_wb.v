module jpeg_quantizer_wb (
    input wire CLK_I,
    input wire RST_I,
    input wire [31:0] DAT_I,
    output reg [31:0] DAT_O,
    input wire [31:0] ADR_I,
    input wire WE_I,
    input wire STB_I,
    input wire CYC_I,
    input wire [3:0] SEL_I,
    output reg ACK_O
);

    wire signed [7:0] q_result;
    reg signed [11:0] dct_input;
    reg [5:0]         addr_input;

    // Giao tiếp với module jpeg_quantizer (đồng bộ clock/reset)
    jpeg_quantizer core (
        .clk(CLK_I),
        .rst(RST_I),
        .addr(addr_input),
        .dct_in(dct_input),
        .q_out(q_result)
    );

    always @(posedge CLK_I or posedge RST_I) begin
        if (RST_I) begin
            ACK_O       <= 0;
            DAT_O       <= 32'b0;
            dct_input   <= 12'b0;
            addr_input  <= 6'b0;
        end else begin
            ACK_O <= 0;

            if (STB_I && CYC_I && !ACK_O) begin
                ACK_O <= 1;

                if (WE_I) begin
                    // Ghi dữ liệu: chỉ lấy 12 bit thấp từ DAT_I
                    dct_input  <= DAT_I[11:0];
                    addr_input <= ADR_I[5:0]; // dùng 6 bit thấp làm địa chỉ
                end else begin
                    // Đọc dữ liệu: trả về kết quả quantized 8 bit, mở rộng thành 32-bit
                    DAT_O <= {24'b0, q_result};
                end
            end
        end
    end

endmodule
