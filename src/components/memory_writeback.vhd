-- Mem/WB register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Memory_WriteBack IS
    PORT (
        clk : IN STD_LOGIC;

        -- Inputs
        signal_bus : IN SIGBUS;

        write_address : IN REG_SELECTOR;
        alu_result : IN REG32;
        mem_data : IN REG32;
        in_port : IN REG32;

        -- Outputs
        out_write_enable : OUT STD_LOGIC;
        out_write_address : OUT REG_SELECTOR;
        out_write_data : OUT REG32
    );
END Memory_WriteBack;

ARCHITECTURE Memory_WriteBack_Arch OF Memory_WriteBack IS
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            out_write_enable <= signal_bus(SIGBUS_WRITE_ENABLE);
            out_write_address <= write_address;

            IF signal_bus(SIGBUS_MEM_TO_REG) = '1' THEN
                out_write_data <= mem_data;
            ELSIF signal_bus(SIGBUS_USE_IO) = '1' THEN
                out_write_data <= in_port; -- IN instruction
            ELSE
                out_write_data <= alu_result;
            END IF;

        END IF;
    END PROCESS;

END Memory_WriteBack_Arch;