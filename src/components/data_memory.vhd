-- Data memory with 32 bit bus, means that we read 2 consecutive words at a time

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Data_Memory IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        address : IN MEM_ADDRESS;

        write_enable : IN STD_LOGIC;
        data_in : IN DATA_MEM_CELL; -- 32bit

        read_enable : IN STD_LOGIC;
        data_out : OUT DATA_MEM_CELL -- 32bit
    );
END Data_Memory;

ARCHITECTURE Data_Memory_Arch OF Data_Memory IS
    SIGNAL memory_arr : MEMORY_ARRAY;

BEGIN
    PROCESS (clk, reset)
    BEGIN
        -- reset memory
        IF reset = '1' THEN
            memory_arr <= (OTHERS => (OTHERS => '0'));
        ELSIF falling_edge(clk) THEN
            -- store into memory LITTLE ENDIAN
            IF write_enable = '1' THEN
                memory_arr(to_integer(unsigned(address))) <= data_in(15 DOWNTO 0);
                memory_arr(to_integer(unsigned(address)) + 1) <= data_in(31 DOWNTO 16);
            END IF;

            -- read from memory LITTLE ENDIAN
            IF read_enable = '1' THEN
                data_out(15 DOWNTO 0) <= memory_arr(to_integer(unsigned(address)));
                data_out(31 DOWNTO 16) <= memory_arr(to_integer(unsigned(address)) + 1);
            END IF;
        END IF;

    END PROCESS;
END Data_Memory_Arch;