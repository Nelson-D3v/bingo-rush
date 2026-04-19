# 🤝 Como Contribuir com o Bingo Rush

Obrigado pelo interesse em contribuir! Este documento explica tudo que você precisa saber para participar do projeto.

---

## 📋 Índice

- [Pré-requisitos](#pré-requisitos)
- [Configurando o ambiente](#configurando-o-ambiente)
- [Como contribuir](#como-contribuir)
- [Padrão de commits](#padrão-de-commits)
- [Abrindo um Pull Request](#abrindo-um-pull-request)
- [Reportando bugs](#reportando-bugs)
- [Sugerindo features](#sugerindo-features)
- [Dúvidas](#dúvidas)

---

## Pré-requisitos

- [Godot 4.x](https://godotengine.org/download) (testado em 4.6 GL Compatibility)
- Git instalado
- Conhecimento básico de GDScript

---

## Configurando o ambiente

```bash
# 1. Faça um fork do repositório clicando em "Fork" no GitHub

# 2. Clone seu fork
git clone https://github.com/Nelson-D3v/bingo-rush.git
cd bingo-rush

# 3. Adicione o repositório original como upstream
git remote add upstream https://github.com/Nelson-D3v/bingo-rush.git

# 4. Abra no Godot
# File → Open Project → selecione a pasta bingo-rush/
# Pressione F5 para rodar
```

---

## Como contribuir

**1.** Crie uma branch a partir da `main`:
```bash
git checkout -b feature/nome-da-sua-feature
# ou
git checkout -b fix/nome-do-bug
```

**2.** Faça suas alterações seguindo os padrões do projeto

**3.** Teste bem antes de commitar — rode o jogo e verifique se nada quebrou

**4.** Commit seguindo o padrão abaixo

**5.** Abra um Pull Request

---

## Padrão de commits

Usamos [Conventional Commits](https://www.conventionalcommits.org/). Siga este formato:

```
tipo: descrição curta em português
```

| Tipo | Quando usar |
|---|---|
| `feat` | Nova funcionalidade |
| `fix` | Correção de bug |
| `docs` | Mudança na documentação |
| `refactor` | Refatoração sem mudar comportamento |
| `perf` | Melhoria de performance |
| `test` | Adição ou correção de testes |
| `chore` | Tarefas de manutenção |

**Exemplos:**
```bash
git commit -m "feat: adiciona padrão de vitória diagonal"
git commit -m "fix: corrige near-win quando há 4 cartelas ativas"
git commit -m "docs: atualiza seção de configuração no README"
git commit -m "refactor: simplifica lógica do DrawManager"
```

---

## Abrindo um Pull Request

- Título claro descrevendo o que foi feito
- Descreva o problema que resolve ou a feature que adiciona
- Se for visual, inclua screenshots ou GIFs
- Referencie a issue relacionada se houver: `Closes #42`
- Aguarde o review — feedbacks são construtivos e bem-vindos

---

## Reportando bugs

Abra uma [issue](https://github.com/Nelson-D3v/bingo-rush/issues) com:

- **Descrição:** o que aconteceu vs o que era esperado
- **Passos para reproduzir:** como chegar no bug
- **Versão do Godot:** ex: 4.6 GL Compatibility
- **Sistema operacional:** Windows, Linux, macOS
- **Screenshot ou GIF** se possível

---

## Sugerindo features

Abra uma [issue](https://github.com/Nelson-D3v/bingo-rush/issues) com:

- **Problema que resolve:** qual dor ou limitação atual
- **Solução proposta:** como você imagina que funcionaria
- **Alternativas consideradas:** outras formas que você pensou

---

## Ideias de contribuição

Não sabe por onde começar? Aqui vão algumas ideias:

- 🎨 Novos temas visuais para as cartelas
- 🏆 Novos padrões de vitória (diagonal, X, bordas)
- 🌍 Tradução para outros idiomas
- 🎮 Modo multiplayer local
- 📊 Leaderboard de pontuação
- 🔊 Efeitos sonoros e música

---

## Dúvidas

Abra uma [issue](https://github.com/Nelson-D3v/bingo-rush/issues) com a tag `question` — respondemos o mais rápido possível.

---

<div align="center">

Feito com ❤️ por [Nelson Felix](https://github.com/Nelson-D3v)

</div>
