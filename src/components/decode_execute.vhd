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
        in_flush : IN STD_LOGIC;

        -- control signals
        signal_bus : IN SIGBUS;

        -- fetch/decode
        write_address : IN REG_SELECTOR;

        -- reg file
        read_data_1 : IN REG32;
        read_data_2 : IN REG32;

        instr_opcode : IN OPCODE;
        instr_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- sp
        pc : IN MEM_ADDRESS;
        sp : IN SIGNED(31 DOWNTO 0);

        flags : IN STD_LOGIC_VECTOR(3 DOWNTO 0);

        -- output
        out_signal_bus : OUT SIGBUS;

        out_write_address : OUT REG_SELECTOR;

        out_read_data_1 : OUT REG32;
        out_read_data_2 : OUT REG32;

        out_instr_opcode : OUT OPCODE;

        -- this could be sp too :)
        out_instr_immediate : OUT SIGNED(31 DOWNTO 0); -- sign extended if needed

        out_port : OUT REG32; -- output port

        out_enforcedPc : OUT MEM_ADDRESS;

        flush : OUT STD_LOGIC
    );
END Decode_Execute;

ARCHITECTURE Decode_Execute_Arch OF Decode_Execute IS
BEGIN
    PROCESS (clk, in_flush)
    BEGIN
        IF in_flush = '1' THEN
            out_signal_bus <= (OTHERS => '0');
            out_write_address <= "000";
            out_read_data_1 <= (OTHERS => '0');
            out_read_data_2 <= (OTHERS => '0');
            out_instr_opcode <= OPCODE_NOP;
            out_instr_immediate <= (OTHERS => '0');
            out_port <= (OTHERS => '0');
            out_enforcedPc <= (OTHERS => '1');
            flush <= '0';
        ELSE
            -- falling edge 3shn el WB
            IF rising_edge(clk) THEN
                out_signal_bus <= signal_bus;

                out_write_address <= write_address;

                IF instr_opcode = OPCODE_PUSHPC THEN
                    out_read_data_2 <= STD_LOGIC_VECTOR(unsigned(pc) + 1);
                ELSE
                    out_read_data_2 <= read_data_2;
                END IF;

                out_read_data_1 <= read_data_1;

                out_instr_opcode <= instr_opcode;

                IF signal_bus(SIGBUS_USE_SP) = '1' THEN
                    out_instr_immediate <= sp;
                ELSE
                    -- sign extend immediate in LDD and STD only
                    IF signal_bus(SIGBUS_SIGN_EXTEND_IMMEDIATE) = '1' THEN
                        out_instr_immediate <= resize(signed(instr_immediate), 32);
                    ELSE
                        out_instr_immediate <= signed(resize(unsigned(instr_immediate), 32));
                    END IF;
                END IF;

                -- check for jmp
                IF signal_bus(SIGBUS_OP_JMP) = '1' OR (signal_bus(SIGBUS_OP_JZ) = '1' AND flags(3) = '1') THEN
                    out_enforcedPc <= read_data_1;
                    flush <= '1';
                ELSIF instr_opcode = OPCODE_RET THEN
                    flush <= '1'; -- because of JMP
                    out_enforcedPc <= (OTHERS => '1');
                ELSE
                    out_enforcedPc <= (OTHERS => '1');
                END IF;

                -- out instruction
                IF instr_opcode = OPCODE_OUT THEN
                    out_port <= read_data_1;
                END IF;
            ELSIF falling_edge(clk) THEN
                flush <= '0';
            END IF;
        END IF;
    END PROCESS;

END Decode_Execute_Arch;