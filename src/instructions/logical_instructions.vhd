-- Logical instructions here
-- NOT, OR, CMP, DEC

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Logical_Instructions IS
    PORT (
        operand_1, operand_2 : IN REG32; -- first & second operands
        alu_control : IN ALU_CS_LOGICAL; -- control signal for ALU
        result : OUT REG32 -- result of the operation
    );
END Logical_Instructions;

ARCHITECTURE Logical_Instructions_Arch OF Logical_Instructions IS
BEGIN
    WITH alu_control SELECT
        result <=

        -- NOT
        NOT operand_1 WHEN ALU_CS_LOGICAL_NOT,

        -- OR
        operand_1 OR operand_2 WHEN ALU_CS_LOGICAL_OR,

        -- DEC
        STD_LOGIC_VECTOR(unsigned(operand_1) - 1) WHEN ALU_CS_LOGICAL_DEC,

        -- CMP
        STD_LOGIC_VECTOR(unsigned(operand_1) - unsigned(operand_2)) WHEN ALU_CS_LOGICAL_CMP,

        -- default
        (OTHERS => 'X') WHEN OTHERS;

END Logical_Instructions_Arch;