library verilog;
use verilog.vl_types.all;
entity dct_2d is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        pixel_in        : in     vl_logic_vector(7 downto 0);
        dct_out         : out    vl_logic_vector(15 downto 0);
        valid_out       : out    vl_logic;
        done            : out    vl_logic
    );
end dct_2d;
