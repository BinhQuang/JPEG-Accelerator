library verilog;
use verilog.vl_types.all;
entity quantizer_1 is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        dct_in          : in     vl_logic_vector(15 downto 0);
        quant_out       : out    vl_logic_vector(15 downto 0);
        valid_out       : out    vl_logic;
        done            : out    vl_logic;
        q_monitor       : out    vl_logic_vector(7 downto 0)
    );
end quantizer_1;
