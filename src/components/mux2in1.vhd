library ieee;
use ieee.std_logic_1164.all;

entity mux2in1 is
    port (
        a : in std_logic;
        b : in std_logic;
        sel : in std_logic;
        y : out std_logic
    );
end mux2in1;

architecture architecture_mux2in1 of mux2in1 is
begin
    process(a, b, sel)
    begin
        if sel = '0' then
            y <= a;
        else
            y <= b;
        end if;
    end process;
end architecture_mux2in1;