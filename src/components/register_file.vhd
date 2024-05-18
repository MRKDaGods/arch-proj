-- Register file
-- 8 regs R0-R7

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY Register_File IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        interrupt : IN STD_LOGIC; -- for sp
        interruptRTI : IN STD_LOGIC;
        pc : IN MEM_ADDRESS; -- for int

        -- two writes
        write_enable_1 : IN STD_LOGIC;
        write_addr_1 : IN REG_SELECTOR;
        write_data_1 : IN REG32;

        write_enable_2 : IN STD_LOGIC;
        write_addr_2 : IN REG_SELECTOR;
        write_data_2 : IN REG32;

        -- two reads
        read_addr_1 : IN REG_SELECTOR;
        read_addr_2 : IN REG_SELECTOR;

        -- sp related
        signal_bus : IN SIGBUS;

        read_data_1 : OUT REG32;
        read_data_2 : OUT REG32;

        -- stack pointer
        out_sp : OUT SIGNED(31 DOWNTO 0);
        interrupt_sp : OUT SIGNED(31 DOWNTO 0);
        interrupt_pc : OUT MEM_ADDRESS
    );
END Register_File;

ARCHITECTURE Register_File_Arch OF Register_File IS
    TYPE reg_array IS ARRAY (0 TO 7) OF REG32;
    SIGNAL regs : reg_array;

    SIGNAL sp : SIGNED(31 DOWNTO 0) := to_signed(4095, 32);

BEGIN
    PROCESS (clk, reset, interrupt)
        VARIABLE tmpSp : SIGNED(31 DOWNTO 0);
    BEGIN
        IF reset = '1' THEN
            regs <= (OTHERS => (OTHERS => '0'));
            sp <= to_signed(4095, sp'length);
        ELSIF interrupt'event AND interrupt = '1' THEN
            tmpSp := sp - 4;
            interrupt_sp <= tmpSp;
            sp <= tmpSp; -- 4 word (2 flags, 2 pc)
            interrupt_pc <= std_logic_vector(unsigned(pc) + 1);
        ELSIF rising_edge(clk) THEN
            -- stack pointer update
            IF signal_bus(SIGBUS_OP_PUSH) = '1' THEN
                sp <= sp - 2; -- 2 words
            END IF;

            IF signal_bus(SIGBUS_OP_POP) = '1' THEN
                sp <= sp + 2; -- 2 words
            END IF;

        ELSIF falling_edge(clk) THEN
            -- should we write?
            IF write_enable_1 = '1' THEN
                regs(to_integer(unsigned(write_addr_1))) <= write_data_1;
            END IF;

            IF write_enable_2 = '1' THEN
                regs(to_integer(unsigned(write_addr_2))) <= write_data_2;
            END IF;
        END IF;
    END PROCESS;

    read_data_1 <= regs(to_integer(unsigned(read_addr_1)));
    read_data_2 <= regs(to_integer(unsigned(read_addr_2)));

    out_sp <= sp;

END Register_File_Arch;