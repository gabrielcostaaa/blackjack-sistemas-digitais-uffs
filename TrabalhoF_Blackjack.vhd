-- trabalho final de sistemas digitais
-- dicentes: Wictor Henrique Greselli e T

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.std_logic_unsigned.ALL;
entity TrabalhoF_Blackjack is
  PORT (
    sw : IN STD_LOGIC_VECTOR(9 DOWNTO 0); --nao ultilizado por agora-> sw(0) = hit, sw(1) = stay, (sw(2),sw(3),sw(4),sw(5)) == card, sw(9) = start
    vez_jogador: in std_logic;
    stay_player: in std_logic;
    start: in std_logic;
    key : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- key(0) = clock
    clk : IN STD_LOGIC;
    ledg : OUT STD_LOGIC; -- ledg(0) = win, ledg(1) = tie, ledg(2) = lose
    ledr : OUT STD_LOGIC; -- ledg(0) = win, ledg(1) = tie, ledg(2) = lose
	 hex0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    hex1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    hex2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
    hex3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
  );
end entity;


ARCHITECTURE arquiteturablackjack OF TrabalhoF_Blackjack IS

  -- Estados
  TYPE estados IS (
    inicio,
    c1_player,
    c1_dealer,
    c2_player,
    c2_dealer,
    turno_player,
    hit_player,
    turno_dealer,
    hit_dealer,
    analise,
    perdeu,
    empate,
    venceu
  );
TYPE temAs is(sim,nao);
signal estado_atual : estados := inicio;
  FUNCTION to_7seg (num : INTEGER) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    CASE num IS
      WHEN 0 => RETURN "1000000"; -- 0
      WHEN 1 => RETURN "1111001"; -- 1
      WHEN 2 => RETURN "0100100"; -- 2
      WHEN 3 => RETURN "0110000"; -- 3
      WHEN 4 => RETURN "0011001"; -- 4
      WHEN 5 => RETURN "0010010"; -- 5
      WHEN 6 => RETURN "0000010"; -- 6
      WHEN 7 => RETURN "1111000"; -- 7
      WHEN 8 => RETURN "0000000"; -- 8
      WHEN 9 => RETURN "0010000"; -- 9
      WHEN 10 => RETURN "0001000"; -- A 10
      WHEN 11 => RETURN "0000011"; -- B 11
      WHEN OTHERS => RETURN "1000000"; -- Display apagado para valores invÃ¡lidos
    END CASE;
  END FUNCTION;

  FUNCTION to_7seg1 (num : INTEGER) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    CASE num IS
      WHEN 0 => RETURN "1000000"; -- 0
      WHEN 1 => RETURN "1111001"; -- 1
      WHEN 2 => RETURN "0100100"; -- 2
      WHEN 3 => RETURN "0110000"; -- 3
      WHEN 4 => RETURN "0011001"; -- 4
      WHEN 5 => RETURN "0010010"; -- 5
      WHEN 6 => RETURN "0000010"; -- 6
      WHEN 7 => RETURN "1111000"; -- 7
      WHEN 8 => RETURN "0000000"; -- 8
      WHEN 9 => RETURN "0010000"; -- 9
      WHEN 10 => RETURN "1000000"; -- 0
      WHEN 11 => RETURN "1111001"; -- 1
      WHEN 12 => RETURN "0100100"; -- 2
      WHEN 13 => RETURN "0110000"; -- 3
      WHEN 14 => RETURN "0011001"; -- 4
      WHEN 15 => RETURN "0010010"; -- 5
      WHEN 16 => RETURN "0000010"; -- 6
      WHEN 17 => RETURN "1111000"; -- 7
      WHEN 18 => RETURN "0000000"; -- 8
      WHEN 19 => RETURN "0010000"; -- 9
      WHEN 20 => RETURN "1000000"; -- 0
      WHEN 21 => RETURN "1111001"; -- 1
      WHEN OTHERS => RETURN "1000000"; -- Display apagado para valores invÃ¡lidos
    END CASE;
  END FUNCTION;

  FUNCTION to_7seg2 (num : INTEGER) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    CASE num IS
      WHEN 0 => RETURN "1000000"; -- 0
      WHEN 1 => RETURN "1000000"; -- 1
      WHEN 2 => RETURN "1000000"; -- 2
      WHEN 3 => RETURN "1000000"; -- 3
      WHEN 4 => RETURN "1000000"; -- 4
      WHEN 5 => RETURN "1000000"; -- 5
      WHEN 6 => RETURN "1000000"; -- 6
      WHEN 7 => RETURN "1000000"; -- 7
      WHEN 8 => RETURN "1000000"; -- 8
      WHEN 9 => RETURN "1000000"; -- 9
      WHEN 10 => RETURN "1111001"; -- 0
      WHEN 11 => RETURN "1111001"; -- 1
      WHEN 12 => RETURN "1111001"; -- 2
      WHEN 13 => RETURN "1111001"; -- 3
      WHEN 14 => RETURN "1111001"; -- 4
      WHEN 15 => RETURN "1111001"; -- 5
      WHEN 16 => RETURN "1111001"; -- 6
      WHEN 17 => RETURN "1111001"; -- 7
      WHEN 18 => RETURN "1111001"; -- 8
      WHEN 19 => RETURN "1111001"; -- 9
      WHEN 20 => RETURN "0100100"; -- 0
      WHEN 21 => RETURN "0100100"; -- 1
      WHEN OTHERS => RETURN "1000000"; -- Display apagado para valores invÃ¡lidos
    END CASE;
  END FUNCTION;

BEGIN

  PROCESS (clk,start)

    VARIABLE proximo_estado : estados := inicio;
    VARIABLE somador_player : INTEGER := 0;
    VARIABLE somador_dealer : INTEGER := 0;
    --variable random_number : INTEGER;
    VARIABLE card : INTEGER RANGE 0 TO 11;
    VARIABLE estado_atual : estados := inicio;

  BEGIN
      IF (estado_atual = inicio OR estado_atual = c1_player OR estado_atual = c2_player OR estado_atual = turno_player OR estado_atual = hit_player OR estado_atual = venceu OR estado_atual = c1_dealer OR estado_atual = c2_dealer) THEN
        hex2 <= to_7seg2(somador_player);
        hex1 <= to_7seg1(somador_player);
      ELSE
        hex2 <= to_7seg2(somador_dealer);
        hex1 <= to_7seg1(somador_dealer);
      END IF;
      IF (estado_atual = venceu) THEN
        ledr <= '0';
        ledg <= '1';
      ELSIF (estado_atual = empate) THEN
        ledr <= '1';
        ledg <= '1';
      ELSIF (estado_atual = perdeu) THEN
        ledg <= '0';
        ledr <= '1';
      ELSE
        ledr <= '0';
        ledg <= '0';
      END IF;

      card := 0;
      card := to_integer(unsigned(sw(5 DOWNTO 2)));
      hex3 <= to_7seg(card);
		hex0 <= "1111111";
    -- Processando o key(0)
    IF (rising_edge(clk)) THEN
      -- Caso o estado atual seja inicio
      IF (estado_atual = inicio) THEN
        somador_player := 0;
        somador_dealer := 0;
        proximo_estado := c1_player;
      END IF;

      -- Caso o estado atual seja c1_player
      IF (estado_atual = c1_player) THEN
        proximo_estado := c1_dealer;

        IF ((card) = 1) THEN
          IF (somador_player < 11) THEN
            somador_player := 11 + somador_player;
            IF (somador_player > 21) THEN
              somador_player := somador_player - 10; -- Rebaixa o Ás para 1
            end IF;
          ELSE
            somador_player := card + somador_player;
          END IF;
        ELSIF ((card) > 9) THEN
          somador_player := 10 + somador_player;
        ELSE
          somador_player := somador_player + card;
        END IF;
      END IF;

      -- Caso o estado atual seja c1_dealer
      IF (estado_atual = c1_dealer) THEN
        proximo_estado := c2_player;

        IF ((card) = 1) THEN
          IF (somador_dealer < 11) THEN
            somador_dealer := 11 + somador_dealer;
            IF (somador_dealer > 21) THEN
            somador_dealer := somador_dealer - 10; -- Rebaixa o Ás para 1
          END IF;
          ELSE
            somador_dealer := somador_dealer + card;
          END IF;
        ELSIF ((card) > 9) THEN
          somador_dealer := 10 + somador_dealer;
        ELSE
          somador_dealer := card;
        END IF;
      END IF;

      -- Caso o estado_atual seja c2_player
      IF (estado_atual = c2_player) THEN
        proximo_estado := c2_dealer;

        IF ((card) = 1) THEN
          IF (somador_player < 11) THEN
            somador_player := 11 + somador_player;
            IF (somador_player > 21) THEN
            somador_player := somador_player - 10; -- Rebaixa o Ás para 1
          END IF;
          ELSE
            somador_player := somador_player +  card;
          END IF;
        ELSIF ((card) > 9) THEN
          somador_player := 10 + somador_player;
        ELSE
          somador_player := somador_player + card;
        END IF;
      END IF;

      -- Caso o estado atual seja c2_dealer
      IF (estado_atual = c2_dealer) THEN
        proximo_estado := turno_player;

        IF ((card) = 1) THEN
          IF (somador_dealer < 11) THEN
            somador_dealer := 11 + somador_dealer;
            IF (somador_dealer > 21) THEN
            somador_dealer := somador_dealer - 10; -- Rebaixa o Ás para 1
          END IF;
          ELSE
            somador_dealer := card + somador_dealer;
          END IF;
        ELSIF ((card) > 9) THEN
          somador_dealer := 10 + somador_dealer;
        ELSE
          somador_dealer := somador_dealer + card;
        END IF;
      END IF;

      -- Caso o estado atual seja turno_player
      IF (estado_atual = turno_player) THEN
        IF vez_jogador = '1' THEN
          proximo_estado := hit_player;
        ELSIF stay_player = '1' THEN
          proximo_estado := turno_dealer;
          ELSE
          proximo_estado := turno_player; -- Aguarda ação do jogador
        END IF;      
      END IF;

      -- Caso o estado atual seja hit player
      IF (estado_atual = hit_player) THEN
        IF ((card) = 1) THEN
          IF (somador_player < 11) THEN
            somador_player := 11 + somador_player;
            IF (somador_player > 21) THEN
            somador_player := somador_player - 10; -- Rebaixa o Ás para 1
          END IF;
          ELSE
            somador_player := 1 + somador_player;
          END IF;
        ELSIF ((card) > 9) THEN
          somador_player := 10 + somador_player;
        ELSE
          somador_player := somador_player + card;
        END IF;

        IF somador_player > 21 THEN
          proximo_estado := perdeu;
        ELSE
          proximo_estado := turno_player;
        END IF;
      END IF;

      -- Caso o estado atual seja turno_dealer
      IF (estado_atual = turno_dealer) THEN
        IF somador_dealer < 17 THEN
          proximo_estado := hit_dealer;
        ELSE
          proximo_estado := analise;
        END IF;
      END IF;

      -- Csao o estado atual seja hit_dealer
      IF (estado_atual = hit_dealer) THEN
        IF ((card) = 1) THEN
          IF (somador_dealer < 11) THEN
            somador_dealer := 11 + somador_dealer;
            IF (somador_dealer > 21) THEN
            somador_dealer := somador_dealer - 10; -- Rebaixa o Ás para 1
          END IF;
          ELSE
            somador_dealer := card + somador_dealer;
          END IF;
        ELSIF ((card) > 9) THEN
          somador_dealer := 10 + somador_dealer;
        ELSE
          somador_dealer := somador_dealer + card;
        END IF;
        IF somador_dealer > 21 THEN
          proximo_estado := venceu;
        ELSE
          proximo_estado := turno_dealer;
        END IF;
      END IF;

      -- Caso o estado atual seja analise
      IF (estado_atual = analise) THEN
        IF (somador_player > somador_dealer) THEN
          proximo_estado := venceu;
        ELSIF (somador_player = somador_dealer) THEN
          proximo_estado := empate;
        ELSE
          proximo_estado := perdeu;
        END IF;
      END IF;

      -- Caso o jogo acabou
      IF (estado_atual = empate OR estado_atual = venceu OR estado_atual = perdeu) THEN
        proximo_estado := inicio;
      END IF;

      estado_atual := proximo_estado;

      -- Processando o que mostrar no HEX1 e HEX2
      

    END IF;

    -- Processando o reset
    IF (start = '1') THEN
      estado_atual := inicio;
      proximo_estado := c1_player;
      card := to_integer(unsigned(sw(5 DOWNTO 2)));
      somador_player := 0;
      somador_dealer := 0;
      hex1 <= to_7seg2(somador_player);
      hex2 <= to_7seg1(somador_player);
      ledr <= '0';
      ledg <= '0';
      hex3 <= to_7seg(card);
    END IF;

  END PROCESS;

END arquiteturablackjack;