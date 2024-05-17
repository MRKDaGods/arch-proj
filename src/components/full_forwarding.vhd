--full forwarding unit

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

LIBRARY mrk;
USE mrk.COMMON.ALL;

entity forwarding_unit is
    PORT (
        data_to_be_forwarded : in std_logic_vector(31 downto 0);--ex/mem
        destination_register : in std_logic_vector(2 downto 0);--ex/mem
        opcode : in std_logic_vector(5 downto 0);--ex/mem

        data_to_be_forwarded_wb : in std_logic_vector(31 downto 0);--mem/wb
        destination_register_wb : in std_logic_vector(2 downto 0);--mem/wb
        opcode_wb : in std_logic_vector(5 downto 0);--mem/wb

        refister_sourse1 : in std_logic_vector(2 downto 0);--de/ex
        refister_sourse2 : in std_logic_vector(2 downto 0);--de/ex
        data_forwarded_out1 : out std_logic_vector(31 downto 0);--de/ex
        data_forwarded_out2 : out std_logic_vector(31 downto 0)--de/ex
    );
end forwarding_unit;

architecture forwarding_unit_arch of forwarding_unit is
begin
    process(data_to_be_forwarded, destination_register, data_to_be_forwarded_wb, destination_register_wb, refister_sourse1, refister_sourse2)
    begin
        if destination_register_wb = refister_sourse1 and opcode = 7aga b twrite fe reg then
            data_forwarded_out1<=data_to_be_forwarded_wb;
        elsif destination_register_wb = refister_sourse2 and opcode = 7aga b twrite fe reg  then
            data_forwarded_out2<=data_to_be_forwarded_wb;
        elsif destination_register = refister_sourse1 and opcode = 7aga b twrite fe reg  then
            data_forwarded_out1<=data_to_be_forwarded;
        else
        data_forwarded_out2<=data_to_be_forwarded;
        end if;
    end process;
end forwarding_unit_arch;