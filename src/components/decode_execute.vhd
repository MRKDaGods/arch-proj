-- Decode/Execute register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Decode_Execute IS
    PORT (
        -- input
        clk : IN STD_LOGIC;

        -- fetch/decode
        write_address : IN REG_SELECTOR;
        write_enable : IN STD_LOGIC;

        -- reg file
        read_data_1 : IN REG32;
        read_data_2 : IN REG32;

        -- memory control
        mem_write : IN STD_LOGIC;
        mem_read : IN STD_LOGIC;
        mem_to_reg : IN STD_LOGIC;

        -- alu control
        alu_pass_through : IN STD_LOGIC;
        alu_use_logical : IN STD_LOGIC;
        alu_use_immediate : IN STD_LOGIC;
        alu_update_flags : IN STD_LOGIC;
        sign_extend_immediate : IN STD_LOGIC;

        instr_opcode : IN OPCODE;
        instr_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- output
        out_write_address : OUT REG_SELECTOR;
        out_write_enable : OUT STD_LOGIC;

        out_read_data_1 : OUT REG32;
        out_read_data_2 : OUT REG32;

        out_mem_write : OUT STD_LOGIC;
        out_mem_read : OUT STD_LOGIC;
        out_mem_to_reg : OUT STD_LOGIC;

        out_alu_pass_through : OUT STD_LOGIC;
        out_alu_use_logical : OUT STD_LOGIC;
        out_alu_use_immediate : OUT STD_LOGIC;
        out_alu_update_flags : OUT STD_LOGIC;

        out_instr_opcode : OUT OPCODE;
        out_instr_immediate : OUT SIGNED(31 DOWNTO 0) -- sign extended if needed
    );
END Decode_Execute;

ARCHITECTURE Decode_Execute_Arch OF Decode_Execute IS
BEGIN
    PROCESS (clk)
    BEGIN
        -- falling edge 3shn el WB
        IF falling_edge(clk) THEN
            out_write_address <= write_address;
            out_write_enable <= write_enable;
            out_read_data_1 <= read_data_1;
            out_read_data_2 <= read_data_2;

            out_mem_write <= mem_write;
            out_mem_read <= mem_read;
            out_mem_to_reg <= mem_to_reg;

            out_alu_pass_through <= alu_pass_through;
            out_alu_use_logical <= alu_use_logical;
            out_alu_use_immediate <= alu_use_immediate;
            out_alu_update_flags <= alu_update_flags;

            out_instr_opcode <= instr_opcode;

            -- sign extend immediate in LDD and STD only
            IF sign_extend_immediate = '1' THEN
                out_instr_immediate <= resize(signed(instr_immediate), 32);
            ELSE
                out_instr_immediate <= signed(resize(unsigned(instr_immediate), 32));
            END IF;
        END IF;
    END PROCESS;

END Decode_Execute_Arch;