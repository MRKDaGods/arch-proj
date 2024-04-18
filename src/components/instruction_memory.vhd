-- Instruction memory 16bit bus

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Instruction_Memory IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        pc : IN MEM_ADDRESS;
        data : OUT MEM_CELL -- output data 16 bit
    );
END Instruction_Memory;

ARCHITECTURE Instruction_Memory_Arch OF Instruction_Memory IS
    SIGNAL memory_arr : MEMORY_ARRAY;

BEGIN
    PROCESS (clk, reset)
    BEGIN
        -- reset memory
        IF reset = '1' THEN
            memory_arr <= (OTHERS => (OTHERS => '0'));
        END IF;
    END PROCESS;

    data <= memory_arr(to_integer(unsigned(pc)));

END Instruction_Memory_Arch;