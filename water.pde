// MODO ÁGUA

// Desenha trilhas: suporta Agua única ou duas massas quando power-up ativo.
// A espessura das linhas é reduzida por espAguaDupla quando power-up ativo.
void desenharCaminhoMedio() {
 if (powerUpActive) {
  // desenha trilha esquerda
  if (caminhoLeft.size() >= 2) {
 noFill();
 for (int i = 0; i < caminhoLeft.size() - 1; i++) {
  float t = map(i, 0, caminhoLeft.size() - 2, 0, 1);
  float esp = (1 + 9 * sin(PI * t)) * espAguaDupla;
  stroke(255, 255, 255, 20);
  strokeWeight(esp * 6);
  line(caminhoLeft.get(i).x, caminhoLeft.get(i).y, caminhoLeft.get(i+1).x, caminhoLeft.get(i+1).y);
  stroke(75, 190, 210);
  strokeWeight(esp * 5);
  line(caminhoLeft.get(i).x, caminhoLeft.get(i).y, caminhoLeft.get(i+1).x, caminhoLeft.get(i+1).y);
 }
  }
  // desenha trilha direita
  if (caminhoRight.size() >= 2) {
 noFill();
 for (int i = 0; i < caminhoRight.size() - 1; i++) {
  float t = map(i, 0, caminhoRight.size() - 2, 0, 1);
  float esp = (1 + 9 * sin(PI * t)) * espAguaDupla;
  stroke(255, 255, 255, 20);
  strokeWeight(esp * 6);
  line(caminhoRight.get(i).x, caminhoRight.get(i).y, caminhoRight.get(i+1).x, caminhoRight.get(i+1).y);
  stroke(75, 190, 210);
  strokeWeight(esp * 5);
  line(caminhoRight.get(i).x, caminhoRight.get(i).y, caminhoRight.get(i+1).x, caminhoRight.get(i+1).y);
 }
  }
 } else {
  // trilha única (com espessura normal)
  if (caminhoMedio.size() < 2) return;
  noFill();
  for (int i = 0; i < caminhoMedio.size() - 1; i++) {
 float t = map(i, 0, caminhoMedio.size() - 2, 0, 1);
 float espessura = 1 + 12 * sin(PI * t);
 stroke(255, 255, 255, 20);
 strokeWeight(espessura * 6);
 line(caminhoMedio.get(i).x, caminhoMedio.get(i).y, caminhoMedio.get(i + 1).x, caminhoMedio.get(i + 1).y);
 stroke(75, 190, 210);
 strokeWeight(espessura * 5);
 line(caminhoMedio.get(i).x, caminhoMedio.get(i).y, caminhoMedio.get(i + 1).x, caminhoMedio.get(i + 1).y);
  }
 }
}

void atualizarAgua() {
 velocidadeAgua.add(aceleracaoAgua);
 velocidadeAgua.mult(amortecimento);
 posicaoAgua.add(velocidadeAgua);
}

void activatePowerUp() {
 // ativa ou reinicia o power-up
 powerUpActive = true;
 powerUpStart = millis();
 espAguaDupla = 0.65; // 35% mais fina

 // inicializa posições das massas com base na Agua atual (ou centro)
 if (kinect.getNumberOfUsers() > 0 && kinect.isTrackingSkeleton(kinect.getUsers()[0])) {
  PVector r = new PVector(), l = new PVector();
  // tenta pegar posições reais das mãos
  kinect.getJointPositionSkeleton(kinect.getUsers()[0], SimpleOpenNI.SKEL_RIGHT_HAND, r);
  kinect.getJointPositionSkeleton(kinect.getUsers()[0], SimpleOpenNI.SKEL_LEFT_HAND, l);
  PVector rProj = new PVector(), lProj = new PVector();
  kinect.convertRealWorldToProjective(r, rProj);
  kinect.convertRealWorldToProjective(l, lProj);
  posLeft.set(lProj.x, lProj.y);
  posRight.set(rProj.x, rProj.y);
 } else {
  // fallback: divide a posição central
  posLeft.set(posicaoAgua.x - 20, posicaoAgua.y);
  posRight.set(posicaoAgua.x + 20, posicaoAgua.y);
 }
 // reset velocidades e trilhas
 velLeft.set(0, 0);
 velRight.set(0, 0);
 accLeft.set(0, 0);
 accRight.set(0, 0);
 caminhoLeft.clear();
 caminhoRight.clear();
}

void deactivatePowerUp() {
 powerUpActive = false;
 powerUpStart = -1;
 espAguaDupla = 1.0;
 // opcional: consolidar posição central a partir da média das massas
 posicaoAgua.set((posLeft.x + posRight.x) / 2.0, (posLeft.y + posRight.y) / 2.0);
 velocidadeAgua.set((velLeft.x + velRight.x) / 2.0, (velLeft.y + velRight.y) / 2.0);
 caminhoMedio.clear();
}

// Reseta parâmetros do jogo (usado ao iniciar/reiniciar partidas)
void resetGameParameters() {
 intervaloSpawn = 1500;
 timer = 45000;
 targetSpeedMultiplier = 1.0;
 filtroVermelhoInt = 0.0;
 powerUpActive = false;
 powerUpStart = -1;
 espAguaDupla = 1.0;
 caminhoMedio.clear();
 caminhoLeft.clear();
 caminhoRight.clear();
}
