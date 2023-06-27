library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity co_cpu is
    port(t3: in std_logic;
         clr: in std_logic;
         ir: in std_logic_vector(7 downto 4);
         sw: in std_logic_vector(2 downto 0);
         w1, w2, w3: in std_logic;
         c, z: in std_logic;
         drw: out std_logic;
         pcinc, arinc: out std_logic;
         lpc, lar, lir: out std_logic;
         pcadd: out std_logic;
         selctl: out std_logic;
         memw: out std_logic;
         stp: out std_logic;
         ldz, ldc: out std_logic;
         cin: out std_logic;
         s: out std_logic_vector(3 downto 0);
         m: out std_logic;
         abus, sbus, mbus: out std_logic;
         short, long: out std_logic;
         sel: out std_logic_vector(3 downto 0));
end co_cpu;

architecture co_cpu_logic of co_cpu is
signal reg_w, reg_r, mem_w, mem_r, prog, ph: std_logic := '0';
signal nop, add, sub, and_, inc, ld, st, jc, jz, jmp, out_, xor_, cmp, mov, stp_: std_logic := '0';
begin
    if sw = "000" then
        case ir is
            when "0000" => nop <= '1';
            when "0001" => add <= '1';
            when "0010" => sub <= '1';
            when "0011" => and_ <= '1';
            when "0100" => inc <= '1';
            when "0101" => ld <= '1';
            when "0110" => st <= '1';
            when "0111" => jc <= '1';
            when "1000" => jz <= '1';
            when "1001" => jmp <= '1';
            when "1010" => out_ <= '1';
            when "1011" => xor_ <= '1';
            when "1100" => cmp <= '1';
            when "1101" => mov <= '1';
            when "1110" => stp_ <= '1';
        end case;
    else
        case sw is
            when "000" => prog <= '1';
            when "011" => reg_w <= '1';
            when "100" => reg_r <= '1';
            when "010" => mem_w <= '1';
            when "001" => mem_r <= '1';
        end case;
    end if;

    process(clr, t3, w3, w2, w1)
	begin
		if (clr = '0') then
			ph <= '0';
		elsif (t3'event and t3 = '0') then
			if (ph = '0' and ((reg_w = '1' and w2 = '1') or ((mem_r = '1' or mem_w = '1' or prog = '1') and w1 = '1'))) then
				ph <= '1';
			elsif (ph = '1' and (reg_w = '1' and w2 = '1')) then
				ph <= '0';
			end if;
		end if;
	end process;

    drw <= ((add or sub or and_ or inc or xor_ or mov) and w2) or (ld and w3) and (reg_w and (w1 or w2));
    pcinc <= prog and w1;
    arinc <= (mem_w or memr) and w1 and ph;
    lpc <= ((jmp) and w2) or (prog and w1 and not ph);
    lar <= ((ld or st) and w2) or ((mem_w or memr) and w1 and not ph);
    lir <= (prog and w1 and ph);
    pcadd <= (jc or jz) and w2;
    selctl <= ((mem_w or mem_r) and w1) or (reg_w and (w1 or w2)) or reg_r; -- why not reg_r or reg_w?
    memw <= (st and w3) or (mem_w and w1 and ph);
    stp <= (stp_ and w2) or (reg_w and (w1 or w2)) or ((mem_r or mem_w) and w1) or (prog and w1 and not ph);
    ldc <= (add or sub or inc or cmp) and w2;
    ldz <= (add or sub or and_ or xor_ or inc or cmp) and w2;
    cin <= add and w2;
    s(3) <= ((add or and_ or inc or ld or jmp or out_ or mov) and w2) or st;
    s(2) <= (sub or st or jmp or xor_ or cmp) and w2;
    s(1) <= ((sub or and_ or ld or jmp or out_ or xor_ or cmp or mov) and w2) or st;
    s(0) <= (add and and_ and st and jmp) and w2;
    m <= ((and_ or ld or jmp or out_ or xor_) and w2) or st;
    abus <= ((add or sub or and_ or inc or ld or jmp or out_ or xor_ or mov) and w2) or st;
    sbus <= (reg_w and (w1 or w2)) or (mem_w and w1) or ((mem_r or prog) and w1 and not ph);
    mbus <= (ld and w3) or (mem_r and w1 and ph);
    short <= ((mem_r or mem_w) and w1) or (prog and not ph);
    long <= (ld or st) and w2;
    sel(3) <= (reg_w and ((w1 or w2) and ph)) or (reg_r and w2);
    sel(2) <= reg_w and w2;
    sel(1) <= (reg_w and ((w1 and not ph) or (w2 and ph))) or (reg_r and w2);
    sel(0) <= (reg_w and w1) or reg_r;
end co_cpu_logic;