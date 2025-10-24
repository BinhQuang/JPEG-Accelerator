module bamodule (
    input wire clk,                   // Clock input
    input wire rst_n,                // Active-low reset
    input wire start,                // Start signal
    input wire [7:0] pixel_in,       // 8-bit unsigned pixel input
    output wire out_valid,           // Output valid signal
    output wire [15:0] out_code,     // Huffman code output
    output wire [3:0] out_len,       // Huffman code length
    output wire done                 // Done signal for 8x8 block
);

    // Internal wires for connecting modules
    wire signed [15:0] dct_out;      // DCT output to quantizer
    wire dct_valid;                  // DCT valid signal
    wire dct_done;                   // DCT done signal
    wire signed [15:0] quant_out;    // Quantizer output to entropy encoder
    wire quant_valid;                // Quantizer valid signal
    wire quant_done;                 // Quantizer done signal
    wire [5:0] quant_index;          // Index for entropy encoder
    wire [7:0] q_monitor;            // Quantization value monitor (optional)

    // Counter to generate index for entropy encoder
    reg [5:0] index_counter;

    // State machine for controlling pipeline
    reg [2:0] state;
    localparam IDLE = 3'd0,
               DCT = 3'd1,
               QUANT = 3'd2,
               ENTROPY = 3'd3,
               DONE = 3'd4;

    // FSM to control pipeline
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            index_counter <= 6'd0;
        end else begin
            case (state)
                IDLE: begin
                    index_counter <= 6'd0;
                    if (start) begin
                        state <= DCT;
                    end
                end

                DCT: begin
                    if (dct_done) begin
                        state <= QUANT;
                    end
                end

                QUANT: begin
                    if (quant_valid) begin
                        index_counter <= index_counter + 1;
                    end
                    if (quant_done) begin
                        state <= ENTROPY;
                    end
                end

                ENTROPY: begin
                    if (quant_done) begin
                        state <= DONE;
                    end
                end

                DONE: begin
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

    // Instantiate DCT module
    dct_2d dct_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .pixel_in(pixel_in),
        .dct_out(dct_out),
        .valid_out(dct_valid),
        .done(dct_done)
    );

    // Instantiate Quantizer module
    quantizer_1 quant_inst (
        .clk(clk),
        .rst_n(rst_n),
        .start(dct_done),
        .dct_in(dct_out),
        .quant_out(quant_out),
        .valid_out(quant_valid),
        .done(quant_done),
        .q_monitor(q_monitor)
    );

    // Instantiate Entropy Encoder module (modified for active-low reset)
    entropy_encoder entropy_inst (
        .clk(clk),
        .rst(~rst_n), // Convert active-low to active-high for entropy_encoder
        .in_valid(quant_valid),
        .in_index(index_counter),
        .in_coeff(quant_out),
        .out_valid(out_valid),
        .out_code(out_code),
        .out_len(out_len)
    );

    // Assign done signal
    assign done = quant_done;

endmodule