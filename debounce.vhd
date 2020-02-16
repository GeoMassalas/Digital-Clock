library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce is
    generic(
        pulse: boolean := true;
        active_low: boolean := true;
        delay: integer := 100000);
    port (
        clk: in std_logic;
        reset: in std_logic; -- active high
        input: in std_logic;
        debounce: out std_logic);
end debounce ;

architecture arch of debounce is
    signal sample: std_logic_vector(9 downto 0) := "0001111000";
    signal sample_pulse: std_logic := '0';

begin

    process(clk) -- clock Divider
        variable count: integer := 0;
    begin  
        if clk'event and clk = '1' then
            if reset = '1' then
                count := 0;
                sample_pulse <= '0';
            else
                if count < delay then
                    count := count + 1;
                    sample_pulse <= '0';
                else
                    count := 0;
                    sample_pulse <= '1';
                end if;
            end if;
        end if;
    end process;

    process(clk) -- sampling process
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                sample <= (others => input);
            else
                if sample_pulse = '1' then
                    sample(9 downto 1) <= sample(8 downto 0);
                    sample(0) <= input;
                end if;
            end if;
        end if;
    end process;
    
    process(clk) -- button debouncing
        variable flag: std_logic := '0';
    begin
        if clk'event and clk = '1' then
            if reset = '1' then
                debounce <= '0';
            else
                if active_low then
                    if pulse then
                        if sample = "0000000000" then -- active low pulse out
                            if flag = '0' then
                                debounce <= '1';
                                flag := '1';
                            else
                                debounce <= '0';
                            end if;
                        else
                            debounce <= '0';
                            flag := '0';
                        end if;
                    else
                        if sample = "0000000000" then   -- active low constant out
                            debounce <= '1';
                        elsif sample = "1111111111" then
                            debounce <= '0';
                        end if;
                    end if;
                else
                    if pulse then
                        if sample = "1111111111" then -- active high pulse out
                            if flag = '0' then
                                debounce <= '1';
                                flag := '1';
                            else
                                debounce <= '0';
                            end if;
                        else
                            debounce <= '0';
                            flag := '0';
                        end if;
                    else
                        if sample = "1111111111" then   -- active high constant out
                            debounce <= '1';
                        elsif sample = "0000000000" then
                            debounce <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture ;