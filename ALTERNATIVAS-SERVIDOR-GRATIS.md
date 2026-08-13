# Servidores grátis — alternativas ao Render

O Render free **dorme**, demora a acordar e às vezes **falha no deploy**.  
Seu servidor é **Node.js + Socket.IO** — precisa de hospedagem que fique **ligada** e aceite **WebSocket**.

---

## Comparativo rápido

| Serviço | Grátis? | WebSocket | Brasil | Dificuldade | Recomendado |
|---------|---------|-----------|--------|-------------|-------------|
| **[Railway](https://railway.app)** | Créditos/mês | Sim | EUA | Fácil | **1º — mais fácil** |
| **[Fly.io](https://fly.io)** | Limite grátis | Sim | **São Paulo (gru)** | Médio | **2º — melhor ping BR** |
| **[Koyeb](https://koyeb.com)** | 1 serviço grátis | Sim | Europa/EUA | Fácil | 3º |
| **Render** | Sim | Sim | EUA | Fácil | Pode falhar/dormir |
| **Oracle Cloud** | VM grátis | Sim | São Paulo | Difícil | Avançado |

**Não serve:** Vercel, Netlify, GitHub Pages (não rodam servidor Node 24h).

---

# OPÇÃO 1 — RAILWAY (recomendado se Render falhou)

### Passo 1
1. Acesse **https://railway.app**
2. **Login with GitHub**
3. Autorize

### Passo 2
1. **New Project**
2. **Deploy from GitHub repo**
3. Escolha **Rastros-Snake**

### Passo 3 — Configurar pasta do servidor
1. Clique no serviço criado → **Settings**
2. **Root Directory** → `server`
3. **Start Command** → `npm start`
4. **Build Command** → `npm install` (ou deixe automático)

### Passo 4 — URL pública
1. Aba **Settings** → **Networking**
2. **Generate Domain**
3. Copie a URL, exemplo:
   ```
   https://rastros-snake-production.up.railway.app
   ```

### Passo 5 — Testar no celular
```
https://SUA-URL.up.railway.app/health
```
Deve mostrar `"ok": true`.

### Passo 6 — Colocar no jogo
`lib/app/constants/server_config.dart`:
```dart
static const String productionServerUrl = 'https://SUA-URL.up.railway.app';
```

---

# OPÇÃO 2 — FLY.IO (melhor para jogadores no Brasil)

Região **gru** = São Paulo → menor lag.

### Passo 1
1. **https://fly.io** → Sign up (GitHub)
2. Instale flyctl no PC: **https://fly.io/docs/hands-on/install-flyctl/**

### Passo 2 — No PowerShell
```powershell
cd "c:\jogo da cobrinha\server"
fly auth login
fly launch --no-deploy
```
- App name: `rastros-snake` (ou outro)
- Region: escolha **São Paulo (gru)**
- Não precisa PostgreSQL → **No**

### Passo 3 — Deploy
```powershell
fly deploy
```

### Passo 4 — URL
```
https://rastros-snake.fly.dev/health
```

Use essa URL no `productionServerUrl`.

---

# OPÇÃO 3 — KOYEB

1. **https://koyeb.com** → Sign up with GitHub
2. **Create App** → **GitHub** → repo **Rastros-Snake**
3. **Builder:** Node.js
4. **Root directory:** `server`
5. **Run command:** `npm start`
6. **Instance:** Free (Nano)
7. **Create App**
8. URL tipo: `https://xxx.koyeb.app/health`

---

# Por que o Render “não carrega”?

| Causa | O que fazer |
|-------|-------------|
| Deploy falhou (vermelho) | Abra **Logs** no Render → veja erro |
| Root Directory errado | Deve ser `server` |
| Start Command errado | Deve ser `npm start` |
| Plano free dormindo | Espere 60 s e teste `/health` de novo |
| Build npm falhou | Logs → falta `package.json` na pasta certa |
| Conta nova não verificada | Verifique e-mail / cartão (Render às vece pede) |

Se nos **Logs** aparecer erro, copie e me envie.

---

# Depois de escolher QUALQUER serviço

1. Teste `/health` no **Chrome do celular**
2. Cole URL em `server_config.dart` → `productionServerUrl`
3. Gere APK:
   ```powershell
   cd "c:\jogo da cobrinha"
   flutter build apk --release
   ```
4. Instale nos celulares — jogadores do Brasil todo na mesma fila

---

# Resumo

- **Render não é obrigatório** — Railway ou Fly.io fazem o **mesmo trabalho**
- **Railway** = mais parecido com Render, fácil
- **Fly.io** = melhor latência no Brasil (São Paulo)
- O código do servidor (`server/index.js`) **não muda** — só a URL no app

Me diga qual você escolheu (Railway, Fly ou Koyeb) e a URL do `/health` que eu confirmo e monto o APK.
