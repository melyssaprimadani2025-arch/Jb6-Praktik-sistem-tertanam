library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity js05_top is
    Port (
        clk  : in  STD_LOGIC;
        btnU : in  STD_LOGIC; -- Up
        btnD : in  STD_LOGIC; -- Down
        btnC : in  STD_LOGIC; -- Reset
        btnR : in  STD_LOGIC; -- Toggle Pause / Resume
        seg  : out STD_LOGIC_VECTOR(6 downto 0);
        dp   : out STD_LOGIC;
        an   : out STD_LOGIC_VECTOR(3 downto 0)
    );
end js05_top;

architecture Behavioral of js05_top is

    -- Sinyal internal hasil Debounce
    signal btnU_db, btnD_db, btnC_db, btnR_db : STD_LOGIC;
    
    -- Sinyal internal hasil Edge Detect (Pulsa 1-siklus)
    signal btnU_pulse, btnD_pulse, btnC_pulse, btnR_pulse : STD_LOGIC;
    
    signal counter_val : STD_LOGIC_VECTOR(15 downto 0);

begin

    ------------------------------------------------------------------
    -- 1. INSTANSIASI DEBOUNCER UNTUK SETIAP TOMBOL
    ------------------------------------------------------------------
    deb_btnU : entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 1 )
        port map ( clk => clk, btn_in => btnU, btn_out => btnU_db );

    deb_btnD : entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 1 )
        port map ( clk => clk, btn_in => btnD, btn_out => btnD_db );

    deb_btnC : entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 1 )
        port map ( clk => clk, btn_in => btnC, btn_out => btnC_db );

    deb_btnR : entity work.debounce
        generic map ( CLK_FREQ_HZ => 100_000_000, STABLE_MS => 1 )
        port map ( clk => clk, btn_in => btnR, btn_out => btnR_db );

    ------------------------------------------------------------------
    -- 2. INSTANSIASI EDGE DETECTOR UNTUK SETIAP TOMBOL
    ------------------------------------------------------------------
    edge_btnU : entity work.edge_detect
        port map ( clk => clk, sig_in => btnU_db, pulse => btnU_pulse );

    edge_btnD : entity work.edge_detect
        port map ( clk => clk, sig_in => btnD_db, pulse => btnD_pulse );

    edge_btnC : entity work.edge_detect
        port map ( clk => clk, sig_in => btnC_db, pulse => btnC_pulse );

    edge_btnR : entity work.edge_detect
        port map ( clk => clk, sig_in => btnR_db, pulse => btnR_pulse );

    ------------------------------------------------------------------
    -- 3. INSTANSIASI PENCACAH (UP/DOWN/RESET/PAUSE)
    ------------------------------------------------------------------
    counter : entity work.updown_counter
        port map (
            clk       => clk,
            rst       => btnC_pulse,
            inc       => btnU_pulse,
            dec       => btnD_pulse,
            pause_btn => btnR_pulse,
            count_out => counter_val,
            is_paused => open
        );

    ------------------------------------------------------------------
    -- 4. INSTANSIASI DRIVER 7-SEGMENT (HEXADECIMAL)
    ------------------------------------------------------------------
    display : entity work.seven_seg_driver
        generic map ( CLK_FREQ_HZ => 100_000_000, DIGITS => 4 )
        port map (
            clk     => clk,
            data_in => counter_val,
            seg     => seg,
            dp      => dp,
            an      => an
        );

end Behavioral;