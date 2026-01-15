// Classe Target
// Alvo do jogo

class Target {
 float x, y; // posição
 float raio; // tamanho visual
 float velocidadeY;  // velocidade vertical (cai para baixo)
 boolean hit = false; // se já foi atingido
 float raioColisao = 25; // raio sensível a colisões

 // Nova flag indicando se é um target surpresa (efeito: zera tempo e finaliza partida)
 boolean surprise = false;

 // Construtor original (por omissão, não surpresa)
 Target(float newX, float newY, float r) {
  this(newX, newY, r, false);
 }

 // Construtor com possibilidade de target surpresa
 Target(float newX, float newY, float r, boolean isSurprise) {
  x = newX;
  y = newY;
  raio = r;
  surprise = isSurprise;
  // aplica multiplicador global ao spawn (para escalar dificuldade)
  velocidadeY = random(0.5, 1.5) * targetSpeedMultiplier;
  // ajusta raio de colisão caso seja surpresa (opcional)
  if (surprise) raioColisao = max(raioColisao, raio * 0.9);
 }

 void desenhar() {
  if (hit) return; // não desenha se já foi atingido

  // sombra simples (mantém estética)
  noStroke();
  noFill();
  ellipse(x + 3, y + 3, raio * 2, raio * 2);



  if (surprise) {
 // desenha a imagem do alvo surpresa
 if (imgSurpriseTarget != null) image(imgSurpriseTarget, x, y, raio * 2, raio * 2);
  } else {
 // desenha a imagem do alvo padrão
 image(imgAlvo, x, y, raio * 2, raio * 2);
  }
 }

 void mover() {
  y += velocidadeY;
  if (y > height + raio) { // saiu da tela inferior
 if (!surprise) {
  // penalidade por deixar passar: reduz 1s do timer (sem negativo)
  timer -= 1000;
  if (timer < 0) timer = 0;
  // aumenta overlay vermelho como feedback visual
  filtroVermelhoInt = constrain(filtroVermelhoInt + 0.01, 0, 1);

  // reposiciona no topo com nova posição e velocidade
  y = -raio;
  x = random(raio, width - raio);
  velocidadeY = random(0.5, 1.5) * targetSpeedMultiplier;
 }
  }
 }

 boolean verificaHit(float px_, float py_) {
  if (hit) return false;
  if (dist(px_, py_, x, y) < raioColisao) {
 hit = true;
 return true;
  }
  return false;
 }
}

// Desenhar alvos

void spawnTarget() {
 float raio = random(20, 35);
 float x = random(raio, width - raio);
 float y = -raio;

 // decide aleatoriamente se este spawn será um target surpresa
 boolean isSurprise = random(1) < surpriseSpawnProbability;

 if (isSurprise) {
  // Cria um target surpresa (usa construtor com flag)
  alvos.add(new Target(x, y, raio, true));
 } else {
  // Cria target comum
  alvos.add(new Target(x, y, raio, false));
 }
}
