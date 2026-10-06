library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_debounce is
end tb_debounce;

architecture Behavioral of tb_debounce is
    signal clk     : STD_LOGIC := '0';
    signal btn_in  : STD_LOGIC := '0';
    signal btn_out : STD_LOGIC;

    constant CLK_PERIOD : time := 10 ns; -- Clock 100 MHz
begin

    -- Generator Clock
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    -- UUT (Unit Under Test)
    uut : entity work.debounce
        generic map (
            CLK_FREQ_HZ => 100_000_000,
            STABLE_MS   => 1 -- Menggunakan 1 ms untuk simulasi cepat
        )
        port map (
            clk     => clk,
            btn_in  => btn_in,
            btn_out => btn_out
        );

    -- Stimulus Simulasi Bouncing Tombol
    stim_proc: process
    begin
        wait for 100 ns;

        -- Simulasi Penekanan Tombol (Bouncing)
        btn_in <= '1'; wait for 50 us;
        btn_in <= '0'; wait for 30 us;
        btn_in <= '1'; wait for 100 us;
        btn_in <= '0'; wait for 20 us;
        btn_in <= '1'; -- Mulai Stabil '1'

        -- Tunggu melebihi ambang batas penstabilan (1 ms)
        wait for 1.5 ms;

        -- Simulasi Pelepasan Tombol (Bouncing)
        btn_in <= '0'; wait for 40 us;
        btn_in <= '1'; wait for 20 us;
        btn_in <= '0'; -- Mulai Stabil '0'

        wait for 1.5 ms;
        wait;
    end process;

end Behavioral;