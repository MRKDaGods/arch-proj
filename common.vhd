-- Common types, etc

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE COMMON IS
    -- our register is 32 bits
    SUBTYPE REG32 IS STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- logical alu signals (or, cmp, dec, etc)
    SUBTYPE ALU_CS_LOGICAL IS STD_LOGIC_VECTOR(1 DOWNTO 0);

    -- memory entry is 16 bits
    SUBTYPE MEM_CELL IS STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- PC and SP are 32 bits, any memory access addr is 32 bits
    SUBTYPE MEM_ADDRESS IS STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- data memory cell is 16, but we assume 32 bits (read 2 consec. cells)
    SUBTYPE DATA_MEM_CELL IS STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- Register selector is 3 bits
    SUBTYPE REG_SELECTOR IS STD_LOGIC_VECTOR(2 DOWNTO 0);

    -- Memory array is 4096 cells
    TYPE MEMORY_ARRAY IS ARRAY (0 TO 4095) OF MEM_CELL;

    -- alu control signals
    CONSTANT ALU_CS_LOGICAL_NOT : ALU_CS_LOGICAL := "00";
    CONSTANT ALU_CS_LOGICAL_OR : ALU_CS_LOGICAL := "01";
    CONSTANT ALU_CS_LOGICAL_DEC : ALU_CS_LOGICAL := "10";
    CONSTANT ALU_CS_LOGICAL_CMP : ALU_CS_LOGICAL := "11";
END PACKAGE COMMON;