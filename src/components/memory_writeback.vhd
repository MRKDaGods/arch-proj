-- Mem/WB register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Memory_WriteBack IS
    PORT (
        clk : IN STD_LOGIC;

        write_enable : IN STD_LOGIC;
        write_address : IN REG_SELECTOR;
        alu_result : IN REG32;
        mem_data : IN REG32;
        mem_to_reg : IN STD_LOGIC;

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
            out_write_enable <= write_enable;
            out_write_address <= write_address;

            IF mem_to_reg = '1' THEN
                out_write_data <= mem_data;
            ELSE
                out_write_data <= alu_result;
            END IF;
            
        END IF;
    END PROCESS;

END Memory_WriteBack_Arch;