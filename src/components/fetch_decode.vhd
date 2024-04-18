-- Fetch/Decode register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Fetch_Decode IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        raw_instruction : IN MEM_CELL; -- 16 bit from instr mem
        extra_reads : IN STD_LOGIC; -- from opcode checker
        fetched_instruction : OUT FETCHED_INSTRUCTION -- 32 bit
    );
END Fetch_Decode;

ARCHITECTURE Fetch_Decode_Arch OF Fetch_Decode IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            fetched_instruction <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- read first 16 bits
            fetched_instruction <= (15 downto 0 => '0') & raw_instruction;

            -- do we need a second read? check falling edge
        ELSIF falling_edge(clk) AND extra_reads = '1' THEN
            -- read second 16 bits
            fetched_instruction(31 DOWNTO 16) <= raw_instruction;
        END IF;

    END PROCESS;

END Fetch_Decode_Arch;