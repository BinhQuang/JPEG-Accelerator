module level_shifter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        start,
    input  wire [7:0]  Y_in,
    input  wire [7:0]  Cb_in,
    input  wire [7:0]  Cr_in,
    output reg  signed [7:0]  Y_out,
    output reg  signed [7:0]  Cb_out,
    output reg  signed [7:0]  Cr_out,
    output reg         done
);

    reg [1:0] state;
    localparam IDLE = 2'd0,
               CALC = 2'd1,
               DONE = 2'd2;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            Y_out   <= 0;
            Cb_out  <= 0;
            Cr_out  <= 0;
            done    <= 0;
            state   <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    if (start)
                        state <= CALC;
                end

                CALC: begin
                    Y_out  <= $signed({1'b0, Y_in}) - 8'sd128;
                    Cb_out <= $signed({1'b0, Cb_in}) - 8'sd128;
                    Cr_out <= $signed({1'b0, Cr_in}) - 8'sd128;
                    state  <= DONE;
                end

                DONE: begin
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule
