module wb_top_module_jpeg (
    input  wire        wb_clk_i,
    input  wire        wb_rst_i,
    input  wire [31:0] wb_adr_i,
    input  wire [31:0] wb_dat_i,
    output reg  [31:0] wb_dat_o,
    input  wire        wb_we_i,
    input  wire        wb_stb_i,
    input  wire        wb_cyc_i,
    output reg         wb_ack_o
);

    wire        clk;
    wire        rst_n;
    wire        start;
    wire [7:0]  R, G, B;
    wire [15:0] out_code;
    wire [3:0]  out_len;
    wire        out_valid;
    wire        img_done;

    reg         start_reg;
    reg [7:0]   R_reg, G_reg, B_reg;
    reg         busy;
    reg [15:0]  code_reg;
    reg [3:0]   len_reg;
    reg         valid_reg;

    localparam ADDR_CONTROL        = 32'h00;
    localparam ADDR_STATUS         = 32'h04;
    localparam ADDR_RGB_INPUT      = 32'h08;
    localparam ADDR_ENCODED_OUTPUT = 32'h0C;

    assign clk = wb_clk_i;
    assign rst_n = ~wb_rst_i;

    top_module_jpeg #(
        .IMG_WIDTH(64),
        .IMG_HEIGHT(64)
    ) jpeg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start_reg),
        .R(R_reg),
        .G(G_reg),
        .B(B_reg),
        .out_code(out_code),
        .out_len(out_len),
        .out_valid(out_valid),
        .img_done(img_done)
    );

    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            busy <= 1'b0;
        end else begin
            if (start_reg && !img_done)
                busy <= 1'b1;
            else if (img_done)
                busy <= 1'b0;
        end
    end

    always @(posedge wb_clk_i or posedge wb_rst_i) begin
        if (wb_rst_i) begin
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'd0;
            start_reg <= 1'b0;
            R_reg <= 8'd0;
            G_reg <= 8'd0;
            B_reg <= 8'd0;
            code_reg <= 16'd0;
            len_reg <= 4'd0;
            valid_reg <= 1'b0;
        end else begin
            wb_ack_o <= 1'b0;
            wb_dat_o <= 32'd0;

            if (out_valid) begin
                code_reg <= out_code;
                len_reg <= out_len;
                valid_reg <= 1'b1;
            end else if (img_done) begin
                valid_reg <= 1'b0;
            end

            if (wb_cyc_i && wb_stb_i) begin
                wb_ack_o <= 1'b1;
                if (wb_we_i) begin
                    case (wb_adr_i)
                        ADDR_CONTROL: begin
                            start_reg <= wb_dat_i[0];
                        end
                        ADDR_RGB_INPUT: begin
                            R_reg <= wb_dat_i[31:24];
                            G_reg <= wb_dat_i[23:16];
                            B_reg <= wb_dat_i[15:8];
                        end
                        default: begin
                        end
                    endcase
                end else begin
                    case (wb_adr_i)
                        ADDR_CONTROL: begin
                            wb_dat_o <= {31'd0, start_reg};
                        end
                        ADDR_STATUS: begin
                            wb_dat_o <= {30'd0, busy, img_done};
                        end
                        ADDR_ENCODED_OUTPUT: begin
                            wb_dat_o <= {code_reg, 12'd0, len_reg};
                        end
                        default: begin
                            wb_dat_o <= 32'd0;
                        end
                    endcase
                end
            end
        end
    end

endmodule
