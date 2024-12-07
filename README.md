# Blackjack em VHDL - GEX606 - Sistemas Digitais - 2024/2

Este projeto foi desenvolvido como parte da avaliação da disciplina de Sistemas Digitais, lecionada pelo professor Geomar Schreiner no curso de Ciência da Computação da Universidade Federal da Fronteira Sul. O objetivo foi implementar uma máquina de estados finitos (FSM) em VHDL para simular o clássico jogo de cassino Blackjack, integrando a lógica digital em uma FPGA DE1-Cyclone II.

## Descrição do Projeto

O Blackjack, também conhecido como "21", é um jogo de cartas em que um jogador enfrenta um carteador, buscando obter uma soma de cartas o mais próxima possível de 21, sem ultrapassá-lo. Este projeto traduz as mecânicas do jogo para o ambiente digital, incluindo:

- Distribuição inicial de cartas.
- Decisões do jogador: **HIT** (pedir carta) e **STAY** (manter mão atual).
- Jogada automática do carteador conforme regras do jogo.
- Avaliação automática do resultado da partida.

O sistema foi implementado como uma FSM, utilizando entradas de controle (botões e switches) e saídas como displays de 7 segmentos e LEDs para interação e exibição do estado atual.

## Estrutura do Sistema

### Diagrama de Estados

O jogo foi modelado como uma FSM composta pelos seguintes estados principais:

1. **Estado Inicial**  
   - Inicializa variáveis (somas das cartas, sinais de controle).  
   - Distribui as cartas iniciais ao jogador e ao carteador.

2. **Estado Jogador**  
   - O jogador pode:
     - Pedir carta (HIT): Atualiza soma; transita para **Resultado** se ultrapassar 21.
     - Manter mão (STAY): Transita para o estado do carteador.

3. **Estado Jogador_as**  
   - Ativado quando o jogador possui um Ás utilizável como 11.

4. **Estado Carteador**  
   - O carteador joga automaticamente até atingir 17 pontos ou mais.

5. **Estado Carteador_as**  
   - Similar ao **Estado Jogador_as**, mas aplicável ao carteador.

6. **Estado Resultado**  
   - Determina o vencedor com base nas somas das cartas:
     - Vitória do jogador.
     - Vitória do carteador.
     - Empate.

### Tabela de Transições de Estado

| Estado Atual   | Condição                       | Próximo Estado | Descrição                                                                 |
|----------------|--------------------------------|----------------|---------------------------------------------------------------------------|
| início         | Cartas iniciais distribuídas  | jogador        | O jogador está pronto para tomar decisões.                               |
| jogador        | `sw(6)='1'` (HIT)             | jogador        | O jogador solicita mais uma carta e permanece no estado.                 |
| jogador        | `sw(7)='1'` (STAY)            | carteador      | O jogador decide não pegar mais cartas e passa a vez ao carteador.       |
| jogador        | soma_cartas_jogador > 21      | resultado      | O jogador ultrapassa 21 pontos e perde o jogo.                           |
| jogador        | Possui Ás e decide usá-lo     | jogador_as     | O jogador utiliza o Ás como 11 para melhorar a soma.                     |
| jogador_as     | `sw(6)='1'` (HIT)             | jogador_as     | O jogador solicita uma nova carta considerando o Ás.                    |
| jogador_as     | `sw(7)='1'` (STAY)            | carteador      | O jogador decide parar e passa a vez para o carteador.                   |
| jogador_as     | soma_cartas_jogador > 21      | resultado      | O jogador ultrapassa 21 pontos, mesmo com o Ás como 11.                  |
| carteador      | soma_cartas_carteador < 17    | carteador      | O carteador pega mais cartas automaticamente.                            |
| carteador      | soma_cartas_carteador >= 17   | resultado      | O carteador atinge ou ultrapassa 17 pontos e para de jogar.              |
| carteador      | soma_cartas_carteador > 21    | resultado      | O carteador ultrapassa 21 pontos e perde o jogo.                         |
| carteador      | Possui Ás e decide usá-lo     | carteador_as   | O carteador utiliza o Ás como 11 para melhorar a soma.                   |
| resultado      | Resultado calculado           | início         | O jogo pode ser reiniciado pressionando o botão de reset.                |

### Código VHDL Mapeado para FPGA

O código VHDL foi projetado para ser sintetizado e implementado em uma FPGA DE1-Cyclone II. As principais funcionalidades incluem:

- Lógica combinacional e sequencial para gerenciar transições de estado.
- Interface de entrada (botões e switches) para controle do jogo.
- Saída para displays de 7 segmentos e LEDs para exibição do estado do jogo.

## Conclusão

O sistema foi testado em um simulador e na FPGA. Apesar de atender à maior parte das especificações, algumas funcionalidades apresentaram falhas devido a desafios de integração. No entanto, o projeto demonstrou a viabilidade de implementar um jogo interativo com lógica digital.

Este projeto possibilitou a aplicação prática dos conceitos de FSM e VHDL, consolidando os conhecimentos adquiridos ao longo da disciplina.

---

**Autores**  
- Gabriel Santos Costa ([gabrielsantoscosta005@gmail.com](mailto:gabrielsantoscosta005@gmail.com))  
- Pedro Augusto Sciesleski ([psciesleski@gmail.com](mailto:psciesleski@gmail.com))  

**Data**: 05/12/2024  
**Disciplina**: GEX606 - Sistemas Digitais  
**Instituição**: Universidade Federal da Fronteira Sul
