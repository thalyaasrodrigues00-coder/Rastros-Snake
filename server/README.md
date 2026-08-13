# Rastros Snake — Matchmaking (Node.js + Socket.IO)

Servidor de fila para os modos **Solo** (50 jogadores) e **Equipe** (10×5).

## Regras

1. Ao entrar na fila de um modo, inicia timer de **30 segundos** (se for o primeiro jogador).
2. Se **50 humanos** entrarem antes do tempo, a partida começa **imediatamente**.
3. Se o timer chegar a **0**, vagas restantes são preenchidas com **bots**.
4. Modo equipe: humanos e bots são **embaralhados** e distribuídos em **10 equipes de 5**.

## Instalação

```bash
cd server
npm install
npm start
```

Servidor padrão: `http://localhost:3000`

## Eventos (cliente → servidor)

| Evento | Payload | Descrição |
|--------|---------|-----------|
| `clicouJogar` | `{ modo: "solo" \| "equipe", nomeUsuario: string }` | Entra na fila |
| `join_lobby` | `{ teamMode: bool, nickname: string }` | Alias Flutter existente |

## Eventos (servidor → cliente)

| Evento | Payload |
|--------|---------|
| `atualizarCarregamento` | `{ humanosConectados, tempo, maxJogadores }` |
| `partidaPronta` | `{ sala, modo, jogadores? \| equipes? }` |
| `iniciarPartida` | alias legado de `partidaPronta` |
| `erroFila` | `{ mensagem }` |

## Exemplo Solo

```json
{
  "sala": "partida_1710000000000",
  "modo": "solo",
  "jogadores": [{ "id": "abc123", "nome": "Player1", "isBot": false }]
}
```

## Exemplo Equipe

```json
{
  "sala": "partida_1710000000000",
  "modo": "equipe",
  "equipes": [
    { "id": 0, "nomeEquipe": "Equipe A", "membros": [/* 5 jogadores */] }
  ]
}
```
