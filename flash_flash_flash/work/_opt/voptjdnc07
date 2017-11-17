library verilog;
use verilog.vl_types.all;
entity flash_manager is
    generic(
        MODE_IDLE       : integer := 0;
        MODE_INIT       : integer := 1;
        MODE_WRITE      : integer := 2;
        MODE_READ       : integer := 3;
        HOME            : integer := 0;
        MEM_INIT        : integer := 1;
        MEM_WAIT        : integer := 2;
        WRITE_READY     : integer := 3;
        WRITE_WAIT      : integer := 4;
        READ_READY      : integer := 5;
        READ_WAIT       : integer := 6
    );
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        dots            : out    vl_logic_vector(639 downto 0);
        writemode       : in     vl_logic;
        wdata           : in     vl_logic_vector(15 downto 0);
        dowrite         : in     vl_logic;
        raddr           : in     vl_logic_vector(22 downto 0);
        frdata          : out    vl_logic_vector(15 downto 0);
        doread          : in     vl_logic;
        busy            : out    vl_logic;
        flash_data      : inout  vl_logic_vector(15 downto 0);
        flash_address   : out    vl_logic_vector(23 downto 0);
        flash_ce_b      : out    vl_logic;
        flash_oe_b      : out    vl_logic;
        flash_we_b      : out    vl_logic;
        flash_reset_b   : out    vl_logic;
        flash_sts       : in     vl_logic;
        flash_byte_b    : out    vl_logic;
        fsmstate        : out    vl_logic_vector(11 downto 0)
    );
end flash_manager;
