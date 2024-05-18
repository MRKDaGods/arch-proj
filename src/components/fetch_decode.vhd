-- Fetch/Decode register

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY MRK;
USE MRK.COMMON.ALL;

ENTITY Fetch_Decode IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        raw_instruction : IN MEM_CELL; -- 16 bit from instr mem
        extra_reads : IN STD_LOGIC; -- from opcode checker

        pc_wait : OUT STD_LOGIC; -- stall the PC

        out_instruction : OUT FETCHED_INSTRUCTION -- 32 bit
    );
END Fetch_Decode;

ARCHITECTURE Fetch_Decode_Arch OF Fetch_Decode IS
BEGIN
    PROCESS (clk, reset)
        VARIABLE instruction_buffer : MEM_CELL := (OTHERS => '0');
        VARIABLE has_buffer : BOOLEAN := FALSE;

        VARIABLE is_swap_buffer : BOOLEAN := FALSE; -- is this a swap buffer?
    BEGIN

        IF reset = '1' THEN
            out_instruction <= (OTHERS => '0');
            instruction_buffer := (OTHERS => '0');
            has_buffer := FALSE;
            is_swap_buffer := FALSE;
            pc_wait <= '0';
        ELSIF rising_edge(clk) THEN
            -- read first 16 bits

            IF has_buffer THEN

                -- check if we need to swap
                IF is_swap_buffer = TRUE THEN
                    out_instruction <= (15 DOWNTO 0 => '0') & instruction_buffer;
                ELSE
                    out_instruction <= raw_instruction & instruction_buffer;
                END IF;

                has_buffer := FALSE;
                is_swap_buffer := FALSE;

                pc_wait <= '0';
            ELSE
                -- check if we need to wait
                IF raw_instruction(4 DOWNTO 0) = OPCODE_SWAP THEN
                    pc_wait <= '1';

                    -- synthesize mov instruction
                    out_instruction <= (17 DOWNTO 0 => '0')
                        & raw_instruction(13 DOWNTO 11) -- DST
                        & "000" -- SRC2
                        & raw_instruction(7 DOWNTO 5) -- SRC1
                        & OPCODE_MOV; -- OPCODE

                    -- set instruction buffer to the other mov
                    instruction_buffer := "00"
                        & raw_instruction(7 DOWNTO 5) -- SRC1
                        & "000" -- SRC2
                        & raw_instruction(13 DOWNTO 11) -- DST
                        & OPCODE_MOV; -- OPCODE

                    has_buffer := TRUE;
                    is_swap_buffer := TRUE;
                ELSE
                    -- IF raw_instruction(4 DOWNTO 0) = OPCODE_JMP THEN
                    --     pc_wait <= '1';
                    -- ELSE
                    --     pc_wait <= '0';
                    -- END IF;

                    pc_wait <= '0';

                    out_instruction <= (15 DOWNTO 0 => '0') & raw_instruction;
                END IF;

            END IF;

            -- do we need a second read? check falling edge
        ELSIF falling_edge(clk) AND extra_reads = '1' THEN
            -- read second 16 bits
            -- out_instruction(31 DOWNTO 16) <= raw_instruction;

            instruction_buffer := raw_instruction;
            has_buffer := TRUE;
        END IF;

    END PROCESS;

END Fetch_Decode_Arch;