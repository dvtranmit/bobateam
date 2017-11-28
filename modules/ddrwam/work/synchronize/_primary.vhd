library verilog;
use verilog.vl_types.all;
entity synchronize is
    generic(
        NSYNC           : integer := 2
    );
    port(
        clk             : in     vl_logic;
        \in\            : in     vl_logic;
        \out\           : out    vl_logic
    );
end synchronize;
