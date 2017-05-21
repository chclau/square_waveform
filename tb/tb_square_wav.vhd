------------------------------------------------------------------
-- Name		   : square_wav.vhd
-- Description : Arbitrary square waveform generator
-- Designed by : Claudio Avi Chami - FPGA Site
--               fpgasite.blogspot.com
-- Date        : 21/05/2017
-- Version     : 1.0
------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.top_pkg.all;


entity tb_square_wave is
   Port ( 
      clk       : in STD_LOGIC;
      reset     : in STD_LOGIC;
      data_out  : out STD_LOGIC
   );
end tb_square_wave;

architecture Behavioral of tb_square_wave is
   -- Used for frequency generation
   constant FREQ1    : natural := 242720;            -- in Hz
   constant FREQ2    : natural := 23600;             
   constant FREQ3    : natural := 57400;
   constant CNT1     : natural := (10*SYS_FREQ/FREQ1 + 5)/10;
   constant CNT2     : natural := (10*SYS_FREQ/FREQ2 + 5)/10;
   constant CNT3     : natural := (10*SYS_FREQ/FREQ3 + 5)/10;

   -- Used for duty cycle of output signal
   constant ACT_HIGH1 : natural := 1200;              -- in ns
   constant ACT_HIGH2 : natural := 15000;             -- in ns
   constant ACT_HIGH3 : natural := 9000;              -- in ns
   constant CNT_H1   : natural := (ACT_HIGH1*SYS_FREQ+5e8) / 1e9;
   constant CNT_H2   : natural := (ACT_HIGH2*SYS_FREQ+5e8) / 1e9;
   constant CNT_H3   : natural := (ACT_HIGH3*SYS_FREQ+5e8) / 1e9;
   constant NCYCLES1 : natural := 3;
   constant NCYCLES2 : natural := 1;
   constant NCYCLES3 : natural := 2;
       
   signal   freq_cnt : unsigned(15 downto 0);
   signal   act_cnt  : unsigned(15 downto 0);
   signal   cyc_cnt  : unsigned(15 downto 0);
     
   type sm_type is (idle, cyc1, cyc2, cyc3);
   signal   state    : sm_type;  

begin
   seq_pr : process(clk)
   begin
      if (rising_edge(clk)) then
         if (reset = '1') then
            state    <= idle;
            data_out <= '0';
         else  
            case(state) is
               when idle =>
                  freq_cnt <= to_unsigned(CNT1-1, 16); 
                  act_cnt  <= to_unsigned(CNT_H1-1, 16); 
                  cyc_cnt  <= to_unsigned(NCYCLES1-1, 16);          
                  data_out <= '1';
                  state    <= cyc1;  
               when cyc1 =>
                  -- Active high timing
                  if (act_cnt = 0) then
                     data_out <= '0';
                  else
                     act_cnt  <= act_cnt - 1;  
                  end if;
              
                  -- Frequency and cycles                
                  if (freq_cnt = 0) then                
                     -- check number of cycles for this frequency
                     data_out <= '1';
                     if (cyc_cnt = 0) then
                        freq_cnt <= to_unsigned(CNT2-1, 16);          
                        act_cnt  <= to_unsigned(CNT_H2-1, 16);          
                        cyc_cnt  <= to_unsigned(NCYCLES2-1, 16);          
                        state    <= cyc2;
                     else   
                        cyc_cnt  <= cyc_cnt - 1;              
                        freq_cnt <= to_unsigned(CNT1-1, 16);          
                        act_cnt  <= to_unsigned(CNT_H1-1, 16);          
                     end if;
                  else     
                     freq_cnt <= freq_cnt - 1;
                  end if;  
              
               when cyc2 =>
                  -- Active high timing
                  if (act_cnt = 0) then
                     data_out <= '0';
                  else
                     act_cnt  <= act_cnt - 1;  
                  end if;
              
                  -- Frequency and cycles                
                  if (freq_cnt = 0) then                
                     -- check number of cycles for this frequency
                     data_out <= '1';
                     if (cyc_cnt = 0) then
                        freq_cnt <= to_unsigned(CNT3-1, 16);          
                        act_cnt  <= to_unsigned(CNT_H3-1, 16);          
                        cyc_cnt  <= to_unsigned(NCYCLES3-1, 16);          
                        state    <= cyc3;
                     else   
                        cyc_cnt  <= cyc_cnt - 1;              
                        freq_cnt <= to_unsigned(CNT2-1, 16);          
                        act_cnt  <= to_unsigned(CNT_H2-1, 16);          
                     end if;
                  else     
                     freq_cnt <= freq_cnt - 1;
                  end if;  
            
               when cyc3 =>
                  -- Active high timing
                  if (act_cnt = 0) then
                     data_out <= '0';
                  else
                     act_cnt  <= act_cnt - 1;  
                  end if;
            
                  if (freq_cnt = 0) then                
                     -- check number of cycles for this frequency
                     data_out <= '1';
                     if (cyc_cnt = 0) then
                        freq_cnt <= to_unsigned(CNT1-1, 16);          
                        act_cnt  <= to_unsigned(CNT_H1-1, 16);          
                        cyc_cnt  <= to_unsigned(NCYCLES1-1, 16);          
                        state    <= cyc1;
                     else   
                        cyc_cnt  <= cyc_cnt - 1;              
                        freq_cnt <= to_unsigned(CNT3-1, 16);          
                        act_cnt  <= to_unsigned(CNT_H3-1, 16);          
                     end if;
                  else     
                     freq_cnt <= freq_cnt - 1;
                  end if;  
            
               when others =>
                  state <= idle;
            end case;
         end if;
      end if;  
   end process seq_pr;           

end Behavioral;