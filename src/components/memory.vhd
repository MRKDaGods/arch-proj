-- Base memory

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Memory IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        address : IN MEM_ADDRESS;
        data_in : IN MEM_CELL;
        write_enable : IN STD_LOGIC;
        read_enable : IN STD_LOGIC;
        data_out : OUT MEM_CELL
    );
END Memory;

ARCHITECTURE Memory_Arch OF Memory IS
    TYPE MEMORY_ARRAY IS ARRAY (0 TO 4095) OF MEM_CELL;
    SIGNAL memory_arr : MEMORY_ARRAY;

BEGIN
    PROCESS (clk, reset)
    BEGIN
        -- reset memory
        IF reset = '1' THEN
            memory_arr <= (OTHERS => (OTHERS => '0'));
        ELSIF rising_edge(clk) THEN -- rising edge
            -- store into memory
            IF write_enable = '1' THEN
                memory_arr(to_integer(unsigned(address))) <= data_in;
            END IF;

            -- load from memory
            IF read_enable = '1' THEN
                data_out <= memory_arr(to_integer(unsigned(address)));
            END IF;
        END IF;
    END PROCESS;

END Memory_Arch;