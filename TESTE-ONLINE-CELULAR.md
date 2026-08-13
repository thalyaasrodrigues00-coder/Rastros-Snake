# Como testar online no celular

## Por que "não carrega" hoje?

O APK que você instalou provavelmente aponta para:

```
http://192.168.15.9:3000
```

Isso **só funciona** se:
- O PC estiver ligado com `npm start` na pasta `server`
- O celular estiver na **mesma Wi‑Fi**

Fora disso → fica "Conectando..." ou cai em partida só com bots.

Para **Brasil todo** → precisa URL do Render **dentro do APK**.

---

## TESTE 1 — Celular + PC (mesma Wi‑Fi) — grátis, hoje

1. No PC:
   ```powershell
   cd "c:\jogo da cobrinha\server"
   npm start
   ```
2. Veja o IP do PC: `ipconfig` → IPv4 (ex.: 192.168.0.15)
3. Confirme `productionServerUrl = ''` em `server_config.dart` (vazio)
4. Gere APK se mudou o IP:
   ```powershell
   flutter build apk --release --dart-define=SERVER_HOST=192.168.0.15
   ```
5. Celular na **mesma Wi‑Fi** → instale APK → lobby deve mostrar **Conectado**

---

## TESTE 2 — Render (Brasil / mundo todo) — recomendado

### A) Testar o servidor no celular (sem APK novo)

Abra o **Chrome do celular** e acesse:

```
https://SUA-URL.onrender.com/health
```

- Se aparecer `"ok": true` → servidor OK
- Se demorar 30–60 s na 1ª vez → normal (plano grátis "acordando")
- Se erro 404/502 → deploy no Render falhou ou URL errada

### B) Colocar URL no jogo

`lib/app/constants/server_config.dart`:

```dart
static const String productionServerUrl = 'https://SUA-URL.onrender.com';
```

### C) Novo APK

```powershell
cd "c:\jogo da cobrinha"
flutter build apk --release
```

Instale nos 2 celulares (podem ser 4G, Wi‑Fi diferente).

Lobby deve mostrar:
- **Conectado — sincronizando jogadores reais**
- Servidor: `https://SUA-URL.onrender.com`

---

## TESTE 3 — Duas pessoas reais

1. Celular A entra no lobby
2. Celular B entra 5 s depois
3. Contador de tempo **igual** nos dois
4. **2 humano(s) na fila**
5. Na partida: nome do outro jogador visível

---

## Render não carrega? Checklist

| Verificar | Onde |
|-----------|------|
| Status **Live** (verde)? | Painel Render |
| Root Directory = `server`? | Settings Render |
| Start Command = `npm start`? | Settings Render |
| `/health` abre no celular? | Chrome |
| URL no `server_config.dart`? | Código |
| APK **novo** instalado? | Celular |
| Esperou 60 s na 1ª conexão? | Plano grátis |

---

## Outras hospedagens (Brasil)

| Serviço | Site | Nota |
|---------|------|------|
| **Render** | render.com | Grátis, fácil, pode dormir |
| **Railway** | railway.app | Grátis limitado |
| **Fly.io** | fly.io | Região São Paulo possível |
| **Oracle Cloud** | oracle.com/cloud | VM grátis, mais difícil |

Todas usam o **mesmo** `server/index.js` — só muda a URL no `server_config.dart`.

---

## Me envie para eu conferir

1. URL do Render (ex.: `https://xxxx.onrender.com`)
2. O que aparece em `/health` no celular
3. O que o lobby mostra em **Servidor:** (linha pequena no fim)
