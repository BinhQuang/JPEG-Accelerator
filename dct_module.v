module dct_module (
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

    localparam IDLE = 0,
               LOAD = 1,
               DCT_ROW = 2,
               DCT_COL = 3,
               DONE = 4;

    reg [2:0] state = IDLE;
    reg [5:0] addr_counter;
    reg [2:0] row_idx;
    reg [2:0] col_idx;
    reg delay; // Thêm biến delay để chờ dữ liệu từ DCT

    reg signed [11:0] input_matrix[0:7][0:7];
    reg signed [11:0] row_dct[0:7][0:7];
    reg signed [11:0] output_matrix[0:7][0:7];

    integer i, j; // Khai báo biến i, j bên ngoài khối always

    wire signed [11:0] dct_in[0:7];
    wire signed [11:0] dct_out[0:7];

    genvar k;
    generate
        for (k = 0; k < 8; k = k + 1) begin : map_inputs
            assign dct_in[k] = (state == DCT_ROW) ? input_matrix[row_idx][k] : row_dct[k][col_idx];
        end
    endgenerate

    DCT dct1d (
        .clk(CLK_I),
        .a0(dct_in[0]), .a1(dct_in[1]), .a2(dct_in[2]), .a3(dct_in[3]),
        .a4(dct_in[4]), .a5(dct_in[5]), .a6(dct_in[6]), .a7(dct_in[7]),
        .b0(dct_out[0]), .b1(dct_out[1]), .b2(dct_out[2]), .b3(dct_out[3]),
        .b4(dct_out[4]), .b5(dct_out[5]), .b6(dct_out[6]), .b7(dct_out[7])
    );

    always @(posedge CLK_I) begin
        if (RST_I) begin
            state <= IDLE;
            addr_counter <= 0;
            row_idx <= 0;
            col_idx <= 0;
            delay <= 0;
            ACK_O <= 0;
            DAT_O <= 0;
            // Reset các ma trận
            for (i = 0; i < 8; i = i + 1) begin
                for (j = 0; j < 8; j = j + 1) begin
                    input_matrix[i][j] <= 0;
                    row_dct[i][j] <= 0;
                    output_matrix[i][j] <= 0;
                end
            end
        end else begin
            ACK_O = 0; // Sử dụng gán chặn
            case (state)
                IDLE: begin
                    if (CYC_I && STB_I && WE_I && SEL_I == 4'b1111) begin
                        state <= LOAD;
                        addr_counter <= 0;
                    end else if (CYC_I && STB_I) begin
                        // Xử lý lỗi: Nếu giao dịch không hợp lệ
                        ACK_O = 1; // Phản hồi ACK để kết thúc giao dịch lỗi
                    end
                end
                LOAD: begin
                    if (CYC_I && STB_I && WE_I && SEL_I == 4'b1111) begin
                        input_matrix[ADR_I[5:3]][ADR_I[2:0]] <= DAT_I[11:0];
                        ACK_O = 1;
                        if (ADR_I[5:0] == 6'd63) begin
                            state <= DCT_ROW;
                            row_idx <= 0;
                            delay <= 0;
                        end
                    end else if (CYC_I && STB_I) begin
                        // Xử lý lỗi: Nếu giao dịch không hợp lệ
                        ACK_O = 1;
                    end
                end
                DCT_ROW: begin
                    if (!delay) begin
                        delay <= 1; // Chờ 1 chu kỳ để dct_out ổn định
                    end else begin
                        row_dct[row_idx][0] <= dct_out[0];
                        row_dct[row_idx][1] <= dct_out[1];
                        row_dct[row_idx][2] <= dct_out[2];
                        row_dct[row_idx][3] <= dct_out[3];
                        row_dct[row_idx][4] <= dct_out[4];
                        row_dct[row_idx][5] <= dct_out[5];
                        row_dct[row_idx][6] <= dct_out[6];
                        row_dct[row_idx][7] <= dct_out[7];
                        if (row_idx == 7) begin
                            col_idx <= 0;
                            state <= DCT_COL;
                            delay <= 0;
                        end else begin
                            row_idx <= row_idx + 1;
                            delay <= 0;
                        end
                    end
                end
                DCT_COL: begin
                    if (!delay) begin
                        delay <= 1; // Chờ 1 chu kỳ để dct_out ổn định
                    end else begin
                        output_matrix[0][col_idx] <= dct_out[0];
                        output_matrix[1][col_idx] <= dct_out[1];
                        output_matrix[2][col_idx] <= dct_out[2];
                        output_matrix[3][col_idx] <= dct_out[3];
                        output_matrix[4][col_idx] <= dct_out[4];
                        output_matrix[5][col_idx] <= dct_out[5];
                        output_matrix[6][col_idx] <= dct_out[6];
                        output_matrix[7][col_idx] <= dct_out[7];
                        if (col_idx == 7) begin
                            state <= DONE;
                        end else begin
                            col_idx <= col_idx + 1;
                        end
                        delay <= 0;
                    end
                end
                DONE: begin
                    if (CYC_I && STB_I && !WE_I && SEL_I == 4'b1111) begin
                        DAT_O <= {{20{output_matrix[ADR_I[5:3]][ADR_I[2:0]][11]}}, output_matrix[ADR_I[5:3]][ADR_I[2:0]]};
                        ACK_O = 1;
                    end else if (CYC_I && STB_I) begin
                        // Xử lý lỗi: Nếu giao dịch không hợp lệ
                        ACK_O = 1;
                    end
                end
            endcase
        end
    end
endmodule