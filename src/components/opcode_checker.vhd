-- Checks opcodes, and determines whether extra reads are needed or not!

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Opcode_Checker IS
    PORT (
        reserved_bit : IN STD_LOGIC; -- res in instruction
        extra_reads : OUT STD_LOGIC
    );
END ENTITY Opcode_Checker;

ARCHITECTURE Opcode_Checker_Arch OF Opcode_Checker IS
BEGIN
    -- reserved is equal to 1 for 32bit instructions
    extra_reads <= reserved_bit;

END Opcode_Checker_Arch;