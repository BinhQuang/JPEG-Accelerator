`timescale 10ns/1ns

module tb_jpeg_quantizer_wb();

    reg CLK_I;
    reg RST_I;
    reg [31:0] DAT_I;
    wire [31:0] DAT_O;
    reg [31:0] ADR_I;
    reg WE_I;
    reg STB_I;
    reg CYC_I;
    reg [3:0] SEL_I;
    wire ACK_O;

    reg [7:0] q_result;

    quantizer_1_wb_wrapper dut (
        .CLK_I(CLK_I),
        .RST_I(RST_I),
        .DAT_I(DAT_I),
        .DAT_O(DAT_O),
        .ADR_I(ADR_I),
        .WE_I(WE_I),
        .STB_I(STB_I),
        .CYC_I(CYC_I),
        .SEL_I(SEL_I),
        .ACK_O(ACK_O)
    );

    initial begin
        CLK_I = 0;
        forever #60 CLK_I = ~CLK_I;
    end

    initial begin
        RST_I = 1;
        #240; 
        RST_I = 0;
    end

    task write_dct(input [11:0] dct, input [5:0] addr);
        begin
            @(negedge CLK_I);
            WE_I    = 1;
            STB_I   = 1;
            CYC_I   = 1;
            SEL_I   = 4'b1111;
            DAT_I   = {20'b0, dct};
            ADR_I   = addr;
            @(posedge CLK_I);
            wait (ACK_O);
            @(negedge CLK_I);
            WE_I  = 0;
            STB_I = 0;
            CYC_I = 0;
        end
    endtask

    task read_q(output [7:0] q_val);
        begin
            @(negedge CLK_I);
            WE_I    = 0;
            STB_I   = 1;
            CYC_I   = 1;
            SEL_I   = 4'b1111;
            @(posedge CLK_I);
            wait (ACK_O);
            @(negedge CLK_I);
            q_val = DAT_O[7:0];
            STB_I = 0;
            CYC_I = 0;
        end
    endtask

    initial begin
        @(negedge RST_I);
        @(posedge CLK_I);

        $display("Start JPEG Quantizer WB testbench");

        write_dct(12'd100, 6'd0);
        @(posedge CLK_I);
        read_q(q_result);
        $display("Quantized Output [DCT=100, Q=16] => %0d", q_result); 

        write_dct(-12'sd80, 6'd7);
        @(posedge CLK_I);
        read_q(q_result);
        $display("Quantized Output [DCT=-80, Q=61] => %0d", q_result); 

        write_dct(12'd255, 6'd14);
        @(posedge CLK_I);
        read_q(q_result);
        $display("Quantized Output [DCT=255, Q=60] => %0d", q_result); 

        #240; 
        $display("Test complete.");
        $finish;
    end

endmodule
