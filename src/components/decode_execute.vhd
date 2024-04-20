-- Decode/Execute register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Decode_Execute IS
    PORT (
        -- input
        clk : IN STD_LOGIC;

        -- fetch/decode
        write_address : IN REG_SELECTOR;
        write_enable : IN STD_LOGIC;

        -- reg file
        read_data_1 : IN REG32;
        read_data_2 : IN REG32;

        -- output
        out_write_address : OUT REG_SELECTOR;
        out_write_enable : OUT STD_LOGIC;

        out_read_data_1 : OUT REG32;
        out_read_data_2 : OUT REG32
    );
END Decode_Execute;

ARCHITECTURE Decode_Execute_Arch OF Decode_Execute IS
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            out_write_address <= write_address;
            out_write_enable <= write_enable;
            out_read_data_1 <= read_data_1;
            out_read_data_2 <= read_data_2;
        END IF;
    END PROCESS;

END Decode_Execute_Arch;