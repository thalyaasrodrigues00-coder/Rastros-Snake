# Deploy do servidor — Rastros Snake (Render)

Guia passo a passo para deixar o jogo **online no mundo todo**.

---

## O que você vai ter no final

- URL pública tipo: `https://rastros-snake.onrender.com`
- Servidor 24h (Render free pode “dormir” após 15 min sem uso — primeiro acesso demora ~30s)
- Qualquer pessoa com o APK entra na fila global

---

## PARTE 1 — Colocar o código no GitHub

1. Crie conta em [github.com](https://github.com) (se não tiver).
2. Crie um repositório novo (ex.: `rastros-snake`).
3. No PC, na pasta do jogo, envie o projeto:

```powershell
cd "c:\jogo da cobrinha"
git init
git add .
git commit -m "Rastros Snake - servidor e jogo"
git branch -M main
git remote add origin https://github.com/SEU_USUARIO/rastros-snake.git
git push -u origin main
```

> Se já usa Git, só faça `git push` com as alterações novas.

---

## PARTE 2 — Deploy no Render (grátis para começar)

1. Acesse [render.com](https://render.com) e crie conta (pode entrar com GitHub).

2. Clique em **New +** → **Blueprint** (ou **Web Service**).

### Opção A — Blueprint (mais fácil)

3. Conecte o repositório GitHub do jogo.
4. O Render detecta o arquivo `render.yaml` na raiz.
5. Clique **Apply** / **Deploy**.

### Opção B — Web Service manual

3. **New +** → **Web Service** → escolha o repositório.
4. Configure:

| Campo | Valor |
|-------|--------|
| Name | `rastros-snake-server` |
| Root Directory | `server` |
| Runtime | Node |
| Build Command | `npm install` |
| Start Command | `npm start` |
| Plan | Free |

5. **Create Web Service**.

---

## PARTE 3 — Copiar a URL do servidor

1. Quando o deploy ficar **Live** (verde), copie a URL no topo, exemplo:

   `https://rastros-snake-server.onrender.com`

2. Teste no navegador:

   `https://SUA-URL.onrender.com/health`

   Deve aparecer: `{"ok":true,"service":"rastros-snake-matchmaking","online":true}`

---

## PARTE 4 — Apontar o APK para o servidor

Abra o arquivo:

`lib/app/constants/server_config.dart`

Cole a URL na linha `productionServerUrl`:

```dart
static const String productionServerUrl = 'https://rastros-snake-server.onrender.com';
```

(Sem barra `/` no final.)

---

## PARTE 5 — Gerar APK de produção

No PowerShell:

```powershell
cd "c:\jogo da cobrinha"
flutter build apk --release
```

Ou use o script (passa a URL automaticamente):

```powershell
.\scripts\build-apk-producao.ps1 -ServerUrl "https://rastros-snake-server.onrender.com"
```

Copie o APK para o site:

```powershell
Copy-Item build\app\outputs\flutter-apk\app-release.apk web_download\RastrosSnake.apk
```

---

## PARTE 6 — Testar com 2 celulares (redes diferentes)

1. Celular 1: instale o APK → Modo Solo → lobby.
2. Celular 2 (pode ser 4G, outra Wi‑Fi): mesmo passo.
3. Deve mostrar **2 humano(s) na fila** e, na partida, **ver o nome do outro jogador**.

---

## Plano gratuito Render — saiba disso

| Comportamento | O que fazer |
|---------------|-------------|
| Servidor “dorme” sem jogadores | Primeiro login demora ~30–60s |
| 750 h/mês grátis | Suficiente para testes e lançamento pequeno |
| WebSocket | Funciona no plano free |

Para **sempre ligado**, upgrade para plano pago (~US$ 7/mês) no Render.

---

## Alternativa: Railway

1. [railway.app](https://railway.app) → New Project → Deploy from GitHub.
2. Root directory: `server`
3. Start: `npm start`
4. Em **Settings → Networking** → **Generate Domain**
5. Use essa URL no `server_config.dart` (mesmo processo).

---

## Resumo visual

```
GitHub (código)
    ↓
Render / Railway (servidor Node.js 24h)
    ↓
https://seu-app.onrender.com  ← URL pública
    ↓
server_config.dart + novo APK
    ↓
Site (Google Sites) → download APK
    ↓
Jogadores do mundo todo na mesma fila
```

---

## Problemas comuns

**Lobby fica “Conectando...”**
→ URL errada em `productionServerUrl` ou servidor ainda acordando (free tier).

**Só bots na partida**
→ Servidor offline ou APK antigo (sem URL de produção).

**Erro de conexão**
→ Confirme `/health` no navegador do celular.

---

## Suporte

Depois do deploy, guarde a URL. Cada vez que mudar o servidor, atualize `server_config.dart` e gere um **novo APK**.
