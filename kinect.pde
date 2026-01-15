void kinectStart() {

  // Inicializa Kinect e arquivos de áudio (SoundFile)
  kinect = new SimpleOpenNI(this);

  // Se a inicialização do Kinect falhar, encerra o sketch
  if (!kinect.isInit()) {
    println("Falha na inicialização da câmera!");
    exit();
    return;
  }

  // Habilita os módulos do Kinect necessários para o sketch
  kinect.enableDepth();
  kinect.enableRGB();
  kinect.enableUser();
  kinect.setMirror(true);
}
