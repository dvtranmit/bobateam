library verilog;
use verilog.vl_types.all;
entity display_string is
    port(
        reset           : in     vl_logic;
        clock_27mhz     : in     vl_logic;
        string_data     : in     vl_logic_vector(127 downto 0);
        disp_blank      : out    vl_logic;
        disp_clock      : out    vl_logic;
        disp_data_out   : out    vl_logic;
        disp_rs         : out    vl_logic;
        disp_ce_b       : out    vl_logic;
        disp_reset_b    : out    vl_logic
    );
end display_string;
