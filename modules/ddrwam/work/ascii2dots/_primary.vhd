library verilog;
use verilog.vl_types.all;
entity ascii2dots is
    port(
        ascii_in        : in     vl_logic_vector(7 downto 0);
        char_dots       : out    vl_logic_vector(39 downto 0)
    );
end ascii2dots;
