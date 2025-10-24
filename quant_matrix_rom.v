module quant_matrix_rom (
    input  [5:0] addr,       
    output reg [7:0] q_val 
);

    always @(*) begin
        case (addr)
            6'd0:  q_val = 8'd16;  6'd1:  q_val = 8'd11;  6'd2:  q_val = 8'd10;  6'd3:  q_val = 8'd16;
            6'd4:  q_val = 8'd24;  6'd5:  q_val = 8'd40;  6'd6:  q_val = 8'd51;  6'd7:  q_val = 8'd61;
            6'd8:  q_val = 8'd12;  6'd9:  q_val = 8'd12;  6'd10: q_val = 8'd14;  6'd11: q_val = 8'd19;
            6'd12: q_val = 8'd26;  6'd13: q_val = 8'd58;  6'd14: q_val = 8'd60;  6'd15: q_val = 8'd55;
            6'd16: q_val = 8'd14;  6'd17: q_val = 8'd13;  6'd18: q_val = 8'd16;  6'd19: q_val = 8'd24;
            6'd20: q_val = 8'd40;  6'd21: q_val = 8'd57;  6'd22: q_val = 8'd69;  6'd23: q_val = 8'd56;
            6'd24: q_val = 8'd14;  6'd25: q_val = 8'd17;  6'd26: q_val = 8'd22;  6'd27: q_val = 8'd29;
            6'd28: q_val = 8'd51;  6'd29: q_val = 8'd87;  6'd30: q_val = 8'd80;  6'd31: q_val = 8'd62;
            6'd32: q_val = 8'd18;  6'd33: q_val = 8'd22;  6'd34: q_val = 8'd37;  6'd35: q_val = 8'd56;
            6'd36: q_val = 8'd68;  6'd37: q_val = 8'd109; 6'd38: q_val = 8'd103; 6'd39: q_val = 8'd77;
            6'd40: q_val = 8'd24;  6'd41: q_val = 8'd35;  6'd42: q_val = 8'd55;  6'd43: q_val = 8'd64;
            6'd44: q_val = 8'd81;  6'd45: q_val = 8'd104; 6'd46: q_val = 8'd113; 6'd47: q_val = 8'd92;
            6'd48: q_val = 8'd49;  6'd49: q_val = 8'd64;  6'd50: q_val = 8'd78;  6'd51: q_val = 8'd87;
            6'd52: q_val = 8'd103; 6'd53: q_val = 8'd121; 6'd54: q_val = 8'd120; 6'd55: q_val = 8'd101;
            6'd56: q_val = 8'd72;  6'd57: q_val = 8'd92;  6'd58: q_val = 8'd95;  6'd59: q_val = 8'd98;
            6'd60: q_val = 8'd112; 6'd61: q_val = 8'd100; 6'd62: q_val = 8'd103; 6'd63: q_val = 8'd99;
            default: q_val = 8'd0;
        endcase
    end

endmodule
