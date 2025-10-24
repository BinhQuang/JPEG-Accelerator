library verilog;
use verilog.vl_types.all;
entity block_splitter is
    generic(
        IMG_WIDTH       : integer := 64;
        IMG_HEIGHT      : integer := 64;
        BLOCK_SIZE      : integer := 8;
        TOTAL_BLOCKS    : vl_notype
    );
    port(
        clk             : in     vl_logic;
        rst_n           : in     vl_logic;
        start           : in     vl_logic;
        pixel_in        : in     vl_logic_vector(7 downto 0);
        valid_in        : in     vl_logic;
        pixel_out       : out    vl_logic_vector(7 downto 0);
        valid_out       : out    vl_logic;
        done            : out    vl_logic;
        img_done        : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of IMG_WIDTH : constant is 1;
    attribute mti_svvh_generic_type of IMG_HEIGHT : constant is 1;
    attribute mti_svvh_generic_type of BLOCK_SIZE : constant is 1;
    attribute mti_svvh_generic_type of TOTAL_BLOCKS : constant is 3;
end block_splitter;
