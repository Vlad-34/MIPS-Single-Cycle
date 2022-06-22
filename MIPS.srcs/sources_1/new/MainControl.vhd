library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MainControl is
    Port ( Instr : in STD_LOGIC_VECTOR (15 downto 0);
           Zero : in STD_LOGIC; -- flag for beq operation
           GrZero : in STD_LOGIC; -- flag for bgtz operation
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUsrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUop : out STD_LOGIC_VECTOR (2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end MainControl;

architecture Behavioral of MainControl is

begin

process(Instr(15 downto 13))
begin
    case(Instr(15 downto 13)) is -- ca pe tabla
        when "000" => RegDst <= '0';
        when others => RegDst <= '1';
    end case;
end process;

process(Instr)
begin
    case(Instr(6)) is
        when '0' => ExtOp <= '0'; -- immediate sign
        when '1' => ExtOp <= '1';
    end case;
end process;


process(Instr(15 downto 13))
begin
    case(Instr(15 downto 13)) is
        when "111" => Jump <= '1'; -- j
        when others => Jump <= '0';
    end case;
end process;

process(Instr(15 downto 13))
begin
    case(Instr(15 downto 13)) is
        when "000" => ALUsrc <= '0'; -- r
        when others => ALUsrc <= '1';
    end case;
end process;

process(Instr(15 downto 13), Zero)
begin
    case(Instr(15 downto 13)) is
        when "101" => -- beq
            if Zero = '1' then
                Branch <= '1';
            end if;
        when "110" =>  -- bgtz
            if GrZero <= '1' then
                Branch <= '1';
            end if;
        when others => Branch <= '0';
    end case;
end process;

process(Instr)
begin
    if Instr(15 downto 13) = "000" then
        ALUop <= Instr(2 downto 0); -- addition, subtraction, sll, srl, and, or, xor, xnor
    else
        if Instr(15 downto 13) = "001" then -- addition
            ALUop <= "000";
        else
            if Instr(15 downto 13) = "010" then -- subtraction
                ALUop <= "001";
            else
                if Instr(15 downto 13) = "101" then -- beq
                    ALUop <= "001";
                else
                    if Instr(15 downto 13) = "110" then -- bgtz
                        ALUop <= "001";
                    else
                        ALUop <= "000";
                    end if;
                end if;
            end if;
        end if;
    end if;
end process;

process(Instr)
begin
    if Instr(15 downto 13) = "100" then -- sw
        MemWrite <= '1';
    else
        MemWrite <= '0';
    end if;
end process;

process(Instr)
begin
    if Instr(15 downto 13) = "011" then -- lw
        MemtoReg <= '1';
    else
        MemtoReg <= '0';
    end if;
end process;

process(Instr)
begin
    case(Instr(15 downto 13)) is
        when "111" => RegWrite <= '0'; -- j
        when "011" => RegWrite <= '0';  -- lw
        when "100" => RegWrite <= '0'; -- sw
        when "101" => RegWrite <= '0'; -- beq
        when "110" => RegWrite <= '0'; -- bgtz
        when others => RegWrite <= '1';
    end case;
end process;

end Behavioral;
