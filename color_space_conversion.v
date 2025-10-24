module color_space_conversion(
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
    // Fixed-point coefficients (Q16.16)
    reg [31:0] Ycoffa = 32'h4CBD2F; // 0.299
    reg [31:0] Ycoffb = 32'h963468; // 0.587
    reg [31:0] Ycoffc = 32'h1D1C7A; // 0.114
    reg [31:0] Crcoffa = 32'h80000;  // 0.5
    reg [31:0] Crcoffb = 32'h6B0A3D; // -0.4187
    reg [31:0] Crcoffc = 32'h02F2E9; // -0.0813
    reg [31:0] Cbcoffa = 32'hAB2F5A; // -0.1687
    reg [31:0] Cbcoffb = 32'h54E5DC; // -0.3313
    reg [31:0] Cbcoffc = 32'h80000;  // 0.5
    reg [31:0] cval = 32'h800000;   // 128

    // Pipeline registers
    reg [7:0] R_in, G_in, B_in;              // Stage 1: Input RGB
    (* keep *) wire [31:0] mult_result_delay1;
	 (* keep *) wire [31:0] mult_result_delay2;
	 assign mult_result_delay = mult_result;
	 assign mult_result_delay2 = mult_result_delay1;
	 reg [31:0] mult_result; 
	 reg [31:0] Y_sum, Cr_sum, Cb_sum;        // Stage 3: Intermediate sums
    reg [7:0] Y_out, Cr_out, Cb_out;         // Stage 3: Final results
    reg valid_s1, valid_s2, valid_s3, valid_s4;        // Pipeline valid flags
	 reg [3:0] mult_state; // Tracks which multiplication (0-8 for Y, Cr, Cb)
    reg mult_active;      // Indicates multiplication in progress
	 reg [31:0] mult_result_reg; // Pipeline register after multiplier
	 reg mult_result_valid;
    reg [31:0] coeff;     // Selected coefficient
    reg [7:0] input_val;
    // Wishbone state
    reg [1:0] out_state; // Tracks output (Y, Cr, Cb)

    always @(posedge CLK_I or negedge RST_I) begin
        if (!RST_I) begin
            R_in <= 8'h0;
            G_in <= 8'h0;
            B_in <= 8'h0;
            mult_result <= 32'h0;
				mult_result_reg <= 32'h0;
            mult_result_valid <= 1'b0;
            Y_sum <= 32'h0;
            Cr_sum <= 32'h0;
            Cb_sum <= 32'h0;
            Y_out <= 8'h0;
            Cr_out <= 8'h0;
            Cb_out <= 8'h0;
            valid_s1 <= 1'b0;
            valid_s2 <= 1'b0;
            valid_s3 <= 1'b0;
            valid_s4 <= 1'b0;
            mult_state <= 4'h0;
            mult_active <= 1'b0;
            coeff <= 32'h0;
            input_val <= 8'h0;
            out_state <= 2'h0;
            DAT_O <= 32'h0;
            ACK_O <= 1'b0;
        end else begin
            // Pipeline Stage 1: Input RGB
            if (CYC_I && STB_I && WE_I && ADR_I[3:0] == 4'h0 && SEL_I[3:0] == 4'b1111) begin
                R_in <= DAT_I[23:16];
                G_in <= DAT_I[15:8];
                B_in <= DAT_I[7:0];
                valid_s1 <= 1'b1;
					 mult_active <= 1'b1;
                mult_state <= 4'h0;
                ACK_O <= 1'b1;
            end else begin
                valid_s1 <= 1'b0;
                ACK_O <= (CYC_I && STB_I && !WE_I) ? 1'b1 : 1'b0;
            end

            if (mult_active) begin
                case (mult_state)
                    4'h0: begin // Y: R * Ycoffa
                        coeff <= Ycoffa;
                        input_val <= R_in;
                        mult_state <= 4'h1;
                    end
                    4'h1: begin // Y: G * Ycoffb
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2; // Pipeline multiplier output
								mult_result_valid <= valid_s1;
                        Y_sum <= mult_result_reg; // Initialize Y_sum
                        coeff <= Ycoffb;
                        input_val <= G_in;
                        mult_state <= 4'h2;
                        valid_s2 <= mult_result_valid;
                    end
                    4'h2: begin // Y: B * Ycoffc
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2;
                        Y_sum <= Y_sum + mult_result_reg;
                        coeff <= Ycoffc;
                        input_val <= B_in;
                        mult_state <= 4'h3;
                    end
						  4'h3: begin // Cr: R * Crcoffa
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2;
                        Y_sum <= Y_sum + mult_result_reg;
                        coeff <= Crcoffa;
                        input_val <= R_in;
                        mult_state <= 4'h4;
                    end
                    4'h4: begin // Cr: G * Crcoffb
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2;
                        Cr_sum <= cval + mult_result_reg;
                        coeff <= Crcoffb;
                        input_val <= G_in;
                        mult_state <= 4'h5;
                    end
                    4'h5: begin // Cr: B * Crcoffc
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2;
                        Cr_sum <= Cr_sum + mult_result_reg;
                        coeff <= Crcoffc;
                        input_val <= B_in;
                        mult_state <= 4'h6;
                    end
                    4'h6: begin // Cb: R * Cbcoffa
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2;
                        Cr_sum <= Cr_sum + mult_result_reg;
                        coeff <= Cbcoffa;
                        input_val <= R_in;
                        mult_state <= 4'h7;
                    end
                    4'h7: begin // Cb: G * Cbcoffb
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2;
                        Cb_sum <= cval + mult_result_reg;
                        coeff <= Cbcoffb;
                        input_val <= G_in;
                        mult_state <= 4'h8;
                    end
                    4'h8: begin // Cb: B * Cbcoffc
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2;
                        Cb_sum <= Cb_sum + mult_result_reg;
                        coeff <= Cbcoffc;
                        input_val <= B_in;
                        mult_state <= 4'h9;
                    end
                    4'h9: begin // Finalize
                        mult_result <= ($signed({1'b0, input_val}) * $signed(coeff)) >>> 16;
                        mult_result_reg <= mult_result_delay2;
                        Cb_sum <= Cb_sum + mult_result_reg;
                        mult_active <= 1'b0;
                        mult_state <= 4'h0;
                        valid_s3 <= mult_result_valid;
                    end
                    default: mult_state <= 4'h0;
                endcase
            end

            // Pipeline Stage 3: Finalize Outputs
            if (valid_s3) begin
                Y_out <= Y_sum[7:0];
                Cr_out <= Cr_sum[7:0];
                Cb_out <= Cb_sum[7:0];
                valid_s4 <= valid_s3;
            end
					
            // Wishbone Output
            if (CYC_I && STB_I && !WE_I && valid_s3) begin
                case (ADR_I[3:0])
                    4'h4: begin
                        if (SEL_I[0]) begin
                            DAT_O <= {24'h0, Y_out};
                        end
                    end
                    4'h5: begin
                        if (SEL_I[0]) begin
                            DAT_O <= {24'h0, Cr_out};
                        end
                    end
                    4'h6: begin
                        if (SEL_I[0]) begin
                            DAT_O <= {24'h0, Cb_out};
                        end
                    end
                    default: DAT_O <= 32'h0;
                endcase
            end else begin
                DAT_O <= 32'h0;
            end
        end
    end
endmodule