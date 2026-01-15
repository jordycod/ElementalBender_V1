void desenharSilhuetaUsuario() {
 if (kinect.getNumberOfUsers() > 0) {
  mapaUsuario = kinect.userMap();
  loadPixels();

  // Se estivermos no modo FIRE, force a silhueta branca; caso contrário, mantém a lógica anterior
  color baseCol;
  int alphaVal;
  
  if (estadoJogo == ESTADO_FOGO) {
 baseCol = color(250); // branco
 alphaVal = 40; // opacidade da silhueta no modo FIRE
  } else {
 baseCol = (powerUpActive) ? silhuetaPowerUp : silhuetaCorNormal;
 alphaVal = 40; // opacidade usada atualmente nas outras telas
  }

  float r = red(baseCol);
  float g = green(baseCol);
  float b = blue(baseCol);

  for (int i = 0; i < mapaUsuario.length; i++) {
 if (mapaUsuario[i] != 0) {
  pixels[i] = color(r, g, b, alphaVal);
 }
  }
  updatePixels();
 }
}

void desenharMaosEsqueleto(PVector maoDireita, PVector maoEsquerda, boolean rastreando) {
}

// CALLBACKS DO KINECT

void onNewUser(SimpleOpenNI kinect, int userId) {
 println("Usuário detectado: " + userId);
 kinect.startTrackingSkeleton(userId); // inicia rastreio do esqueleto deste usuário
 detectUser.play();
}
void onLostUser(SimpleOpenNI curContext, int userId) {
 println("Usuário perdido: " + userId);
 lostUser.play();
}
