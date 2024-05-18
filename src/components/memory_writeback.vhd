-- Mem/WB register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.std_logic_textio.ALL;
USE std.textio.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Memory_WriteBack IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        -- Inputs
        signal_bus : IN SIGBUS;

        write_address : IN REG_SELECTOR;
        alu_result : IN REG32;
        mem_data : IN REG32;
        in_port : IN REG32;

        -- Outputs
        out_write_enable : OUT STD_LOGIC;
        out_write_address : OUT REG_SELECTOR;
        out_write_data : OUT REG32;
        out_enforcedPc : OUT MEM_ADDRESS;
        out_flush : OUT STD_LOGIC
    );
END Memory_WriteBack;

ARCHITECTURE Memory_WriteBack_Arch OF Memory_WriteBack IS
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            out_write_enable <= '0';
            out_write_address <= (OTHERS => '0');
            out_write_data <= (OTHERS => '0');
            out_enforcedPc <= (OTHERS => '1');
            out_flush <= '0';
        ELSE
            IF rising_edge(clk) THEN
                out_write_enable <= signal_bus(SIGBUS_WRITE_ENABLE);
                out_write_address <= write_address;

                IF signal_bus(SIGBUS_OP_POPPC) = '1' THEN
                    out_enforcedPc <= mem_data;

                    out_flush <= '1';
                ELSE
                    out_enforcedPc <= (OTHERS => '1');
                END IF;

                IF signal_bus(SIGBUS_MEM_TO_REG) = '1' THEN
                    out_write_data <= mem_data;
                ELSE
                    out_write_data <= alu_result;
                END IF;

            ELSIF falling_edge(clk) THEN
                out_flush <= '0';
            END IF;
        END IF;
    END PROCESS;

END Memory_WriteBack_Arch;