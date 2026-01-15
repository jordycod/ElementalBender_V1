// INTERFACE / BOTÕES / TECLADO (IMPLEMENTAÇÕES)
// Desenha os botões do menu principal e controla hover por tempo (seleção automática)

void drawMenuButtons() {
  textAlign(CENTER, CENTER);
  textSize(22);

  float btnW = width * 0.25;
  float btnH = height * 0.10;
  float space = height * 0.06;
  float x = width - btnW * 0.8;
  float yStart = height * 0.08;

  // Calcula bounding boxes e detecta qual botão está em hover pelo cursor
  btnHovered = -1;
  for (int i = 0; i < BTN_COUNT; i++) {
    float y = yStart + i * (btnH + space);
    btnRects[i][0] = x - btnW / 2;
    btnRects[i][1] = y;
    btnRects[i][2] = btnW;
    btnRects[i][3] = btnH;
    if (cursorX > x - btnW / 2 && cursorX < x + btnW / 2 &&
      cursorY > y && cursorY < y + btnH) {
      btnHovered = i;
    }
  }

  // Hover timing / seleção (mantido)
  if (btnHovered != -1) {
    if (btnActive != btnHovered) {
      btnActive = btnHovered;
      btnHoverStart = millis();
    }
    float t = constrain((millis() - btnHoverStart) / hoverTime, 0, 1);
    if (t >= 1) {
      onButtonSelected(btnActive);
      btnActive = -1;
      btnHoverStart = -1;
      btnHovered = -1;
    }
  } else {
    btnActive = -1;
    btnHoverStart = -1;
  }

  // Desenha cada botão usando ImageButton (mantendo alinhamento e tamanho original)
  for (int i = 0; i < BTN_COUNT; i++) {
    float bx = btnRects[i][0], by = btnRects[i][1], bw = btnRects[i][2], bh = btnRects[i][3];
    ImageButton ib = new ImageButton(bx, by, bw * 1.0, bh, btnImgNormal[i], btnImgHover[i], btnImageScale);
    ib.draw(cursorX, cursorY);
  }
}

// Desenha o botão de som no canto inferior direito (imagem on/off + hover)
void drawBotaoSomHover() {
  botaoSomX = width - botaoSomTam - 15;
  botaoSomY = height - botaoSomTam - 24;

  boolean hover = dist(cursorX, cursorY, botaoSomX, botaoSomY) < botaoSomTam / 2;

  // Escolhe imagens carregadas (iconeSomLigado / iconeSomDesligado)
  PImage normal = somAtivo ? iconeSomLigado : iconeSomDesligado;
  PImage hov  = normal; // se tiver variantes hover, pode ser substituído

  textFont(lastShuriken);
  fill(40);
  textSize(25);
  textAlign(RIGHT, BOTTOM);
  text("SOM", botaoSomX - botaoAjudaTam/1.30, botaoSomY);

  textAlign(CENTER, CENTER);

  ImageButton sb = new ImageButton(botaoSomX - botaoSomTam/2, botaoSomY - botaoSomTam/2, botaoSomTam, botaoSomTam, normal, hov, soundBtnImageScale);
  sb.draw(cursorX, cursorY);

  // Lógica de hover + tempo: se o cursor ficar sobre o botão por 'hoverTimeSom', alterna som
  if (hover) {
    if (btnSomHovered == 0) {
      btnSomHovered = 1;
      somHoverStart = millis();
    }
    float t = constrain((millis() - somHoverStart) / hoverTimeSom, 0, 1);
    noFill();
    stroke(60, 180, 255, 180);
    strokeWeight(6);
    arc(botaoSomX, botaoSomY-5, botaoSomTam * 1.25, botaoSomTam * 1.25, -HALF_PI, -HALF_PI + t * TWO_PI);
    if (t >= 1) {
      somAtivo = !somAtivo;
      if (somAtivo) {
        if (estadoJogo == ESTADO_AGUA) {
          if (musicaAgua != null) musicaAgua.amp(1);
        } else if (estadoJogo == ESTADO_FOGO) {
          if (musicaFogo != null) musicaFogo.amp(1);
        } else {
          if (musica != null) musica.amp(1);
        }
      } else {
        if (musica != null) musica.amp(0);
        if (musicaAgua != null) musicaAgua.amp(0);
        if (musicaFogo != null) musicaFogo.amp(0);
      }
      somHoverStart = -1;
      btnSomHovered = 0;
    }
  } else {
    btnSomHovered = 0;
    somHoverStart = -1;
  }
}

// Botão de ajuda/tutorial (imagem)
void drawBotaoAjudaHover() {
  botaoAjudaX = botaoSomX;
  botaoAjudaY = botaoSomY - botaoAjudaTam - 25;

  ImageButton hb = new ImageButton(botaoAjudaX - botaoAjudaTam/2, botaoAjudaY - botaoAjudaTam/2, botaoAjudaTam, botaoAjudaTam, iconeAjuda, iconeAjuda, helpBtnImageScale);
  hb.draw(cursorX, cursorY);

  boolean hoverHelp = hb.isHover(cursorX, cursorY);

  // Desenha rótulo "AJUDA" ao lado do botão (mantive comportamento visual anterior)
  textFont(lastShuriken);
  fill(40);
  textSize(25);
  textAlign(RIGHT, BOTTOM);
  text("AJUDA", botaoAjudaX - botaoAjudaTam/1.30, botaoAjudaY);
  textAlign(CENTER, CENTER);

  // Hover prolongado: abre o tutorial slides (mesma lógica de hover+tempo usada em outros botões)
  if (hoverHelp) {
    if (helpHoverStart < 0) helpHoverStart = millis();
    float t = constrain((millis() - helpHoverStart) / hoverTime, 0, 1);
    // desenha arco de progresso perto do botão
    noFill();
    stroke(60, 180, 255, 180);
    strokeWeight(6);
    arc(botaoAjudaX, botaoAjudaY-5, botaoAjudaTam * 1.25, botaoAjudaTam * 1.25, -HALF_PI, -HALF_PI + t * TWO_PI);
    if (t >= 1) {
      // abre slides do tutorial
      estadoJogo = ESTADO_TUTORIAL_SLIDES;
      tutorialIndex = 0;
      // reseta timers
      helpHoverStart = -1;
    }
  } else {
    helpHoverStart = -1;
  }
}

// Desenha cursor customizado e mostra arco de progresso quando um botão está em processo de seleção por hover
void drawCustomCursor() {
  float raio = 21;
  float cx = cursorX, cy = cursorY;

  boolean hovering = false;
  float prog = 0;

  // determina se há algum botão em estado de "aguardar seleção" e calcula progresso
  if (estadoJogo == ESTADO_MENU) {
    if (btnHovered != -1 && btnActive == btnHovered && btnHoverStart > 0) {
      hovering = true;
      prog = constrain((millis() - btnHoverStart) / hoverTime, 0, 1);
    }
  } else if (estadoJogo == ESTADO_FINAL) {
    if (finalBtnHovered != -1 && finalBtnActive == finalBtnHovered && finalBtnHoverStart > 0) {
      hovering = true;
      prog = constrain((millis() - finalBtnHoverStart) / hoverTime, 0, 1);
    }
  } else if (estadoJogo == ESTADO_RANK) {
    if (nickBtnHovered != -1 && nickBtnActive == nickBtnHovered && nickBtnHoverStart > 0) {
      hovering = true;
      prog = constrain((millis() - nickBtnHoverStart) / hoverTime, 0, 1);
    }
  } else if (estadoJogo == ESTADO_NICK) {
    if (nickBtnHovered != -1 && nickBtnActive == nickBtnHovered && nickBtnHoverStart > 0) {
      hovering = true;
      prog = constrain((millis() - nickBtnHoverStart) / hoverTime, 0, 1);
    }
  }

  // desenho do cursor e arco de progresso
  noFill();
  stroke(100);
  strokeWeight(2);
  ellipse(cx, cy, raio * 2, raio * 2);
  if (hovering) {
    stroke(40, 230, 100, 220);
    strokeWeight(5);
    arc(cx, cy, raio * 2, raio * 2, -HALF_PI, -HALF_PI + prog * TWO_PI);
  }
  noStroke();
  fill(255, 220);
  ellipse(cx, cy, raio * 1.4, raio * 1.4);
}

void exibirTimer() {
  textFont(lastShuriken);
  if (estadoJogo != ESTADO_AGUA) return;

  // tempo decorrido desde o início da partida
  int tempoAtual = millis() - tempoInicial;
  int tempoRestante = timer - tempoAtual;
  if (tempoRestante <= 0) tempoRestante = 0;

  // evita divisão por zero caso timerInitialDuration não tenha sido inicializado
  float progress = 0;
  if (timerInitialDuration > 0) {
    progress = (float)tempoRestante / (float)timerInitialDuration; // 1.0 = cheio, 0.0 = esgotado
    progress = constrain(progress, 0, 1);
  }

  // Calcula comprimento total da barra em pixels a partir do tempo inicial (convertendo ms->s)
  float totalSeconds = max(1.0, timerInitialDuration / 1000.0); // evita zero
  int barTotalWidth = int(totalSeconds * timerBarPixelsPerSecond);

  // Largura atual proporcional ao tempo restante
  int currentWidth = int(barTotalWidth * progress);

  // Posição da barra (ajuste conforme layout): desenha na parte inferior esquerda
  int bx = 20;
  int by = height - 45;
  int bw = barTotalWidth;
  int bh = barraTempoAltura;

  // Desenha fundo da barra (track)
  noStroke();
  fill(40, 40, 40, 80);
  rect(bx - 2, by - 2, bw + 4, bh + 4, 6);

  // Calcula cor interpolada conforme o tempo restante (azul -> verde -> amarelo -> laranja -> vermelho)
  // progress: 1.0 -> início (azul), 0.0 -> fim (vermelho)
  float elapsedFrac = 1.0 - progress; // 0.0..1.0 indica quanto já passou
  // cores de referência
  color C0 = color(0, 120, 255);  // azul
  color C1 = color(40, 200, 100); // verde
  color C2 = color(255, 215, 0);  // amarelo
  color C3 = color(255, 140, 0);  // laranja
  color C4 = color(255, 0, 0); // vermelho

  // mapeia elapsedFrac para segmento 0..4
  float seg = constrain(elapsedFrac * 4.0, 0, 4.0);
  int segIndex = int(floor(seg));
  float local = seg - segIndex;

  color fromC = C0;
  color toC = C4;
  if (segIndex == 0) {
    fromC = C0;
    toC = C1;
  } else if (segIndex == 1) {
    fromC = C1;
    toC = C2;
  } else if (segIndex == 2) {
    fromC = C2;
    toC = C3;
  } else if (segIndex == 3) {
    fromC = C3;
    toC = C4;
  } else {
    fromC = C4;
    toC = C4;
    local = 0;
  }

  // interpola canais RGBA
  float r = lerp(red(fromC), red(toC), local);
  float g = lerp(green(fromC), green(toC), local);
  float bcol = lerp(blue(fromC), blue(toC), local);

  fill(r, g, bcol, 230);
  rect(bx, by, currentWidth, bh, 6);

  // Desenha contorno da barra
  noFill();
  stroke(0, 0, 0, 120);
  strokeWeight(2);
  rect(bx, by, bw, bh, 6);

  // Texto com segundos restantes ao lado da barra
  textFont(lastShuriken);
  noStroke();
  fill(255);
  textSize(23);
  textAlign(LEFT, CENTER);
  String segs = str(int(ceil(tempoRestante / 1000.0)));
  text(segs, bx + bw + 10, by + bh / 2);
}

// Desenha overlay vermelho quando intensity > 0 (feedback visual de erro/perda)
void drawRedOverlay() {
  if (filtroVermelhoInt <= 0) return;
  noStroke();
  fill(255, 0, 0, filtroVermelhoInt * 255);
  rect(0, 0, width, height);
}

// FINAL SCREEN
// Desenha painel e informações da tela final (pontuação)
void drawFinalScreen() {

  // Texto do painel de pontuação final
  textFont(hoshiko);
  textAlign(CENTER, CENTER);
  fill(90, 65, 0);
  textSize(100);
  text(pontuacao, 265, height / 2 - 45);
  fill(40);
  textSize(50);
  text(obterRecorde(), 400, height / 2 - 45);
  textSize(15);
  text("RECORDE", 400, height / 2);
}


// Desenha botões da tela final usando ImageButton (substitui retângulos + texto)
// Mantém cálculo de bounding boxes finalRects[] e lógica de hover por tempo.
void drawFinalBtns() {
  float bw = 200, bh = 130, space = 5;
  float x = 20;//width / 2 - bw * 1.5 - space * 1.5 + 10;
  float y = height - 180;

  finalBtnHovered = -1;
  for (int i = 0; i < 3; i++) {
    float bx = x + i * (bw + space);
    float by = y;
    finalRects[i][0] = bx;
    finalRects[i][1] = by;
    finalRects[i][2] = bw;
    finalRects[i][3] = bh;
    if (cursorX > bx && cursorX < bx + bw && cursorY > by && cursorY < by + bh) finalBtnHovered = i;
  }

  for (int i = 0; i < 3; i++) {
    float bx = finalRects[i][0], by = finalRects[i][1], bwRect = finalRects[i][2], bhRect = finalRects[i][3];
    ImageButton ib = new ImageButton(bx, by, bwRect, bhRect, finalBtnImgNormal[i], finalBtnImgHover[i], finalBtnImageScale);
    ib.draw(cursorX, cursorY);
  }
}

// Desenha botão VOLTAR na tela de ranking com imagem
void drawRankingBtns() {
  float bx = width / 2 - 120, by = height - 120, bw = 250, bh = 75;
  nickRects[0][0] = bx;
  nickRects[0][1] = by;
  nickRects[0][2] = bw;
  nickRects[0][3] = bh;

  if (cursorX > bx && cursorX < bx + bw && cursorY > by && cursorY < by + bh) nickBtnHovered = 0;
  else nickBtnHovered = -1;

  ImageButton ib = new ImageButton(bx, by, bw, bh, imgVoltarNormal, imgVoltarHover, voltarBtnImageScale);
  ib.draw(cursorX, cursorY);
}

// Verifica hover+tempo para os botões da tela final (seleção automática)
void verificaHoverFinalBtns() {
  if (finalBtnHovered != -1) {
    if (finalBtnActive != finalBtnHovered) {
      finalBtnActive = finalBtnHovered;
      finalBtnHoverStart = millis();
    }
    float t = constrain((millis() - finalBtnHoverStart) / hoverTime, 0, 1);
    if (t >= 1) {
      onFinalBtnSelected(finalBtnActive); // executa ação associada
      finalBtnActive = -1;
      finalBtnHoverStart = -1;
      finalBtnHovered = -1;
    }
  } else {
    finalBtnActive = -1;
    finalBtnHoverStart = -1;
  }
}

// Verifica hover+tempo para botão do ranking (Voltar)
void verificaHoverRankingBtn() {
  if (nickBtnHovered != -1) {
    if (nickBtnActive != nickBtnHovered) {
      nickBtnActive = nickBtnHovered;
      nickBtnHoverStart = millis();
    }
    float t = constrain((millis() - nickBtnHoverStart) / hoverTime, 0, 1);
    if (t >= 1) {
      onRankingBtnSelected();
      nickBtnActive = -1;
      nickBtnHoverStart = -1;
      nickBtnHovered = -1;
    }
  } else {
    nickBtnActive = -1;
    nickBtnHoverStart = -1;
  }
}

// NICKNAME / TECLADO
// Desenha caixa de texto que mostra o nickname digitado
void desenhaCaixaTexto() {
  textFont(bagel);
  float x = 20;
  float y = height - 210;
  float largura = width - 40;
  float altura = 40;
  stroke(10, 10);
  fill(255);
  rect(x, y, largura, altura, 5);
  fill(0);
  textSize(28);
  text(textoDigitado, x, y, largura, altura);
}

// Desenha layout do teclado virtual e detecta qual tecla está em hover
void desenhaTeclado() {
  textFont(bagel);
  float inicioX = width / 2 - 270;
  float inicioY = 40;
  float espacamento = 5;
  tecladoHoverLinha = tecladoHoverCol = -1;

  for (int linha = 0; linha < layoutTeclado.length; linha++) {
    for (int coluna = 0; coluna < layoutTeclado[linha].length; coluna++) {
      float x = inicioX + coluna * (larguraTeclas + espacamento);
      float y = inicioY + linha * (alturaTeclas + espacamento);
      char tecla = layoutTeclado[linha][coluna];
      if (cursorX >= x && cursorX <= x + larguraTeclas && cursorY >= y && cursorY <= y + alturaTeclas) {
        tecladoHoverLinha = linha;
        tecladoHoverCol = coluna;
      }
      if (teclaHoverAtual == tecla) fill(150, 200);
      else fill(250);
      stroke(10, 20);
      rect(x, y, larguraTeclas, alturaTeclas, 5);
      fill(0);
      textSize(30);
      text(tecla, x + larguraTeclas / 2, y + alturaTeclas / 2);
    }
  }
}

// Lógica de hover+tempo para inserir caracteres do teclado virtual
void verificaHoverTeclado() {
  if (tecladoHoverLinha != -1 && tecladoHoverCol != -1) {
    char tecla = layoutTeclado[tecladoHoverLinha][tecladoHoverCol];
    if (teclaHoverAtual != tecla) {
      tempoInicioHover = millis();
      teclaHoverAtual = tecla;
      cursorSound.play();
    }
    if (millis() - tempoInicioHover >= tempoParaSelecao) {
      if (textoDigitado.length() < NICK_MAX) textoDigitado += teclaHoverAtual;
      // reinicia o temporizador para permitir repetições controladas
      tempoInicioHover = millis();
    }
  } else {
    // sem hover: reseta variáveis
    tempoInicioHover = -1;
    teclaHoverAtual = ' ';
  }
}

// Desenha botões "Gravar" e "Voltar" abaixo do teclado usando imagens (substitui rect+texto)
// Atenção: espera que existam imagens nickBtnImgNormal[0..1], nickBtnImgHover[0..1] carregadas em setup()
void desenhaTecladoBtns() {
  float bw = 250, bh = 75, space = 30;
  float x = width / 2 - bw - space / 2, y = height - 150;

  nickBtnHovered = -1;

  for (int i = 0; i < 2; i++) {
    float bx = x + i * (bw + space), by = y;
    nickRects[i][0] = bx;
    nickRects[i][1] = by;
    nickRects[i][2] = bw;
    nickRects[i][3] = bh;
    if (cursorX > bx && cursorX < bx + bw && cursorY > by && cursorY < by + bh) nickBtnHovered = i;
  }

  for (int i = 0; i < 2; i++) {
    float bx = nickRects[i][0], by = nickRects[i][1], bwRect = nickRects[i][2], bhRect = nickRects[i][3];
    PImage normal = (nickBtnImgNormal != null && nickBtnImgNormal.length > i) ? nickBtnImgNormal[i] : null;
    PImage hover = (nickBtnImgHover != null && nickBtnImgHover.length > i) ? nickBtnImgHover[i] : null;
    ImageButton ib = new ImageButton(bx, by, bwRect, bhRect, normal, hover, finalBtnImageScale);
    ib.draw(cursorX, cursorY);
  }
}

// Verifica hover+tempo para botões do teclado (Gravar/Voltar)
void verificaHoverTecladoBtns() {
  if (nickBtnHovered != -1) {
    if (nickBtnActive != nickBtnHovered) {
      nickBtnActive = nickBtnHovered;
      nickBtnHoverStart = millis();
    }
    float t = constrain((millis() - nickBtnHoverStart) / hoverTime, 0, 1);
    if (t >= 1) {
      onNickBtnSelected(nickBtnActive); // aciona ação do botão selecionado
      nickBtnActive = -1;
      nickBtnHoverStart = -1;
      nickBtnHovered = -1;
    }
  } else {
    nickBtnActive = -1;
    nickBtnHoverStart = -1;
  }
}

// Mostra arco de progresso sobre a tecla atualmente em hover no teclado virtual
void desenhaCursorAnimadoTeclado() {
  if (teclaHoverAtual != ' ' && tecladoHoverLinha != -1 && tecladoHoverCol != -1) {
    float inicioX = width / 2 - 270;
    float inicioY = 40;
    float espacamento = 5;
    float x = inicioX + tecladoHoverCol * (larguraTeclas + espacamento) + larguraTeclas / 2;
    float y = inicioY + tecladoHoverLinha * (alturaTeclas + espacamento) + alturaTeclas / 2;
    float prog = constrain((millis() - tempoInicioHover) / tempoParaSelecao, 0, 1);

    noFill();
    stroke(40, 230, 100, 220);
    strokeWeight(5);
    arc(x, y, larguraTeclas, alturaTeclas, -HALF_PI, -HALF_PI + prog * TWO_PI);
  }
}

// AÇÃO DOS BOTÕES

// Chamado quando um botão principal (menu) é selecionado via hover completo
void onButtonSelected(int btn) {
  if (btn == 0) {
    resetGameParameters();
    cursorSound.play();
    delay(1000);
    musica.stop();
    musicaAgua.play();

    estadoJogo = ESTADO_AGUA;
    tempoInicial = millis();
    timerInitialDuration = timer; // preserva a duração inicial (ms) usada para calcular a barra
    pontuacao = 0;
    alvos.clear();
    proximoSpawn = millis() + intervaloSpawn;
    caminhoMedio.clear();
  } else if (btn == 2) {
    cursorSound.play();
    delay(500);
    estadoJogo = ESTADO_RANK;
  } else if (btn == 1) {
    cursorSound.play();
    delay(500);
    musica.stop();
    musicaFogo.play();

    // Entra no modo artístico "Fogo"
    estadoJogo = ESTADO_FOGO;
    // garante que os engines de fogo estejam criados e limpa sua memória
    if (fireEffect1 == null) fireEffect1 = new Fire(2, width, height, 1);
    if (fireEffect2 == null) fireEffect2 = new Fire(2, width, height, 1);
    // limpa mapa interno dos dois engines para começar "do zero"
    fireEffect1.pixel_map = new int[width + 2 * fireEffect1.fire_power][height + 2 * fireEffect1.fire_power];
    fireEffect2.pixel_map = new int[width + 2 * fireEffect2.fire_power][height + 2 * fireEffect2.fire_power];
    // desativa lógica de jogo (alvos/pontuação) já que este modo é apenas interação visual
    alvos.clear();
    caminhoMedio.clear();
    if (pm != null) pm.resetPrevJoints(); // evita deltas gigantes no primeiro frame
  }
}

// Ações para os botões exibidos na tela final
void onFinalBtnSelected(int btn) {
  if (btn == 0) {
    cursorSound.play();
    delay(500);
    estadoJogo = ESTADO_MENU;
    musicaAgua.stop();
    musica.play();
  } else if (btn == 1) {
    cursorSound.play();
    delay(500);
    cursorSound.play();
    resetGameParameters();
    estadoJogo = ESTADO_AGUA;
    tempoInicial = millis();
    timerInitialDuration = timer; // reinicia referência para a barra também
    pontuacao = 0;
    alvos.clear();
    proximoSpawn = millis() + intervaloSpawn;
    caminhoMedio.clear();
    musicaAgua.loop();
  } else if (btn == 2 && !pontuacaoSalva) {
    // entra no modo de digitar nickname para salvar pontuação
    cursorSound.play();
    estadoJogo = ESTADO_NICK;
    textoDigitado = "";
    tecladoHoverLinha = tecladoHoverCol = -1;
    teclaHoverAtual = ' ';
  }
}

void onRankingBtnSelected() {
  cursorSound.play();
  estadoJogo = ESTADO_MENU;
  nickBtnActive = nickBtnHovered = -1;
  nickBtnHoverStart = -1;
}

void onNickBtnSelected(int btn) {
  if (btn == 0) {
    if (textoDigitado.length() > 0) {
      ranking.add(new RegistroRank(textoDigitado, pontuacao));
      salvarRanking();
      pontuacaoSalva = true;
      cursorSound.play();
    }
    estadoJogo = ESTADO_FINAL;
  } else if (btn == 1) {
    estadoJogo = ESTADO_FINAL;
  }
}
