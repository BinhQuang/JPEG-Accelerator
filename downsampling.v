module downsampling (
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
    // Registers for 2x2 block (Y, Cr, Cb for 4 pixels)
    reg [7:0] Y [0:3];        // Y for pixels 0,1,2,3
    reg [7:0] Cr [0:3];       // Cr for pixels 0,1,2,3
    reg [7:0] Cb [0:3];       // Cb for pixels 0,1,2,3
    reg [9:0] Cr_sum, Cb_sum; // Sum for averaging
    reg [7:0] Cr_avg, Cb_avg; // Averaged Cr, Cb
    reg [3:0] func_state;     // State machine
    reg [2:0] pixel_idx;      // Tracks pixel in 2x2 block
	 
	 integer i;
	 
    always @(posedge CLK_I or negedge RST_I) begin
        if (!RST_I) begin
            func_state <= 4'h0;
            pixel_idx <= 3'h0;
            ACK_O <= 1'b0;
            DAT_O <= 32'h0;
            Cr_sum <= 10'h0;
            Cb_sum <= 10'h0;
            Cr_avg <= 8'h0;
            Cb_avg <= 8'h0;
            for (i = 0; i < 4; i = i + 1) begin
                Y[i] <= 8'h0;
                Cr[i] <= 8'h0;
                Cb[i] <= 8'h0;
            end
        end else if (CYC_I && STB_I && !ACK_O) begin
            ACK_O <= 1'b1;
            case (func_state)
                4'h0: begin // Load Y for pixel_idx
                    if (WE_I && ADR_I[3:0] == 4'h0 && SEL_I[0]) begin
                        Y[pixel_idx] <= DAT_I[7:0];
                        func_state <= 4'h1;
                    end
                end
                4'h1: begin // Load Cr for pixel_idx
                    if (WE_I && ADR_I[3:0] == 4'h1 && SEL_I[0]) begin
                        Cr[pixel_idx] <= DAT_I[7:0];
                        func_state <= 4'h2;
                    end
                end
                4'h2: begin // Load Cb for pixel_idx
                if (WE_I && ADR_I[3:0] == 4'h2 && SEL_I[0]) begin
                    Cb[pixel_idx] <= DAT_I[7:0];
                    // Trigger averaging once 4th pixel is loaded
                    if (pixel_idx == 3'h3) begin
								Cr_sum <= Cr[0] + Cr[1] + Cr[2] + Cr[3];
								Cb_sum <= Cb[0] + Cb[1] + Cb[2] + Cb[3];
                        func_state <= 4'h9; 
                    end else begin
                        pixel_idx <= pixel_idx + 1;
                        func_state <= 4'h0; // Next pixel
                    end
						end
					 end
                4'h3: begin // Output Y or Cr_avg, Cb_avg
                    if (!WE_I) begin
                        case (ADR_I[3:0])
                            4'h4: begin // Y0
                                if (SEL_I[0]) DAT_O <= {24'h0, Y[0]};
                                func_state <= 4'h4;
                            end
                            default: DAT_O <= 32'h0;
                        endcase
                    end
                end
                4'h4: begin
                    if (!WE_I && ADR_I[3:0] == 4'h5 && SEL_I[0]) begin
                        DAT_O <= {24'h0, Y[1]};
                        func_state <= 4'h5;
                    end
                end
                4'h5: begin
                    if (!WE_I && ADR_I[3:0] == 4'h6 && SEL_I[0]) begin
                        DAT_O <= {24'h0, Y[2]};
                        func_state <= 4'h6;
                    end
                end
                4'h6: begin
                    if (!WE_I && ADR_I[3:0] == 4'h7 && SEL_I[0]) begin
                        DAT_O <= {24'h0, Y[3]};
                        func_state <= 4'h7;
                    end
                end
                4'h7: begin
                    if (!WE_I && ADR_I[3:0] == 4'h8 && SEL_I[0]) begin
                        DAT_O <= {24'h0, Cr_avg};
                        func_state <= 4'h8;
                    end
                end
					 4'h8: begin
                    if (!WE_I && ADR_I[3:0] == 4'h9 && SEL_I[0]) begin
                        DAT_O <= {24'h0, Cb_avg};
                        func_state <= 4'h0;
                    end
                end
					 4'h9: begin // Averaging Cr
						  Cr_avg <= Cr_sum >> 2;
						  Cb_avg <= Cb_sum >> 2;
						  pixel_idx <= 3'h0;
						  func_state <= 4'h3;
					 end
                default: DAT_O <= 32'h0;
            endcase
        end else begin
            ACK_O <= 1'b0;
        end
    end
endmodule