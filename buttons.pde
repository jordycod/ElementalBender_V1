// Buttons.pde
// Classe genérica para botões baseados em imagem.
// Mantém bbox, imagens normal/hover e escala.
// Usada por Interface.pde para desenhar todos os botões do jogo (menu, final, ranking, teclado).

class ImageButton {
 float x, y, w, h; // bounding box (x,y top-left, w,h)
 PImage imgNormal; // imagem normal
 PImage imgHover;  // imagem hover/ativa
 float scale = 1.0; // escala prática (1.0 => usa w/h como referência)
 boolean visibleIfMissing = true; // se false, não desenha fallback quando imagem ausente

 ImageButton() {}

 ImageButton(float x_, float y_, float w_, float h_, PImage n, PImage hov, float s) {
  set(x_, y_, w_, h_, n, hov, s);
 }

 void set(float x_, float y_, float w_, float h_, PImage n, PImage hov, float s) {
  x = x_;
  y = y_;
  w = w_;
  h = h_;
  imgNormal = n;
  imgHover = hov;
  scale = s;
 }

 // Verifica se o cursor está sobre o botão
 boolean isHover(float cursorX, float cursorY) {
  return (cursorX > x && cursorX < x + w && cursorY > y && cursorY < y + h);
 }

 // Desenha o botão conforme o estado (hover ou normal)
 void draw(float cursorX, float cursorY) {
  boolean hov = isHover(cursorX, cursorY);
  PImage toDraw = hov ? (imgHover != null ? imgHover : imgNormal) : imgNormal;

  if (toDraw != null) {
 imageMode(CENTER);
 float cx = x + w/2;
 float cy = y + h/2;
 float dw = w * scale;
 float dh = h * scale;
 image(toDraw, cx, cy, dw, dh);
 
  } else if (visibleIfMissing) {
 // fallback mínimo (contorno sutil)
 pushStyle();
 noFill();
 stroke(255, 50);
 strokeWeight(2);
 rect(x, y, w, h, 6);
 popStyle();
  }
 }
}
