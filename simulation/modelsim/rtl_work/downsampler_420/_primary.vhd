library verilog;
use verilog.vl_types.all;
entity downsampler_420 is
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        cb_in           : in     vl_logic_vector(7 downto 0);
        cr_in           : in     vl_logic_vector(7 downto 0);
        valid_in        : in     vl_logic;
        cb_out          : out    vl_logic_vector(7 downto 0);
        cr_out          : out    vl_logic_vector(7 downto 0);
        valid_out       : out    vl_logic
    );
end downsampler_420;
