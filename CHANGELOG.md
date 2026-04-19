# 📝 Changelog

Todas as mudanças notáveis do projeto serão documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto segue [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [1.2.0] — 2025-04-18

### Adicionado
- Layout adaptativo para 1, 2, 3 ou 4 cartelas simultâneas
- Miniaturas de padrão de vitória na tela de seleção
- Fallback automático de configuração quando `game_config.json` está ausente ou corrompido

### Corrigido
- Miniaturas de padrão não renderizavam corretamente com 4 cartelas ativas
- Posicionamento dos elementos UI em resoluções não-padrão

---

## [1.1.0] — 2025-03-10

### Adicionado
- Sistema de troca gratuita de cartelas pré-jogo
- Near-win inteligente com detecção de 1, 2 ou 3 números faltando
- Oferta de bola extra com preço dinâmico e countdown de 10 segundos
- Popup de near-win com animação de entrada

### Alterado
- Custo da bola extra agora é calculado dinamicamente com base nos números restantes
- Melhorado feedback visual ao trocar cartelas

---

## [1.0.0] — 2025-02-01

### Adicionado
- Cartelas 3×5 com 15 números únicos por cartela
- Pool de números sem repetição entre até 4 cartelas simultâneas
- Sorteio progressivo com velocidade de 0,30 s → 0,12 s
- Modo Turbo com intervalo de 0,07 s
- 4 padrões de vitória: Coluna (×2), Linha (×4), Duas Linhas (×12), Cartela Cheia (×40)
- Eventos aleatórios: Bola Bônus (5 %), Multiplicador ×1,5/×2/×3 (4 %), Rodada Turbo (8 %)
- Progressão persistente com XP, nível, moedas e sequência de vitórias
- Economia e regras 100% configuráveis via `config/game_config.json`
- Signal bus global via `GameEvents.gd` para desacoplamento dos sistemas
- Máquina de estados: `IDLE → CARD_SELECTION → DRAWING → CHECKING_WIN → EXTRA_BALL_OFFER → REWARDING`

---

[1.2.0]: https://github.com/Nelson-D3v/bingo-rush/releases/tag/v1.2.0
[1.1.0]: https://github.com/Nelson-D3v/bingo-rush/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/Nelson-D3v/bingo-rush/releases/tag/v1.0.0
