-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Henrich Sobotovič xsoboth00

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

 

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;



-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal cnt_start   : std_logic;
    signal read_start  : std_logic;
    
    signal mid_done  : std_logic;
    signal cnt_done  : std_logic;
    signal bit_done  : std_logic;

    signal cycle_cnt : std_logic_vector(3 downto 0);
    signal bit_cnt   : std_logic_vector(3 downto 0); 
    
    signal data  : std_logic_vector(7 downto 0);
begin

    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK      => CLK,
        RST      => RST,
        DIN      => DIN,
        CNT_DONE => cnt_done,
        MID_DONE => mid_done,
        BIT_DONE => bit_done,
        CNT_START   => cnt_start,
        READ_START  => read_start,
        DOUT_VLD => DOUT_VLD
    );
    cycle_counter: process(CLK)
    begin
        if rising_edge(CLK) then
            if cnt_start = '1' then
                cycle_cnt <= cycle_cnt + 1;
            else
                cycle_cnt <= (others => '0'); 
            end if;
        end if;
    end process;

    bit_counter: process(CLK)
    begin
        if rising_edge(CLK) then
            if read_start = '1' then
                if mid_done = '1' then
                    bit_cnt <= bit_cnt + 1;
                end if;
            else
                bit_cnt <= (others => '0'); 
            end if;
        end if;
    end process;
    data_shift_register: process(CLK)
    begin
        if rising_edge(CLK) then
            if read_start = '1' and mid_done = '1' then
                data(7) <= DIN;
                data(6 downto 0) <= data(7 downto 1);
            end if;
        end if;
    end process;

    DOUT <= data;

    bit_done <= '1' when bit_cnt = "1000" else '0'; 
    mid_done <= '1' when cycle_cnt = "0111" else '0'; 
    cnt_done <= '1' when cycle_cnt = "1111" else '0';
end architecture;
