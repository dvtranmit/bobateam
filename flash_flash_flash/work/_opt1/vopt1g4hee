library verilog;
use verilog.vl_types.all;
entity flash_int is
    generic(
        access_cycles   : integer := 5;
        reset_assert_cycles: integer := 1000;
        reset_recovery_cycles: integer := 30
    );
    port(
        reset           : in     vl_logic;
        clock           : in     vl_logic;
        op              : in     vl_logic_vector(1 downto 0);
        address         : in     vl_logic_vector(22 downto 0);
        wdata           : in     vl_logic_vector(15 downto 0);
        rdata           : out    vl_logic_vector(15 downto 0);
        busy            : out    vl_logic;
        flash_data      : inout  vl_logic_vector(15 downto 0);
        flash_address   : out    vl_logic_vector(23 downto 0);
        flash_ce_b      : out    vl_logic;
        flash_oe_b      : out    vl_logic;
        flash_we_b      : out    vl_logic;
        flash_reset_b   : out    vl_logic;
        flash_sts       : in     vl_logic;
        flash_byte_b    : out    vl_logic
    );
end flash_int;
