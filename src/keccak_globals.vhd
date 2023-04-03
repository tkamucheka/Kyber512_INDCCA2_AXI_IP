--Algorithm Name: Keccak
--Authors: Guido Bertoni, Joan Daemen, Michaël Peeters and Gilles Van Assche
--Date: January 6, 2009

--This code, originally by Guido Bertoni, Joan Daemen, MichaÃ«l Peeters and
--Gilles Van Assche as a part of the SHA-3 submission, is hereby put in the
--public domain. It is given as is, without any guarantee.

--For more information, feedback or questions, please refer to our website:
--http://keccak.noekeon.org/
library STD;
 use STD.textio.all;


  library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.std_logic_misc.all;
    use IEEE.std_logic_arith.all;
    

library work;


package keccak_globals is


constant num_plane : integer := 5;
constant num_sheet : integer := 5;
constant logD : integer :=4;
constant N : integer := 64;



--types
 type k_lane        is  array ((N-1) downto 0)  of std_logic;    
 type k_plane        is array ((num_sheet-1) downto 0)  of k_lane;    
 type k_state        is array ((num_plane-1) downto 0)  of k_plane;  

end package;