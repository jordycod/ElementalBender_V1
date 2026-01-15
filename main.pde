void setup() {
  size(640, 480);
  noCursor(); // oculta cursor do mouse (usa cursor customizado)

  kinectStart(); // Inicia o kinect
  resourcesManager(); // Carrega assets do jogo
  carregarRanking(); // Carrega ranking a partir de ficheiro local
  
  musica.play(); // inicia música de fundo
  // inicializa entrada de microfone e analisador de amplitude
  mic = new AudioIn(this, 0); // dispositivo de captura padrão (canal 0)
  mic.start(); // começa a capturar
  ampAnalyzer = new Amplitude(this);
  ampAnalyzer.input(mic); // conecta o analisador ao microfone
  micAmpSmoothed = 0;

  // Ajuste global de escala de botões (se precisar)
  btnImageScale = 1.5;
  helpBtnImageScale = 1.5;
  soundBtnImageScale = 1.5;
  finalBtnImageScale = 1.0;
  voltarBtnImageScale = 1.0;

  // Inicializa variáveis da Agua / física do cursor
  posicaoAgua = new PVector(width/2, height/2);
  velocidadeAgua = new PVector(0, 0);
  aceleracaoAgua = new PVector(0, 0);

  // Inicializa massas duplas (posições/velocidades/ações)
  posLeft = new PVector(width/2 - 20, height/2);
  velLeft = new PVector(0, 0);
  accLeft = new PVector(0, 0);
  posRight = new PVector(width/2 + 20, height/2);
  velRight = new PVector(0, 0);
  accRight = new PVector(0, 0);

  // Inicializa motores de fogo (um por possível usuário)
  fireEffect1 = new Fire(2, width, height, 1);
  fireEffect2 = new Fire(2, width, height, 1);

  // Inicializa sistema de partículas guiado por juntas (N-grid, np partículas)
  pm = new ParticleMotion(16, 2000, width, height);

  // Inicializa lista de alvos e agenda o primeiro spawn
  alvos = new ArrayList<Target>();
  proximoSpawn = millis() + intervaloSpawn;

  // garante que começamos no ESTADO_INTRO
  estadoJogo = ESTADO_INTRO;
  tutorialIndex = 0;
}

// ========================================================================================================================================

void draw() {
  // Atualiza leituras do Kinect (obrigatório a cada frame)
  kinect.update();

  // Rastreio do esqueleto e atualização do cursor
  int[] users = kinect.getUsers();  // obtém IDs dos usuários detectados
  boolean rastreando = false;  // flag se o esqueleto principal está a ser rastreado
  PVector maoDireita = new PVector();
  PVector maoEsquerda = new PVector();
  PVector pontoMedioTela = new PVector();

  // Se o primeiro usuário (prioritário) estiver rastreado, atualiza juntas base
  if (users.length > 0 && kinect.isTrackingSkeleton(users[0])) {
    rastreando = true;
    // obtem posição real (3D) de juntas
    kinect.getJointPositionSkeleton(users[0], SimpleOpenNI.SKEL_RIGHT_HAND, maoDireita);
    kinect.getJointPositionSkeleton(users[0], SimpleOpenNI.SKEL_LEFT_HAND, maoEsquerda);

    // Atualiza cursor (mão direita projetada) se leitura válida
    if (!Float.isNaN(maoDireita.x)) {
      PVector cursorPos = new PVector();
      kinect.convertRealWorldToProjective(maoDireita, cursorPos);
      cursorX = cursorPos.x;
      cursorY = cursorPos.y;
    }

    // Se power-up ativo: usa posições reais projetadas das mãos para controlar duas massas
    if (powerUpActive) {
      PVector handR = new PVector(), handL = new PVector();
      kinect.convertRealWorldToProjective(maoDireita, handR);
      kinect.convertRealWorldToProjective(maoEsquerda, handL);

      // Calcula acelerações direcionais para cada massa (esquerda/direita)
      accLeft.set(handL.x - posLeft.x, handL.y - posLeft.y);
      accLeft.mult(fatorAtracao*2);
      accRight.set(handR.x - posRight.x, handR.y - posRight.y);
      accRight.mult(fatorAtracao*2);
    } else {
      // comportamento normal: calcula ponto médio entre as mãos e aplica força de atração à Agua
      PVector pontoMedio3D = new PVector(
        (maoDireita.x + maoEsquerda.x) / 2,
        (maoDireita.y + maoEsquerda.y) / 2,
        (maoDireita.z + maoEsquerda.z) / 2
        );
      kinect.convertRealWorldToProjective(pontoMedio3D, pontoMedioTela);
      aceleracaoAgua.set(pontoMedioTela.x - posicaoAgua.x, pontoMedioTela.y - posicaoAgua.y);
      aceleracaoAgua.mult(fatorAtracao);
    }
  } else {
    // Se não há rastreio válido: reset dos estados
    posicaoAgua.set(width/2, height/2);
    caminhoMedio.clear();
    posLeft.set(width/2 - 20, height/2);
    velLeft.set(0, 0);
    accLeft.set(0, 0);
    posRight.set(width/2 + 20, height/2);
    velRight.set(0, 0);
    accRight.set(0, 0);
    caminhoLeft.clear();
    caminhoRight.clear();
  }

  // Verifica expiração do power-up (se ativo)
  if (powerUpActive && millis() - powerUpStart >= powerUpTempo) {
    deactivatePowerUp();
  }

  // Intro
  if (estadoJogo == ESTADO_INTRO) {
    background(255); // tela branca

    // desenha logo (se presente) na posição fixa (500x165)
    if (introLogo != null) {
      imageMode(CENTER);
      image(introLogo, width/2, 150, 500, 155);
      imageMode(CORNER);
    }

    // instrução de posicionamento
    textFont(lastShuriken);
    fill(10);
    textSize(25);
    textAlign(CENTER, CENTER);
    text("FIQUE DIANTE DO KINECT", width/2, height/2 + 50);

    // Se utilizador detectado e rastreado, desenha silhueta e cursor e avança para tutorial
    if (users.length > 0 && kinect.isTrackingSkeleton(users[0])) {
      // desenha cursor custom (mão direita)
      drawCustomCursor();
      cursorSound.play();
      // Avança para tutorial slides
      estadoJogo = ESTADO_TUTORIAL_SLIDES;
      tutorialIndex = 0;
      // reset timers de hover em tutorial
      slideBtnHovered = -1;
      slideBtnActive = -1;
      slideBtnHoverStart = -1;
      return;
    }
    return; // não processa outros estados
  }

  // Tutorial
  if (estadoJogo == ESTADO_TUTORIAL_SLIDES) {
    background(255);

    // também desenha silhueta e cursor enquanto tutorial ativo se o usuário estiver presente
    if (users.length > 0 && kinect.isTrackingSkeleton(users[0])) {
      desenharSilhuetaUsuario();
      drawCustomCursor();
    }

    // Desenha slide centralizado (se existir)
    if (tutorialSlides != null && tutorialSlides.length > 0 && tutorialSlides[tutorialIndex] != null) {
      PImage slide = tutorialSlides[tutorialIndex];
      imageMode(CENTER);
      // ajustar escala para caber confortavelmente na tela mantendo margem
      image(slide, width/2, height/2);
      imageMode(CORNER);
      drawCustomCursor();
    }

    // Desenha botão lateral na direita (central verticalmente) para avançar/exportar para o menu
    float bw = slideBtnW;
    float bh = slideBtnH;
    float bx = width - bw - slideBtnMarginRight;
    float by = height/2 - bh/2;

    // Decide qual imagem usar: se último slide => 'done' else 'next'
    PImage normal = (tutorialIndex >= tutorialSlides.length - 1) ? slideDoneNormal : slideNextNormal;
    PImage hover = (tutorialIndex >= tutorialSlides.length - 1) ? slideDoneHover : slideNextHover;

    // Desenha o botão com ImageButton
    ImageButton nav = new ImageButton(bx, by, bw, bh, normal, hover, 1.0);
    nav.draw(cursorX, cursorY);

    // Lógica de hover+tempo para avançar slides / finalizar
    boolean hover1 = nav.isHover(cursorX, cursorY);
    if (hover1) {
      if (slideBtnActive != 1) {
        slideBtnActive = 1;
        slideBtnHoverStart = millis();
      }
      float t = constrain((millis() - slideBtnHoverStart) / hoverTime, 0, 1);
      // desenha arco de progresso ao redor do botão
      noFill();
      stroke(60, 180, 255, 180);
      strokeWeight(6);
      float cx = bx + bw/2, cy = by + bh/2;
      arc(cx, cy-5, bw * 1.1, bh * 1.1, -HALF_PI, -HALF_PI + t * TWO_PI);
      if (t >= 1.0) {
        // ação do botão: avançar slide ou ir para menu
        if (tutorialIndex < tutorialSlides.length - 1) {
          tutorialIndex++;
          cursorSound.play();
        } else {
          // vai para menu principal
          estadoJogo = ESTADO_MENU;
          cursorSound.play();
        }
        // reset hover timers
        slideBtnActive = -1;
        slideBtnHoverStart = -1;
      }
    } else {
      slideBtnActive = -1;
      slideBtnHoverStart = -1;
    }


    return;
  }

  if (estadoJogo == ESTADO_MENU) {
    // Se não há usuários rastreados, retorna à tela de intro para forçar reposicionamento
    if (users.length == 0 || !kinect.isTrackingSkeleton(users[0])) {
      estadoJogo = ESTADO_INTRO;
      // opcional: resetar alguns estados visuais / hover timers para evitar entrada imediata
      btnHovered = -1;
      btnActive = -1;
      btnHoverStart = -1;
      helpHoverStart = -1;
      return;
    }
    // MENU: fundo de menu, silhueta, overlay e botões
    background(telaInicial);
    desenharSilhuetaUsuario(); // desenha silhueta do usuário sobre o background
    drawMenuButtons(); // botões do menu com lógica de hover por tempo
    drawBotaoSomHover();  // botão de som
    drawCustomCursor();  // cursor custom (indicador + progress arc)
    drawBotaoAjudaHover(); // botão de ajuda / tutorial
  } else if (estadoJogo == ESTADO_AGUA) {

    // JOGO: fundo do jogo, silhueta, spawn e gestão de alvos, física da Agua/massas
    background(imagemFundo);
    desenharSilhuetaUsuario();
    image(imgPainelJogo, width/2, height/2);
    drawRedOverlay();

    // Spawn condicionai de alvos
    if (alvos.size() < maxAlvos && millis() > proximoSpawn) {
      spawnTarget();
      proximoSpawn = millis() + intervaloSpawn;
    }

    // Move cada alvo
    for (Target alvo : alvos) alvo.mover();

    // Verifica fim de jogo por tempo
    if (millis() - tempoInicial >= timer) {
      textSize(50);
      text("TEMPO ESGOTADO", width/2, height/2);
      estadoJogo = ESTADO_FINAL;
      pontuacaoSalva = false;
      resetGameParameters();
      return;
    }

    // Atualiza física: duas massas durante power-up ou Agua única caso contrário
    if (powerUpActive) {
      // atualiza massa esquerda e direita, registra trilhas
      velLeft.add(accLeft);
      velLeft.mult(amortecimento * .9);
      posLeft.add(velLeft);

      velRight.add(accRight);
      velRight.mult(amortecimento * .9);
      posRight.add(velRight);

      // registra trilhas com limite de tamanho
      caminhoLeft.add(0, posLeft.copy());
      if (caminhoLeft.size() > tamanhoCaminhoAgua) caminhoLeft.remove(caminhoLeft.size() - 1);
      caminhoRight.add(0, posRight.copy());
      if (caminhoRight.size() > tamanhoCaminhoAgua) caminhoRight.remove(caminhoRight.size() - 1);
    } else {
      // integração da Agua única (velocidade com amortecimento)
      velocidadeAgua.add(aceleracaoAgua);
      velocidadeAgua.mult(amortecimento);
      posicaoAgua.add(velocidadeAgua);
      // registra trilha da Agua única
      caminhoMedio.add(0, posicaoAgua.copy());
      if (caminhoMedio.size() > tamanhoCaminhoAgua) caminhoMedio.remove(caminhoMedio.size() - 1);
    }

    // Desenha alvos e trilhas
    for (Target alvo : alvos) alvo.desenhar();
    desenharCaminhoMedio();

    // (Opcional) desenhar marcadores das mãos/cabeça para debug
    desenharMaosEsqueleto(null, null, false);

    // Colisões entre Agua(s) e alvos, remoção e efeitos associados
    for (int i = alvos.size() - 1; i >= 0; i--) {
      Target alvo = alvos.get(i);
      boolean hitRegistered = false;

      if (powerUpActive) {
        // verifica colisão com cada massa separadamente
        float distLeft = dist(posLeft.x, posLeft.y, alvo.x, alvo.y);
        float distRight = dist(posRight.x, posRight.y, alvo.x, alvo.y);
        if (distLeft < alvo.raioColisao || distRight < alvo.raioColisao)
          hitRegistered = alvo.verificaHit((distLeft < distRight) ? posLeft.x : posRight.x, (distLeft < distRight) ? posLeft.y : posRight.y);
      } else {
        float distancia = dist(posicaoAgua.x, posicaoAgua.y, alvo.x, alvo.y);
        if (distancia < alvo.raioColisao) hitRegistered = alvo.verificaHit(posicaoAgua.x, posicaoAgua.y);
      }

      if (hitRegistered) {
        if (alvo.surprise) {
          // TARGET SURPRESA: zera o tempo e finaliza a partida imediatamente
          if (target != null) target.play(); 
          delay(2000);
          estadoJogo = ESTADO_FINAL;
          pontuacaoSalva = false;
          resetGameParameters(); // limpa parâmetros de jogo
          return; // sai do draw() imediatamente
        }

        // comportamento padrão para targets comuns:
        if (target != null) target.play();
        pontuacao += 1;

        // ativa power-up quando pontuação for múltipla de 40
        if (pontuacao >= 40 && pontuacao % 40 == 0) {
          activatePowerUp();
        }

        // recompensa: adiciona 1s ao timer
        timer += 1000;

        // reduz intervalo de spawn (aumenta dificuldade), com limite mínimo de 500ms
        intervaloSpawn = max(500, int(intervaloSpawn * 0.95));

        // aumenta multiplicador de velocidade global (limitado a 2.5)
        float desiredMultiplier = targetSpeedMultiplier * 1.03;
        float newMultiplier = min(desiredMultiplier, 2.50);
        float appliedFactor = (targetSpeedMultiplier > 0) ? (newMultiplier / targetSpeedMultiplier) : 1.03;
        targetSpeedMultiplier = newMultiplier;

        // remove alvo atingido e aplica fator às velocidades restantes
        alvos.remove(i);
        for (Target t : alvos) t.velocidadeY *= appliedFactor;
      }
    }

    // HUD: pontuação, FPS e recorde
    textFont(lastShuriken);
    textAlign(CENTER);
    textSize(35);
    fill(255);
    text(pontuacao, width - 135, height - 20);
    textSize(25);
    fill(175, 245, 65);
    text(obterRecorde(), width - 30, height - 30);

    fill(255);
    textSize(12);
    text("PONTOS", width -135, height - 60);
    text("FPS " + int(frameRate), width - 60, 25);
    text("RECORDE", width - 30, height - 60);

    // Desenha a barra de tempo
    exibirTimer();
    println();
  } else if (estadoJogo == ESTADO_FINAL) {
    // TELA FINAL: desenha painel de resultado, botão e cursor
    background(telaFinal);
    //desenharSilhuetaUsuario();
    drawFinalScreen();
    drawFinalBtns();
    verificaHoverFinalBtns();
    drawCustomCursor();
  } else if (estadoJogo == ESTADO_RANK) {
    // TELA RANKING: mostra ranking, botões e cursor
    desenharSilhuetaUsuario();
    background(telaRanking);
    fill(250, 40);
    rect(0, 0, width, height);
    desenharRanking();
    drawRankingBtns();
    verificaHoverRankingBtn();
    drawCustomCursor();
  } else if (estadoJogo == ESTADO_NICK) {
    // TELA DE NICKNAME: teclado virtual, caixa de texto e botões
    background(telaInicial);
    desenharSilhuetaUsuario();
    fill(10, 240);
    rectMode(CENTER);
    rect(width/2, height/2, width+10, height+10);
    rectMode(CORNER);
    desenhaTeclado();
    desenhaCaixaTexto();
    desenhaTecladoBtns();
    verificaHoverTeclado();
    verificaHoverTecladoBtns();
    drawCustomCursor();
    desenhaCursorAnimadoTeclado();
  } else if (estadoJogo == ESTADO_FOGO) {
    //background(telaFogo); // fundo com leve persistência (não limpa totalmente para efeito visual)
    background(20, 50);
    
    // configura opacidade do fogo (ambos)
    if (fireEffect1 != null) fireEffect1.setParticleAlpha(80);
    if (fireEffect2 != null) fireEffect2.setParticleAlpha(80);

    // obtém lista de usuários rastreados (até 2)
    int[] usersFire = kinect.getUsers();
    int usersToProcess = min(2, usersFire.length);

    // se não houver usuários rastreados -> sair do modo e voltar ao menu
    if (usersToProcess == 0) {
      estadoJogo = ESTADO_MENU;
      musicaFogo.stop();
      musica.play();
      return;
    }

    // desenha silhueta (opcional visual)
    desenharSilhuetaUsuario();

    // Leitura/saída do microfone para determinar raios dinâmicos
    float rawAmp = 0;
    if (ampAnalyzer != null) {
      rawAmp = ampAnalyzer.analyze(); // leitura bruta (ex.: 0.0 .. 0.2/0.3 dependendo do ambiente)
    }
    // suavização exponencial para reduzir jitter
    micAmpSmoothed = lerp(micAmpSmoothed, rawAmp, micAmpSmoothing);

    // mapeamento da amplitude suavizada para raios em pixels (5 .. 30)
    float ampMaxExpected = 0.30; // ajuste conforme sensibilidade do microfone/ambiente
    int minRadius = 20;
    int maxRadius = 150;
    int dynamicRadius = int(constrain(map(micAmpSmoothed, 0, ampMaxExpected, minRadius, maxRadius), minRadius, maxRadius));
    int handRadius = dynamicRadius;
    int footRadius = dynamicRadius;

    // coleção de posições de juntas válidas (será passada ao particle motion)
    ArrayList<PVector> jointPositions = new ArrayList<PVector>();

    // para cada usuário (0 = user1, 1 = user2) tente obter mãos e pés e alimentar o respectivo fire engine
    for (int u = 0; u < usersToProcess; u++) {
      int userId = usersFire[u];
      if (!kinect.isTrackingSkeleton(userId)) continue;

      // pega juntas 3D
      PVector rHand3 = new PVector(), lHand3 = new PVector(), rFoot3 = new PVector(), lFoot3 = new PVector();
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rHand3);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_HAND, lHand3);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_FOOT, rFoot3);
      kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_LEFT_FOOT, lFoot3);

      // converte para projetivo (pixel)
      PVector rHandP = new PVector(), lHandP = new PVector(), rFootP = new PVector(), lFootP = new PVector();
      kinect.convertRealWorldToProjective(rHand3, rHandP);
      kinect.convertRealWorldToProjective(lHand3, lHandP);
      kinect.convertRealWorldToProjective(rFoot3, rFootP);
      kinect.convertRealWorldToProjective(lFoot3, lFootP);

      // escolhe engine e cor conforme usuário
      Fire fe = (u == 0) ? fireEffect1 : fireEffect2;
      if (fe == null) continue;

      // define tint: usuário 1 mantém cor padrão, usuário 2 terá tonalidade azulada
      if (u == 0) {
        fe.tintColor = color(255, 255, 150); // amarelo/quente neutro
      } else {
        fe.tintColor = color(0, 255, 255); // azulada
      }

      // adiciona fontes nas mãos e pés (apenas se as posições forem válidas) E coleta para partículas
      if (!Float.isNaN(rHandP.x) && rHandP.x > 0 && rHandP.x < width && rHandP.y > 0 && rHandP.y < height) {
        fe.place_circle_fire_source(handRadius, int(rHandP.x), int(rHandP.y));
        jointPositions.add(rHandP.copy());
      }
      if (!Float.isNaN(lHandP.x) && lHandP.x > 0 && lHandP.x < width && lHandP.y > 0 && lHandP.y < height) {
        fe.place_circle_fire_source(handRadius, int(lHandP.x), int(lHandP.y));
        jointPositions.add(lHandP.copy());
      }
      if (!Float.isNaN(rFootP.x) && rFootP.x > 0 && rFootP.x < width && rFootP.y > 0 && rFootP.y < height) {
        fe.place_circle_fire_source(footRadius, int(rFootP.x), int(rFootP.y));
        jointPositions.add(rFootP.copy());
      }
      if (!Float.isNaN(lFootP.x) && lFootP.x > 0 && lFootP.x < width && lFootP.y > 0 && lFootP.y < height) {
        fe.place_circle_fire_source(footRadius, int(lFootP.x), int(lFootP.y));
        jointPositions.add(lFootP.copy());
      }
    }

    // Injeta as forças das juntas no campo de movimento das partículas (se houver)
    if (pm != null && jointPositions.size() > 0) {
      pm.addForcesFromJoints(jointPositions);
    }

    // atualiza e desenha ambos os engines (se existirem)
    if (fireEffect1 != null) {
      fireEffect1.fire_update();
      fireEffect1.screen_update();
    }
    if (fireEffect2 != null) {
      fireEffect2.fire_update();
      fireEffect2.screen_update();
    }

    // atualiza e desenha as partículas guiadas pelas juntas (sobre o fogo)
    if (pm != null) {
      pm.updateAndDraw();
    }

    fill(255, 200, 0, 5);
    rect(0, 0, width, height);
    // aplica blur leve ao resultado
    //filter(BLUR, 1);
  }
}
