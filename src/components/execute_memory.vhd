-- Execute/Memory Register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Execute_Memory IS
    PORT (
        clk : IN STD_LOGIC;
        flush : IN STD_LOGIC;

        -- input
        signal_bus : IN SIGBUS;
        write_address : IN REG_SELECTOR;
        mem_write_data : IN REG32; -- read_data_2
        alu_result : IN REG32;

        -- output
        out_signal_bus : OUT SIGBUS;
        out_write_address : OUT REG_SELECTOR;
        out_mem_write_data : OUT REG32;
        out_alu_result : OUT REG32
    );
END Execute_Memory;

ARCHITECTURE Execute_Memory_Arch OF Execute_Memory IS
BEGIN
    PROCESS (clk, flush)
    BEGIN
        IF flush = '1' THEN
            out_signal_bus <= (OTHERS => '0');
            out_write_address <= (OTHERS => '0');
            out_mem_write_data <= (OTHERS => '0');
            out_alu_result <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            out_signal_bus <= signal_bus;
            out_write_address <= write_address; -- wb
            out_mem_write_data <= mem_write_data;

            IF signal_bus(SIGBUS_OP_PUSH) = '1' THEN
                out_alu_result <= STD_LOGIC_VECTOR(unsigned(alu_result) - 1);
            ELSIF signal_bus(SIGBUS_OP_POP) = '1' OR signal_bus(SIGBUS_OP_POPPC) = '1' THEN
                out_alu_result <= STD_LOGIC_VECTOR(unsigned(alu_result) + 1);
            ELSE
                out_alu_result <= alu_result; -- used for mem addr
            END IF;
        END IF;
    END PROCESS;
END Execute_Memory_Arch;