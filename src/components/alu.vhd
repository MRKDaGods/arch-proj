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

        signal_bus : IN SIGBUS; -- signal bus

        -- control signals
        -- ctrl_pass_through : IN STD_LOGIC; -- pass through
        -- ctrl_use_logic : IN STD_LOGIC; -- logic or arithmetic operation
        -- ctrl_use_immediate : IN STD_LOGIC; -- use immediate value
        -- ctrl_update_flags : IN STD_LOGIC; -- update flags

        result : OUT REG32; -- result
        flags : OUT STD_LOGIC_VECTOR(3 DOWNTO 0) -- flags
    );
END ENTITY ALU;

ARCHITECTURE ALU_Arch OF ALU IS
    SIGNAL result_logical : REG32;
    SIGNAL result_arithmetic : REG32;
    SIGNAL internal_result : REG32;

    SIGNAL arithmetic_op_2 : SIGNED(31 DOWNTO 0);
    SIGNAL pass_through_operand : REG32; -- which operand is passing through?

    SIGNAL arithmetic_carry_flag : STD_LOGIC := '0';
    SIGNAL arithmetic_overflow_flag : STD_LOGIC := '0';

    -- flags
    SIGNAL Z, N, C, O : STD_LOGIC;

BEGIN

    flagsProcess : PROCESS (signal_bus(SIGBUS_ALU_UPDATE_FLAGS), internal_result)
    BEGIN
        IF signal_bus(SIGBUS_ALU_UPDATE_FLAGS) = '1' THEN
            -- update zero flag regardless
            IF internal_result = (31 DOWNTO 0 => '0') THEN
                Z <= '1';
            ELSE
                Z <= '0';
            END IF;

            -- update negative flag regardless
            N <= internal_result(31);

            -- only update carry and overflow flags if not using logic
            IF signal_bus(SIGBUS_ALU_USE_LOGICAL) = '0' AND opcode /= OPCODE_CMP THEN
                -- update flags
                C <= arithmetic_carry_flag;
                O <= arithmetic_overflow_flag;
            END IF;
        END IF;
    END PROCESS flagsProcess;

    -- operands are always registers for logical instructions
    logical : ENTITY mrk.Logical_Instructions PORT MAP (
        opcode => opcode,
        operand_1 => operand_1,
        operand_2 => operand_2,
        result => result_logical
        );

    arithmetic_op_2 <=
        immediate WHEN signal_bus(SIGBUS_ALU_USE_IMMEDIATE) = '1' ELSE
        SIGNED(operand_2);

    arithmetic : ENTITY mrk.Arithmetic_Instructions PORT MAP (
        opcode => opcode,
        operand_1 => operand_1,
        operand_2 => arithmetic_op_2,
        result => result_arithmetic,
        carry_flag => arithmetic_carry_flag,
        overflow_flag => arithmetic_overflow_flag
        );

    -- op1 will pass through if ctrl_use_immediate is not set
    pass_through_operand <= STD_LOGIC_VECTOR(immediate) WHEN signal_bus(SIGBUS_ALU_USE_IMMEDIATE) = '1' ELSE
        operand_1;

    -- to use within process
    internal_result <= pass_through_operand WHEN signal_bus(SIGBUS_ALU_PASS_THROUGH) = '1' ELSE
        result_logical WHEN signal_bus(SIGBUS_ALU_USE_LOGICAL) = '1' ELSE
        result_arithmetic;

    result <= internal_result;
    flags <= Z & N & C & O;

END ALU_Arch;