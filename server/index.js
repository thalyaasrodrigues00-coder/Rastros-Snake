const http = require("http");
const { Server } = require("socket.io");

const PORT = process.env.PORT || 3000;
const MAX_JOGADORES = 50;
const ESPERA_MIN_SEG = 12;
const ESPERA_MAX_SEG = 22;
const EQUIPES = 10;
const JOGADORES_POR_EQUIPE = 5;

const server = http.createServer((req, res) => {
  if (req.url === "/" || req.url === "/health") {
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(
      JSON.stringify({
        ok: true,
        service: "rastros-snake-matchmaking",
        online: true,
      })
    );
    return;
  }
  res.writeHead(404);
  res.end();
});
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
  },
});

/** @type {{ solo: SalaEspera, equipe: SalaEspera }} */
const salasEspera = {
  solo: criarSalaEspera(),
  equipe: criarSalaEspera(),
};

function criarSalaEspera() {
  return {
    jogadores: [],
    tempoRestante: 0,
    fimEsperaMs: null,
    timer: null,
  };
}

function modoValido(modo) {
  return modo === "solo" || modo === "equipe";
}

function embaralhar(lista) {
  const copia = [...lista];
  for (let i = copia.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copia[i], copia[j]] = [copia[j], copia[i]];
  }
  return copia;
}

function tempoRestanteDaSala(sala) {
  if (!sala.fimEsperaMs) return 0;
  return Math.max(0, Math.ceil((sala.fimEsperaMs - Date.now()) / 1000));
}

function emitirCarregamento(modo) {
  const sala = salasEspera[modo];
  const tempo = tempoRestanteDaSala(sala);
  sala.tempoRestante = tempo;

  io.to(`fila_${modo}`).emit("atualizarCarregamento", {
    humanosConectados: sala.jogadores.length,
    tempo,
    maxJogadores: MAX_JOGADORES,
    fimEsperaMs: sala.fimEsperaMs,
  });
}

function pararTimer(modo) {
  const sala = salasEspera[modo];
  if (sala.timer !== null) {
    clearInterval(sala.timer);
    sala.timer = null;
  }
}

function resetarSala(modo) {
  const sala = salasEspera[modo];
  pararTimer(modo);
  sala.jogadores = [];
  sala.tempoRestante = 0;
  sala.fimEsperaMs = null;
}

function removerJogadorDeTodasFilas(socketId) {
  for (const modo of ["solo", "equipe"]) {
    const sala = salasEspera[modo];
    const antes = sala.jogadores.length;
    sala.jogadores = sala.jogadores.filter((j) => j.id !== socketId);

    if (sala.jogadores.length !== antes) {
      if (sala.jogadores.length === 0) {
        resetarSala(modo);
      } else {
        emitirCarregamento(modo);
      }
    }
  }
}

function definirFimEspera(sala) {
  if (sala.fimEsperaMs) return;
  const segundos =
    ESPERA_MIN_SEG +
    Math.floor(Math.random() * (ESPERA_MAX_SEG - ESPERA_MIN_SEG + 1));
  sala.fimEsperaMs = Date.now() + segundos * 1000;
}

function gerenciarFila(modo) {
  const sala = salasEspera[modo];
  if (sala.timer !== null) return;

  definirFimEspera(sala);
  emitirCarregamento(modo);

  sala.timer = setInterval(() => {
    const tempo = tempoRestanteDaSala(sala);
    sala.tempoRestante = tempo;
    emitirCarregamento(modo);

    console.log(
      `[${modo.toUpperCase()}] Humanos: ${sala.jogadores.length}/${MAX_JOGADORES} | ${tempo}s restantes`
    );

    if (sala.jogadores.length >= MAX_JOGADORES) {
      iniciarPartidaComHumanos(modo);
    } else if (tempo <= 0) {
      completarComBotsEIniciar(modo);
    }
  }, 250);
}

function iniciarPartidaComHumanos(modo) {
  const sala = salasEspera[modo];
  pararTimer(modo);

  const listaFinal = [...sala.jogadores];
  resetarSala(modo);

  console.log(`[${modo.toUpperCase()}] 50 humanos! Iniciando partida.`);
  dispararJogo(modo, listaFinal);
}

function completarComBotsEIniciar(modo) {
  const sala = salasEspera[modo];
  pararTimer(modo);

  const listaFinal = [...sala.jogadores];
  const humanosQuantidade = listaFinal.length;
  const botsNecessarios = MAX_JOGADORES - humanosQuantidade;

  for (let i = 0; i < botsNecessarios; i++) {
    listaFinal.push({
      id: `bot_${Date.now()}_${i}_${Math.floor(Math.random() * 10000)}`,
      nome: `Bot ${i + 1}`,
      isBot: true,
    });
  }

  resetarSala(modo);

  console.log(
    `[${modo.toUpperCase()}] ${humanosQuantidade} humano(s) + ${botsNecessarios} bots.`
  );

  dispararJogo(modo, listaFinal);
}

function montarEquipes(participantes) {
  const misturados = embaralhar(participantes);
  const equipes = [];

  for (let i = 0; i < EQUIPES; i++) {
    const membros = misturados.splice(0, JOGADORES_POR_EQUIPE);
    equipes.push({
      id: i,
      nomeEquipe: `Equipe ${String.fromCharCode(65 + i)}`,
      membros,
    });
  }

  return equipes;
}

function dispararJogo(modo, participantes) {
  const idDaPartida = `partida_${Date.now()}`;
  const payload =
    modo === "solo"
      ? {
          sala: idDaPartida,
          modo: "solo",
          jogadores: embaralhar(participantes),
        }
      : {
          sala: idDaPartida,
          modo: "equipe",
          equipes: montarEquipes(participantes),
        };

  const socketIds = participantes.filter((p) => !p.isBot).map((p) => p.id);

  for (const socketId of socketIds) {
    const socket = io.sockets.sockets.get(socketId);
    if (socket) {
      socket.leave(`fila_${modo}`);
      socket.join(idDaPartida);
      socket.emit("partidaPronta", payload);
    }
  }

  console.log(`[${modo.toUpperCase()}] Partida ${idDaPartida} iniciada.`);
}

function entrarFila(socket, dados) {
  const modo = dados.modo;
  const nomeUsuario = (dados.nomeUsuario || dados.nickname || "Jogador").trim();

  if (!modoValido(modo)) {
    socket.emit("erroFila", { mensagem: "Modo inválido. Use 'solo' ou 'equipe'." });
    return;
  }

  removerJogadorDeTodasFilas(socket.id);

  const sala = salasEspera[modo];
  const jaNaFila = sala.jogadores.some((j) => j.id === socket.id);

  if (!jaNaFila) {
    if (sala.jogadores.length >= MAX_JOGADORES) {
      socket.emit("erroFila", { mensagem: "Fila cheia. Aguarde a próxima partida." });
      return;
    }

    sala.jogadores.push({
      id: socket.id,
      nome: nomeUsuario,
      isBot: false,
    });
    socket.join(`fila_${modo}`);
  }

  if (sala.jogadores.length === 1) {
    gerenciarFila(modo);
  } else {
    emitirCarregamento(modo);
  }

  if (sala.jogadores.length >= MAX_JOGADORES) {
    iniciarPartidaComHumanos(modo);
  }
}

io.on("connection", (socket) => {
  console.log(`Cliente conectado: ${socket.id}`);

  socket.on("clicouJogar", (dados) => {
    entrarFila(socket, dados);
  });

  socket.on("join_lobby", (dados) => {
    entrarFila(socket, {
      modo: dados?.teamMode ? "equipe" : "solo",
      nomeUsuario: dados?.nickname,
    });
  });

  socket.on("entrandoPartida", (dados) => {
    const sala = dados?.sala;
    if (sala) socket.join(sala);
  });

  socket.on("syncEstado", (dados) => {
    const sala = dados?.sala;
    if (!sala) return;
    socket.to(sala).emit("syncEstado", {
      id: socket.id,
      x: dados.x,
      y: dados.y,
      angle: dados.angle,
      score: dados.score,
      boosting: dados.boosting,
      alive: dados.alive,
      nome: dados.nome,
      teamId: dados.teamId,
    });
  });

  socket.on("syncMorte", (dados) => {
    const sala = dados?.sala;
    if (!sala) return;
    socket.to(sala).emit("syncMorte", {
      id: socket.id,
      mortoPor: dados?.mortoPor ?? null,
    });
  });

  socket.on("disconnect", () => {
    removerJogadorDeTodasFilas(socket.id);
    console.log(`Cliente desconectado: ${socket.id}`);
  });
});

server.listen(PORT, "0.0.0.0", () => {
  console.log(`Rastros Snake — matchmaking rodando em 0.0.0.0:${PORT}`);
});
