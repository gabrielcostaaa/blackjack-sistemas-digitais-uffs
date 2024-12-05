library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity blackjack is
    port (
        clk : in std_logic;
        start_reset : in std_logic;
        hit : in std_logic;
        stay : in std_logic;

        sw : IN STD_LOGIC_VECTOR(9 DOWNTO 0); -- sw(3), sw(2), sw(1), sw(0) => CARTA_CIRCUITO_EXTERNO;

        hex0 : out std_logic_vector(6 downto 0);  -- unidade soma cartas decimal
        hex1 : out std_logic_vector(6 downto 0);  -- dezena soma cartas decimal
        hex2 : out std_logic_vector(6 downto 0);  -- usado para escrever em alguns estados
        hex3 : out std_logic_vector(6 downto 0);  -- hexadecimal carta mão

        ledR : out std_logic_vector(9 downto 0)  -- WIN (7,8,9); TIE (4,5); LOSE (0,1,2);
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

    -- Sinais temporários para hex0 e hex1
    signal temp_hex0 : std_logic_vector(6 downto 0);
    signal temp_hex1 : std_logic_vector(6 downto 0);

    -- Função para conversão de carta para display de 7 segmentos
    function conversao_hexadecimal(carta : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case carta is
            when "0000" => return "0000000"; -- 0
            when "0001" => return "0000110"; -- 1
            when "0010" => return "1011011"; -- 2
            when "0011" => return "0011111"; -- 3
            when "0100" => return "0110110"; -- 4
            when "0101" => return "0111101"; -- 5
            when "0110" => return "1111101"; -- 6
            when "0111" => return "0000111"; -- 7
            when "1000" => return "1111111"; -- 8
            when "1001" => return "0111111"; -- 9
            when "1010" => return "1110111"; -- a (10)
            when "1011" => return "1111100"; -- b (11)
            when "1100" => return "1101001"; -- c (12)
            when "1101" => return "1011110"; -- d (13)
            when others => return "0000000"; -- tudo apagado
        end case;
    end conversao_hexadecimal;

    function conversao_unidade(valor : integer) return std_logic_vector is
    begin
        case valor is
            when 0 => return "0000000";
            when 1 => return "0000110";
            when 2 => return "1011011";
            when 3 => return "0011111";
            when 4 => return "0110110";
            when 5 => return "0111101";
            when 6 => return "1111101";
            when 7 => return "0000111";
            when 8 => return "1111111";
            when 9 => return "0111111";
            when 10 => return "0000000";
            when 11 => return "0000110";
            when 12 => return "1011011";
            when 13 => return "0011111";
            when 14 => return "0110110";
            when 15 => return "0111101";
            when 16 => return "1111101";
            when 17 => return "0000111";
            when 18 => return "1111111";
            when 19 => return "0111111";
            when 20 => return "0000000";
            when 21 => return "0000110";
            when 22 => return "1011011";
            when 23 => return "0011111";
            when others => return "0000000"; -- tudo apagado
        end case;
    end function conversao_unidade;

    function conversao_dezena(numero : integer) return std_logic_vector is
    begin
        if (numero < 10) then
            return "0000000";
        elsif (numero < 20) then
            return "0000110";
        elsif (numero < 30) then
            return "1011011";
        elsif (numero < 40) then
            return "0011111";
        end if;
        return "1000000";  -- Default case
    end function conversao_dezena;

begin

    process(start_reset, clk)  -- start_reset => start/reset; clk => clock;
    begin
        if (start_reset = '1') then  -- start/reset
            soma_cartas_jogador <= 0;
            soma_cartas_carteador <= 0;
            distribui <= "00";
            possui_as <= "00";
            estado_atual <= inicio;

        elsif falling_edge(clk) then  -- lógica de transição de estados embutida no process do clock
            -- Atualizar hex3 com a carta do circuito externo
            if ((distribui /= "01" and estado_atual = inicio) or ((estado_atual = jogador or estado_atual = jogador_as) and stay /= '1')) then
                hex3 <= conversao_hexadecimal(carta_circuito_externo);
            end if;

            -- Lógica de distribuição de cartas no estado 'inicio'
            if (estado_atual = inicio) then
                hex2 <= "0010000"; --identifica se ta no estado de inicio
                if (distribui(0) = '0') then
                    if (carta_atual = "000001") then
                        possui_as(0) <= '1';
                    end if;
                    soma_cartas_jogador <= soma_cartas_jogador + to_integer(unsigned(carta_atual));
                    hex1 <= conversao_dezena(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                    hex0 <= conversao_unidade(soma_cartas_jogador + to_integer(unsigned(carta_atual)));

                    distribui(0) <= '1';
                else
                    if (carta_atual = "000001") then
                        possui_as(1) <= '1';
                    end if;
                    soma_cartas_carteador <= soma_cartas_carteador + to_integer(unsigned(carta_atual));
                    distribui <= "10";
                    estado_atual <= jogador;
                end if;
            end if;

            -- Estado de 'jogador'
            if (estado_atual = jogador) then
                hex2 <= "0011000"; --identifica se ta no estado de inicio
                if (stay = '1') then  -- STAY
                    if (possui_as(1) = '1') then
                        estado_atual <= carteador_as;
                    else
                        estado_atual <= carteador;
                    end if;
                elsif (hit = '1') then  -- HIT
                    soma_cartas_jogador <= soma_cartas_jogador + to_integer(unsigned(carta_atual));
                    if (soma_cartas_jogador > 21) then
                        estado_atual <= resultado;
                    else
                        hex1 <= conversao_dezena(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                        hex0 <= conversao_unidade(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                    end if;
                end if;
            end if;

           -- Estado de 'jogador_as' (quando o jogador tem um Ás e quer usá-lo como 11)
            if (estado_atual = jogador_as) then
                if (stay = '1') then  -- STAY
                    if (possui_as(0) = '1' and soma_cartas_jogador + 10 < 22) then
                        soma_cartas_jogador <= soma_cartas_jogador + 10;
                        -- Atualizar os displays
                        hex1 <= conversao_dezena(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                        hex0 <= conversao_unidade(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                    elsif (possui_as(1) = '1') then  -- Carteador com Ás
                        estado_atual <= carteador_as;
                    else
                        estado_atual <= carteador;
                    end if;
                elsif (hit = '1') then  -- HIT
                    soma_cartas_jogador <= soma_cartas_jogador + to_integer(unsigned(carta_atual));
                    if (soma_cartas_jogador > 21) then
                        estado_atual <= resultado;
                    else
                        hex1 <= conversao_dezena(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                        hex0 <= conversao_unidade(soma_cartas_jogador + to_integer(unsigned(carta_atual)));
                    end if;
                end if;
            end if;

            -- Estado de 'carteador'
            if (estado_atual = carteador) then
                if (soma_cartas_carteador < 17) then
                    soma_cartas_carteador <= soma_cartas_carteador + to_integer(unsigned(carta_atual));
                    if (soma_cartas_carteador + to_integer(unsigned(carta_atual)) > 21) then
                        estado_atual <= resultado;
                    end if;
                    if (carta_atual = "000001") then
                        estado_atual <= carteador_as;
                    end if;
                else
                    estado_atual <= resultado;
                end if;
            end if;

            -- Estado de 'carteador_as' (quando o carteador tem um Ás)
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
                end if;
            end if;

        end if;
    end process;

    -- Processo para exibir o resultado final (Vitória, Derrota ou Empate)
    process (estado_atual)
    begin
        -- Resultado (estado resultado)
        if (estado_atual = resultado) then
            -- Se o jogador perdeu (soma > 21 ou carta do jogador é menor que a do carteador, e carteador não passou de 21)
            if (soma_cartas_jogador > 21 or (soma_cartas_jogador < soma_cartas_carteador and soma_cartas_carteador < 22)) then
                ledR(0) <= '1';  -- Lose
                ledR(1) <= '1';
                ledR(2) <= '1';
            -- Se o jogador ganhou (soma do carteador > 21 ou carta do jogador é maior que a do carteador)
            elsif (soma_cartas_carteador > 21 or soma_cartas_carteador < soma_cartas_jogador) then
                ledR(7) <= '1';  -- Win
                ledR(8) <= '1';
                ledR(9) <= '1';
            -- Se for empate
            else
                ledR(4) <= '1';  -- Tie
                ledR(5) <= '1';
            end if;
        end if;
    end process;

    -- Processo para a entrada das cartas externas
    process (sw(3), sw(2), sw(1), sw(0))
    variable valor_carta : std_logic_vector(3 downto 0) := "0000";
    begin
        -- Atribuindo os valores de sw para a variável valor_carta
        valor_carta(0) := sw(0);
        valor_carta(1) := sw(1);
        valor_carta(2) := sw(2);
        valor_carta(3) := sw(3);

        -- Verificando o valor da carta
        if (to_integer(unsigned(valor_carta)) > 10) then
            carta_atual <= "1010";  -- Atribuindo carta atual para "1010" quando valor > 10
        else
            carta_atual <= valor_carta;  -- Quando a carta for menor ou igual a 10
        end if;

        -- Atribuindo o valor de carta_circuito_externo (cartas externas no circuito)
        carta_circuito_externo <= sw(3 downto 0);
    end process;

end gurizes;