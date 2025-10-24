module top_quantizer (
    input clk,
    input rst,
    input [5:0] addr,                
    input signed [11:0] dct_in,
    output signed [7:0] quantized_out
);

    wire [7:0] q_value;

    quant_matrix_rom q_rom (
        .addr(addr),
        .q_val(q_value)
    );

    quantizer q_block (
        .clk(clk),
        .rst(rst),
        .dct_in(dct_in),
        .q_val(q_value),
        .q_out(quantized_out)
    );

endmodule
