library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity RAM is
    Port ( clk : in STD_LOGIC;
           we : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR(15 downto 0);
           di : in STD_LOGIC_VECTOR(15 downto 0);
           do : out STD_LOGIC_VECTOR(15 downto 0));
end RAM;

architecture Behavioral of RAM is

type memory is array(0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
signal ram : memory;

begin

process(clk)
	begin
		if rising_edge(clk) then
			if we = '1' then
				ram(conv_integer(unsigned(addr))) <= di;
			end if;
		end if;
	end process;
	
do <= ram(conv_integer(unsigned(addr)));

end Behavioral;
