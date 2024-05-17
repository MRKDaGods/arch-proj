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

        -- control signals
        signal_bus : IN SIGBUS;

        -- fetch/decode
        write_address : IN REG_SELECTOR;

        -- reg file
        read_data_1 : IN REG32;
        read_data_2 : IN REG32;

        instr_opcode : IN OPCODE;
        instr_immediate : IN STD_LOGIC_VECTOR(15 DOWNTO 0);

        -- output
        out_signal_bus : OUT SIGBUS;

        out_write_address : OUT REG_SELECTOR;

        out_read_data_1 : OUT REG32;
        out_read_data_2 : OUT REG32;

        out_instr_opcode : OUT OPCODE;
        out_instr_immediate : OUT SIGNED(31 DOWNTO 0); -- sign extended if needed

        out_port : OUT REG32 -- output port
    );
END Decode_Execute;

ARCHITECTURE Decode_Execute_Arch OF Decode_Execute IS
BEGIN
    PROCESS (clk)
    BEGIN
        -- falling edge 3shn el WB
        IF falling_edge(clk) THEN
            out_signal_bus <= signal_bus;

            out_write_address <= write_address;
            out_read_data_1 <= read_data_1;
            out_read_data_2 <= read_data_2;

            out_instr_opcode <= instr_opcode;

            -- sign extend immediate in LDD and STD only
            IF signal_bus(SIGBUS_SIGN_EXTEND_IMMEDIATE) = '1' THEN
                out_instr_immediate <= resize(signed(instr_immediate), 32);
            ELSE
                out_instr_immediate <= signed(resize(unsigned(instr_immediate), 32));
            END IF;

            -- out instruction
            IF instr_opcode = OPCODE_OUT THEN
                out_port <= read_data_1;
            END IF;
        END IF;
    END PROCESS;

END Decode_Execute_Arch;