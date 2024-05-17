--exption unit
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;


ENTITY exption IS
    port (
    --inputs
    access_exeption : IN STD_LOGIC;--protect/free unit after anding
    overflow_exeption : IN STD_LOGIC;--alu unit
    --outputs
    Restor_data : OUT STD_LOGIC;--to data memorey unit
    output_exeption : OUT STD_LOGIC--output bit
    );
end exption;

ARCHITECTURE exption OF exption IS
BEGIN
    PROCESS (access_exeption, overflow_exeption)
    BEGIN
        IF access_exeption = '1' THEN
            output_exeption <= '1';
            Restor_data <= '1';
        ELSIF overflow_exeption = '1' THEN
            output_exeption <= '1';
        ELSE
            output_exeption <= '0';
            Restor_data <= '0';
        END IF;
    END PROCESS;
END exption;





