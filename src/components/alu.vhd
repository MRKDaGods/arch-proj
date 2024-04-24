-- ALU

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY ALU IS
    PORT (
        operand_1 : IN REG32; -- first
        operand_2 : IN REG32; -- second
        immediate : IN SIGNED(31 DOWNTO 0); -- sign extended immediate value

        opcode : IN OPCODE; -- opcode

        -- control signals
        ctrl_pass_through : IN STD_LOGIC; -- pass through
        ctrl_use_logic : IN STD_LOGIC; -- logic or arithmetic operation
        ctrl_use_immediate : IN STD_LOGIC; -- use immediate value

        result : OUT REG32 -- result
    );
END ENTITY ALU;

ARCHITECTURE ALU_Arch OF ALU IS
    SIGNAL result_logical : REG32;
    SIGNAL result_arithmetic : REG32;

    SIGNAL arithmetic_op_2 : SIGNED(31 DOWNTO 0);

BEGIN

    -- operands are always registers for logical instructions
    logical : ENTITY mrk.Logical_Instructions PORT MAP (
        opcode => opcode,
        operand_1 => operand_1,
        operand_2 => operand_2,
        result => result_logical
        );

    arithmetic_op_2 <=
        immediate WHEN ctrl_use_immediate = '1' ELSE
        SIGNED(operand_2);

    arithmetic : ENTITY mrk.Arithmetic_Instructions PORT MAP (
        opcode => opcode,
        operand_1 => operand_1,
        operand_2 => arithmetic_op_2,
        result => result_arithmetic
        );

    result <= operand_1 WHEN ctrl_pass_through = '1' ELSE
        result_logical WHEN ctrl_use_logic = '1' ELSE
        result_arithmetic;

END ALU_Arch;