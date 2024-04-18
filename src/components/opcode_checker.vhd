-- Checks opcodes, and determines whether extra reads are needed or not!

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Opcode_Checker IS
    PORT (
        clk : IN STD_LOGIC;
        opcode : IN OPCODE; -- 5 bits
        extra_reads : OUT STD_LOGIC
    );
END ENTITY Opcode_Checker;

ARCHITECTURE Opcode_Checker_Arch OF Opcode_Checker IS
BEGIN
    PROCESS (clk)
    BEGIN
        -- for now LDM is the only instruction that requires extra reads
        CASE opcode IS
            WHEN OPCODE_LDM =>
                extra_reads <= '1';
            WHEN OTHERS =>
                extra_reads <= '0';
        END CASE;

    END PROCESS;

END Opcode_Checker_Arch;