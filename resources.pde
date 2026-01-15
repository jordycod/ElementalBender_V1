void resourcesManager() {
  // Carrega audios
  cursorSound = new SoundFile(this, "sound/BipeCursor.mp3");
  detectUser = new SoundFile(this, "sound/StartSucess.mp3");
  lostUser = new SoundFile(this, "sound/LostUser.mp3");
  target = new SoundFile(this, "sound/Target.mp3");
  musica = new SoundFile(this, "sound/MusicaTema.mp3");
  musicaAgua = new SoundFile(this, "sound/MusicaAgua.mp3");
  musicaFogo = new SoundFile(this, "sound/MusicaFogo.mp3");
  
  // Carrega fontes
  bagel = loadFont("BagelFatOne-Regular-48.vlw");
  hoshiko = loadFont("BagelFatOne-Regular-48.vlw");
  lastShuriken = loadFont("TheLastShuriken-Regular-48.vlw");
  textFont(bagel);
  textAlign(CENTER, CENTER);

  // Carrega imagens (assets) e adapta ao tamanho da janela
  imageMode(CENTER);

  imagemFundo = loadImage("backgrounds/Fundo_WB.png");
  if (imagemFundo != null) imagemFundo.resize(width, height);
  imgAlvo = loadImage("sprites/Target.png");
  if (imgAlvo != null) imgAlvo.resize(40, 50);
  imgSurpriseTarget = loadImage("sprites/imgSurpriseTarget.png"); // deixe como null se não houver arquivo
  if (imgSurpriseTarget != null) imgSurpriseTarget.resize(50, 50);
  imgPainelJogo = loadImage("buttons/agua_painel_inf.png");
  telaRanking = loadImage("backgrounds/Tela_Ranking.png");
  telaInicial = loadImage("backgrounds/Tela_Inicial.png");
  telaFinal = loadImage("backgrounds/Tela_Final.png");
  telaFogo = loadImage("backgrounds/Tela_Fogo.png");
  imgTutorial = loadImage("help/Tutorial.png");

  // --- Menu buttons (ÁGUA / FOGO / RANK) ---
  btnImgNormal[0] = loadImage("buttons/btn_agua_normal.png");
  btnImgHover[0] = loadImage("buttons/btn_agua_hover.png");
  btnImgNormal[1] = loadImage("buttons/btn_fogo_normal.png");
  btnImgHover[1] = loadImage("buttons/btn_fogo_hover.png");
  btnImgNormal[2] = loadImage("buttons/btn_ranking_normal.png");
  btnImgHover[2] = loadImage("buttons/btn_ranking_hover.png");

  // --- Help & Sound icons ---
  iconeAjuda = loadImage("buttons/btn_help.png");
  iconeSomLigado = loadImage("buttons/btn_sound_on.png");
  iconeSomDesligado = loadImage("buttons/btn_sound_off.png");

  // --- Final screen buttons (TELA INICIAL, REINICIAR, SALVAR) ---
  finalBtnImgNormal[0] = loadImage("buttons/btn_home_normal.png");
  finalBtnImgHover[0] = loadImage("buttons/btn_home_hover.png");
  finalBtnImgNormal[1] = loadImage("buttons/btn_restart_normal.png");
  finalBtnImgHover[1] = loadImage("buttons/btn_restart_hover.png");
  finalBtnImgNormal[2] = loadImage("buttons/btn_save_normal.png");
  finalBtnImgHover[2] = loadImage("buttons/btn_save_hover.png");

  // --- Ranking "VOLTAR" button ---
  imgVoltarNormal = loadImage("buttons/btn_voltar_normal.png");
  imgVoltarHover = loadImage("buttons/btn_voltar_hover.png");

  // --- Nick keyboard buttons (GRAVAR/VOLTAR) images (optional) ---
  nickBtnImgNormal = new PImage[2];
  nickBtnImgHover = new PImage[2];
  nickBtnImgNormal[0] = loadImage("buttons/btn_save_rank_normal.png");
  nickBtnImgHover[0] = loadImage("buttons/btn_save_rank_hover.png");
  nickBtnImgNormal[1] = loadImage("buttons/btn_voltar_normal.png");
  nickBtnImgHover[1] = loadImage("buttons/btn_voltar_hover.png");

  // --- Intro / Tutorial slides assets ---
  introLogo = loadImage("intro/logo.png");
  // slides: carregar dinamicamente (3 slides). se arquivo não existir, slide fica null e será ignorado
  tutorialSlides = new PImage[4];
  tutorialSlides[0] = loadImage("tutorial/tutorial_1.png");
  tutorialSlides[1] = loadImage("tutorial/tutorial_2.png");
  tutorialSlides[2] = loadImage("tutorial/tutorial_3.png");
  tutorialSlides[3] = loadImage("tutorial/tutorial_4.png");

  // botões laterais para avançar/concluir
  slideNextNormal = loadImage("buttons/btn_slide_next_normal.png");
  slideNextHover = loadImage("buttons/btn_slide_next_hover.png");
  slideDoneNormal = loadImage("buttons/btn_slide_done_normal.png");
  slideDoneHover = loadImage("buttons/btn_slide_done_hover.png");
}
