module dct_2d (
    input wire clk,                   // Clock input
    input wire rst_n,                // Active-low reset
    input wire start,                // Start signal
    input wire [7:0] pixel_in,       // 8-bit unsigned pixel input
    output reg signed [15:0] dct_out, // 16-bit signed DCT output
    output reg valid_out,            // Output valid signal
    output reg done                  // Done signal for 8x8 block
);

    // Internal registers and memories
    reg [7:0] pixel_block [0:63];    // 8x8 pixel block storage
    reg signed [15:0] temp_block [0:63]; // Temporary block for row DCT
    reg signed [15:0] dct_block [0:63];  // Final DCT block
    reg [5:0] counter;               // Counter for 64 elements
    reg [2:0] state;                 // FSM state
    reg [5:0] load_idx;              // Index for loading pixels
    reg [3:0] row, col;              // Indices for row-column computation
    reg [3:0] coeff_idx;             // Coefficient index for DCT computation

    // Zigzag order for output
    reg [5:0] zigzag [0:63];
    initial begin
        zigzag[0] = 0;  zigzag[1] = 1;  zigzag[2] = 8;  zigzag[3] = 16; zigzag[4] = 9;  zigzag[5] = 2;  zigzag[6] = 3;  zigzag[7] = 10;
        zigzag[8] = 17; zigzag[9] = 24; zigzag[10] = 32; zigzag[11] = 25; zigzag[12] = 18; zigzag[13] = 11; zigzag[14] = 4;  zigzag[15] = 5;
        zigzag[16] = 12; zigzag[17] = 19; zigzag[18] = 26; zigzag[19] = 33; zigzag[20] = 40; zigzag[21] = 48; zigzag[22] = 41; zigzag[23] = 34;
        zigzag[24] = 27; zigzag[25] = 20; zigzag[26] = 13; zigzag[27] = 6;  zigzag[28] = 7;  zigzag[29] = 14; zigzag[30] = 21; zigzag[31] = 28;
        zigzag[32] = 35; zigzag[33] = 42; zigzag[34] = 49; zigzag[35] = 56; zigzag[36] = 57; zigzag[37] = 50; zigzag[38] = 43; zigzag[39] = 36;
        zigzag[40] = 29; zigzag[41] = 22; zigzag[42] = 15; zigzag[43] = 23; zigzag[44] = 30; zigzag[45] = 37; zigzag[46] = 44; zigzag[47] = 51;
        zigzag[48] = 58; zigzag[49] = 59; zigzag[50] = 52; zigzag[51] = 45; zigzag[52] = 38; zigzag[53] = 31; zigzag[54] = 39; zigzag[55] = 46;
        zigzag[56] = 53; zigzag[57] = 60; zigzag[58] = 61; zigzag[59] = 54; zigzag[60] = 47; zigzag[61] = 55; zigzag[62] = 62; zigzag[63] = 63;
    end

    // DCT coefficients (scaled by 1024 for fixed-point precision)
    reg signed [15:0] dct_coeff [0:7][0:7];
    initial begin
        dct_coeff[0][0] = 362; dct_coeff[0][1] = 362; dct_coeff[0][2] = 362; dct_coeff[0][3] = 362;
        dct_coeff[0][4] = 362; dct_coeff[0][5] = 362; dct_coeff[0][6] = 362; dct_coeff[0][7] = 362;
        dct_coeff[1][0] = 502; dct_coeff[1][1] = 415; dct_coeff[1][2] = 284; dct_coeff[1][3] = 97;
        dct_coeff[1][4] = -97; dct_coeff[1][5] = -284; dct_coeff[1][6] = -415; dct_coeff[1][7] = -502;
        dct_coeff[2][0] = 473; dct_coeff[2][1] = 191; dct_coeff[2][2] = -191; dct_coeff[2][3] = -473;
        dct_coeff[2][4] = -473; dct_coeff[2][5] = -191; dct_coeff[2][6] = 191; dct_coeff[2][7] = 473;
        dct_coeff[3][0] = 415; dct_coeff[3][1] = -97; dct_coeff[3][2] = -502; dct_coeff[3][3] = -284;
        dct_coeff[3][4] = 284; dct_coeff[3][5] = 502; dct_coeff[3][6] = 97; dct_coeff[3][7] = -415;
        dct_coeff[4][0] = 362; dct_coeff[4][1] = -362; dct_coeff[4][2] = -362; dct_coeff[4][3] = 362;
        dct_coeff[4][4] = 362; dct_coeff[4][5] = -362; dct_coeff[4][6] = -362; dct_coeff[4][7] = 362;
        dct_coeff[5][0] = 284; dct_coeff[5][1] = -502; dct_coeff[5][2] = 97; dct_coeff[5][3] = 415;
        dct_coeff[5][4] = -415; dct_coeff[5][5] = -97; dct_coeff[5][6] = 502; dct_coeff[5][7] = -284;
        dct_coeff[6][0] = 191; dct_coeff[6][1] = -473; dct_coeff[6][2] = 473; dct_coeff[6][3] = -191;
        dct_coeff[6][4] = -191; dct_coeff[6][5] = 473; dct_coeff[6][6] = -473; dct_coeff[6][7] = 191;
        dct_coeff[7][0] = 97; dct_coeff[7][1] = -284; dct_coeff[7][2] = 415; dct_coeff[7][3] = -502;
        dct_coeff[7][4] = 502; dct_coeff[7][5] = -415; dct_coeff[7][6] = 284; dct_coeff[7][7] = -97;
    end

    // State machine states
    localparam IDLE = 3'd0,
               LOAD = 3'd1,
               ROW_DCT = 3'd2,
               COL_DCT = 3'd3,
               OUTPUT = 3'd4,
               DONE = 3'd5;

    // Accumulator for DCT computation
    reg signed [31:0] accum;

    // Main FSM
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            counter <= 6'd0;
            load_idx <= 6'd0;
            row <= 4'd0;
            col <= 4'd0;
            coeff_idx <= 4'd0;
            state <= IDLE;
            valid_out <= 1'b0;
            done <= 1'b0;
            dct_out <= 16'd0;
            accum <= 32'd0;
        end else begin
            case (state)
                IDLE: begin
                    valid_out <= 1'b0;
                    done <= 1'b0;
                    counter <= 6'd0;
                    load_idx <= 6'd0;
                    row <= 4'd0;
                    col <= 4'd0;
                    coeff_idx <= 4'd0;
                    accum <= 32'd0;
                    if (start) begin
                        state <= LOAD;
                    end
                end

                LOAD: begin
                    pixel_block[load_idx] <= pixel_in; // Store pixel
                    if (load_idx == 6'd63) begin
                        state <= ROW_DCT;
                    end else begin
                        load_idx <= load_idx + 1;
                    end
                end

                ROW_DCT: begin
                    if (coeff_idx < 8) begin
                        if (col < 8) begin
                            if (col == 0) accum <= 32'd0; // Reset accum before new calculation
                            accum <= accum + dct_coeff[coeff_idx][col] * $signed({1'b0, pixel_block[row*8 + col]});
                            col <= col + 1;
                        end else begin
                            temp_block[row*8 + coeff_idx] <= accum[25:10]; // Scale down by 1024
                            accum <= 32'd0;
                            col <= 4'd0;
                            coeff_idx <= coeff_idx + 1;
                        end
                    end else begin
                        coeff_idx <= 4'd0;
                        if (row == 7) begin
                            state <= COL_DCT;
                            row <= 4'd0;
                        end else begin
                            row <= row + 1;
                        end
                    end
                end

                COL_DCT: begin
                    if (coeff_idx < 8) begin
                        if (row < 8) begin
                            if (row == 0) accum <= 32'd0; // Reset accum before new calculation
                            accum <= accum + dct_coeff[coeff_idx][row] * temp_block[row*8 + col];
                            row <= row + 1;
                        end else begin
                            dct_block[coeff_idx*8 + col] <= accum[25:10]; // Scale down by 1024
                            accum <= 32'd0;
                            row <= 4'd0;
                            coeff_idx <= coeff_idx + 1;
                        end
                    end else begin
                        coeff_idx <= 4'd0;
                        if (col == 7) begin
                            state <= OUTPUT;
                        end else begin
                            col <= col + 1;
                        end
                    end
                end

                OUTPUT: begin
                    valid_out <= 1'b1;
                    dct_out <= dct_block[zigzag[counter]];
                    if (counter == 6'd63) begin
                        state <= DONE;
                    end else begin
                        counter <= counter + 1;
                    end
                end

                DONE: begin
                    valid_out <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule