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
        external_reset : IN STD_LOGIC;
        out_port : OUT REG32; -- 32 bit
        exception : OUT STD_LOGIC
    );
END Processor;

ARCHITECTURE Processor_Arch OF Processor IS
    SIGNAL clk : STD_LOGIC := '1';
    SIGNAL reset : STD_LOGIC := '1';

    -- pc
    SIGNAL pc : MEM_ADDRESS; -- 32 bit

    -- output port buffer
    SIGNAL out_port_buffer : REG32 := (OTHERS => '0');

    -- instruction memory
    SIGNAL im_instruction_memory_bus : MEM_CELL; -- 16 bit

    -- opcode checker unit
    SIGNAL opc_extra_reads : STD_LOGIC;

    -- fetch/decode register
    SIGNAL fd_fetched_instruction : FETCHED_INSTRUCTION;
    SIGNAL fd_pc_wait : STD_LOGIC := '0'; -- wait?

    -- register file
    SIGNAL regf_read_data_1 : REG32;
    SIGNAL regf_read_data_2 : REG32;
    SIGNAL regf_sp : SIGNED(31 DOWNTO 0);

    -- control unit
    SIGNAL ctrl_signal_bus : SIGBUS;

    -- decode/execute -- todo: put em in a bus
    SIGNAL de_signal_bus : SIGBUS;
    SIGNAL de_write_address : REG_SELECTOR;
    SIGNAL de_read_data_1 : REG32;
    SIGNAL de_read_data_2 : REG32;
    SIGNAL de_instr_opcode : OPCODE;
    SIGNAL de_instr_immediate : SIGNED(31 DOWNTO 0);
    SIGNAL de_enforcedPc : MEM_ADDRESS := (OTHERS => '1');
    SIGNAL de_flush : STD_LOGIC := '0'; -- flush?

    -- alu
    SIGNAL alu_result : REG32;
    SIGNAL alu_flags : STD_LOGIC_VECTOR(3 DOWNTO 0);

    -- execute/memory
    SIGNAL em_signal_bus : SIGBUS;
    SIGNAL em_write_address : REG_SELECTOR;
    SIGNAL em_mem_write_data : REG32;
    SIGNAL em_alu_result : REG32;

    -- data memory
    SIGNAL dm_out : REG32;

    -- write back
    SIGNAL wb_write_enable : STD_LOGIC;
    SIGNAL wb_write_address : REG_SELECTOR;
    SIGNAL wb_write_data : REG32;

BEGIN
    clkProcess : PROCESS -- Clock process
    BEGIN
        WAIT FOR 50 ps;
        clk <= NOT clk;
    END PROCESS clkProcess;

    rstProcess : PROCESS -- Reset process
    BEGIN
        -- reset <= '1'; -- initially on
        WAIT FOR 50 ps;
        reset <= '0';

        WAIT;
    END PROCESS rstProcess;

    -- pc
    programCounter : ENTITY mrk.PC
        PORT MAP(
            clk => clk,
            reset => '0',
            extra_reads => opc_extra_reads,
            pcWait => fd_pc_wait,
            enforcedPc => de_enforcedPc,
            pcCounter => pc
        );

    -- instruction memory
    instructionMemory : ENTITY mrk.Instruction_Memory
        PORT MAP(
            clk => clk,
            reset => '0', -- never
            pc => pc,
            data => im_instruction_memory_bus
        );

    -- opcode checker unit FOR Backward compatibility
    opcodeChecker : ENTITY mrk.Opcode_Checker
        PORT MAP(
            reserved_bit => im_instruction_memory_bus(14), -- reserved bit
            extra_reads => opc_extra_reads
        );

    -- fetch/decode register
    fetchDecodeRegister : ENTITY mrk.Fetch_Decode
        PORT MAP(
            clk => clk,
            reset => reset,
            flush => de_flush,
            raw_instruction => im_instruction_memory_bus,
            extra_reads => opc_extra_reads,
            pc_wait => fd_pc_wait,
            out_instruction => fd_fetched_instruction
        );

    -- register file
    registerFile : ENTITY mrk.Register_File
        PORT MAP(
            clk => clk,
            reset => '0', -- override

            -- input

            write_enable_1 => wb_write_enable,
            write_addr_1 => wb_write_address, -- wb
            write_data_1 => wb_write_data, -- wb

            write_enable_2 => '0',
            write_addr_2 => (OTHERS => '0'), -- wb
            write_data_2 => (OTHERS => '0'), -- wb

            read_addr_1 => fd_fetched_instruction(7 DOWNTO 5), -- src1
            read_addr_2 => fd_fetched_instruction(10 DOWNTO 8), -- src2

            signal_bus => ctrl_signal_bus,

            -- output
            read_data_1 => regf_read_data_1,
            read_data_2 => regf_read_data_2,
            out_sp => regf_sp
        );

    -- control unit
    controlUnit : ENTITY mrk.Controller
        PORT MAP(
            opcode => fd_fetched_instruction(4 DOWNTO 0), -- opcode
            reserved_bit => fd_fetched_instruction(14), -- res(0)

            -- output
            out_signal_bus => ctrl_signal_bus
        );

    -- decode/execute
    decodeExecute : ENTITY mrk.Decode_Execute
        PORT MAP(
            -- input
            clk => clk,

            signal_bus => ctrl_signal_bus,

            write_address => fd_fetched_instruction(13 DOWNTO 11), -- dst

            read_data_1 => regf_read_data_1,
            read_data_2 => regf_read_data_2,

            instr_opcode => fd_fetched_instruction(4 DOWNTO 0),
            instr_immediate => fd_fetched_instruction(31 DOWNTO 16),

            sp => regf_sp,
            flags => alu_flags,

            -- output
            out_signal_bus => de_signal_bus,

            out_write_address => de_write_address,
            out_read_data_1 => de_read_data_1,
            out_read_data_2 => de_read_data_2,

            out_instr_opcode => de_instr_opcode,
            out_instr_immediate => de_instr_immediate,

            out_port => out_port_buffer,
            out_enforcedPc => de_enforcedPc,
            flush => de_flush
        );

    -- alu
    alu : ENTITY mrk.ALU
        PORT MAP(
            operand_1 => de_read_data_1,
            operand_2 => de_read_data_2,
            immediate => de_instr_immediate,
            opcode => de_instr_opcode,

            signal_bus => de_signal_bus,

            result => alu_result,
            flags => alu_flags
        );

    -- execute/memory
    executeMemory : ENTITY mrk.Execute_Memory
        PORT MAP(
            clk => clk,

            signal_bus => de_signal_bus,
            write_address => de_write_address,
            mem_write_data => de_read_data_2,
            alu_result => alu_result,

            -- output
            out_signal_bus => em_signal_bus,
            out_write_address => em_write_address,
            out_mem_write_data => em_mem_write_data,
            out_alu_result => em_alu_result
        );

    -- memory
    memory : ENTITY mrk.Data_Memory
        PORT MAP(
            clk => clk,
            reset => '0', -- override
            address => em_alu_result,

            write_enable => em_signal_bus(SIGBUS_MEM_WRITE),
            data_in => em_mem_write_data,

            read_enable => em_signal_bus(SIGBUS_MEM_READ),
            data_out => dm_out
        );

    -- write back
    memWriteBack : ENTITY mrk.Memory_WriteBack
        PORT MAP(
            clk => clk,

            signal_bus => em_signal_bus,

            write_address => em_write_address,
            alu_result => em_alu_result,
            mem_data => dm_out,
            in_port => in_port,

            out_write_enable => wb_write_enable,
            out_write_address => wb_write_address,
            out_write_data => wb_write_data
        );


    -- output port
    out_port <= out_port_buffer;

END Processor_Arch;