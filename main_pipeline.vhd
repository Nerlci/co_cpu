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
signal nop, add, sub, and_ins, inc, ld, st, jc, jz, jmp, out_ins, xor_ins, cmp, mov, stp_ins: std_logic := '0';
begin
    prog <= '1' when sw = "000" else '0';
    reg_w <= '1' when sw = "100" else '0';
    reg_r <= '1' when sw = "011" else '0';
    mem_w <= '1' when sw = "001" else '0';
    mem_r <= '1' when sw = "010" else '0';
    
    nop <= '1' when ir = "0000" and prog = '1' and ph = '1' else '0';
    add <= '1' when ir = "0001" and prog = '1' and ph = '1' else '0';
    sub <= '1' when ir = "0010" and prog = '1' and ph = '1' else '0';
    and_ins <= '1' when ir = "0011" and prog = '1' and ph = '1' else '0';
    inc <= '1' when ir = "0100" and prog = '1' and ph = '1' else '0';
    ld <= '1' when ir = "0101" and prog = '1' and ph = '1' else '0';
    st <= '1' when ir = "0110" and prog = '1' and ph = '1' else '0';
    jc <= '1' when ir = "0111" and prog = '1' and ph = '1' else '0';
    jz <= '1' when ir = "1000" and prog = '1' and ph = '1' else '0';
    jmp <= '1' when ir = "1001" and prog = '1' and ph = '1' else '0';
    out_ins <= '1' when ir = "1010" and prog = '1' and ph = '1' else '0';
    xor_ins <= '1' when ir = "1011" and prog = '1' and ph = '1' else '0';
    cmp <= '1' when ir = "1100" and prog = '1' and ph = '1' else '0';
    mov <= '1' when ir = "1101" and prog = '1' and ph = '1' else '0';
    stp_ins <= '1' when ir = "1110" and prog = '1' and ph = '1' else '0';
    

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

    drw <= ((add or sub or and_ins or inc or xor_ins or mov) and w1) or (ld and w2) or (reg_w and (w1 or w2));
    pcinc <= ((nop or add or and_ins or out_ins or xor_ins or cmp or mov) and w1) or ((st or jmp) and w2) or 
             (prog and w2 and not ph) or (jc and ((w1 and not c) or (w3 and c))) or (jz and ((w1 and not z) or (w3 and z))) or
             ((sub or inc) and w2) or (ld and w3);
    arinc <= (mem_w or mem_r) and w1 and ph;
    lpc <= ((jmp) and w1) or (prog and w1 and not ph);
    lar <= ((ld or st) and w1) or ((mem_w or mem_r) and w1 and not ph);
    lir <= ((nop or add or and_ins or out_ins or xor_ins or cmp or mov) and w1) or ((st or jmp) and w2) or 
           (prog and w2 and not ph) or (jc and ((w1 and not c) or (w3 and c))) or (jz and ((w1 and not z) or (w3 and z))) or
           ((sub or inc) and w2) or (ld and w3);
    pcadd <= ((jc and c) or (jz and z)) and w1;
    selctl <= ((mem_w or mem_r) and w1) or ((reg_r or reg_w) and (w1 or w2));
    memw <= (st and w2) or (mem_w and w1 and ph);
    stp <= (stp_ins and w1) or ((reg_r or reg_w) and (w1 or w2)) or ((mem_r or mem_w) and w1) or (prog and w1 and not ph);
    ldc <= (add or sub or inc or cmp) and w1;
    ldz <= (add or sub or and_ins or xor_ins or inc or cmp) and w1;
    cin <= add and w1;
    s(3) <= ((add or and_ins or ld or jmp or out_ins or mov) and w1) or st;
    s(2) <= (sub or st or jmp or xor_ins or cmp) and w1;
    s(1) <= ((sub or and_ins or ld or jmp or out_ins or xor_ins or cmp or mov) and w1) or st;
    s(0) <= (add or and_ins or st or jmp) and w1;
    m <= ((and_ins or ld or jmp or out_ins or xor_ins or mov) and w1) or st;
    abus <= ((add or sub or and_ins or inc or ld or jmp or out_ins or xor_ins or mov) and w1) or st;
    sbus <= (reg_w and (w1 or w2)) or (mem_w and w1) or ((mem_r or prog) and w1 and not ph);
    mbus <= (ld and w2) or (mem_r and w1 and ph);
    short <= ((mem_r or mem_w) and w1) or (prog and w1 and not ph) or 
             ((nop or add or and_ins or out_ins or xor_ins or cmp or mov or stp_ins) and w1)
             or (jc and w1 and not c) or (jz and w1 and not z);
    long <= (ld and w2) or (jc and w2 and c) or (jz and w2 and z);
    sel(3) <= (reg_w and ((w1 or w2) and ph)) or (reg_r and w2);
    sel(2) <= reg_w and w2;
    sel(1) <= (reg_w and ((w1 and not ph) or (w2 and ph))) or (reg_r and w2);
    sel(0) <= (reg_w and w1) or (reg_r and (w1 or w2));
end co_cpu_logic;