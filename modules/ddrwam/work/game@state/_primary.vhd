library verilog;
use verilog.vl_types.all;
entity gameState is
    port(
        clk             : in     vl_logic;
        misstep         : in     vl_logic;
        whacked         : in     vl_logic;
        start           : in     vl_logic;
        reset           : in     vl_logic;
        request_mole    : in     vl_logic;
        expired         : in     vl_logic;
        random_mole_location: in     vl_logic_vector(2 downto 0);
        start_timer     : out    vl_logic;
        timer_value     : out    vl_logic_vector(3 downto 0);
        display_state   : out    vl_logic_vector(3 downto 0);
        mole_location   : out    vl_logic_vector(2 downto 0);
        lives           : out    vl_logic_vector(1 downto 0);
        score           : out    vl_logic_vector(7 downto 0)
    );
end gameState;
