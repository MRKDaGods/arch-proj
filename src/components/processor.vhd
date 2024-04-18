-- Processor.

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Processor IS
    PORT (
        in_port : IN REG32; -- 32 bit
        interrupt : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        out_port : OUT REG32; -- 32 bit
        exception : OUT STD_LOGIC
    );
END Processor;

ARCHITECTURE Processor_Arch OF Processor IS
    SIGNAL clk : STD_LOGIC := '1';

    -- pc
    SIGNAL pc : MEM_ADDRESS; -- 32 bit

    -- instruction memory
    SIGNAL instruction_memory_bus : MEM_CELL; -- 16 bit

    -- opcode checker unit
    SIGNAL extra_reads : STD_LOGIC;

    -- fetch/decode register
    SIGNAL fetched_instruction : FETCHED_INSTRUCTION;

BEGIN
    clkProcess : PROCESS -- Clock process
    BEGIN
        WAIT FOR 50 ps;
        clk <= NOT clk;
    END PROCESS clkProcess;

    -- pc
    programCounter : ENTITY mrk.PC
        PORT MAP(
            clk => clk,
            reset => reset,
            extra_reads => extra_reads,
            pcCounter => pc
        );

    -- instruction memory
    instructionMemory : ENTITY mrk.Instruction_Memory
        PORT MAP(
            clk => clk,
            reset => reset,
            pc => pc,
            data => instruction_memory_bus
        );

    -- opcode checker unit
    opcodeChecker : ENTITY mrk.Opcode_Checker
        PORT MAP(
            clk => clk,
            opcode => instruction_memory_bus(4 DOWNTO 0), -- first 5 bits
            extra_reads => extra_reads
        );

    -- fetch/decode register
    fetchDecodeRegister : ENTITY mrk.Fetch_Decode
        PORT MAP(
            clk => clk,
            reset => reset,
            raw_instruction => instruction_memory_bus,
            extra_reads => extra_reads,
            fetched_instruction => fetched_instruction
        );

END Processor_Arch;