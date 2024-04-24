-- Control unit bro

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Controller IS
    PORT (
        opcode : IN OPCODE; -- instruction opcode
        reserved_bit : IN STD_LOGIC; -- reserved bit in the instruction

        write_enable : OUT STD_LOGIC; -- should we write in a register?
        mem_write : OUT STD_LOGIC; -- should we write in memory?
        mem_read : OUT STD_LOGIC; -- should we read from memory?

        mem_to_reg : OUT STD_LOGIC; -- should we write memory data to register?

        -- some alu signals
        alu_pass_through : OUT STD_LOGIC; -- should we use the alu? (or just pass the data)
        alu_use_logical : OUT STD_LOGIC; -- logical or arithmetic operation?
        alu_use_immediate : OUT STD_LOGIC; -- is the second operand an immediate value?
        alu_update_flags : OUT STD_LOGIC; -- should we update flags?

        sign_extend_immediate : OUT STD_LOGIC -- should we sign extend the immediate value?
    );
END ENTITY Controller;

ARCHITECTURE Controller_Arch OF Controller IS
BEGIN

    -- when do we write to registers?
    WITH opcode SELECT
        write_enable <=
        '0' WHEN OPCODE_NOP,
        '0' WHEN OPCODE_OUT,
        '0' WHEN OPCODE_PROTECT,
        '0' WHEN OPCODE_FREE,
        '0' WHEN OPCODE_STD,
        '0' WHEN OPCODE_PUSH,
        '0' WHEN OPCODE_CMP,
        '0' WHEN OPCODE_JZ,
        '0' WHEN OPCODE_JMP,
        '0' WHEN OPCODE_CALL,
        '0' WHEN OPCODE_RET,
        '0' WHEN OPCODE_RTI,
        '0' WHEN OPCODE_RESET,
        '0' WHEN OPCODE_INTERRUPT,
        '1' WHEN OTHERS;

    -- when do we write to memory?
    WITH opcode SELECT
        mem_write <=
        '1' WHEN OPCODE_PUSH,
        '1' WHEN OPCODE_STD,
        '1' WHEN OPCODE_CALL,
        '1' WHEN OPCODE_INTERRUPT,
        '0' WHEN OTHERS;

    -- when do we read from memory?
    WITH opcode SELECT
        mem_read <=
        '1' WHEN OPCODE_POP,
        '1' WHEN OPCODE_LDD,
        '1' WHEN OPCODE_RET,
        '1' WHEN OPCODE_RTI,
        '0' WHEN OTHERS;

    -- when do we use logical alu?
    WITH opcode SELECT
        alu_use_logical <=
        '1' WHEN OPCODE_NOT,
        '1' WHEN OPCODE_AND,
        '1' WHEN OPCODE_OR,
        '1' WHEN OPCODE_XOR,
        '0' WHEN OTHERS;

    -- when do we write memory data to register?
    WITH opcode SELECT
        mem_to_reg <=
        '1' WHEN OPCODE_POP,
        '1' WHEN OPCODE_LDD,
        '0' WHEN OTHERS;

    -- when do we sign extend the immediate value?
    WITH opcode SELECT
        sign_extend_immediate <=
        '1' WHEN OPCODE_STD,
        '1' WHEN OPCODE_LDD,
        '0' WHEN OTHERS;

    -- when do we pass the data through ALU? (for write enabled instructions)
    WITH opcode SELECT
        alu_pass_through <=
        '1' WHEN OPCODE_MOV,
        '1' WHEN OPCODE_SWAP,
        '1' WHEN OPCODE_LDM,
        '0' WHEN OTHERS;

    -- when do we use immediate value as the second operand?
    alu_use_immediate <= reserved_bit;

    -- when do we need to update flags? (to optimize, do we need all these with select?)
    WITH opcode SELECT
        alu_update_flags <=
        '1' WHEN OPCODE_NOT,
        '1' WHEN OPCODE_AND,
        '1' WHEN OPCODE_OR,
        '1' WHEN OPCODE_XOR,
        '1' WHEN OPCODE_CMP,
        '1' WHEN OPCODE_NEG,
        '1' WHEN OPCODE_ADD,
        '1' WHEN OPCODE_ADDI,
        '1' WHEN OPCODE_SUB,
        '1' WHEN OPCODE_SUBI,
        '1' WHEN OPCODE_INC,
        '1' WHEN OPCODE_DEC,
        '0' WHEN OTHERS;

END Controller_Arch;