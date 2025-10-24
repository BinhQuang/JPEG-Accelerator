library verilog;
use verilog.vl_types.all;
entity top_module_jpeg is
    generic(
        IMG_WIDTH       : integer := 64;
        IMG_HEIGHT      : integer := 64
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        R               : in     vl_logic_vector(7 downto 0);
        G               : in     vl_logic_vector(7 downto 0);
        B               : in     vl_logic_vector(7 downto 0);
        out_code        : out    vl_logic_vector(15 downto 0);
        out_len         : out    vl_logic_vector(3 downto 0);
        out_valid       : out    vl_logic;
        img_done        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IMG_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of IMG_HEIGHT : constant is 1;
end top_module_jpeg;
