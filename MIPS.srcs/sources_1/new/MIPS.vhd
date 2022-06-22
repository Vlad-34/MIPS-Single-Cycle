library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MIPS is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR(2 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0);
           an : out STD_LOGIC_VECTOR(3 downto 0);
           led : out STD_LOGIC_VECTOR(15 downto 0));
end MIPS;

architecture Behavioral of MIPS is

component MPG is -- pentru buton
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC;
           enable : out STD_LOGIC);
end component;

component SSD is -- display
	port( input : in STD_LOGIC_VECTOR(15 downto 0);
		  clk : in STD_LOGIC;
		  cat : out STD_LOGIC_VECTOR(6 downto 0);
	  	  an : out STD_LOGIC_VECTOR(3 downto 0));
end component;

component IFetch is -- Instruction Fetch
port ( clk : in STD_LOGIC;
       btn : in STD_LOGIC;
       JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
       BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
       Jump : in STD_LOGIC;
       PCsrc : in STD_LOGIC;
       Instr : out STD_LOGIC_VECTOR(15 downto 0);
       NextInstr : out STD_LOGIC_VECTOR(15 downto 0));
end component;

component ID is -- Instruction Decode
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
end component;

component ALU is -- Execute
    Port ( A : in STD_LOGIC_VECTOR (15 downto 0);
           RD2 : in STD_LOGIC_VECTOR (15 downto 0);
           ExtImm : in STD_LOGIC_VECTOR(15 downto 0);
           ALUop : in STD_LOGIC_VECTOR(2 downto 0);
           ALUsrc : in STD_LOGIC;
           C : out STD_LOGIC_VECTOR (15 downto 0);
           Zero : out STD_LOGIC;
           GrZero : out STD_LOGIC);
end component;

component RAM is -- Memory
    Port ( clk : in STD_LOGIC;
           we : in STD_LOGIC;
           addr : in STD_LOGIC_VECTOR(15 downto 0);
           di : in STD_LOGIC_VECTOR(15 downto 0);
           do : out STD_LOGIC_VECTOR(15 downto 0));
end component;

component MainControl is
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
end component;

signal enable : STD_LOGIC; -- iesirea MPG-ului

signal RegDst_signal : STD_LOGIC; -- Main Controller
signal ExtOp_signal : STD_LOGIC;
signal ALUsrc_signal : STD_LOGIC;
signal Branch_signal : STD_LOGIC;
signal PCSrc_signal : STD_LOGIC;
signal Jump_signal : STD_LOGIC;
signal ALUop_signal : STD_LOGIC_VECTOR (2 downto 0);
signal MemWrite_signal : STD_LOGIC;
signal MemtoReg_signal : STD_LOGIC;
signal RegWrite_signal : STD_LOGIC;

signal Instr_signal : STD_LOGIC_VECTOR(15 downto 0); -- IF
signal NextInstr_signal : STD_LOGIC_VECTOR(15 downto 0);
signal JumpAddress_signal : STD_LOGIC_VECTOR(15 downto 0);
signal BranchAddress_signal : STD_LOGIC_VECTOR(15 downto 0);
signal ExtImm_signal : STD_LOGIC_VECTOR(15 downto 0);
signal WD_signal : STD_LOGIC_VECTOR(15 downto 0);

signal RD1_signal : STD_LOGIC_VECTOR (15 downto 0); -- ID
signal RD2_signal : STD_LOGIC_VECTOR (15 downto 0);

signal C_signal : STD_LOGIC_VECTOR(15 downto 0); -- EXE
signal Zero_signal : STD_LOGIC;
signal GrZero_signal : STD_LOGIC;

signal do_signal : STD_LOGIC_VECTOR(15 downto 0); -- MEM

signal input_signal : STD_LOGIC_VECTOR(15 downto 0);

begin
button: MPG port map(clk => clk, btn => btn, enable => enable);
MainController: MainControl port map(Instr => Instr_signal, Zero => Zero_signal, GrZero => GrZero_signal, RegDst => RegDst_signal, ExtOp => ExtOp_signal, ALUsrc => ALUsrc_signal, Branch => Branch_signal, Jump => Jump_signal, ALUop => ALUop_signal, MemWrite => MemWrite_signal, MemtoReg => MemtoReg_signal, RegWrite => RegWrite_signal);

JumpAddress_signal <= "000" & Instr_signal(12 downto 0);
BranchAddress_signal <= NextInstr_signal + ExtImm_signal;
PCSrc_signal <= (Branch_signal and Zero_signal) or (Branch_signal and GrZero_signal);
InstructionFetch: IFetch port map(clk => clk, btn => enable, JumpAddress => JumpAddress_signal, BranchAddress => BranchAddress_signal, Jump => Jump_signal, PCSrc => PCSrc_signal, Instr => Instr_signal, NextInstr => NextInstr_signal);

InstructionDecode: ID port map(RegWrite => RegWrite_signal, Instr => Instr_signal, RegDst => RegDst_signal, ExtOp => ExtOp_signal, WD => WD_signal, clk => clk, RD1 => RD1_signal, RD2 => RD2_signal, ExtImm => ExtImm_signal);
Execute: ALU port map(ALUsrc => ALUsrc_signal, A => RD1_signal, RD2 => RD2_signal, ExtImm => ExtImm_signal, ALUop => ALUop_signal, C => C_signal, Zero => Zero_signal, GrZero => GrZero_signal);
Memory: RAM port map(clk => clk, we => MemWrite_signal, addr => C_signal, di => RD2_signal, do => do_signal);

process(MemtoReg_signal) -- WB
begin
    if(MemtoReg_signal = '0') then
        WD_signal <= C_signal;
    else
        WD_signal <= do_signal;
    end if;
end process;

process(sw)
begin
    case(sw) is
        when "000" => input_signal <= Instr_signal;
        when "001" => input_signal <= NextInstr_signal;
        when "010" => input_signal <= RD1_signal;
        when "011" => input_signal <= RD2_signal;
        when "100" => input_signal <= ExtImm_signal;
        when "101" => input_signal <= C_signal;
        when "110" => input_signal <= do_signal;
        when "111" => input_signal <= WD_signal;
    end case;
end process;

Display: SSD port map(input => input_signal, clk => clk, cat => cat, an => an);

led(0) <= RegDst_signal;
led(1) <= ExtOp_signal;
led(2) <= Branch_signal;
led(3) <= Jump_signal;
led(6 downto 4) <= ALUop_signal;
led(7) <= MemWrite_signal;
led(8) <= MemtoReg_signal;
led(9) <= Zero_signal;
led(10) <= GrZero_signal; 
led(11) <= ALUsrc_signal;
led(12) <= RegWrite_signal;

end Behavioral;
