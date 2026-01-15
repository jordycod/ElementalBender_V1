
// IMPORTS - Bibliotecas externas e utilitários usados no sketch:

import processing.sound.*;  // áudio/música
import java.util.ArrayList;  // listas dinâmicas
import SimpleOpenNI.*;  // Kinect SimpleOpenNI

// CONSTANTES E ESTADOS - Definições constantes usadas em todo o sketch
final int BTN_COUNT = 3;

final int ESTADO_MENU = 0;
final int ESTADO_AGUA = 1;
final int ESTADO_FINAL = 2;
final int ESTADO_NICK = 3;
final int ESTADO_RANK = 4;
final int ESTADO_FOGO = 5;
final int ESTADO_INTRO = 6;
final int ESTADO_TUTORIAL_SLIDES = 7;

// VARIÁVEIS GLOBAIS (AGRUPADAS POR TEMA)
// KINECT / ÁUDIO - Objetos responsáveis por captura do Kinect e reprodução de som.
SimpleOpenNI kinect;  // objeto de interação com Kinect
SoundFile musica, target;  // música de fundo e som de "target"
SoundFile musicaAgua, musicaFogo;  // música padrão do modo água e fogo
SoundFile cursorSound, detectUser, lostUser; // Alertas de feedback

// Microfone / análise de amplitude
AudioIn mic;  // captura do microfone
Amplitude ampAnalyzer; // analisador de amplitude do processing.sound
float micAmpSmoothed = 0; // valor suavizado da amplitude (para evitar jitter)
float micAmpSmoothing = 0.10; // fator de suavização (0..1) — maior = mais suave

// Modo de fogo - Dois engines independentes para suportar até 2 utilizadores.
Fire fireEffect1 = null;
Fire fireEffect2 = null;
ParticleMotion pm = null; // sistema de partículas guiado por movimento de juntas

// IMAGENS / SILHUETA - Armazenamento de imagens e propriedades visuais da silhueta.
PImage imagemFundo, telaInicial, telaFinal, telaRanking, telaFogo; // telas principais do sketch
PImage imgPainelJogo;
PImage imgTutorial = null;  // imagem do tutorial (opcional)
PImage iconeAjuda = null;  // ícone de ajuda (opcional)
PImage imgAlvo;  // imagem do alvo (bolha)
PFont bagel, lastShuriken, hoshiko;

int[] mapaUsuario;  // mapa de usuário do Kinect (userMap)
color silhuetaCorNormal = color(60); // cor padrão da silhueta (com alpha)
color silhuetaPowerUp = color(250); // cor quando power-up ativo
float filtroVermelhoInt = 0.0;  // intensidade do overlay vermelho (feedback visual)

// Agua (massa de água) / TRILHA (SINGLE) - Variáveis e parâmetros da Agua (modelo físico simplificado) e rastro.
PVector posicaoAgua, velocidadeAgua, aceleracaoAgua; // estado da Agua única
ArrayList<PVector> caminhoMedio = new ArrayList<>(); // histórico usado para desenhar rastro
int tamanhoCaminhoAgua = 20; // número máximo de pontos no rastro
float fatorAtracao = 0.020;  // força que puxa a Agua para o ponto de controlo
float amortecimento = 0.95; // amortecimento aplicado à velocidade

// POWER-UP: Agua dupla - Quando ativo, usa duas massas (posLeft/posRight) controladas por cada mão.
boolean powerUpActive = false;
int powerUpStart = -1;
int powerUpTempo = 15000; // duracao em ms
float espAguaDupla = 1.0; // espessura das trilhas quando power-up ativo

// Para as duas massas controladas por cada mão
PVector posLeft, velLeft, accLeft;
PVector posRight, velRight, accRight;
ArrayList<PVector> caminhoLeft = new ArrayList<PVector>();
ArrayList<PVector> caminhoRight = new ArrayList<PVector>();

// ALVOS / PONTUAÇÃO / SPAWN - Estruturas para gerenciar bolhas-alvo, pontuação e spawn timing.
ArrayList<Target> alvos; // lista de alvos ativos
int pontuacao = 0;
int maxAlvos = 10;
int intervaloSpawn = 1500; // intervalo entre spawns (ms)
int proximoSpawn;
float targetSpeedMultiplier = 1.0; // multiplicador global das velocidades dos alvos

float surpriseSpawnProbability = 0.05; // probabilidade por spawn de um target surpresa
PImage imgSurpriseTarget = null;  // imagem opcional para target surpresa (carregar em setup)
boolean debugDrawSurpriseAsCircle = true; // se true desenha círculo preto em vez da imagem

// CURSOR (mão direita) - Coordenadas do cursor controlado pela mão direita (em pixels projetados).
float cursorX = 0, cursorY = 0; // posição projetada da mão direita (pixels)

// TIMER / JOGO - Estado do jogo, temporizadores e parâmetros para exibição de barra de tempo.
int estadoJogo = ESTADO_INTRO; // inicia no ESTADO_INTRO (nova dinâmica)
int tempoInicial; // timestamp de início da partida (millis)
int timer = 45000;  // duração da partida em ms
int timerInitialDuration = 0; // guarda duração inicial quando o jogo começa (ms)
int barraTempoAltura = 20; // altura da barra do timer (pixels)
float timerBarPixelsPerSecond = 3.0; // fator para converter segundos em pixels

// RANKING - Estruturas para salvar/carregar ranking localmente.
ArrayList<RegistroRank> ranking = new ArrayList<RegistroRank>();
String rankingFile = "ranking/ranking.txt"; // arquivo local para salvar ranking

// INTERFACE / BOTÕES / TECLADO (AGRUPAMENTO DE VARIÁVEIS)
String[] btnLabels = { "ÁGUA", "FOGO", "RANKING"};
int btnHovered = -1;  // índice do botão em hover
int btnActive = -1;  // índice do botão ativo (aguardando seleção)
float btnHoverStart = -1; // timestamp de início do hover
float hoverTime = 2500;  // ms necessários de hover para seleção automática
color btnColor = color(0, 125, 150); // cor base dos botões
color btnColorHover = color(240, 125, 25); // cor quando em hover
color btnText = color(255); // cor do texto do botão
float[][] btnRects = new float[BTN_COUNT][4]; // bounding boxes (x,y,w,h) para cada botão

float botaoAjudaX, botaoAjudaY, botaoAjudaTam = 54; // posição/tamanho do botão de ajuda
boolean mostrandoTutorial = false; // flag para exibir tutorial quando hover no botão

// NOVO: controle de hover do botão de ajuda (para acionar slides via hover+tempo)
float helpHoverStart = -1;

// Botão som - Parâmetros de posição e lógica de alternância com hover por tempo.
boolean somAtivo = true;
PImage iconeSomLigado = null, iconeSomDesligado = null; // ícones opcionais
float botaoSomX, botaoSomY, botaoSomTam = 54;
int btnSomHovered = 0;
float somHoverStart = -1;
float hoverTimeSom = 2000;  // tempo de hover para alternar som (ms)

// Tela final / nickname - Labels e áreas de clique para a tela final (salvar pontuação, reiniciar...)
String[] finalLabels = { "TELA INICIAL", "REINICIAR", "SALVAR" };
float[][] finalRects = new float[3][4];
int finalBtnHovered = -1, finalBtnActive = -1;
float finalBtnHoverStart = -1;

// Teclado virtual / Nickname - Layout do teclado virtual e lógica de seleção por hover/tempo.
String textoDigitado = "";
final int NICK_MAX = 5;
boolean pontuacaoSalva = false;

char[][] layoutTeclado = {
 {'1', '2', '3', '4', '5', '6', '7', '8', '9', '0'},
 {'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P'},
 {'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ';'},
 {'Z', 'X', 'C', 'V', 'B', 'N', 'M', ',', '.', '/'}
};
int larguraTeclas = 50, alturaTeclas = 50;
float tempoInicioHover = -1;
char teclaHoverAtual = ' ';
int tempoParaSelecao = 2000; // ms necessários de hover para entrada de tecla
int tecladoHoverLinha = -1, tecladoHoverCol = -1;

// Botões do teclado ("Gravar", "Voltar")
String[] nickLabels = { "GRAVAR", "VOLTAR" };
float[][] nickRects = new float[2][4];
int nickBtnHovered = -1, nickBtnActive = -1;
float nickBtnHoverStart = -1;

// ----------------------
// NOVAS VARIÁVEIS DE IMAGENS PARA BOTÕES / SLIDES (global)
// ----------------------
// Menu buttons (normal/hover)
PImage[] btnImgNormal = new PImage[BTN_COUNT];
PImage[] btnImgHover = new PImage[BTN_COUNT];
float btnImageScale = 1.0;

// Help & Sound button image scales / optional hover variants
float helpBtnImageScale = 1.0;
float soundBtnImageScale = 1.0;

// Final screen buttons (TELA INICIAL, REINICIAR, SALVAR)
PImage[] finalBtnImgNormal = new PImage[3];
PImage[] finalBtnImgHover = new PImage[3];
float finalBtnImageScale = 1.0;

// Ranking "VOLTAR" button images
PImage imgVoltarNormal = null;
PImage imgVoltarHover = null;
float voltarBtnImageScale = 1.0;

// Nick keyboard buttons images (GRAVAR / VOLTAR small)
PImage[] nickBtnImgNormal;
PImage[] nickBtnImgHover;

// ----------------------
// INTRO + TUTORIAL SLIDES
// ----------------------
PImage introLogo = null; // logo mostrado na tela branca inicial
PImage[] tutorialSlides = null; // carregar slides dinamicamente (3 slides por padrão)
int tutorialIndex = 0;  // slide atual

// imagens do botão lateral (avançar / finalizar)
PImage slideNextNormal = null;
PImage slideNextHover = null;
PImage slideDoneNormal = null;
PImage slideDoneHover = null;

// hover control para o botão de slide
int slideBtnHovered = -1;
int slideBtnActive = -1;
float slideBtnHoverStart = -1;
float slideBtnW = 75;
float slideBtnH = 75;
float slideBtnMarginRight = 15;
