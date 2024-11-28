LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.all;
USE IEEE.NUMERIC_STD.all;

ENTITY blackjack IS
    PORT (

        key : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- random_cards => key(0), clock => key(1), key(2) => hit, key(3) => stay;
        sw : IN STD_LOGIC_VECTOR(1 DOWNTO 0); -- start/reset => sw(0);

        hex0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- unidades soma cartas decimal
        hex1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- dezenas soma cartas decimal

        hex3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- hexadecimal carta mão

        ledr : OUT STD_LOGIC_VECTOR(9 DOWNTO 0); -- WIN (9 a 7), TIE (5 a 4), LOSE (2 a 0);

        win, tie, lose : OUT STD_LOGIC;
    );
END blackjack;

ARCHITECTURE gurizes OF blackjack IS

    TYPE state_type IS (
        inicio,
        gera_aleatorio,
        circuito_externo,
        entrega_jogador,
        entrega_dealer,
        pedir_carta_jogador,
        pedir_carta_dealer,
        finalizar_mao_jogador,
        finalizar_mao_dealer,
        blackjack_jogador,
        blackjack_dealer,
        dealer_joga,
        jogador_vence_rodada,
        jogador_empata_rodada,
        jogador_perde_rodada,
    );
    SIGNAL current_state, next_state : state_type;

    SIGNAL cheap    : STD_LOGIC_VECTOR(51 DOWNTO 0) := (OTHERS => '1'); -- baralho

    SIGNAL card : STD_LOGIC_VECTOR(3 DOWNTO 0) := (OTHERS => '0'); -- valor da carta que esta agora
    SIGNAL random_card_index : INTEGER RANGE 0 TO 51;

    SIGNAL sum_cards_player : INTEGER RANGE 0 TO 30 := 0; -- soma dos valores das cartas na mão
    SIGNAL sum_cards_dealer : INTEGER RANGE 0 TO 30 := 0; -- soma dos valores das cartas na mão

    SIGNAL distribui_jogador : INTEGER RANGE 0 TO 2 := 0; -- quantidade de cartas que pegou no inicio
    SIGNAL distribui_dealer : INTEGER RANGE 0 TO 2 := 0; -- quantidade de cartas que pegou no inicio

    FUNCTION card_to_hex(card : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS
        VARIABLE hex_pattern : STD_LOGIC_VECTOR(6 DOWNTO 0);
    BEGIN
        CASE card IS
            WHEN "0001" => hex_pattern := "0110000"; -- 1
            WHEN "0010" => hex_pattern := "1101101"; -- 2
            WHEN "0011" => hex_pattern := "1111001"; -- 3
            WHEN "0100" => hex_pattern := "0110011"; -- 4
            WHEN "0101" => hex_pattern := "1011011"; -- 5
            WHEN "0110" => hex_pattern := "1011111"; -- 6
            WHEN "0111" => hex_pattern := "1110000"; -- 7
            WHEN "1000" => hex_pattern := "1111111"; -- 8
            WHEN "1001" => hex_pattern := "1111011"; -- 9
            WHEN "1010" => hex_pattern := "1110111"; -- A (10)
            WHEN "1011" => hex_pattern := "0011111"; -- b (11)
            WHEN OTHERS => hex_pattern := "0000000"; -- Tudo apagado
        END CASE;
        RETURN hex_pattern;
    END card_to_hex;

BEGIN

    PROCESS(key(1), sw(0))
    BEGIN
        IF sw(0) = '1' THEN
            current_state <= inicio;
        ELSIF falling_edge(key(1)) THEN
            current_state <= next_state;
        END IF;
    END PROCESS;

    -- LÓGICA DE TRANSIÇÃO DE ESTADOS
    PROCESS(current_state)
    BEGIN
        CASE current_state IS
            WHEN inicio =>
                IF key(0) = '1' THEN -- se random_cards = 1
                    next_state <= gera_aleatorio;
                ELSE
                    next_state <= circuito_externo;
                END IF;
            
            WHEN gera_aleatorio =>
                IF distribui_jogador AND distribui_dealer < 2 THEN
                    next_state <= entrega_jogador;
                ELSIF sum_cards_player = 21 THEN
                    next_state <= blackjack_jogador;
                ELSIF key(2) = '1' THEN -- hit
                    next_state <= pedir_carta_jogador;
                ELSIF key(3) = '1' THEN -- stay
                    next_state <= finalizar_mao_jogador;
                END IF;

            WHEN circuito_externo =>


            WHEN entrega_jogador =>
                IF distribui_dealer < 2 THEN
                    next_state <= entrega_dealer;
                END IF;

            WHEN entrega_dealer =>
                IF distribui_jogador < 2 THEN
                    next_state <= entrega_jogador;
                ELSE
                    next_state <= gera_aleatorio;
                END IF;

            WHEN pedir_carta_jogador => 
                IF sum_cards_player > 21 THEN
                    next_state <= jogador_perde_rodada;
                ELSIF sum_cards_player = 21 THEN
                    next_state <= blackjack_jogador;
                ELSIF hit = '1' THEN
                    next_state <= pedir_carta_jogador;
                ELSIF stay = '1' THEN
                    next_state <= finalizar_mao_jogador;
                END IF;

            WHEN pedir_carta_dealer =>
                IF sum_cards_dealer = 21 THEN
                    next_state <= blackjack_dealer;
                ELSIF sum_cards_dealer >= 17 THEN
                    next_state <= finalizar_mao_dealer;
                ELSE
                    next_state <= pedir_carta_dealer;
                END IF;

            WHEN finalizar_mao_jogador =>
               next_state <= dealer_joga;

            WHEN finalizar_mao_dealer =>
               IF sum_cards_dealer < sum_cards_player THEN
                   next_state <= jogador_vence_rodada;
               ELSIF sum_cards_dealer = sum_cards_player THEN
                   next_state <= jogador_empata_rodada;
               ELSE
                   next_state <= jogador_perde_rodada;
               END IF;

            WHEN blackjack_jogador => 
                IF sum_cards_dealer < 21 THEN
                    next_state <= dealer_joga;
                ELSIF sum_cards_dealer = 21 THEN
                    next_state <= blackjack_dealer;
                END IF;

            WHEN blackjack_dealer =>
                IF sum_cards_player = 21 THEN
                    next_state <= jogador_empata_rodada;
                ELSIF sum_cards_player < 21 THEN
                    next_stae <= jogador_perde_rodada;
                END IF;

            WHEN dealer_joga =>
                IF sum_cards_dealer = 21 THEN
                    next_state <= blackjack_dealer;
                ELSIF sum_cards_dealer >= 17 THEN
                    next_state <= finalizar_mao_dealer;
                ELSE
                    next_state <= pedir_carta_dealer;
                END IF;

            WHEN jogador_vence_rodada =>
                next_state <= inicio;

            WHEN jogador_empata_rodada =>
                next_state <= inicio;

            WHEN jogador_perde_rodada =>
                next_state <= inicio;

    END PROCESS;

    -- LÓGICA DE OPERAÇÃO E SAÍDAS
    PROCESS(current_state)

    VARIABLE indice : INTEGER RANGE 0 TO 51;

    BEGIN
        CASE current_state IS
            WHEN inicio =>
                -- aqui vai zerar todas as variáveis e reiniciar o jogo
            WHEN gera_aleatorio =>


            WHEN entrega_jogador => 
                indice := RANDOM_GENERATOR(distribui_jogador + distribui_dealer);

                WHILE cheap(indice) = '0' LOOP
                        indice := RANDOM_GENERATOR(indice); -- Gera novo índice
                END LOOP;

                cheap(indice) <= '0'; -- carta retirada do baralho
                card <= STD_LOGIC_VECTOR(TO_UNSIGNED((indice / 4) + 1, 4)); -- passa valor da carta a card

                sum_cards_player <= sum_cards_player + card;

                distribui_jogador <= distribui_jogador + 1;

                hex3 <= card_to_hex(card);

            WHEN entrega_dealer =>
                indice := RANDOM_GENERATOR(distribui_jogador + distribui_dealer);

                WHILE cheap(indice) = '0' LOOP
                        indice := RANDOM_GENERATOR(indice); -- Gera novo índice
                END LOOP;

                cheap(indice) <= '0'; -- carta retirada do baralho
                card <= STD_LOGIC_VECTOR(TO_UNSIGNED((indice / 4) + 1, 4)); -- passa valor da carta a card

                sum_cards_dealer <= sum_cards_dealer + card;

                distribui_dealer <= distribui_dealer + 1;

                hex3 <= card_to_hex(card);

            WHEN jogador_vence_rodada =>
                win <= '1';
                ledr(9 DOWNTO 7) <= "111"; -- WIN
            
            WHEN jogador_empata_rodada =>
                tie <= '1';
                ledr(5 DOWNTO 4) <= "11"; -- TIE
            
            WHEN jogador_perde_rodada =>
                lose <= '1';
                ledr(2 DOWNTO 0) <= "111"; -- LOSE
        
    END PROCESS;

END gurizes;
