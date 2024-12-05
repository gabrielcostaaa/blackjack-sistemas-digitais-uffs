library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity blackjack is
    port (
        key : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- key(2) => START/RESET; key(3) => CLOCK;
        sw : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- sw(6) => HIT; sw(7) => STAY; sw(3), sw(2), sw(1), sw(0) => CARTA_CIRCUITO_EXTERNO;

        hex0 : out std_logic_vector(6 downto 0); -- unidade soma cartas decimal
        hex1 : out std_logic_vector(6 downto 0); -- dezena soma cartas decimal
        hex2 : out std_logic_vector(6 downto 0); -- usado para escrever em alguns estados
        hex3 : out std_logic_vector(6 downto 0); -- hexadecimal carta mão

        ledR : out std_logic_vector(9 downto 0); -- WIN (7,8,9); TIE (4,5); LOSE (0,1,2);
    );
end blackjack;

architecture gurizes of blackjack is

    type tipo_estado is (
        inicio,
        jogador,
        jogador_as,
        carteador,
        carteador_as,
        resultado,
    );

    signal estado_atual : tipo_estado := inicio;

    signal carta_atual : std_logic_vector(3 downto 0) := "0000";
    signal carta_circuito_externo : std_logic_vector(3 downto 0) := "0000";

    signal soma_cartas_jogador : std_logic_vector(5 downto 0) := "000000";
    signal soma_cartas_carteador : std_logic_vector(5 downto 0) := "000000";

    signal possui_as : std_logic_vector(1 downto 0) := "00";

    signal distribui : std_logic_vector(1 downto 0) := "00";

    function conversao_hexadecimal(carta : std_logic_vector(3 downto 0)) return std_logic_vector is
    begin
        case carta is
            when "0000" => return "1000000"; -- 0
            when "0001" => return "1111100"; -- 1
            when "0010" => return "0100100"; -- 2
            when "0011" => return "0110000"; -- 3
            when "0100" => return "0011001"; -- 4
            when "0101" => return "0010010"; -- 5
            when "0110" => return "0000010"; -- 6
            when "0111" => return "1111000"; -- 7
            when "1000" => return "0000000"; -- 8
            when "1001" => return "0010000"; -- 9
            when "1010" => return "0001000"; -- a (10)
            when "1011" => return "0000011"; -- b (11)
            when "1100" => return "1000110"; -- c (12)
            when "1101" => return "0100001"; -- d (13)
            when others => return "1111111"; -- tudo apagado
        end case;
    end conversao_hexadecimal;

    function conversao_unidade(valor : std_logic_vector(5 downto 0)) return std_logic_vector is
    begin
        case valor is
            when "000000" => return "1000000";
            when "000001" => return "1111001";
            when "000010" => return "0100100";
            when "000011" => return "0110000";
            when "000100" => return "0011001";
            when "000101" => return "0010010";
            when "000110" => return "0000010";
            when "000111" => return "1111000";
            when "001000" => return "0000000";
            when "001001" => return "0010000";

            when "001010" => return "1000000";
            when "001011" => return "1111001";
            when "001100" => return "0100100";
            when "001101" => return "0110000";
            when "001110" => return "0011001";
            when "001111" => return "0010010";
            when "010000" => return "0000010";
            when "010001" => return "1111000";
            when "010010" => return "0000000";
            when "010011" => return "0010000";

            when "010100" => return "1000000";
            when "010101" => return "1111100";
            when "010110" => return "0100100";
            when "010111" => return "0110000";
            when "011000" => return "0011001";
            when "011001" => return "0010010";
            when "011010" => return "0000010";
            when "011011" => return "1111000";
            when "011100" => return "0000000";
            when "011101" => return "0010000";

            when others => return "1000000";
        end case;
    end function conversao_unidade;

    function conversao_dezena(numero : std_logic_vector(5 downto 0)) return std_logic_vector is
    begin
        if (numero < 10) then
            return "1000000";
        elsif (numero < 20) then
            return "1111001";
        elsif (numero < 30) then
            return "0100100";
        elsif (numero < 40) then
            return "0110000";
        end if;
        return "1000000";
    end function conversao_dezena;

begin

    process(key(2), key(3)) -- key(2) => start/reset; key(3) => clock;
    begin
        if (key(2) = '0') then -- start/reset

            soma_cartas_jogador <= "000000";
            soma_cartas_carteador <= "000000";
            distribui <= "00";
            possui_as <= "00";

            hex3 <= "0010010";
            hex2 <= "1111000";
            hex1 <= "0011001";
            hex0 <= "1111000";

            estado_atual <= inicio;

        elsif falling_edge(key(3)) then -- lógica de transição de estados embutida no process do clock
            
            if ((distribui /= "01" and estado_atual = inicio) or ((estado_atual = jogador or estado_atual = jogador_as) and sw(7) /= '1')) then
                hex3 <= conversao_hexadecimal(carta_circuito_externo);
            end if;

            if (estado_atual = inicio) then
                if (distribui(0) = '0') then
                    if (carta_atual = "000001") then
                        possui_as(0) <= '1';
                    end if;

                    soma_cartas_jogador <= soma_cartas_jogador + carta_atual;
                    hex1 <= conversao_dezena(soma_cartas_jogador + carta_atual);
                    hex0 <= conversao_unidade(soma_cartas_jogador + carta_atual);

                    distribui(0) <= '1';
                else
                    if (carta_atual = "000001") then
                        possui_as(1) <= '1';
                    end if;

                    soma_cartas_carteador <= soma_cartas_carteador + carta_atual;

                    if (distribui = "01") then
                        distribui <= "10";
                    else
                        if (possui_as(0) = '1') then
                            estado_atual <= jogador_as;
                        else
                            estado_atual <= user;
                        end if;
                    end if;
                end if;
            end if;

            if (estado_atual = jogador) then
                if (sw(7) = '1') then -- STAY
                    if (possui_as(1) = '1') then
                        estado_atual <= carteador_as;
                    else
                        estado_atual <= carteador;
                    end if;
                elsif (sw(7) = '1') then -- HIT
                    if (soma_cartas_jogador + carta_atual > 21) then
                        soma_cartas_jogador <= soma_cartas_jogador + carta_atual;
                        estado_atual <= resultado;
                    else
                        soma_cartas_jogador <= soma_cartas_jogador + carta_atual;
                        hex1 <= conversao_dezena(soma_cartas_jogador + carta_atual);
                        hex0 <= conversao_unidade(soma_cartas_jogador + carta_atual);
                    end if; 

                    if (carta_atual = "000001") then
                        estado_atual <= jogador_as;
                    end if;
            end if;

            if (estado_atual = jogador_as) then
                if (sw(7) = '1') then -- STAY
                    if (possui_as(0) = '1' and soma_cartas_jogador + 10 < 22) then
                        soma_cartas_jogador <= soma_cartas_jogador + 10;
                        hex1 <= conversao_dezena(soma_cartas_jogador + 10);
                        hex0 <= conversao_unidade(soma_cartas_jogador + 10);
                    end if;
                    if (possui_as(1) = '1') then
                        estado_atual <= carteador_as;
                    else
                        estado_atual <= carteador;
                    end if;
                elsif (sw(6) = '1') then -- HIT
                    if (soma_cartas_jogador + carta_atual > 21) then
                        soma_cartas_jogador <= soma_cartas_jogador + carta_atual;
                        estado_atual <= resultado;
                    else
                        soma_cartas_jogador <= soma_cartas_jogador + carta_atual;
                        hex1 <= conversao_dezena(soma_cartas_jogador + carta_atual);
                        hex0 <= conversao_unidade(soma_cartas_jogador + carta_atual);
                    end if; 

                    if (carta_atual = "000001") then
                        estado_atual <= jogador_as;
                    end if;
                end if;
            end if;

            if (estado_atual = carteador) then
                if (soma_cartas_carteador < 17) then

                    soma_cartas_carteador <= soma_cartas_carteador + carta_atual;

                    if (soma_cartas_carteador + carta_atual > 21) then
                        estado_atual = resultado;
                    end if;

                    if (carta_atual = "000001") then
                        estado_atual <= carteador_as;
                    end if;

                else
                    estado_atual <= resultado;
                end if;
            end if;

            if (estado_atual = carteador_as) then
                if (soma_cartas_carteador + 10 < 17) then
                    soma_cartas_carteador <= soma_cartas_carteador + carta_atual;
                    if (soma_cartas_carteador + carta_atual > 21) then
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

    process (estado_atual)
    begin

        if (estado_atual = resultado)
            -- WIN
            if (soma_cartas_jogador > 21 or (soma_cartas_jogador < soma_cartas_carteador and soma_cartas_carteador < 22)) then
                ledR(0) <= '1';
                ledR(1) <= '1';
                ledR(2) <= '1';
            -- LOSE
            elsif (soma_cartas_carteador > 21 or soma_cartas_carteador < soma_cartas_jogador) then
                ledR(7) <= '1';
                ledR(8) <= '1';
                ledR(9) <= '1';
            -- TIE
            else
                ledR(4) <= '1';
                ledR(5) <= '1';
            end if;
        end if;
    end process;
    
END gurizes;
