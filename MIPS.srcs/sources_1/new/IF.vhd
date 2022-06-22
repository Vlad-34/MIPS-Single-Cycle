library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity IFetch is
port ( clk : in STD_LOGIC;
       btn : in STD_LOGIC;
       JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
       BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
       Jump : in STD_LOGIC;
       PCsrc : in STD_LOGIC;
       Instr : out STD_LOGIC_VECTOR(15 downto 0);
       NextInstr : out STD_LOGIC_VECTOR(15 downto 0));
end IFetch;

architecture Behavioral of IFetch is

type ROM_type is array (0 to 255) of std_logic_vector (15 downto 0);
signal ROM : ROM_type := (B"001_001_001_0000001",
B"001_001_010_0000011",
B"000_010_001_011_0_000",
B"100_000_011_0000111",
B"011_000_100_0000111",
B"000_100_010_010_0_001"
, others => x"0000");

signal iesireMuxJump: STD_LOGIC_VECTOR(15 downto 0);
signal iesireMuxPCSrc: STD_LOGIC_VECTOR(15 downto 0);

signal iesireAdunare: STD_LOGIC_VECTOR(15 downto 0);
signal instructiune: STD_LOGIC_VECTOR(15 downto 0);

begin
        
    process(clk)
    begin
        if rising_edge(clk) then
            if btn = '1' then
                instructiune <= iesireMuxJump;
            end if;
        end if;
    end process;
    
    Instr <= ROM(conv_integer(instructiune));
    iesireAdunare <= instructiune + 1;
    NextInstr <= iesireAdunare;
    
    process(PCSrc, iesireAdunare, branchAddress)
    begin
        case PCSrc is
            when '0' => iesireMuxPCSrc <= iesireAdunare;
            when '1' => iesireMuxPCSrc <= branchAddress;
        end case;
    end process; 
    
    process(iesireMuxPCSrc, Jump)
    begin
        case Jump is
            when '0' => iesireMuxJump <= iesireMuxPCSrc;
            when '1' => iesireMuxJump <= jumpAddress;
        end case;
    end process;
    
end Behavioral;
