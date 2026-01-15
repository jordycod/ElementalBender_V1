// Classe Fire: motor de partículas/visual de "fogo"

public class Fire {
 // Dimensões da janela / mapa interno ---
 int window_size_x;  // largura útil (em pixels) que o engine cobre
 int window_size_y;  // altura útil (em pixels) que o engine cobre

 // pixel_map: matriz que guarda índices na paleta para cada célula do fogo.
 // A alocação considera margem (fire_power) para deslocamentos durante a simulação.
 public int[][] pixel_map;

 // Parâmetros do motor ---
 public int fire_length;  // comprimento (opcional) do efeito em algumas overloads
 public int fire_power;  // margem/alcance usado na difusão/propagação
 public int fire_decay;  // fator de decaimento aleatório
 public color tintColor = color(255, 255, 255); // multiplicador de cor por engine (tint)

 // Paleta de cor (R,G,B) ---
 // Arrays com a paleta do fogo (valores 0..255). Cada índice descreve um "nível" de intensidade.
 int pixel_size = 20; // usado apenas na função palette_color_show (visualização)
 int[] R = {
  0x07,0x1f,0x2f,0x47,0x57,0x67,0x77,0x8f,0x9f,0xaf,0xb7,0xc7,
  0xdf,0xdf,0xdf,0xd7,0xd7,0xc7,0xcf,0xcf,0xcf,0xc7,0xc7,0xc7,
  0xbf,0xbf,0xbf,0xbf,0xbf,0xb7,0xb7,0xb7,0xcf,0xdf,0xef,0xff
 };
 int[] G = {
  0x07,0x07,0x0f,0x0f,0x17,0x17,0x1f,0x27,0x2f,0x3f,0x47,0x47,
  0x4f,0x57,0x57,0x5f,0x67,0x6f,0x77,0x7f,0x87,0x87,0x8f,0x97,
  0x9f,0x9f,0xa7,0xa7,0xaf,0xaf,0xb7,0xb7,0xcf,0xdf,0xef,0xff
 };
 int[] B = {
  0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,0x07,
  0x07,0x07,0x07,0x07,0x0f,0x0f,0x0f,0x0f,0x17,0x17,0x17,0x1f,
  0x1f,0x1f,0x27,0x27,0x2f,0x2f,0x2f,0x37,0x6f,0x9f,0xc7,0xff
 };

 // tabela de pequenos deslocamentos/aleatoriedade e alpha de partículas
 int random_table_size = 5;
 int[] random_table = {0, 1, 1, 1, 1};
 public int particleAlpha = 255; // alpha global para render das partículas (0..255)

 // Utilitários públicos ---
 // Ajusta opacidade das partículas em tempo de execução (uso em draw/modos)
 public void setParticleAlpha(int a) {
  particleAlpha = constrain(a, 0, 255);
 }

 // Construtores ---
 // Várias assinaturas para conveniência (compatíveis com o código original)
 public Fire() {
  // construtor vazio: usa setters/atribuições posteriores
 }

 // Construtor básico: fire_power controla margem e decay
 public Fire(int fire_power_input, int window_size_x_input, int window_size_y_input) {
  window_size_x = window_size_x_input;
  window_size_y = window_size_y_input;
  fire_decay = fire_power_input;
  fire_power = fire_power_input;
  pixel_map = new int[window_size_x + 2 * fire_power][window_size_y + 2 * fire_power];
 }

 // Construtor com parâmetro de decaimento explícito
 public Fire(int fire_power_input, int window_size_x_input, int window_size_y_input, int fire_decay_input) {
  window_size_x = window_size_x_input;
  window_size_y = window_size_y_input;
  fire_decay = fire_decay_input;
  fire_power = fire_power_input;
  pixel_map = new int[window_size_x + 2 * fire_power][window_size_y + 2 * fire_power];
 }

 // Construtor com comprimento especificado (variante usada em algumas versões)
 public Fire(int fire_power_input, int window_size_x_input, int window_size_y_input, int fire_decay_input, int fire_length_input) {
  window_size_x = window_size_x_input;
  window_size_y = window_size_y_input;
  fire_decay = fire_decay_input;
  fire_power = fire_power_input;
  fire_length = fire_length_input;
  pixel_map = new int[window_size_x + 2 * fire_power][window_size_y];
 }

 // Inserção de fontes ---
 // Coloca uma fonte circular de intensidade fixa (30) dentro do pixel_map,
 // deslocando o índice por fire_power para manter margem interna.
 void place_circle_fire_source(int radius, int cx, int cy) {
  // cheque limites para evitar escrever fora do buffer
  if (cy > radius && cy < window_size_y - fire_power - radius && cx > radius && cx < window_size_x - fire_power - radius) {
 for (int i = cy - radius; i < cy + radius; i++) {
  for (int j = cx - radius; j < cx + radius; j++) {
 // equação do círculo (pontos dentro do raio)
 if (((i - cy) * (i - cy) + (j - cx) * (j - cx)) < (radius * radius)) {
  pixel_map[j + fire_power][i + fire_power] = 30; // valor de "pico" na paleta
 }
  }
 }
  }
 }

 // Função utilitária de decaimento aleatório ---
 // Retorna um pequeno inteiro aleatório usado na atualização do fogo.
 int decay_random(int fire_decay) {
  int r = int(random(fire_decay));
  if (r > 2) {
 r = 0;
  }
  return r;
 }

 // Atualização da simulação do fogo ---
 // Propaga valores no pixel_map de baixo para cima e aplica decaimento/aleatoriedade.
 void fire_update() {
  // percorre cada célula do mapa (evitando a margem fire_power)
  for (int i = fire_power; i < window_size_y; i++) {
 for (int j = 0; j < window_size_x; j++) {
  int px = j + fire_power;
  int py = i;
  int val = pixel_map[px][py];
  // mecanismo de propagação/espalhamento com pequenas condições heurísticas
  if (val < 35 && val > 27 + random(5)) {
 pixel_map[px - int(random(fire_power)) + int(random(fire_power))][py + int(random(fire_power))] = val - int(random(fire_decay)) - 2;
  }
  if (val > 4) {
 pixel_map[px - int(random(fire_power)) + int(random(fire_power))][py - int(random(fire_power))] = val - random_table[int(random(random_table_size))];
  }
  if (val > 0) {
 pixel_map[px][py] = val - random_table[int(random(random_table_size))];
  }
 }
  }
 }

 // Renderização 
 // Transforma índices do pixel_map em cores reais da tela usando a paleta,
 // aplicando também um tintColor multiplicativo e particleAlpha.
 void screen_update() {
  loadPixels(); // prepara acesso ao array pixels[]

  // calcula fatores (0..1) de tint por canal a partir da cor definida
  float tr = red(tintColor) / 255.0;
  float tg = green(tintColor) / 255.0;
  float tb = blue(tintColor) / 255.0;

  // itera sobre área útil do mapa e escreve diretamente no buffer 'pixels'
  for (int i = fire_power; i < window_size_y; i++) {
 for (int j = 0; j < window_size_x; j++) {
  int idx = pixel_map[j + fire_power][i]; // índice na paleta
  if (idx > 0) {
 // aplica tint multiplicativo e garente valores dentro de 0..255
 int rr = int(constrain(R[idx] * tr, 0, 255));
 int gg = int(constrain(G[idx] * tg, 0, 255));
 int bb = int(constrain(B[idx] * tb, 0, 255));
 // escreve pixel com alpha particleAlpha
 pixels[(i * window_size_x) + j] = color(rr, gg, bb, particleAlpha);
  }
 }
  }

  updatePixels(); // aplica alterações
 }
}
