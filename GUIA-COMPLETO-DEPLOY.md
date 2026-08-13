# Guia completo — GitHub + Render (do zero)

Este guia assume que você **nunca usou** GitHub nem Render.  
Siga **na ordem**. Não pule etapas.

Tempo total estimado: **40 a 60 minutos** ( primeira vez ).

---

# PARTE A — GITHUB (guardar o código na internet)

## A1. Criar conta no GitHub

1. Abra o navegador (Chrome).
2. Acesse: **https://github.com**
3. Clique em **Sign up** (Cadastrar-se).
4. Preencha:
   - E-mail
   - Senha
   - Nome de usuário (ex.: `thalligames` — anote, você vai usar sempre)
5. Confirme o e-mail se o GitHub pedir.

---

## A2. Instalar o Git no Windows (se ainda não tiver)

1. Acesse: **https://git-scm.com/download/win**
2. Baixe e instale (Next, Next, Finish — padrão está ok).
3. Feche e abra de novo o PowerShell ou o Cursor.

**Testar:** abra PowerShell e digite:

```powershell
git --version
```

Se aparecer algo como `git version 2.x.x`, está ok.

---

## A3. Criar um repositório vazio no GitHub

1. Entre em **https://github.com** (logada).
2. No canto superior direito, clique no **+** → **New repository**.
3. Preencha:

   | Campo | O que colocar |
   |-------|----------------|
   | Repository name | `rastros-snake` |
   | Description | (opcional) Jogo Rastros Snake |
   | Public / Private | **Public** (Render free usa repo public ou conectado) |
   | Add a README file | **NÃO marque** |
   | Add .gitignore | **NÃO marque** |
   | Choose a license | **Nenhum** |

4. Clique **Create repository**.

5. Na página que abrir, **copie a URL** que aparece (botão verde **Code**):

   Exemplo:
   ```
   https://github.com/SEU_USUARIO/rastros-snake.git
   ```

   Troque `SEU_USUARIO` pelo seu nome de usuário real. **Guarde essa URL.**

---

## A4. Enviar o jogo do seu PC para o GitHub

### Abrir o terminal na pasta do jogo

1. No Cursor, menu **Terminal** → **New Terminal**.
2. Ou PowerShell: navegue até a pasta:

```powershell
cd "c:\jogo da cobrinha"
```

### Comandos (copie um bloco por vez)

**1) Iniciar Git na pasta:**

```powershell
git init
```

**2) Configurar seu nome (só na primeira vez no PC):**

```powershell
git config user.name "Seu Nome"
git config user.email "seu-email@gmail.com"
```

(Use o **mesmo e-mail** da conta GitHub.)

**3) Adicionar todos os arquivos:**

```powershell
git add .
```

**4) Criar o primeiro pacote (commit):**

```powershell
git commit -m "Rastros Snake - jogo e servidor online"
```

**5) Renomear branch para main:**

```powershell
git branch -M main
```

**6) Conectar ao GitHub** (cole **sua** URL do passo A3):

```powershell
git remote add origin https://github.com/SEU_USUARIO/rastros-snake.git
```

**7) Enviar para a internet:**

```powershell
git push -u origin main
```

### Login no push

- Pode abrir janela do navegador para login GitHub — autorize.
- Ou pedir **usuário + senha**: a senha **não** é a da conta; use um **Personal Access Token**:
  1. GitHub → foto perfil → **Settings**
  2. **Developer settings** → **Personal access tokens** → **Tokens (classic)**
  3. **Generate new token** → marque **repo** → Generate
  4. Copie o token e use como **senha** no terminal

### Confirmar que deu certo

1. Atualize a página do repositório no GitHub.
2. Deve listar pastas: `lib`, `server`, `android`, `web_download`, etc.
3. Entre na pasta **server** — deve ter `index.js` e `package.json`.

---

# PARTE B — RENDER (colocar o servidor online 24h)

## B1. Criar conta no Render

1. Acesse: **https://render.com**
2. Clique **Get Started** ou **Sign Up**.
3. Escolha **Sign up with GitHub** (mais fácil).
4. Autorize o Render a ver seus repositórios.

---

## B2. Criar o serviço (servidor do jogo)

### Método recomendado: Web Service manual

1. No painel Render, clique **New +** (canto superior direito).
2. Escolha **Web Service**.
3. Se pedir, conecte o GitHub e dê acesso ao repositório **rastros-snake**.
4. Clique **Connect** ao lado de `rastros-snake`.

### Preencher cada campo (IMPORTANTE)

| Campo | Valor exato |
|-------|-------------|
| **Name** | `rastros-snake-server` |
| **Region** | Oregon (US West) ou o mais perto — qualquer serve |
| **Branch** | `main` |
| **Root Directory** | `server` |
| **Runtime** | **Node** |
| **Build Command** | `npm install` |
| **Start Command** | `npm start` |
| **Instance Type** | **Free** |

5. Role até **Advanced** (opcional):
   - **Health Check Path**: `/health`

6. Clique **Create Web Service**.

---

## B3. Aguardar o deploy

1. Você verá logs rolando (Installing, Building, Deploying).
2. Quando ficar **Live** (etiqueta verde), está no ar.
3. No topo da página, copie a URL:

   Exemplo:
   ```
   https://rastros-snake-server.onrender.com
   ```

   (O nome pode variar um pouco.)

---

## B4. Testar se o servidor funciona

1. Abra no celular ou PC:
   ```
   https://SUA-URL.onrender.com/health
   ```
2. Deve aparecer texto parecido com:
   ```json
   {"ok":true,"service":"rastros-snake-matchmaking","online":true}
   ```

Se aparecer isso, **o servidor global está funcionando**.

### Se der erro 502 ou demorar muito

- Plano **Free** “dorme” após ~15 min sem uso.
- Espere **30–60 segundos** e atualize a página.

---

# PARTE C — LIGAR O APK AO SERVIDOR

## C1. Colar a URL no código

1. No Cursor, abra:
   ```
   lib/app/constants/server_config.dart
   ```
2. Encontre a linha:
   ```dart
   static const String productionServerUrl = '';
   ```
3. Cole sua URL do Render **entre as aspas** (sem `/` no final):

   ```dart
   static const String productionServerUrl = 'https://rastros-snake-server.onrender.com';
   ```

4. Salve o arquivo (Ctrl+S).

---

## C2. Gerar APK de produção

No PowerShell:

```powershell
cd "c:\jogo da cobrinha"
flutter build apk --release
```

Copiar para o site:

```powershell
Copy-Item -Force build\app\outputs\flutter-apk\app-release.apk web_download\RastrosSnake.apk
```

Suba o novo **RastrosSnake.apk** no Google Drive / site (como você já fez antes).

---

## C3. Testar multiplayer global

1. Celular 1: instale o APK → entre no lobby.
2. Celular 2 (pode ser outra rede, 4G): instale o mesmo APK → entre no lobby.
3. Deve mostrar **2 humano(s) na fila**.
4. Na partida, deve ver o **nome** do outro jogador.

---

# PARTE D — Atualizar depois (quando mudar o código)

Sempre que alterar o jogo ou o servidor:

```powershell
cd "c:\jogo da cobrinha"
git add .
git commit -m "Descricao da mudanca"
git push
```

O Render **atualiza sozinho** em 2–5 minutos após o push.

Se mudou só o Flutter (APK), rode de novo:
```powershell
flutter build apk --release
```

---

# Resumo em 6 frases

1. **GitHub** = cofre do código na internet.  
2. **git push** = enviar pasta do PC para o GitHub.  
3. **Render** = computador na nuvem que roda `server/index.js` 24h.  
4. **URL .onrender.com** = endereço que o APK usa para achar jogadores.  
5. **productionServerUrl** = onde você cola essa URL no Flutter.  
6. **Novo APK** = jogadores precisam baixar de novo após mudar a URL.

---

# Checklist final

- [ ] Conta GitHub criada  
- [ ] Repositório `rastros-snake` criado  
- [ ] `git push` funcionou (arquivos visíveis no GitHub)  
- [ ] Conta Render criada (login com GitHub)  
- [ ] Web Service **Live** com Root Directory = `server`  
- [ ] `/health` abre no navegador  
- [ ] `productionServerUrl` preenchida  
- [ ] APK novo gerado e no site  

---

# Precisa de ajuda?

Quando terminar o passo **B3**, me envie:

1. A URL do Render (ex.: `https://xxxx.onrender.com`)  
2. Se o `/health` abriu ok  

Aí monto o trecho exato do `server_config.dart` e o comando do APK para você.
