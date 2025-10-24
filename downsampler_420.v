module downsampler_420(
    input clk,
    input rst_n,
    input [7:0] cb_in,
    input [7:0] cr_in,
    input valid_in,
    output reg [7:0] cb_out,
    output reg [7:0] cr_out,
    output reg valid_out
);
    reg [1:0] pixel_count;
    reg [7:0] cb_sum, cr_sum;
    reg [1:0] valid_count;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_count <= 0;
            cb_sum <= 0;
            cr_sum <= 0;
            cb_out <= 0;
            cr_out <= 0;
            valid_out <= 0;
            valid_count <= 0;
        end else begin
            valid_out <= 0;
            
            if (valid_in) begin
                // Accumulate samples
                cb_sum <= cb_sum + cb_in;
                cr_sum <= cr_sum + cr_in;
                pixel_count <= pixel_count + 1;
                valid_count <= valid_count + 1;
                
                // Every 4 pixels, output average
                if (pixel_count == 3) begin
                    cb_out <= cb_sum >> 2;  // Divide by 4
                    cr_out <= cr_sum >> 2;
                    valid_out <= 1;
                    cb_sum <= 0;
                    cr_sum <= 0;
                    pixel_count <= 0;
                end
            end
        end
    end
endmodule