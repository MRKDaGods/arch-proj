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

    -- sp
    SIGNAL sp : MEM_ADDRESS := X"00000FFF"; -- 32 bit

    -- instruction memory
    SIGNAL im_instruction_memory_bus : MEM_CELL; -- 16 bit

    -- opcode checker unit
    SIGNAL opc_extra_reads : STD_LOGIC;

    -- fetch/decode register
    SIGNAL fd_fetched_instruction : FETCHED_INSTRUCTION;

    -- register file
    SIGNAL regf_read_data_1 : REG32;
    SIGNAL regf_read_data_2 : REG32;

    -- control unit
    SIGNAL ctrl_write_enable : STD_LOGIC;
    SIGNAL ctrl_mem_write : STD_LOGIC;
    SIGNAL ctrl_mem_read : STD_LOGIC;
    SIGNAL ctrl_mem_to_reg : STD_LOGIC;
    SIGNAL ctrl_alu_pass_through : STD_LOGIC;
    SIGNAL ctrl_alu_use_logical : STD_LOGIC;
    SIGNAL ctrl_alu_use_immediate : STD_LOGIC;
    SIGNAL ctrl_alu_update_flags : STD_LOGIC;
    SIGNAL ctrl_sign_extend_immediate : STD_LOGIC;

    -- decode/execute -- todo: put em in a bus
    SIGNAL de_write_address : REG_SELECTOR;
    SIGNAL de_write_enable : STD_LOGIC;
    SIGNAL de_read_data_1 : REG32;
    SIGNAL de_read_data_2 : REG32;
    SIGNAL de_mem_write : STD_LOGIC;
    SIGNAL de_mem_read : STD_LOGIC;
    SIGNAL de_mem_to_reg : STD_LOGIC;
    SIGNAL de_alu_pass_through : STD_LOGIC;
    SIGNAL de_alu_use_logical : STD_LOGIC;
    SIGNAL de_alu_use_immediate : STD_LOGIC;
    SIGNAL de_alu_update_flags : STD_LOGIC;
    SIGNAL de_instr_opcode : OPCODE;
    SIGNAL de_instr_immediate : SIGNED(31 DOWNTO 0);

    -- alu
    SIGNAL alu_result : REG32;

    -- execute/memory
    SIGNAL em_write_address : REG_SELECTOR;
    SIGNAL em_write_enable : STD_LOGIC;
    SIGNAL em_mem_write_data : REG32;
    SIGNAL em_mem_write : STD_LOGIC;
    SIGNAL em_mem_read : STD_LOGIC;
    SIGNAL em_mem_to_reg : STD_LOGIC;
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
            reset => '0',
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

            write_enable_1 => wb_write_enable,
            write_addr_1 => wb_write_address, -- wb
            write_data_1 => wb_write_data, -- wb

            write_enable_2 => '0',
            write_addr_2 => (OTHERS => '0'), -- wb
            write_data_2 => (OTHERS => '0'), -- wb

            read_addr_1 => fd_fetched_instruction(7 DOWNTO 5), -- src1
            read_addr_2 => fd_fetched_instruction(10 DOWNTO 8), -- src2

            -- output
            read_data_1 => regf_read_data_1,
            read_data_2 => regf_read_data_2
        );

    -- control unit
    controlUnit : ENTITY mrk.Controller
        PORT MAP(
            opcode => fd_fetched_instruction(4 DOWNTO 0), -- opcode
            reserved_bit => fd_fetched_instruction(14), -- res(0)

            -- output
            write_enable => ctrl_write_enable,
            mem_write => ctrl_mem_write,
            mem_read => ctrl_mem_read,
            mem_to_reg => ctrl_mem_to_reg,
            alu_pass_through => ctrl_alu_pass_through,
            alu_use_logical => ctrl_alu_use_logical,
            alu_use_immediate => ctrl_alu_use_immediate,
            alu_update_flags => ctrl_alu_update_flags,
            sign_extend_immediate => ctrl_sign_extend_immediate
        );

    -- decode/execute
    decodeExecute : ENTITY mrk.Decode_Execute
        PORT MAP(
            -- input
            clk => clk,

            write_address => fd_fetched_instruction(13 DOWNTO 11), -- dst
            write_enable => ctrl_write_enable,

            read_data_1 => regf_read_data_1,
            read_data_2 => regf_read_data_2,

            mem_write => ctrl_mem_write,
            mem_read => ctrl_mem_read,
            mem_to_reg => ctrl_mem_to_reg,

            alu_pass_through => ctrl_alu_pass_through,
            alu_use_logical => ctrl_alu_use_logical,
            alu_use_immediate => ctrl_alu_use_immediate,
            alu_update_flags => ctrl_alu_update_flags,
            sign_extend_immediate => ctrl_sign_extend_immediate,
            instr_opcode => fd_fetched_instruction(4 DOWNTO 0),
            instr_immediate => fd_fetched_instruction(31 DOWNTO 16),

            -- output
            out_write_address => de_write_address,
            out_write_enable => de_write_enable,
            out_read_data_1 => de_read_data_1,
            out_read_data_2 => de_read_data_2,
            out_mem_write => de_mem_write,
            out_mem_read => de_mem_read,
            out_mem_to_reg => de_mem_to_reg,
            out_alu_pass_through => de_alu_pass_through,
            out_alu_use_logical => de_alu_use_logical,
            out_alu_use_immediate => de_alu_use_immediate,
            out_alu_update_flags => de_alu_update_flags,
            out_instr_opcode => de_instr_opcode,
            out_instr_immediate => de_instr_immediate
        );

    -- alu
    alu : ENTITY mrk.ALU
        PORT MAP(
            operand_1 => de_read_data_1,
            operand_2 => de_read_data_2,
            immediate => de_instr_immediate,
            opcode => de_instr_opcode,

            ctrl_pass_through => de_alu_pass_through,
            ctrl_use_logic => de_alu_use_logical,
            ctrl_use_immediate => de_alu_use_immediate,
            ctrl_update_flags => de_alu_update_flags,

            result => alu_result
        );

    -- execute/memory
    executeMemory : ENTITY mrk.Execute_Memory
        PORT MAP(
            clk => clk,

            write_address => de_write_address,
            write_enable => de_write_enable,

            mem_write_data => de_read_data_2,
            mem_write => de_mem_write,
            mem_read => de_mem_read,
            mem_to_reg => de_mem_to_reg,

            alu_result => alu_result,

            -- output
            out_write_address => em_write_address,
            out_write_enable => em_write_enable,
            out_mem_write_data => em_mem_write_data,
            out_mem_write => em_mem_write,
            out_mem_read => em_mem_read,
            out_mem_to_reg => em_mem_to_reg,
            out_alu_result => em_alu_result
        );

    -- memory
    memory : ENTITY mrk.Data_Memory
        PORT MAP(
            clk => clk,
            reset => reset,
            address => em_alu_result,

            write_enable => em_mem_write,
            data_in => em_mem_write_data,

            read_enable => em_mem_read,
            data_out => dm_out
        );

    -- write back
    memWriteBack : ENTITY mrk.Memory_WriteBack
        PORT MAP(
            clk => clk,

            write_enable => em_write_enable,
            write_address => em_write_address,
            alu_result => em_alu_result,
            mem_data => dm_out,
            mem_to_reg => em_mem_to_reg,
            
            out_write_enable => wb_write_enable,
            out_write_address => wb_write_address,
            out_write_data => wb_write_data
        );

END Processor_Arch;