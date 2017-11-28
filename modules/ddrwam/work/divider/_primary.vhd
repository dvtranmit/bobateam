library verilog;
use verilog.vl_types.all;
entity divider is
    generic(
        DELAY           : integer := 27000000
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        one_hz_enable   : out    vl_logic
    );
end divider;
