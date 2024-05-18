-- Data memory with 32 bit bus, means that we read 2 consecutive words at a time

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Data_Memory IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        address : IN MEM_ADDRESS;
        signal_bus : IN SIGBUS;

        write_enable : IN STD_LOGIC;
        data_in : IN DATA_MEM_CELL; -- 32bit

        read_enable : IN STD_LOGIC;
        data_out : OUT DATA_MEM_CELL; -- 32bit
        exception : OUT STD_LOGIC -- exception signal
    );
END Data_Memory;

ARCHITECTURE Data_Memory_Arch OF Data_Memory IS
    SIGNAL memory_arr : MEMORY_ARRAY;
    SIGNAL protection_arr : STD_LOGIC_VECTOR(4095 DOWNTO 0) := (OTHERS => '0');

BEGIN
    PROCESS (clk, reset)
        VARIABLE exc : STD_LOGIC := '0';
    BEGIN
        exc := '0';

        -- reset memory
        IF reset = '1' THEN
            memory_arr <= (OTHERS => (OTHERS => '0'));
            protection_arr <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            IF signal_bus(SIGBUG_OP_PROTECT) = '1' THEN
                IF unsigned(address) > 4095 THEN
                    exc := '1';
                ELSE
                    protection_arr(to_integer(unsigned(address))) <= '1';
                END IF;
            END IF;

            IF signal_bus(SIGBUS_OP_FREE) = '1' THEN
                IF unsigned(address) > 4095 THEN
                    exc := '1';
                ELSE
                    protection_arr(to_integer(unsigned(address))) <= '0';
                END IF;
            END IF;
        ELSIF falling_edge(clk) THEN
            -- store into memory LITTLE ENDIAN
            IF write_enable = '1' THEN
                IF unsigned(address) <= 4094
                    AND protection_arr(to_integer(unsigned(address))) = '0'
                    AND protection_arr(to_integer(unsigned(address)) + 1) = '0' THEN
                    memory_arr(to_integer(unsigned(address))) <= data_in(15 DOWNTO 0);
                    memory_arr(to_integer(unsigned(address)) + 1) <= data_in(31 DOWNTO 16);
                ELSE
                    -- REPORT "Memory error" & to_string(address) SEVERITY ERROR;
                    exc := '1';
                END IF;
            END IF;

            -- read from memory LITTLE ENDIAN
            IF read_enable = '1' THEN
                IF unsigned(address) > 4094 THEN
                    exc := '1';
                ELSE
                    data_out(15 DOWNTO 0) <= memory_arr(to_integer(unsigned(address)));
                    data_out(31 DOWNTO 16) <= memory_arr(to_integer(unsigned(address)) + 1);
                END IF;
            END IF;
        END IF;

        exception <= exc;

    END PROCESS;
END Data_Memory_Arch;