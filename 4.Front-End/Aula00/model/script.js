// ---------- Massa de Dados (Dataset Inicial) ----------
/** DIDÁTICO: Isso é "estado em memória". Em vez de buscar dados de uma API/servidor
 * (fetch, axios, etc.), simulamos um banco de dados usando uma simples variável JS.
 * Como é `const`, não podemos reatribuir `sensoresIniciais = [...]`, mas PODEMOS
 * alterar o conteúdo do array (ex: mudar o `.valor` de um objeto, usar `.push()`),
 * porque `const` trava a referência, não o conteúdo. É esse detalhe que permite
 * a função `atualizarValoresSensores` "mutar" os dados depois. */
const sensoresIniciais = [
  { id: 1, nome: "Sensor Galpão A", tipo: "Temperatura", valor: 24.5, unidade: "°C", status: "normal" },
  { id: 2, nome: "Sensor Estufa 02", tipo: "Umidade", valor: 88.0, unidade: "%", status: "critico" },
  { id: 3, nome: "Sensor Compressor", tipo: "Pressão", valor: 6.2, unidade: "bar", status: "normal" },
  { id: 4, nome: "Sensor Câmara Fria", tipo: "Temperatura", valor: -2.1, unidade: "°C", status: "normal" },
  { id: 5, nome: "Sensor Almoxarifado", tipo: "Umidade", valor: 45.5, unidade: "%", status: "normal" },
  { id: 6, nome: "Sensor Caldeira", tipo: "Temperatura", valor: 98.4, unidade: "°C", status: "critico" },
];

// ---------- Ícones por tipo de sensor (Google Material Symbols) ----------
/** DIDÁTICO: Esse objeto funciona como uma "tabela de tradução" (lookup table).
 * Em vez de escrever um if/else ou switch pra decidir o ícone de cada sensor,
 * a gente usa o próprio valor de `sensor.tipo` como CHAVE do objeto e lê o
 * ícone correspondente. Isso é bem mais rápido e limpo que várias comparações. */
const iconesPorTipo = {
  Temperatura: "thermostat",
  Umidade: "water_drop",
  Pressão: "speed",
};

const limitesCriticosPorTipo = {
  Temperatura: { minimo: -10, maximo: 35 },
  Umidade: { minimo: 20, maximo: 80 },
  Pressão: { minimo: 1, maximo: 7 },
};

// ---------- Referências do DOM ----------
/** DIDÁTICO: `document.getElementById` busca UM elemento específico pelo atributo
 * `id="..."` no HTML. Guardamos essas referências em constantes no topo do arquivo
 * pra não precisar buscar no DOM toda vez que formos usá-las (isso também melhora
 * a performance, já que consultar o DOM tem um certo custo). */
const gridSensores = document.getElementById("grid-sensores");
const filtroTipo = document.getElementById("filtro-tipo");
const btnAtualizar = document.getElementById("btn-atualizar");
const statusConexao = document.getElementById("status-conexao");
const spanTimestamp = document.getElementById("ultimo-timestamp");
const modalOverlay = document.getElementById("modal-historico");
const listaHistorico = document.getElementById("lista-historico");
const btnFecharModal = document.getElementById("btn-fechar-modal");

let estaOnline = true;
const historicosSensores = {};

function registrarLeitura(sensor) {
  if (!historicosSensores[sensor.id]) {
    historicosSensores[sensor.id] = [];
  }

  historicosSensores[sensor.id].unshift({
    timestamp: new Date(),
    valor: sensor.valor,
    unidade: sensor.unidade,
  });

  if (historicosSensores[sensor.id].length > 5) {
    historicosSensores[sensor.id].pop();
  }
}

function registrarLeiturasIniciais() {
  sensoresIniciais.forEach(registrarLeitura);
}

function formatarTempoRelativo(timestamp) {
  const segundosPassados = Math.floor((Date.now() - timestamp.getTime()) / 1000);

  if (segundosPassados < 60) {
    return `há ${segundosPassados} segundo${segundosPassados === 1 ? "" : "s"}`;
  }

  const minutosPassados = Math.floor(segundosPassados / 60);
  if (minutosPassados < 60) {
    return `há ${minutosPassados} minuto${minutosPassados === 1 ? "" : "s"}`;
  }

  const horasPassadas = Math.floor(minutosPassados / 60);
  return `há ${horasPassadas} hora${horasPassadas === 1 ? "" : "s"}`;
}

function atualizarStatusConexao() {
  statusConexao.textContent = estaOnline ? "Online" : "Offline";
  statusConexao.classList.toggle("status--online", estaOnline);
  statusConexao.classList.toggle("status--offline", !estaOnline);
  btnAtualizar.disabled = !estaOnline;
  btnAtualizar.classList.toggle("botao--desabilitado", !estaOnline);
}

function abrirModalHistorico(sensorId) {
  const sensor = sensoresIniciais.find((item) => item.id === sensorId);
  const historico = historicosSensores[sensorId] || [];

  if (!sensor) return;

  document.getElementById("titulo-historico").textContent = `Histórico | ${sensor.nome}`;
  listaHistorico.innerHTML = historico
    .map(
      (item) => `
        <li class="modal-card__item">
          <strong>${item.valor.toFixed(1)} ${sensor.unidade}</strong>
          <time>${formatarTempoRelativo(item.timestamp)}</time>
        </li>
      `
    )
    .join("");

  modalOverlay.classList.add("modal--ativo");
  modalOverlay.setAttribute("aria-hidden", "false");
}

function fecharModalHistorico() {
  modalOverlay.classList.remove("modal--ativo");
  modalOverlay.setAttribute("aria-hidden", "true");
}

modalOverlay.addEventListener("click", (event) => {
  if (event.target === modalOverlay) {
    fecharModalHistorico();
  }
});

btnFecharModal.addEventListener("click", fecharModalHistorico);

document.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    fecharModalHistorico();
  }
});

statusConexao.addEventListener("click", () => {
  estaOnline = !estaOnline;
  atualizarStatusConexao();
});

// ---------- Regra de negócio: define se o sensor está crítico ----------
/** DIDÁTICO: Isso é uma "função pura" — ela recebe um sensor, olha os dados dele
 * e retorna true/false SEM alterar nada de fora (não mexe no DOM, não muda variável
 * global). Funções assim são mais fáceis de testar e prever o comportamento.
 * A regra combina duas condições com `||` (OU): já nasce crítico (`status`)
 * OU passou do limite de temperatura definido no PDF (> 35°C). */
function verificarCritico(sensor) {
  const limite = limitesCriticosPorTipo[sensor.tipo];
  if (!limite) return sensor.status === "critico";

  return sensor.valor < limite.minimo || sensor.valor > limite.maximo;
}

function atualizarStatusSensor(sensor) {
  sensor.status = verificarCritico(sensor) ? "critico" : "normal";
}

// ---------- Renderização Dinâmica do DOM ----------
/** DIDÁTICO: Essa é a função mais importante do projeto. Ela implementa o padrão
 * "renderizar a partir do estado": sempre que os dados mudam (filtro, atualização),
 * NÃO editamos os cards antigos um por um — nós APAGAMOS tudo (`innerHTML = ""`)
 * e desenhamos tudo de novo do zero, a partir do array atual. Pode parecer
 * "desperdício", mas é o que torna o código previsível: a tela É um reflexo
 * fiel do array em memória, sempre. Frameworks como React fazem uma versão
 * otimizada dessa mesma ideia. */
function renderizarDashboard(listaSensores) {
  gridSensores.innerHTML = "";

  /** DIDÁTICO: `.forEach()` percorre o array item por item, executando a função
   * de callback pra cada sensor — é o "laço de repetição" pedido no PDF, só que
   * na sintaxe moderna do JS (equivalente a um for tradicional, porém mais legível). */
  listaSensores.forEach((sensor) => {
    const critico = verificarCritico(sensor);

    const card = document.createElement("article");
    /** DIDÁTICO: Aqui aplicamos a "Regra de Negócio Visual" do PDF: se o sensor
     * está crítico, concatenamos a classe extra `.card-alerta` na string do
     * className. O CSS depois usa essa classe pra pintar o card de vermelho. */
    card.className = "card-sensor" + (critico ? " card-alerta" : "");

    const nomeIcone = iconesPorTipo[sensor.tipo] || "sensors";

    /** DIDÁTICO: Isso é uma "template literal" (crase `` ` `` em vez de aspas).
     * Ela permite escrever HTML de várias linhas e usar `${variavel}` para
     * injetar valores JS diretamente no meio do texto — é assim que o JS
     * "gera HTML dinamicamente" que o PDF pede. */
    card.innerHTML = `
      <div class="card-sensor__topo">
        <span class="material-symbols-outlined card-sensor__icone">${nomeIcone}</span>
        <span class="card-sensor__tipo">${sensor.tipo}</span>
      </div>
      <p class="card-sensor__nome">${sensor.nome}</p>
      <p class="card-sensor__valor">${sensor.valor.toFixed(1)} ${sensor.unidade}</p>
      <div class="card-sensor__rodape">
        <span class="card-sensor__estado">
          <span class="material-symbols-outlined">${critico ? "warning" : "check_circle"}</span>
          ${critico ? "Crítico" : "Normal"}
        </span>
        <button class="card-sensor__historico" type="button">Histórico</button>
      </div>
    `;

    const botaoHistorico = card.querySelector(".card-sensor__historico");
    botaoHistorico.addEventListener("click", () => abrirModalHistorico(sensor.id));

    gridSensores.appendChild(card);
  });
}

// ---------- Filtros em Memória ----------
/** DIDÁTICO: `addEventListener("change", callback)` registra um "escutador de
 * eventos": o navegador vai "ouvir" o select e, toda vez que o usuário escolher
 * uma opção diferente (evento `change`), a função dentro dos parênteses é
 * executada automaticamente. A gente nunca chama essa função diretamente —
 * quem chama é o próprio navegador, quando o evento acontece. */
filtroTipo.addEventListener("change", () => {
  const tipoSelecionado = filtroTipo.value;

  /** DIDÁTICO: `.filter()` é um método de array que NÃO modifica o array original
   * — ele retorna um array NOVO, contendo só os itens em que a função de teste
   * retornou `true`. Aqui, testamos se o `tipo` do sensor bate com o que foi
   * selecionado no dropdown. Se for "Todos", pulamos o filtro e usamos a lista
   * inteira (operador ternário: `condição ? seVerdadeiro : seFalso`). */
  const listaFiltrada =
    tipoSelecionado === "Todos"
      ? sensoresIniciais
      : sensoresIniciais.filter((sensor) => sensor.tipo === tipoSelecionado);

  renderizarDashboard(listaFiltrada);
});

// ---------- Simulação de Atualização (Tempo Real) ----------
/** DIDÁTICO: O objeto `Date` do JavaScript representa um instante no tempo.
 * `getHours()`, `getMinutes()` e `getSeconds()` retornam números "crus" (ex: 5,
 * não "05"). Por isso usamos `.padStart(2, "0")`: ele transforma a STRING do
 * número, garantindo que sempre tenha 2 dígitos (preenchendo com "0" à esquerda
 * se precisar) — é assim que exibimos "05" em vez de "5". */
function atualizarTimestamp() {
  const agora = new Date();
  const horas = String(agora.getHours()).padStart(2, "0");
  const minutos = String(agora.getMinutes()).padStart(2, "0");
  const segundos = String(agora.getSeconds()).padStart(2, "0");
  spanTimestamp.textContent = `${horas}:${minutos}:${segundos}`;
}

function gerarVariacaoAleatoria(maximo) {
  return (Math.random() - 0.5) * 2 * maximo;
}

function obterMaximoVariacao(sensor) {
  if (sensor.tipo === "Temperatura") return 1.2;
  if (sensor.tipo === "Umidade") return 2.0;
  if (sensor.tipo === "Pressão") return 0.35;
  return 1.0;
}

/** DIDÁTICO: Essa é a função que resolve o "Desafio do Código" do PDF: simular
 * sensores mudando de valor sozinhos, como se fossem leituras reais. */
function atualizarValoresSensores() {
  if (!estaOnline) return;

  sensoresIniciais.forEach((sensor) => {
    const maximoVariacao = obterMaximoVariacao(sensor);
    const variacao = gerarVariacaoAleatoria(maximoVariacao);
    let novoValor = Math.round((sensor.valor + variacao) * 10) / 10;

    /** DIDÁTICO: Validação física por tipo de sensor:
     * A Temperatura pode ser negativa (ex: Sensor Câmara Fria a -2.1°C), mas
     * a Pressão (e a Umidade) não podem ser menores que 0 bar/%.
     * `Math.max(0, novoValor)` impede que a pressão assuma valores negativos. */
    if (sensor.tipo === "Pressão" || sensor.tipo === "Umidade") {
      novoValor = Math.max(0, novoValor);
    }

    sensor.valor = novoValor;

    // Recalcula status crítico após a variação
    atualizarStatusSensor(sensor);
    registrarLeitura(sensor);
  });

  // Reaplica o filtro atualmente selecionado ao re-renderizar
  const tipoSelecionado = filtroTipo.value;
  const listaAtual =
    tipoSelecionado === "Todos"
      ? sensoresIniciais
      : sensoresIniciais.filter((sensor) => sensor.tipo === tipoSelecionado);

  renderizarDashboard(listaAtual);
  atualizarTimestamp();
}

// Clique manual no botão "Atualizar"
btnAtualizar.addEventListener("click", atualizarValoresSensores);

/** DIDÁTICO: `setInterval(funcao, tempoEmMs)` agenda uma função pra rodar
 * repetidamente, de tempos em tempos, sem que a gente precise chamá-la de novo
 * manualmente. O tempo é sempre em MILISSEGUNDOS, por isso 30000 = 30 segundos.
 * Isso cria um "timer" que fica rodando em segundo plano enquanto a página
 * estiver aberta (se quiséssemos parar, guardaríamos o retorno dessa função
 * numa variável e chamaríamos `clearInterval(essaVariavel)` depois). */
setInterval(atualizarValoresSensores, 30000);

// ---------- Inicialização ----------
/** DIDÁTICO: Essas duas chamadas rodam UMA VEZ, assim que o script carrega —
 * é o que garante que os cards já apareçam preenchidos e o relógio já mostre
 * a hora certa antes mesmo do primeiro clique ou do primeiro `setInterval`
 * disparar (que só aconteceria depois de 30s se não chamássemos aqui). */
registrarLeiturasIniciais();
atualizarStatusConexao();
renderizarDashboard(sensoresIniciais);
atualizarTimestamp();