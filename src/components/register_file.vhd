-- Register file
-- 8 regs R0-R7

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Register_File IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        -- two writes
        write_enable_1 : IN STD_LOGIC;
        write_addr_1 : IN REG_SELECTOR;
        write_data_1 : IN REG32;

        write_enable_2 : IN STD_LOGIC;
        write_addr_2 : IN REG_SELECTOR;
        write_data_2 : IN REG32;

        -- two reads
        read_addr_1 : IN REG_SELECTOR;
        read_addr_2 : IN REG_SELECTOR;

        read_data_1 : OUT REG32;
        read_data_2 : OUT REG32
    );
END Register_File;

ARCHITECTURE Register_File_Arch OF Register_File IS
    TYPE reg_array IS ARRAY (0 TO 7) OF REG32;
    SIGNAL regs : reg_array;

BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            regs <= (OTHERS => (OTHERS => '0'));
        ELSIF rising_edge(clk) THEN
            -- should we write?
            IF write_enable_1 = '1' THEN
                regs(to_integer(unsigned(write_addr_1))) <= write_data_1;
            END IF;

            IF write_enable_2 = '1' THEN
                regs(to_integer(unsigned(write_addr_2))) <= write_data_2;
            END IF;
        END IF;
    END PROCESS;

    read_data_1 <= regs(to_integer(unsigned(read_addr_1)));
    read_data_2 <= regs(to_integer(unsigned(read_addr_2)));

END Register_File_Arch;