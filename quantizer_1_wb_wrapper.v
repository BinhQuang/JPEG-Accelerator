module quantizer_1_wb_wrapper (
    // Standard Wishbone Interface
    input wire CLK_I,
    input wire RST_I,
    input wire [31:0] DAT_I,
    output reg [31:0] DAT_O,
    input wire [31:0] ADR_I,
    input wire WE_I,
    input wire STB_I,
    input wire CYC_I,
    input wire [3:0] SEL_I,
    output reg ACK_O,
    
    // Optional debug outputs
    output wire [15:0] dct_in_monitor,
    output wire [15:0] quant_out_monitor,
    output wire valid_out_monitor,
    output wire done_monitor
);

    // Register map (word addresses)
    localparam REG_DCT_IN    = 2'h0;  // Write-only
    localparam REG_QUANT_OUT = 2'h1;  // Read-only
    localparam REG_CONTROL   = 2'h2;  // Write-only
    localparam REG_STATUS    = 2'h3;  // Read-only

    // Internal signals
    reg start;
    wire done;
    wire valid_out;
    wire [7:0] q_monitor;
    reg signed [15:0] dct_in;
    wire signed [15:0] quant_out;
    
    // Byte enable mask
    wire [3:0] byte_sel = SEL_I;
    
    // Assign monitoring signals
    assign dct_in_monitor = dct_in;
    assign quant_out_monitor = quant_out;
    assign valid_out_monitor = valid_out;
    assign done_monitor = done;
    
    // Instantiate the quantizer module
    quantizer_1 quantizer (
        .clk(CLK_I),
        .rst_n(~RST_I),
        .start(start),
        .dct_in(dct_in),
        .quant_out(quant_out),
        .valid_out(valid_out),
        .done(done),
        .q_monitor(q_monitor)
    );
    
    // Wishbone interface FSM
    always @(posedge CLK_I or posedge RST_I) begin
        if (RST_I) begin
            DAT_O <= 32'h0;
            ACK_O <= 1'b0;
            dct_in <= 16'h0;
            start <= 1'b0;
        end else begin
            // Default values
            ACK_O <= 1'b0;
            start <= 1'b0;
            
            // Handle Wishbone transactions
            if (CYC_I && STB_I && !ACK_O) begin
                ACK_O <= 1'b1;  // Acknowledge all requests
                
                if (WE_I) begin
                    // Write operation
                    case (ADR_I[3:2])
                        REG_DCT_IN: begin
                            // Handle byte selects for DCT input
                            if (byte_sel[0]) dct_in[7:0] <= DAT_I[7:0];
                            if (byte_sel[1]) dct_in[15:8] <= DAT_I[15:8];
                        end
                        REG_CONTROL: begin
                            // Start control (only LSB matters)
                            if (byte_sel[0]) start <= DAT_I[0];
                        end
                    endcase
                end else begin
                    // Read operation
                    case (ADR_I[3:2])
                        REG_QUANT_OUT: begin
                            DAT_O <= {16'h0, quant_out};
                        end
                        REG_STATUS: begin
                            DAT_O <= {30'h0, done, valid_out};
                        end
                        default: begin
                            DAT_O <= 32'h0;
                        end
                    endcase
                end
            end
        end
    end
    
    // Error checking (optional)
    always @(posedge CLK_I) begin
        if (CYC_I && STB_I && !ACK_O) begin
            // Check for unsupported operations
            if (ADR_I[1:0] != 2'b00) begin
                $display("Warning: Unaligned access at address %h", ADR_I);
            end
        end
    end
endmodule