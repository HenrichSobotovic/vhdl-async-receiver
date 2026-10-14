-- uart_rx_fsm.vhd: UART controller - finite state machine controlling RX side
-- Author(s): Henrich Sobotovič xsoboth00

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

 

entity UART_RX_FSM is
    port(
       CLK : in std_logic;
       RST : in std_logic;
       DIN : in std_logic; 
       CNT_DONE : in std_logic;
       MID_DONE : in std_logic;
       BIT_DONE : in std_logic;
       CNT_START : out std_logic;
       READ_START : out std_logic; 
       DOUT_VLD : out std_logic
    );
end entity;



architecture behavioral of UART_RX_FSM is
    type status is (START_BIT, FIRST_BIT, GET_DATA, STOP_BIT);
    signal now_state : status := START_BIT; 
    signal next_state : status; 
begin
    state_logic: process(CLK)
    begin 
        if rising_edge(CLK) then
            if RST = '1' then 
                now_state <= START_BIT;
            else 
                now_state <= next_state;
            end if;
        end if;
    end process; 
    next_state_logic: process(now_state, DIN, MID_DONE, CNT_DONE, BIT_DONE)
    begin 
        next_state <= now_state; 
        CNT_START   <= '0';
        READ_START  <= '0';
        DOUT_VLD <= '0';
        case now_state is
            when START_BIT => 
                if DIN = '0' then 
                    next_state <= FIRST_BIT;
                end if;
            when FIRST_BIT =>
                CNT_START <= '1';
                if MID_DONE = '1' then
                    next_state <= GET_DATA;
                end if;

            when GET_DATA =>
                CNT_START <= '1';
                READ_START <= '1';
                if BIT_DONE = '1' then
                    next_state <= STOP_BIT;
                end if;

            when STOP_BIT =>
                CNT_START <= '1';
                if CNT_DONE = '1' then
                    next_state <= START_BIT;
                    DOUT_VLD <= '1';
                end if;

            when others =>
                next_state <= START_BIT;
        end case;
    end process;
end architecture;
