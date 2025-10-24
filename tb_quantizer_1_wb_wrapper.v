`timescale 1ns/1ps

module tb_quantizer_1_wb_wrapper();

    // Chuẩn Wishbone signals
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
    
    // Debug signals
    wire [15:0] dct_in_monitor;
    wire [15:0] quant_out_monitor;
    wire valid_out_monitor;
    wire done_monitor;
    
    // Test variables
    integer i;
    reg [31:0] read_data;
    reg [15:0] expected_values [0:63];
    reg [15:0] test_pattern [0:63];
    
    // Khởi tạo DUT
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
        .ACK_O(ACK_O),
        .dct_in_monitor(dct_in_monitor),
        .quant_out_monitor(quant_out_monitor),
        .valid_out_monitor(valid_out_monitor),
        .done_monitor(done_monitor)
    );
    
    // Clock generation (100MHz)
    initial begin
        CLK_I = 0;
        forever #5 CLK_I = ~CLK_I;
    end
    
    // Khởi tạo test pattern và expected values
    initial begin
        // Tạo test pattern từ -2048 đến 2047 với bước 64
        for (i = 0; i < 64; i = i + 1) begin
            test_pattern[i] = (i * 64) - 2048;
            
            // Tính toán giá trị mong đợi (làm tròn)
            case (i)
                0: expected_values[i] = test_pattern[i] / 16;
                1: expected_values[i] = test_pattern[i] / 11;
                2: expected_values[i] = test_pattern[i] / 10;
                // ... (thêm các trường hợp khác theo quantization table)
                default: expected_values[i] = 0;
            endcase
        end
    end
    
    // Task ghi Wishbone
    task wb_write;
        input [31:0] address;
        input [31:0] data;
        input [3:0] sel;
        begin
            @(posedge CLK_I);
            ADR_I = address;
            DAT_I = data;
            WE_I = 1'b1;
            STB_I = 1'b1;
            CYC_I = 1'b1;
            SEL_I = sel;
            @(posedge CLK_I);
            while (!ACK_O) @(posedge CLK_I);
            STB_I = 1'b0;
            CYC_I = 1'b0;
            #10;
        end
    endtask
    
    // Task đọc Wishbone
    task wb_read;
        input [31:0] address;
        output [31:0] data;
        begin
            @(posedge CLK_I);
            ADR_I = address;
            WE_I = 1'b0;
            STB_I = 1'b1;
            CYC_I = 1'b1;
            SEL_I = 4'b1111;
            @(posedge CLK_I);
            while (!ACK_O) @(posedge CLK_I);
            data = DAT_O;
            STB_I = 1'b0;
            CYC_I = 1'b0;
            #10;
        end
    endtask
    
    // Main test sequence
    initial begin
        // Khởi tạo giá trị
        RST_I = 1'b1;
        DAT_I = 32'h0;
        ADR_I = 32'h0;
        WE_I = 1'b0;
        STB_I = 1'b0;
        CYC_I = 1'b0;
        SEL_I = 4'b0;
        
        // Reset hệ thống
        #20;
        RST_I = 1'b0;
        #20;
        
        $display("Bắt đầu kiểm tra Quantizer với giao diện Wishbone");
        
        // Ghi từng giá trị DCT và kiểm tra kết quả
        for (i = 0; i < 64; i = i + 1) begin
            // Ghi giá trị DCT (16-bit)
            wb_write(32'h00, {16'h0, test_pattern[i]}, 4'b0011);
            
            // Kích hoạt xử lý
            wb_write(32'h08, 32'h00000001, 4'b0001);
            
            // Chờ valid output
            while (!valid_out_monitor) @(posedge CLK_I);
            
            // Đọc kết quả
            wb_read(32'h04, read_data);
            
            // Kiểm tra kết quả
            if (read_data[15:0] !== expected_values[i]) begin
                $display("LỖI tại index %0d: Input=%0d, Mong đợi=%0d, Nhận được=%0d", 
                        i, test_pattern[i], expected_values[i], read_data[15:0]);
            end else begin
                $display("Thành công tại index %0d: Input=%0d, Output=%0d", 
                        i, test_pattern[i], read_data[15:0]);
            end
            
            // Kiểm tra tín hiệu done khi hoàn thành khối
            if (i == 63) begin
                while (!done_monitor) @(posedge CLK_I);
                $display("Hoàn thành xử lý khối 8x8");
            end
        end
        
        // Kiểm tra đọc status register
        wb_read(32'h0C, read_data);
        $display("Status register: done=%b, valid=%b", read_data[1], read_data[0]);
        
        // Kết thúc kiểm tra
        #100;
        $display("Kiểm tra hoàn tất");
        $finish;
    end
    
    // Ghi waveform
    initial begin
        $dumpfile("quantizer_wb_tb.vcd");
        $dumpvars(0, tb_quantizer_1_wb);
    end
endmodule