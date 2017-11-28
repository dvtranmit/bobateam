library verilog;
use verilog.vl_types.all;
entity mole is
    generic(
        COUNTING        : integer := 1;
        MOLE            : integer := 0
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        one_hz_enable   : in     vl_logic;
        music_address   : in     vl_logic_vector(22 downto 0);
        request_mole    : out    vl_logic
    );
end mole;
