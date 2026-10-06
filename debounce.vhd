library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Generic (
        CLK_FREQ_HZ : integer := 100_000_000; -- Clock 100 MHz (Basys 3)
        STABLE_MS   : integer := 10          -- Waktu stabil 10 ms
    );
    Port (
        clk     : in  STD_LOGIC;
        btn_in  : in  STD_LOGIC;  -- Sinyal mentah dari tombol
        btn_out : out STD_LOGIC   -- Sinyal bersih (debounced)
    );
end debounce;

architecture Behavioral of debounce is
    -- Hitung total siklus clock yang dibutuhkan untuk stabil (100MHz * 10ms = 1.000.000 siklus)
    constant LIMIT : integer := (CLK_FREQ_HZ / 1000) * STABLE_MS;
    
    -- Register synchronizer 2-stage untuk mencegah metastabilitas
    signal ff1, ff2 : STD_LOGIC := '0';
    
    -- Counter penstabil sinyal
    signal cnt   : integer range 0 to LIMIT := 0;
    signal state : STD_LOGIC := '0';

begin

    process(clk)
    begin
        if rising_edge(clk) then
            -- 2-stage flip-flop synchronizer
            ff1 <= btn_in;
            ff2 <= ff1;

            -- Jika masukan terdeteksi berbeda dari kondisi stabil saat ini
            if ff2 /= state then
                if cnt < LIMIT - 1 then
                    cnt <= cnt + 1; -- Hitung durasi kestabilan sinyal baru
                else
                    state <= ff2;   -- Sinyal baru stabil selama LIMIT siklus -> perbarui state
                    cnt   <= 0;
                end if;
            else
                cnt <= 0; -- Reset hitungan jika masukan kembali sama dengan state
            end if;
        end if;
    end process;

    btn_out <= state;

end Behavioral;