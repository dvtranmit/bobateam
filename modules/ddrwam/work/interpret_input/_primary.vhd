library verilog;
use verilog.vl_types.all;
entity interpret_input is
    port(
        clk             : in     vl_logic;
        upleft          : in     vl_logic;
        up              : in     vl_logic;
        upright         : in     vl_logic;
        left            : in     vl_logic;
        right           : in     vl_logic;
        downleft        : in     vl_logic;
        down            : in     vl_logic;
        downright       : in     vl_logic;
        reset           : in     vl_logic;
        mole_location   : in     vl_logic_vector(2 downto 0);
        misstep         : out    vl_logic;
        whacked         : out    vl_logic
    );
end interpret_input;
