library verilog;
use verilog.vl_types.all;
entity rgb2ycbcr is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        R               : in     vl_logic_vector(7 downto 0);
        G               : in     vl_logic_vector(7 downto 0);
        B               : in     vl_logic_vector(7 downto 0);
        Y               : out    vl_logic_vector(7 downto 0);
        Cb              : out    vl_logic_vector(7 downto 0);
        Cr              : out    vl_logic_vector(7 downto 0);
        done            : out    vl_logic
    );
end rgb2ycbcr;
