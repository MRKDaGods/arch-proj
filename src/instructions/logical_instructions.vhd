-- Logical instructions here
-- NOT, AND, OR, XOR

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Logical_Instructions IS
    PORT (
        opcode : IN OPCODE; -- opcode of the instruction
        operand_1, operand_2 : IN REG32; -- first & second operands
        result : OUT REG32 -- result of the operation
    );
END Logical_Instructions;

ARCHITECTURE Logical_Instructions_Arch OF Logical_Instructions IS
BEGIN
    WITH opcode SELECT
        result <=

        -- NOT
        NOT operand_1 WHEN OPCODE_NOT,

        -- AND
        operand_1 AND operand_2 WHEN OPCODE_AND,

        -- OR
        operand_1 OR operand_2 WHEN OPCODE_OR,

        -- XOR
        operand_1 XOR operand_2 WHEN OPCODE_XOR,

        -- default
        (OTHERS => 'X') WHEN OTHERS;

END Logical_Instructions_Arch;