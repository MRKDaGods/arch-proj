-- Checks opcodes, and determines whether extra reads are needed or not!

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Opcode_Checker IS
    PORT (
        opcode : IN OPCODE; -- 5 bits
        extra_reads : OUT STD_LOGIC
    );
END ENTITY Opcode_Checker;

ARCHITECTURE Opcode_Checker_Arch OF Opcode_Checker IS
BEGIN
    WITH opcode SELECT
        extra_reads <=
        '1' WHEN OPCODE_LDM,
        '0' WHEN OTHERS;

END Opcode_Checker_Arch;