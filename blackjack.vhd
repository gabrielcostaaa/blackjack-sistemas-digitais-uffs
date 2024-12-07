library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity blackjack is
    port (

        key : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- key(2) => START/RESET; key(3) => CLOCK;
        sw : IN STD_LOGIC_VECTOR(9 DOWNTO 0); -- -- sw(6) => HIT; sw(7) => STAY; sw(3), sw(2), sw(1), sw(0) => CARTA_CIRCUITO_EXTERNO;

        hex0 : out std_logic_vector(6 downto 0);  -- unidade soma cartas decimal
        hex1 : out std_logic_vector(6 downto 0);  -- dezena soma cartas decimal
        hex2 : out std_logic_vector(6 downto 0);  -- usado para escrever em alguns estados
        hex3 : out std_logic_vector(6 downto 0);  -- hexadecimal carta mão

        --ledR : out std_logic_vector(9 downto 0)  -- WIN (7,8,9); TIE (4,5); LOSE (0,1,2);
        ledg : out std_logic_vector(7 downto 0)
    );
end blackjack;

architecture gurizes of blackjack is

  
  type tipo_estado is (
        inicio,
        jogador,
        jogador_as,
        carteador,
        carteador_as,
        resultado
    );

    signal estado_atual : tipo_estado := inicio;

    signal carta_atual : std_logic_vector(3 downto 0) := "0000";
    signal carta_circuito_externo : std_logic_vector(3 downto 0) := "0000";

    signal soma_cartas_jogador : integer := 0;
    signal soma_cartas_carteador : integer := 0;

    signal possui_as : std_logic_vector(1 downto 0) := "00";

    signal distribui : std_logic_vector(1 downto 0) := "00";

    signal temp_hex0 : std_logic_vector(6 downto 0);
    signal temp_hex1 : std_logic_vector(6 downto 0);

    function conversao_hexadecimal(carta : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case carta is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111001"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when "1010" => return "0001000"; -- A (10)
            when "1011" => return "0000011"; -- b (11)
            when "1100" => return "1000110"; -- c (12)
            when "1101" => return "0100001"; -- d (13)
            when others => return "1000000";
        end case;
    end conversao_hexadecimal;


    function conversao_unidade(valor : integer) return std_logic_vector is
    begin
        case valor is
            when 0 => return "1000000";
            when 1 => return "1111001";
            when 2 => return "0100100";
            when 3 => return "0110000";
            when 4 => return "0011001";
            
            when 5 => return "0010010";
            when 6 => return "0000010";
            when 7 => return "1111000";
            when 8 => return "0000000";
            when 9 => return "0010000";
            when 10 => return "1000000";
            when 11 => return "1111001";
            when 12 => return "0100100";
            when 13 => return "0110000";
            when 14 => return "0011001";
            when 15 => return "0010010";
            when 16 => return "0000010";
            when 17 => return "1111000";
            when 18 => return "0000000";
            when 19 => return "0010000";
            when 20 => return "1000000";
            when 21 => return "1111001";
            when others => return "1000000";
        end case;
    end function conversao_unidade;

    function conversao_dezena(numero : integer) return std_logic_vector is
    begin
        if numero >= 0 and numero < 10 then
            return "1000000"; -- 0
        elsif numero >= 10 and numero <= 19 then
            return "1111001"; -- 1
        elsif numero >=20 and numero <= 21 then
            return "0100100"; -- 2
        else
            return "1000000"; -- Default (0)
        end if;
    end function conversao_dezena;


begin

    process(key(2), key(3))  -- key(2) => start/reset; key(3) => clock;
    begin
        if (key(2) = '0') then  -- start/reset
            soma_cartas_jogador <= 0;
            soma_cartas_carteador <= 0;
            distribui <= "00";
            possui_as <= "00";
            estado_atual <= inicio;
            hex0 <= "1101101";
            hex1 <= "0000111";
            hex2 <= "0110011";
            hex3 <= "0000111";

        elsif falling_edge(key(3)) then  -- lógica de transição de estados embutida no process do clock

            if ((distribui /= "01" and estado_atual = inicio) or ((estado_atual = jogador or estado_atual = jogador_as) and sw(7) /= '1')) then
                hex3 <= conversao_hexadecimal(carta_circuito_externo);
           
            end if;

            if (estado_atual = inicio) then
                hex2 <= "1101111";
                if (distribui(0) = '0') then
                    if (carta_atual = "0001") then
                        possui_as(0) <= '1';
                    end if;
                    soma_cartas_jogador <= soma_cartas_jogador + to_integer(unsigned(carta_atual));
                    hex1 <= conversao_dezena(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                    hex0 <= conversao_unidade(soma_cartas_jogador + to_integer(unsigned(carta_atual)));

                    distribui(0) <= '1';
                else
                    if (carta_atual = "0001") then
                        possui_as(1) <= '1';
                    end if;
                    soma_cartas_carteador <= soma_cartas_carteador + to_integer(unsigned(carta_atual));
                    distribui <= "10";
                end if;
                    if (distribui(0) = '1' AND distribui(1) = '1') then
                    estado_atual <= jogador;
                    end if;
            end if;

            if (estado_atual = jogador) then
                hex2 <= "1001111";
                if (sw(7) = '1') then  -- STAY
                    if (possui_as(1) = '1') then
                        estado_atual <= carteador_as;
                    else
                        estado_atual <= carteador;
                    end if;
                elsif (sw(6) = '1') then  -- sw(6)
                    soma_cartas_jogador <= soma_cartas_jogador + to_integer(unsigned(carta_atual));
                    if (soma_cartas_jogador > 21) then
                        estado_atual <= resultado;
                    else
                        hex1 <= conversao_dezena(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                        hex0 <= conversao_unidade(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                    end if;
                end if;
            end if;

            if (estado_atual = jogador_as) then
                if (sw(7) = '1') then  -- STAY
                    if (possui_as(0) = '1' and soma_cartas_jogador + 10 < 22) then
                        soma_cartas_jogador <= soma_cartas_jogador + 10;

                        hex1 <= conversao_dezena(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                        hex0 <= conversao_unidade(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                    elsif (possui_as(1) = '1') then
                        estado_atual <= carteador_as;

                    else
                        estado_atual <= carteador;
                    end if;
                elsif (sw(6) = '1') then  -- HIT
                    soma_cartas_jogador <= soma_cartas_jogador + to_integer(unsigned(carta_atual));
                    if (soma_cartas_jogador > 21) then
                        estado_atual <= resultado;
                    else
                        hex1 <= conversao_dezena(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                        hex0 <= conversao_unidade(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                    end if;
                end if;
            end if;

            if (estado_atual = carteador) then
                hex2 <= "1110011";
                if (soma_cartas_carteador < 17) then
                 0  soma_cartas_carteador <= soma_cartas_carteador + to_integer(unsigned(carta_atual));
                    if (soma_cartas_carteador + to_integer(unsigned(carta_atual)) > 21) then
                        estado_atual <= resultado;
                    end if;
                    if (carta_atual = "0001") then
                        estado_atual <= carteador_as;
                    end if;
                else
                    estado_atual <= resultado;
                    hex2 <= "1001111";
                end if;
            end if;

            if (estado_atual = carteador_as) then
                if (soma_cartas_carteador + 10 < 17) then
                    soma_cartas_carteador <= soma_cartas_carteador + to_integer(unsigned(carta_atual));
                    if (soma_cartas_carteador + to_integer(unsigned(carta_atual)) > 21) then
                        estado_atual <= resultado;
                    end if;
                else
                    if (soma_cartas_carteador + 10 < 22) then
                        soma_cartas_carteador <= soma_cartas_carteador + 10;
                    end if;
                    estado_atual <= resultado;
                    hex2 <= "1001111";
                end if;
            end if;

        end if;
    end process;

    process (estado_atual)
    begin
        if (estado_atual = resultado) then
            -- Se o jogador perdeu (soma > 21 ou carta do jogador é menor que a do carteador, e carteador não passou de 21)


            if (soma_cartas_jogador > 21 or (soma_cartas_jogador < soma_cartas_carteador and soma_cartas_carteador < 22)) then
              --  ledR(0) <= '1';  -- Lose
              --  ledR(1) <= '1';
              --  ledR(2) <= '1';
                ledg(7) <= '1';
            -- Se o jogador ganhou (soma do carteador > 21 ou carta do jogador é maior que a do carteador)
            elsif (soma_cartas_carteador > 21 or soma_cartas_carteador < soma_cartas_jogador) then
              --  ledR(7) <= '1';  -- Win
              --  ledR(8) <= '1';
              --  ledR(9) <= '1';
                 ledg(6) <= '1';
            -- Se for empate
            else
                ledg(7) <= '1';
                ledg(6) <= '1';
                -- ledR(4)<= '0';
               -- ledR(5) <= '1';
            end if;
        end if;
    end process;

    process (sw(3), sw(2), sw(1), sw(0))
    variable valor_carta : std_logic_vector(3 downto 0) := "0000";
    begin

        valor_carta(0) := sw(0);
        valor_carta(1) := sw(1);
        valor_carta(2) := sw(2);
        valor_carta(3) := sw(3);

        if (to_integer(unsigned(valor_carta)) > 10) then
            carta_atual <= "1010";
        else
            carta_atual <= valor_carta;
        end if;

        carta_circuito_externo <= sw(3 downto 0);
    end process;

end gurizes;
