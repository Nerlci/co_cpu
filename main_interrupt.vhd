library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity co_cpu is
    port(t3, pulse: in std_logic;
         clr: in std_logic;
         ir: in std_logic_vector(7 downto 4);
         sw: in std_logic_vector(2 downto 0);
         w1, w2, w3: in std_logic;
         c, z: in std_logic;
         light_int: out std_logic;
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
signal nop, add, sub, and_ins, inc, ld, st, jmp, out_ins, iret, di, ei, stp_ins: std_logic := '0';
signal int, in_int, empty: std_logic := '0';
signal int_en: std_logic := '1';
begin
    prog <= '1' when sw = "000" else '0';
    reg_w <= '1' when sw = "100" else '0';
    reg_r <= '1' when sw = "011" else '0';
    mem_w <= '1' when sw = "001" else '0';
    mem_r <= '1' when sw = "010" else '0';
    
    nop <= '1' when ir = "0000" and prog = '1' and ph = '1' and empty = '0' else '0';
    add <= '1' when ir = "0001" and prog = '1' and ph = '1' and empty = '0' else '0';
    sub <= '1' when ir = "0010" and prog = '1' and ph = '1' and empty = '0' else '0';
    and_ins <= '1' when ir = "0011" and prog = '1' and ph = '1' and empty = '0' else '0';
    inc <= '1' when ir = "0100" and prog = '1' and ph = '1' and empty = '0' else '0';
    ld <= '1' when ir = "0101" and prog = '1' and ph = '1' and empty = '0' else '0';
    st <= '1' when ir = "0110" and prog = '1' and ph = '1' and empty = '0' else '0';
    jmp <= '1' when ir = "1001" and prog = '1' and ph = '1' and empty = '0' else '0';
    out_ins <= '1' when ir = "1010" and prog = '1' and ph = '1' and empty = '0' else '0';
    iret <= '1' when ir = "1011" and prog = '1' and ph = '1' and empty = '0' else '0';
    di <= '1' when ir = "1100" and prog = '1' and ph = '1' and empty = '0' else '0';
    ei <= '1' when ir = "1101" and prog = '1' and ph = '1' and empty = '0' else '0';
    stp_ins <= '1' when ir = "1110" and prog = '1' and ph = '1' and empty = '0' else '0';
    

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

    process(clr, pulse, int_en)
    begin
        if (clr = '0') then
            int <= '0';
        elsif (int_en = '1') then
            if (pulse'event and pulse = '1') then
                int <= '1';
            end if;
        else
            int <= '0';
        end if;
    end process;

    process(clr, int, in_int, ei, di, iret, prog, w2, ph)
    begin
        if (clr = '0') then
            int_en <= '1';
        elsif (int = '1' and in_int = '1' and prog = '1' and w2 = '1' and ph = '1') then
            int_en <= '0';
        elsif ((int = '0' and in_int = '1') or (di = '1' and w2 = '1' and ph = '1')) then
            int_en <= '0';
        elsif (iret = '1' and w2 = '1' and ph = '1') then
            int_en <= '1';
        elsif (in_int = '0' and ei = '1' and w2 = '1' and ph = '1') then
            int_en <= '1';
        end if;
    end process;

    process(clr, int, prog, ph, w1, w2, w3, ld, st, iret)
    begin
        if (clr = '0') then
            in_int <= '0';
        elsif (int = '1' and (prog = '1' and ph = '1' and w3 = '1')) then
            in_int <= '1';
        elsif (iret = '1' and w2 = '1' and ph = '1') then
            in_int <= '0';
        end if;
    end process;

    process(clr, prog, ph, w1, int, in_int)
    begin
        if (clr = '0') then
            empty <= '0';
        elsif (prog = '1' and w1 = '1' and ph = '1' and int = '1' and in_int = '1') then
            empty <= '1';
        elsif (prog = '1' and w1 = '1' and ph = '1' and int = '0' and in_int = '1') then
            empty <= '0';
        end if;
    end process;

    
    light_int <= int;
    
    drw <= ((add or sub or and_ins or inc or (jmp and not in_int)) and w2) or (ld and w3) or (reg_w and (w1 or w2)) or (prog and w1 and not in_int);
    pcinc <= prog and w1 and ph and not (in_int and int);
    arinc <= (mem_w or mem_r) and w1 and ph;
    lpc <= ((jmp or iret) and w2) or (prog and w1 and not ph) or (prog and w1 and ph and in_int and int);
    lar <= ((ld or st) and w2) or ((mem_w or mem_r) and w1 and not ph);
    lir <= prog and w1 and ph and not (in_int and int);
    selctl <= ((mem_w or mem_r) and w1) or ((reg_r or reg_w) and (w1 or w2)) or (prog and w1 and not in_int);
    memw <= (st and w3) or (mem_w and w1 and ph);
    stp <= (stp_ins and w2) or ((reg_r or reg_w) and (w1 or w2)) or ((mem_r or mem_w) and w1) or (prog and w1 and not ph) or (prog and w1 and ph and in_int and int);
    ldc <= (add or sub or inc) and w2;
    ldz <= (add or sub or and_ins  or inc) and w2;
    cin <= add and w2;
    s(3) <= ((add or and_ins or ld or jmp or iret or out_ins) and w2) or st;
    s(2) <= (sub or st or iret) and w2;
    s(1) <= ((sub or and_ins or ld or jmp or iret or out_ins) and w2) or st;
    s(0) <= (add or and_ins or st or iret) and w2;
    m <= ((and_ins or ld or jmp or iret or out_ins) and w2) or st;
    abus <= ((add or sub or and_ins or inc or ld or jmp or iret or out_ins) and w2) or st or (prog and w1 and ph and not in_int);
    sbus <= (reg_w and (w1 or w2)) or (mem_w and w1) or ((mem_r or prog) and w1 and not ph) or (prog and w1 and ph and in_int and int);
    mbus <= (ld and w3) or (mem_r and w1 and ph);
    short <= ((mem_r or mem_w) and w1) or (prog and w1 and not ph);
    long <= ((ld or st or int) and w2);
    sel(3) <= (reg_w and ((w1 or w2) and ph)) or (reg_r and w2) or (prog and w1 and not in_int);
    sel(2) <= (reg_w and w2) or (prog and w1 and not in_int);
    sel(1) <= (reg_w and ((w1 and not ph) or (w2 and ph))) or (reg_r and w2);
    sel(0) <= (reg_w and w1) or (reg_r and (w1 or w2));
end co_cpu_logic;
