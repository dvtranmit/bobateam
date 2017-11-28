library verilog;
use verilog.vl_types.all;
entity random is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        r               : out    vl_logic_vector(2 downto 0)
    );
end random;
