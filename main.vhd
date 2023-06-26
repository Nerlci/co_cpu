library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity co_cpu is
    port(t3: in std_logic;
         ir: in std_logic_vector(7 downto 4);
         swa, swb, swc: in std_logic;
         w1, w2, w3: in std_logic;
         c, z: in std_logic;
         drw: out std_logic;
         pcinc, arinc: out std_logic;
         lpc, lar: out std_logic;
         pcadd: out std_logic;
         selctl: out std_logic;
         memw: out std_logic;
         stp: out std_logic;
         lir, ldz, ldc: out std_logic;
         cin: out std_logic;
         s: out std_logic_vector(3 downto 0);
         m: out std_logic;
         abus, sbus, mbus: out std_logic;
         short, long: out std_logic;
         sel: out std_logic_vector(3 downto 0));
end co_cpu;

architecture co_cpu_logic of co_cpu is
begin

end co_cpu_logic;