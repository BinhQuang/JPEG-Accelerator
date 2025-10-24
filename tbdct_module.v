`timescale 1ns / 1ps

module tbdct_module;

  reg CLK_I;
  reg RST_I;
  reg [31:0] DAT_I;
  wire [31:0] DAT_O;
  reg [31:0] ADR_I;
  reg WE_I, STB_I, CYC_I;
  reg [3:0] SEL_I;
  wire ACK_O;

  // Instantiate the DUT (device under test)
  dct_module dut (
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

  // Clock generation (improved)
  initial begin
    CLK_I = 0;
    forever #5 CLK_I = ~CLK_I; // Toggle clock every 5ns (period = 10ns)
  end

  integer i, j;

  initial begin
    // Initialize
    RST_I = 1;
    DAT_I = 0;
    ADR_I = 0;
    WE_I = 0;
    STB_I = 0;
    CYC_I = 0;
    SEL_I = 4'b1111;

    // Wait 2 clock cycles then release reset
    #20;
    RST_I = 0;

    // Write input matrix: for simplicity, input[i][j] = i*8 + j
    for (i = 0; i < 8; i = i + 1) begin
      for (j = 0; j < 8; j = j + 1) begin
        write_word(i*8 + j, (i*8 + j));
      end
    end

    // Start DCT (write to control register - address 64)
    write_word(64, 32'h0000_0001);  // any value to trigger start

    // Wait for DCT to complete (simulate long enough)
    #1000;

    // Read output matrix
    $display("===== DCT 2D Output Matrix =====");
    for (i = 0; i < 8; i = i + 1) begin
      for (j = 0; j < 8; j = j + 1) begin
        read_word(i*8 + j);
        $write("%d\t", $signed(DAT_O));
        #10;
      end
      $write("\n");
    end

    $finish;
  end

  // Write Wishbone transaction
  task write_word(input [31:0] addr, input [31:0] data);
  begin
    @(posedge CLK_I);
    ADR_I = addr;
    DAT_I = data;
    WE_I = 1;
    STB_I = 1;
    CYC_I = 1;
    @(posedge CLK_I);
    wait(ACK_O);
    @(posedge CLK_I);
    WE_I = 0;
    STB_I = 0;
    CYC_I = 0;
  end
  endtask

  // Read Wishbone transaction
  task read_word(input [31:0] addr);
  begin
    @(posedge CLK_I);
    ADR_I = addr;
    WE_I = 0;
    STB_I = 1;
    CYC_I = 1;
    @(posedge CLK_I);
    wait(ACK_O);
    @(posedge CLK_I);
    STB_I = 0;
    CYC_I = 0;
  end
  endtask

endmodule