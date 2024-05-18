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
        pcWait : IN STD_LOGIC; -- from FETCH, do we need to wait?

        enforcedPcExecute : IN MEM_ADDRESS; -- from EXECUTE, do we need to enforce PC?
        enforcedPcMemory : IN MEM_ADDRESS;
        reset_address : IN MEM_ADDRESS;

        pcCounter : OUT MEM_ADDRESS
    );
END ENTITY PC;

ARCHITECTURE PC_Arch OF PC IS
    SIGNAL internal_pcCounter : MEM_ADDRESS;

BEGIN
    PROCESS (clk, reset)
    BEGIN
        IF reset'event THEN
            -- reset pc to 0
            internal_pcCounter <= reset_address;
        ELSIF rising_edge(clk) THEN
            IF enforcedPcMemory /= (0 TO 31 => '1') AND enforcedPcMemory /= (0 TO 31 => 'U') THEN
                -- if we're enforcing PC, set PC to the enforced value
                internal_pcCounter <= enforcedPcMemory;
            ELSIF enforcedPcExecute /= (0 TO 31 => '1') AND enforcedPcExecute /= (0 TO 31 => 'U') THEN
                internal_pcCounter <= enforcedPcExecute;
            ELSIF pcWait = '0' THEN
                -- in rising edge, we'll increment PC as usual
                internal_pcCounter <= STD_LOGIC_VECTOR(unsigned(internal_pcCounter) + 1);
            END IF;
        ELSIF falling_edge(clk) THEN
            -- if we're on falling edge, we'll increment PC again if extra_reads is high
            IF extra_reads = '1' AND pcWait = '0' THEN
                internal_pcCounter <= STD_LOGIC_VECTOR(unsigned(internal_pcCounter) + 1);
            END IF;
        END IF;
    END PROCESS;

    pcCounter <= internal_pcCounter;

END PC_Arch;