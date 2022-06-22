library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ID is
    Port ( RegWrite : in STD_LOGIC;
           Instr : in STD_LOGIC_VECTOR (15 downto 0);
           RegDst : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           WD : in STD_LOGIC_VECTOR (15 downto 0);
           clk : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR (15 downto 0);
           RD2 : out STD_LOGIC_VECTOR (15 downto 0);
           ExtImm : out STD_LOGIC_VECTOR (15 downto 0)
           -- Func : out STD_LOGIC_VECTOR (2 downto 0);
           -- Sa : out STD_LOGIC);
           );
end ID;

architecture Behavioral of ID is

signal WA : STD_LOGIC_VECTOR(2 downto 0);

type memory is array(0 to 15) of STD_LOGIC_VECTOR(15 downto 0);
signal regfile : memory := (others => x"0000");

begin
-- MUX
--process(RegDst)
--begin
--    case RegDst is
--        when '1' => WA <= Instr(6 downto 4);
--        when '0' => WA <= Instr(9 downto 7);
--    end case;
--end process;

--RegFile
RD1 <= regfile(conv_integer(unsigned(Instr(12 downto 10))));
RD2 <= regfile(conv_integer(unsigned(Instr(9 downto 7))));
process(clk)
begin
    case RegDst is
        when '0' => WA <= Instr(6 downto 4);
        when '1' => WA <= Instr(9 downto 7);
    end case;
	if rising_edge(clk) then
	   if RegWrite = '1' then
	       regfile(conv_integer(unsigned(WA))) <= WD;
	   end if;
	end if;
end process;

-- Extender
process(ExtOp)
begin
    case ExtOp is
        when '0' => ExtImm <= "000000000" & Instr(6 downto 0);     
        when '1' => ExtImm <= "111111111" & Instr(6 downto 0);
        
    end case;
end process;

-- Func <= Instr(2 downto 0);
-- Sa <= Instr(3);
	
end Behavioral;
