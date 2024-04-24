-- Fetch/Decode register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Fetch_Decode IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        raw_instruction : IN MEM_CELL; -- 16 bit from instr mem
        extra_reads : IN STD_LOGIC; -- from opcode checker
        out_instruction : OUT FETCHED_INSTRUCTION -- 32 bit
    );
END Fetch_Decode;

ARCHITECTURE Fetch_Decode_Arch OF Fetch_Decode IS
BEGIN
    PROCESS (clk, reset)
        VARIABLE instruction_buffer : MEM_CELL := (OTHERS => '0');
        VARIABLE has_buffer : BOOLEAN := FALSE;
    BEGIN

        IF reset = '1' THEN
            out_instruction <= (OTHERS => '0');
            instruction_buffer := (OTHERS => '0');
            has_buffer := FALSE;
        ELSIF rising_edge(clk) THEN
            -- read first 16 bits

            IF has_buffer THEN
                out_instruction <= raw_instruction & instruction_buffer;
                has_buffer := FALSE;
            ELSE
                out_instruction <= (15 downto 0 => '0') & raw_instruction;
            END IF;

            -- do we need a second read? check falling edge
        ELSIF falling_edge(clk) AND extra_reads = '1' THEN
            -- read second 16 bits
            -- out_instruction(31 DOWNTO 16) <= raw_instruction;

            instruction_buffer := raw_instruction;
            has_buffer := TRUE;
        END IF;

    END PROCESS;

END Fetch_Decode_Arch;