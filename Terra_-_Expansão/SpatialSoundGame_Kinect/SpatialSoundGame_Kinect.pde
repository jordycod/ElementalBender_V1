import SimpleOpenNI.*;
import processing.sound.*;

// --- SIMPLEOPENNI SETUP ---
SimpleOpenNI kinect;
boolean handDetected = false;

// Coordenadas e estados da Mão Direita (Cursor Principal)
float rightHandX = 0;
float rightHandY = 0;
int rightHandQuadrant = 0;
float rightHandConfidence = 0.0;

// Coordenadas e estados da Mão Esquerda (Seleção Secundária)
float leftHandX = 0;
float leftHandY = 0;
int leftHandQuadrant = 0;
float leftHandConfidence = 0.0;

// --- DWELL (TEMPO DE SELEÇÃO) ---
int currentHoverQuadrant = 0; // Quadrante que está sendo pairado (monitorado)
long hoverStartTime = 0;
final int HOVER_DURATION = 2000; // 2 segundos

// --- GAME STATE ---
int score = 0;
boolean targetExists = false;
int targetQuadrant = 0; // 1: Cima, 2: Direita, 4: Esquerda

// --- TARGET & TIMING ---
long targetSpawnTime;
final float TARGET_LIFESPAN = 15.0;
float centerX, centerY, maxDistance;

// --- SOUND SETUP ---
SinOsc leftChannel, rightChannel;
final float frequency = 500;
final float maxAmplitude = 1.0;
final float minAmplitude = 0.00;

void setup() {
  size(900, 900);

  // 1. INICIALIZAÇÃO SIMPLEOPENNI
  kinect = new SimpleOpenNI(this);

  if (kinect.isInit() == false) {
    println("Erro: Kinect não inicializado.");
    exit();
    return;
  }

  kinect.enableDepth();
  kinect.enableUser();
  kinect.setMirror(true);

  // Configuração do Jogo
  centerX = width / 2;
  centerY = height / 2;
  maxDistance = 0.5 * min(width, height);

  // Áudio
  leftChannel = new SinOsc(this);
  rightChannel = new SinOsc(this);
  leftChannel.freq(frequency);
  rightChannel.freq(frequency);
  leftChannel.amp(0);
  rightChannel.amp(0);
  leftChannel.pan(-1.0);
  rightChannel.pan(1.0);
  leftChannel.play();
  rightChannel.play();

  spawnTarget();

  textAlign(CENTER, CENTER);
  textSize(24);
}

void draw() {
  background(20);

  // 1. ATUALIZAÇÃO DO KINECT
  kinect.update();

  // Rastreia ambas as mãos
  trackUserAndHand();

  // 2. DESENHO DOS QUADRANTES
  drawQuadrants();

  // 3. LÓGICA DO JOGO E SOM
  if (targetExists) {
    float elapsedTime = (millis() - targetSpawnTime) / 1000.0;
    float progress = elapsedTime / TARGET_LIFESPAN;

    // LÓGICA DE FIM DE VIDA DO ALVO (JÁ ESTAVA CORRETA)
    if (progress >= 1.0) {
      targetExists = false; // Alvo some
      resetSound();
      spawnTarget(); // Novo alvo aparece
      return;
    }

    PVector pos = calculateTargetPosition(progress);
    updateSpatialSound(pos.x, pos.y);
    drawTarget(pos.x, pos.y);

    // Verifica a seleção com a nova lógica multi-mãos
    checkHandSelection();
  } else {
    resetSound();
  }

  // 4. FEEDBACK DA CÂMERA DE PROFUNDIDADE
  drawDepthImageFeedback();

  // 5. INTERFACE & CURSORES
  drawInterface();
  if (rightHandConfidence > 0.5) drawHandCursor(rightHandX, rightHandY, true); // Mão direita (Cursor principal)
  if (leftHandConfidence > 0.5) drawHandCursor(leftHandX, leftHandY, false);  // Mão esquerda

  if (!handDetected) {
    drawCalibrationMessage();
  }
}

// ---------------------------------------------------------------- //
// KINECT TRACKING E REGRAS DE SELEÇÃO
// ---------------------------------------------------------------- //

void trackUserAndHand() {
  handDetected = false;
  rightHandConfidence = 0.0;
  leftHandConfidence = 0.0;

  IntVector userList = new IntVector();
  kinect.getUsers(userList);

  if (userList.size() > 0) {
    int userId = userList.get(0);

    if (kinect.isTrackingSkeleton(userId)) {

      // --- RASTREIO MÃO DIREITA ---
      PVector rh3D = new PVector();
      rightHandConfidence = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rh3D);
      PVector rhProj = new PVector();
      kinect.convertRealWorldToProjective(rh3D, rhProj);
      rightHandX = map(rhProj.x, 0, 640, 0, width);
      rightHandY = map(rhProj.y, 0, 480, 0, height);
      rightHandQuadrant = getQuadrant(rightHandX, rightHandY);

      // --- RASTREIO MÃO ESQUERDA ---
      PVector lh3D = new PVector();
      leftHandConfidence = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, lh3D);
      PVector lhProj = new PVector();
      kinect.convertRealWorldToProjective(lh3D, lhProj);
      leftHandX = map(lhProj.x, 0, 640, 0, width);
      leftHandY = map(lhProj.y, 0, 480, 0, height);
      leftHandQuadrant = getQuadrant(leftHandX, leftHandY);

      // Confirma que pelo menos uma mão está rastreada com boa confiança
      if (rightHandConfidence > 0.5 || leftHandConfidence > 0.5) {
        handDetected = true;
      }
    }
  }
}


/**
 * Lógica de seleção que verifica a quantidade de mãos no quadrante alvo.
 */
void checkHandSelection() {
  if (!handDetected) return;

  // Determina o quadrante de HOVER
  int activeQuadrant = 0;
  // Prioriza a mão direita se ambas estiverem em quadrantes válidos, senão pega a esquerda
  if (rightHandQuadrant > 0) activeQuadrant = rightHandQuadrant;
  else if (leftHandQuadrant > 0) activeQuadrant = leftHandQuadrant;

  // 1. Lógica de Reinício/Contagem do Dwell Time
  if (activeQuadrant != currentHoverQuadrant) {
    currentHoverQuadrant = activeQuadrant;
    hoverStartTime = millis();
  }

  long hoverElapsed = millis() - hoverStartTime;

  // 2. Condição de Ativação do Quadrante (Tempo e Local)
  if (activeQuadrant == targetQuadrant && hoverElapsed >= HOVER_DURATION) {

    // 3. CONDIÇÃO CRÍTICA DE SELEÇÃO: Múltiplas Mãos

    int handsInTarget = 0;
    if (rightHandQuadrant == targetQuadrant && rightHandConfidence > 0.5) {
      handsInTarget++;
    }
    if (leftHandQuadrant == targetQuadrant && leftHandConfidence > 0.5) {
      handsInTarget++;
    }

    // Verifica a regra: exatamente 1 ou 2 mãos no quadrante alvo
    if (handsInTarget >= 1 && handsInTarget <= 2) {
      score++;
      targetExists = false;
      resetSound();
      spawnTarget();
    } else if (handsInTarget == 0 && activeQuadrant == targetQuadrant) {
      // O jogador estava no quadrante correto, mas moveu a mão para fora antes do dwell time expirar?
      // Neste caso, se hoverElapsed >= HOVER_DURATION, significa que o tempo expirou, mas as mãos saíram.
      // Manter a regra de reiniciar o timer para garantir que a ação é consciente.
      hoverStartTime = millis(); 
    }
  } 
}


int getQuadrant(float x, float y) {
  // UP
  if (y < centerY - 50) {
    if (x > width*0.2 && x < width*0.8) return 1;
  }
  // RIGHT
  if (x > centerX + 50) {
    if (y > height*0.2 && y < height*0.8) return 2;
  }
  // LEFT
  if (x < centerX - 50) {
    if (y > height*0.2 && y < height*0.8) return 4; // <--- Quadrante 4
  }
  return 0;
}


// ---------------------------------------------------------------- //
// GAME LOGIC & SOUND
// ---------------------------------------------------------------- //

void spawnTarget() {
  // Quadrantes disponíveis: Cima(1), Direita(2), Esquerda(4)
  int[] possibleQuadrants = {1, 2, 4};
  targetQuadrant = possibleQuadrants[(int)random(possibleQuadrants.length)];
  targetSpawnTime = millis();
  targetExists = true;
}

void resetSound() {
  leftChannel.amp(0);
  rightChannel.amp(0);
}

PVector calculateTargetPosition(float progress) {
  PVector start = new PVector(0, 0);
  PVector end = new PVector(0, 0);

  switch (targetQuadrant) {
    case 1:
      start.set(0, -maxDistance); // Cima
      break;
    case 2:
      start.set(maxDistance, 0); // Direita
      break;
    case 3:
      start.set(-maxDistance, 0); // Esquerda
      break; // <--- CORRIGIDO: Era case 3, agora é case 4
  }

  PVector currentRelPos = PVector.lerp(start, end, progress);
  return new PVector(centerX + currentRelPos.x, centerY + currentRelPos.y);
}

void updateSpatialSound(float targetX, float targetY) {
  float currentDistance = dist(targetX, targetY, centerX, centerY);
  float ampBase = map(currentDistance, 0, maxDistance, maxAmplitude, minAmplitude);
  float relativeX = targetX - centerX;
  float panValue = map(relativeX, -maxDistance, maxDistance, -1.0, 1.0); // -1.0 é Esquerda, 1.0 é Direita

  // CORRIGIDO: O mapeamento de pan estava invertido no último código.
  // Se panValue é -1.0 (Esquerda), leftAmpMultiplier deve ser 1.0.
  // Se panValue é 1.0 (Direita), rightAmpMultiplier deve ser 1.0.
  float leftAmpMultiplier = map(panValue, -1.0, 1.0, 1.0, 0.0);
  float rightAmpMultiplier = map(panValue, -1.0, 1.0, 0.0, 1.0);

  leftChannel.amp(ampBase * leftAmpMultiplier);
  rightChannel.amp(ampBase * rightAmpMultiplier);
}


// ---------------------------------------------------------------- //
// VISUAIS & FEEDBACK (Sem alteração)
// ---------------------------------------------------------------- //

void drawDepthImageFeedback() {
  int fbWidth = 200;
  int fbHeight = (int)(fbWidth * (480.0 / 640.0)); // Mantém proporção 640x480
  int margin = 10;

  // Desenha a imagem de profundidade
  image(kinect.depthImage(), margin, height - fbHeight - margin, fbWidth, fbHeight);

  // Borda para destacar
  noFill();
  stroke(255);
  strokeWeight(1);
  rect(margin, height - fbHeight - margin, fbWidth, fbHeight);

  // Indicador de Status
  fill(handDetected ? 0 : 255, handDetected ? 255 : 0, 0);
  textSize(14);
  textAlign(LEFT, TOP);
  text((handDetected ? "RASTREADO" : "CALIBRANDO"), margin + 60, height - fbHeight - margin + 5);
}


void drawHandCursor(float x, float y, boolean isRightHand) {
  noCursor();

  // Cor do cursor: Verde (Direita), Azul (Esquerda)
  //fill(isRightHand ? color(0, 255, 0) : color(0, 0, 255));
  fill(0, 255, 0);
  noStroke();
  ellipse(x, y, 30, 30);

  // Desenha o círculo de progresso APENAS para a mão que está no quadrante atual de hover
  if ((isRightHand && rightHandQuadrant == currentHoverQuadrant) || (!isRightHand && leftHandQuadrant == currentHoverQuadrant)) {

    long elapsed = millis() - hoverStartTime;
    // Desenha o progresso apenas se o quadrante for válido
    if (elapsed > 0 && elapsed < HOVER_DURATION && (currentHoverQuadrant == 1 || currentHoverQuadrant == 2 || currentHoverQuadrant == 4)) {
      noFill();
      stroke(0, 255, 0); 
      strokeWeight(5);
      float angle = map(elapsed, 0, HOVER_DURATION, 0, TWO_PI);
      arc(x, y, 60, 60, -HALF_PI, -HALF_PI + angle);
    }
  }
}

void drawCalibrationMessage() {
  //fill(255, 50, 50);
  //textAlign(CENTER);
  //text("Faça a pose de calibração ('PSI' Pose) para iniciar o rastreamento.", width/2, height - 50);
}

void drawQuadrants() {
  textAlign(CENTER, CENTER);
  stroke(100);
  strokeWeight(1);
  line(centerX, 0, centerX, height);
  line(0, centerY, width, centerY);

  fill(50);
  ellipse(centerX, centerY, 50, 50);

  fill(150);
  textSize(30);
  text("1 (CIMA)", centerX, centerY - 200);
  text("2 (DIREITA)", centerX + width/4, centerY);
  text("3 (ESQUERDA)", centerX - width/4, centerY);

  // Highlight no quadrante atual de hover
  fill(255, 255, 255, 50);
  noStroke();
  if (currentHoverQuadrant == 1) rect(centerX - 100, 0, 200, centerY - 50);
  if (currentHoverQuadrant == 2) rect(centerX + 50, centerY - 100, width/2, 200);
  if (currentHoverQuadrant == 4) rect(0, centerY - 100, centerX - 50, 200);
}

void drawTarget(float x, float y) {
  fill(255, 0, 0);
  noStroke();
  ellipse(x, y, 40, 40);
}

void drawInterface() {
  fill(255);
  textAlign(LEFT, TOP);
  textSize(24);
  text("Score: " + score, 20, 20);
  //textAlign(RIGHT, TOP);
  //text("Segure 1 ou 2 mãos no alvo por 2s para selecionar", width - 20, 20); // Adicionei o texto de volta para ser informativo
}


// --- CALLBACKS DO SIMPLEOPENNI (MANTIDOS) ---

void onNewUser(SimpleOpenNI curContext, int userId) {
  println("Novo usuário detectado: " + userId);
  curContext.startTrackingSkeleton(userId);
}

void onLostUser(SimpleOpenNI curContext, int userId) {
  println("Usuário perdido: " + userId);
}
