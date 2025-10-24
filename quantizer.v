module quantizer (
    input clk,
    input rst,
    input signed [11:0] dct_in,      
    input [7:0] q_val,               
    output reg signed [7:0] q_out     
);
    reg signed [13:0] temp; 
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            q_out <= 0;
        end else begin
            if (dct_in >= 0)
                temp = dct_in + (q_val >> 1);  
            else
                temp = dct_in - (q_val >> 1);  
            
            q_out <= temp / q_val;             
        end
    end
endmodule
