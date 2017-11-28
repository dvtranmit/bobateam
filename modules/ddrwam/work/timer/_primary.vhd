library verilog;
use verilog.vl_types.all;
entity timer is
    generic(
        IDLE            : integer := 0;
        COUNTING        : integer := 1;
        \EXPIRED\       : integer := 2
    );
    port(
        clk             : in     vl_logic;
        start_timer     : in     vl_logic;
        one_hz_enable   : in     vl_logic;
        timer_value     : in     vl_logic_vector(3 downto 0);
        expired         : out    vl_logic;
        displayed_counter: out    vl_logic_vector(3 downto 0)
    );
end timer;
