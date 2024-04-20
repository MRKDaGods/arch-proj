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
    SIGNAL im_instruction_memory_bus : MEM_CELL; -- 16 bit

    -- opcode checker unit
    SIGNAL opc_extra_reads : STD_LOGIC;

    -- fetch/decode register
    SIGNAL fd_fetched_instruction : FETCHED_INSTRUCTION;

    -- register file
    SIGNAL regf_read_data_1 : REG32;
    SIGNAL regf_read_data_2 : REG32;

    -- decode/execute
    SIGNAL de_read_data_1 : REG32;
    SIGNAL de_read_data_2 : REG32;

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
            extra_reads => opc_extra_reads,
            pcCounter => pc
        );

    -- instruction memory
    instructionMemory : ENTITY mrk.Instruction_Memory
        PORT MAP(
            clk => clk,
            reset => reset,
            pc => pc,
            data => im_instruction_memory_bus
        );

    -- opcode checker unit
    opcodeChecker : ENTITY mrk.Opcode_Checker
        PORT MAP(
            opcode => im_instruction_memory_bus(4 DOWNTO 0), -- first 5 bits
            extra_reads => opc_extra_reads
        );

    -- fetch/decode register
    fetchDecodeRegister : ENTITY mrk.Fetch_Decode
        PORT MAP(
            clk => clk,
            reset => reset,
            raw_instruction => im_instruction_memory_bus,
            extra_reads => opc_extra_reads,
            out_instruction => fd_fetched_instruction
        );

    -- register file
    registerFile : ENTITY mrk.Register_File
        PORT MAP(
            clk => clk,
            reset => reset,

            -- input

            write_enable_1 => '0',
            write_addr_1 => (others => '0'), -- wb
            write_data_1 => (others => '0'), -- wb

            write_enable_2 => '0',
            write_addr_2 => (others => '0'), -- wb
            write_data_2 => (others => '0'), -- wb

            read_addr_1 => fd_fetched_instruction(7 DOWNTO 5), -- src1
            read_addr_2 => fd_fetched_instruction(10 DOWNTO 8), -- src2

            -- output
            read_data_1 => regf_read_data_1,
            read_data_2 => regf_read_data_2
        );

    -- decode/execute
    decodeExecute : ENTITY mrk.Decode_Execute
        PORT MAP(
            -- input
            clk => clk,

            write_enable => '0', -- controller?
            write_address => fd_fetched_instruction(13 downto 11), -- dst
            
            read_data_1 => regf_read_data_1,
            read_data_2 => regf_read_data_2,

            -- output
            out_read_data_1 => de_read_data_1,
            out_read_data_2 => de_read_data_2
        );

END Processor_Arch;