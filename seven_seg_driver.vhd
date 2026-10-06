library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity seven_seg_driver is
    Generic (
        CLK_FREQ_HZ : integer := 100_000_000;
        DIGITS      : integer := 4
    );
    Port (
        clk     : in  STD_LOGIC;
        data_in : in  STD_LOGIC_VECTOR(15 downto 0); -- 4 digit @ 4-bit (Hex)
        seg     : out STD_LOGIC_VECTOR(6 downto 0);  -- Katoda g-a (Active Low)
        dp      : out STD_LOGIC;                     -- Decimal Point (Active Low)
        an      : out STD_LOGIC_VECTOR(3 downto 0)   -- Anoda seleksi digit (Active Low)
    );
end seven_seg_driver;

architecture Behavioral of seven_seg_driver is
    -- Refresh rate ~1 kHz per digit (~250 Hz total)
    constant REFRESH_LIMIT : integer := CLK_FREQ_HZ / (1000 * DIGITS);
    signal refresh_cnt     : integer range 0 to REFRESH_LIMIT := 0;
    signal digit_sel       : unsigned(1 downto 0) := "00";
    signal current_nibble  : STD_LOGIC_VECTOR(3 downto 0);

    -- Konversi Hex ke Seven-Segment (Active Low: '0' = Nyala, '1' = Padam)
    -- Urutan segmen: "g f e d c b a"
    function hex_to_seg(hex : STD_LOGIC_VECTOR(3 downto 0)) return STD_LOGIC_VECTOR is
    begin
        case hex is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0100010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when "1010" => return "0001000"; -- A
            when "1011" => return "0000011"; -- b
            when "1100" => return "1000110"; -- C
            when "1101" => return "0100001"; -- d
            when "1110" => return "0000110"; -- E
            when "1111" => return "0001110"; -- F
            when others => return "1111111"; -- Blank
        end case;
    end function;

begin
    -- Timer Multiplexing
    process(clk)
    begin
        if rising_edge(clk) then
            if refresh_cnt < REFRESH_LIMIT then
                refresh_cnt <= refresh_cnt + 1;
            else
                refresh_cnt <= 0;
                digit_sel   <= digit_sel + 1;
            end if;
        end if;
    end process;

    -- Seleksi Digit & Multiplexing Anoda (Active Low)
    process(digit_sel, data_in)
    begin
        case digit_sel is
            when "00" =>
                an             <= "1110"; -- Digit 0 (Paling Kanan)
                current_nibble <= data_in(3 downto 0);
            when "01" =>
                an             <= "1101"; -- Digit 1
                current_nibble <= data_in(7 downto 4);
            when "10" =>
                an             <= "1011"; -- Digit 2
                current_nibble <= data_in(11 downto 8);
            when "11" =>
                an             <= "0111"; -- Digit 3 (Paling Kiri)
                current_nibble <= data_in(15 downto 12);
            when others =>
                an             <= "1111";
                current_nibble <= "0000";
        end case;
    end process;

    seg <= hex_to_seg(current_nibble);
    dp  <= '1'; -- Matikan titik desimal
end Behavioral;