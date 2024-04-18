-- Program counter

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

ENTITY PC IS
    PORT (
        clk : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        extra_reads : IN STD_LOGIC; -- from opcode checker, do we need to increment twice in 1 cycle?
        pcCounter : OUT MEM_ADDRESS
    );
END ENTITY PC;

ARCHITECTURE PC_Arch OF PC IS
SIGNAL internal_pcCounter : MEM_ADDRESS := (OTHERS => '0');
BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset = '1' THEN
            -- reset pc to 0
            internal_pcCounter <= (OTHERS => '0');
        ELSIF rising_edge(clk) THEN
            -- in rising edge, we'll increment PC as usual
            internal_pcCounter <= STD_LOGIC_VECTOR(unsigned(internal_pcCounter) + 1);
        ELSIF falling_edge(clk) THEN
            -- if we're on falling edge, we'll increment PC again if extra_reads is high
            IF extra_reads = '1' THEN
                internal_pcCounter <= STD_LOGIC_VECTOR(unsigned(internal_pcCounter) + 1);
            END IF;
        END IF;
    END PROCESS;

    pcCounter <= internal_pcCounter;

END PC_Arch;