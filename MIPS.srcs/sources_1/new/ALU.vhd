library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( A : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           ExtImm : in STD_LOGIC_VECTOR(15 downto 0);
           ALUop : in STD_LOGIC_VECTOR(2 downto 0);
           ALUsrc : in STD_LOGIC;
           C : out STD_LOGIC_VECTOR (15 downto 0);
           Zero : out STD_LOGIC;
           GrZero : out STD_LOGIC);
end ALU;

architecture Behavioral of ALU is

signal B_signal : STD_LOGIC_VECTOR(15 downto 0);
signal C_signal : STD_LOGIC_VECTOR(15 downto 0);

begin

    process(ALUsrc)
    begin
        if ALUsrc = '0' then
             B_signal <= RD2;
        else
             B_signal <= ExtImm;
        end if;
    end process;
    
    process(ALUop)
    begin

        case(ALUop) is
            when "000" => C_signal <= A + B_signal;
            when "001" => C_signal <= A - B_signal;
            when "010" => C_signal <= "0000" & A(11 downto 0);
            when "011" => C_signal <= "0000" & A(11 downto 0);
            when "100" => C_signal <= A and B_signal;
            when "101" => C_signal <= A or B_signal;
            when "110" => C_signal <= A xor B_signal;
            when "111" => C_signal <= A xnor B_signal;
        end case;    

        if C_signal = 0 then
            Zero <= '1';
        else
            Zero <= '0';
        end if;
        if C_signal > 0 then
            GrZero <= '1';
        else
            GrZero <= '0';
        end if;   
    end process;
    
C <= C_signal;

end Behavioral;
