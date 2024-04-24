-- Execute/Memory Register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Execute_Memory IS
    PORT (
        clk : IN STD_LOGIC;
        write_address : IN REG_SELECTOR;
        write_enable : IN STD_LOGIC; -- for wb

        mem_write_data : IN REG32; -- read_data_2
        mem_write : IN STD_LOGIC;
        mem_read : IN STD_LOGIC;
        mem_to_reg : IN STD_LOGIC;
        alu_result : IN REG32;

        -- output
        out_write_address : OUT REG_SELECTOR;
        out_write_enable : OUT STD_LOGIC;
        out_mem_write_data : OUT REG32;
        out_mem_write : OUT STD_LOGIC;
        out_mem_read : OUT STD_LOGIC;
        out_mem_to_reg : OUT STD_LOGIC;
        out_alu_result : OUT REG32
    );
END Execute_Memory;

ARCHITECTURE Execute_Memory_Arch OF Execute_Memory IS
BEGIN
    PROCESS (clk)
    BEGIN
        IF rising_edge(clk) THEN
            out_write_address <= write_address;
            out_write_enable <= write_enable;
            out_mem_write_data <= mem_write_data;
            out_mem_write <= mem_write;
            out_mem_read <= mem_read;
            out_alu_result <= alu_result;
            out_mem_to_reg <= mem_to_reg;
        END IF;
    END PROCESS;
END Execute_Memory_Arch;