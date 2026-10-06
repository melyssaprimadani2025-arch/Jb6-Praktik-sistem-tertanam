library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity updown_counter is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC; -- Pulsa btnC
        inc       : in  STD_LOGIC; -- Pulsa btnU
        dec       : in  STD_LOGIC; -- Pulsa btnD
        pause_btn : in  STD_LOGIC; -- Pulsa btnR (Toggle Pause)
        count_out : out STD_LOGIC_VECTOR(15 downto 0);
        is_paused : out STD_LOGIC -- Indikator status pause (opsional)
    );
end updown_counter;

architecture Behavioral of updown_counter is
    signal count_reg : unsigned(15 downto 0) := (others => '0');
    signal pause_reg : STD_LOGIC := '0'; -- '0' = Run, '1' = Pause
begin
    process(clk)
    begin
        if rising_edge(clk) then
            -- Logika Toggle Pause (Tekan btnR untuk ganti status Pause/Resume)
            if pause_btn = '1' then
                pause_reg <= not pause_reg;
            end if;

            -- Logika Pencacah (Hanya aktif jika TIDAK dalam kondisi Pause)
            if pause_reg = '0' then
                if rst = '1' then
                    count_reg <= (others => '0');
                elsif inc = '1' then
                    count_reg <= count_reg + 1;
                elsif dec = '1' then
                    count_reg <= count_reg - 1;
                end if;
            end if;
        end if;
    end process;

    count_out <= std_logic_vector(count_reg);
    is_paused <= pause_reg;
end Behavioral;