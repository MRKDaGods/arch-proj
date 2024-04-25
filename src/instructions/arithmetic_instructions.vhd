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
        result : OUT REG32; -- result of the operation

        carry_flag : OUT STD_LOGIC; -- carry flag
        overflow_flag : OUT STD_LOGIC -- overflow flag
    );
END Arithmetic_Instructions;

ARCHITECTURE Arithmetic_Instructions_Arch OF Arithmetic_Instructions IS
    SIGNAL op_1 : signed(31 DOWNTO 0); -- our signed operands
    SIGNAL op_2 : signed(31 DOWNTO 0);
    SIGNAL neg_operand_2 : signed(31 DOWNTO 0); -- negated operand_2
    SIGNAL internal_result : REG32; -- internal result

BEGIN
    -- single adder for all arithmetic operations
    -- op_1 is always operand_1 for most instructions

    op_1 <=
        (OTHERS => '0') WHEN opcode = OPCODE_NEG ELSE
        signed(operand_1);

    -- we negate operand_2 alot
    neg_operand_2 <= - operand_2;

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
    internal_result <= STD_LOGIC_VECTOR(op_1 + op_2);
    result <= internal_result;

    -- ALI CHANGE CODE HERE
    -- e7sb el carry wl overflow flag lel SUB, SUBI, DEC btre2a
    -- w lel ADD, INC, ADDI btre2a tnya

    -- set the flags
    carry_flag <= '1' WHEN
    -- For addition: carry occurs if result is greater than or equal to 2^32
    (opcode = OPCODE_ADD AND (internal_result(31) = '1')) OR
    -- For subtraction: borrow occurs if minuend is smaller than subtrahend
    ((opcode = OPCODE_SUB OR opcode = OPCODE_SUBI OR opcode = OPCODE_DEC) AND op_1 < abs(op_2)) ELSE
    '0';

    overflow_flag <= '1' WHEN
    -- For signed overflow: sign of result differs from signs of operands
    ((op_1(31) = op_2(31)) AND (op_1(31) /= internal_result(31))) ELSE
    '0'; -- no overflow

    --ya bronzeeeeee ya fashel 

END Arithmetic_Instructions_Arch;