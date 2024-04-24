-- Arithmetic instructions here

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Arithmetic_Instructions IS
    PORT (
        opcode : IN OPCODE; -- opcode of the instruction
        operand_1 : IN REG32;
        operand_2 : IN SIGNED(31 DOWNTO 0); -- first & second operands
        result : OUT REG32 -- result of the operation
    );
END Arithmetic_Instructions;

ARCHITECTURE Arithmetic_Instructions_Arch OF Arithmetic_Instructions IS
    SIGNAL op_1 : signed(31 DOWNTO 0); -- our signed operands
    SIGNAL op_2 : signed(31 DOWNTO 0);
    SIGNAL neg_operand_2 : signed(31 DOWNTO 0); -- negated operand_2

BEGIN
    -- single adder for all arithmetic operations
    -- op_1 is always operand_1 for most instructions

    op_1 <=
        (OTHERS => '0') WHEN opcode = OPCODE_NEG ELSE
        signed(operand_1);

    -- we negate operand_2 alot
    neg_operand_2 <= -operand_2;

    WITH opcode SELECT
        op_2 <=
        - signed(operand_1) WHEN OPCODE_NEG, -- -R1
        to_signed(1, 32) WHEN OPCODE_INC, -- R1 + 1
        to_signed(-1, 32) WHEN OPCODE_DEC, -- R1 - 1
        neg_operand_2 WHEN OPCODE_SUB, -- R1 - R2
        neg_operand_2 WHEN OPCODE_SUBI, -- R1 - imm
        neg_operand_2 WHEN OPCODE_CMP, -- R1 - R2

        operand_2 WHEN OTHERS;

    -- add the two operands
    result <= STD_LOGIC_VECTOR(op_1 + op_2);

END Arithmetic_Instructions_Arch;