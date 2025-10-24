library verilog;
use verilog.vl_types.all;
entity entropy_encoder is
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        in_valid        : in     vl_logic;
        in_index        : in     vl_logic_vector(5 downto 0);
        in_coeff        : in     vl_logic_vector(15 downto 0);
        out_valid       : out    vl_logic;
        out_code        : out    vl_logic_vector(15 downto 0);
        out_len         : out    vl_logic_vector(3 downto 0)
    );
end entropy_encoder;
